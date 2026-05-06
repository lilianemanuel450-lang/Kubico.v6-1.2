import 'package:fpdart/fpdart.dart';
import 'package:geolocator/geolocator.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/network/network_info.dart';
import '../../domain/entities/property.dart';
import '../../domain/repositories/property_repository.dart';
import '../datasources/property_local_datasource.dart';
import '../datasources/property_remote_datasource.dart';
import '../models/property_model.dart';

class PropertyRepositoryImpl implements PropertyRepository {
  final PropertyRemoteDataSource remoteDataSource;
  final PropertyLocalDataSource localDataSource;
  final NetworkInfo networkInfo;

  PropertyRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, List<Property>>> getProperties({
    String? type,
    String? propertyType,
    double? minPrice,
    double? maxPrice,
    String? neighborhood,
    double? latitude,
    double? longitude,
    double? radiusKm,
  }) async {
    final isConnected = await networkInfo.isConnected;

    if (isConnected) {
      try {
        final remote = await remoteDataSource.getProperties(
          type: type,
          propertyType: propertyType,
          minPrice: minPrice,
          maxPrice: maxPrice,
          neighborhood: neighborhood,
          latitude: latitude,
          longitude: longitude,
          radiusKm: radiusKm,
        );
        // Cache automático após busca bem-sucedida
        await localDataSource.cacheProperties(remote);
        return Right(remote.map((m) => m.toEntity()).toList());
      } on ServerException catch (e) {
        return Left(ServerFailure(e.message));
      } catch (e) {
        return Left(ServerFailure(e.toString()));
      }
    } else {
      // Modo offline — usa cache com filtros locais
      try {
        final cached = await localDataSource.getCachedProperties();
        if (cached.isEmpty) {
          return const Left(CacheFailure('Nenhum imóvel em cache.'));
        }
        var filtered = cached;
        if (type != null) filtered = filtered.where((p) => p.type == type).toList();
        if (propertyType != null) {
          filtered = filtered.where((p) => p.propertyType == propertyType).toList();
        }
        if (minPrice != null) filtered = filtered.where((p) => p.price >= minPrice).toList();
        if (maxPrice != null) filtered = filtered.where((p) => p.price <= maxPrice).toList();
        if (neighborhood != null && neighborhood.isNotEmpty) {
          filtered = filtered
              .where((p) => p.neighborhood.toLowerCase().contains(neighborhood.toLowerCase()))
              .toList();
        }
        return Right(filtered.map((m) => m.toEntity()).toList());
      } on CacheException catch (e) {
        return Left(CacheFailure(e.message));
      }
    }
  }

  @override
  Future<Either<Failure, Property>> getPropertyById(String id) async {
    final isConnected = await networkInfo.isConnected;
    if (isConnected) {
      try {
        final property = await remoteDataSource.getPropertyById(id);
        await localDataSource.cacheProperty(property);
        return Right(property.toEntity());
      } on ServerException catch (e) {
        return Left(ServerFailure(e.message));
      }
    } else {
      try {
        final cached = await localDataSource.getCachedPropertyById(id);
        if (cached == null) {
          return const Left(CacheFailure('Imóvel não encontrado no cache.'));
        }
        return Right(cached.toEntity());
      } on CacheException catch (e) {
        return Left(CacheFailure(e.message));
      }
    }
  }

  @override
  Future<Either<Failure, List<Property>>> searchProperties(String query) async {
    final isConnected = await networkInfo.isConnected;
    if (isConnected) {
      try {
        final results = await remoteDataSource.searchProperties(query);
        return Right(results.map((m) => m.toEntity()).toList());
      } on ServerException catch (e) {
        return Left(ServerFailure(e.message));
      }
    } else {
      try {
        final results = await localDataSource.searchCachedProperties(query);
        return Right(results.map((m) => m.toEntity()).toList());
      } on CacheException catch (e) {
        return Left(CacheFailure(e.message));
      }
    }
  }

  @override
  Future<Either<Failure, List<Property>>> getNearbyProperties(
    double latitude,
    double longitude,
    double radiusMeters,
  ) async {
    final isConnected = await networkInfo.isConnected;
    if (isConnected) {
      try {
        final results = await remoteDataSource.getNearbyProperties(
            latitude, longitude, radiusMeters);
        return Right(results.map((m) => m.toEntity()).toList());
      } on ServerException catch (e) {
        return Left(ServerFailure(e.message));
      }
    } else {
      // Offline: filtra cache por distância
      try {
        final cached = await localDataSource.getCachedProperties();
        final nearby = cached.where((p) {
          final dist = Geolocator.distanceBetween(
              latitude, longitude, p.latitude, p.longitude);
          return dist <= radiusMeters;
        }).toList();
        nearby.sort((a, b) {
          final dA = Geolocator.distanceBetween(
              latitude, longitude, a.latitude, a.longitude);
          final dB = Geolocator.distanceBetween(
              latitude, longitude, b.latitude, b.longitude);
          return dA.compareTo(dB);
        });
        return Right(nearby.map((m) => m.toEntity()).toList());
      } on CacheException catch (e) {
        return Left(CacheFailure(e.message));
      }
    }
  }

  @override
  Future<Either<Failure, List<Property>>> getCachedProperties() async {
    try {
      final cached = await localDataSource.getCachedProperties();
      return Right(cached.map((m) => m.toEntity()).toList());
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, void>> cacheProperties(List<Property> properties) async {
    try {
      final models = properties.map(PropertyModel.fromEntity).toList();
      await localDataSource.cacheProperties(models);
      return const Right(null);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, String>> publishProperty(Property property) async {
    final isConnected = await networkInfo.isConnected;
    if (!isConnected) {
      return const Left(NetworkFailure('Precisas de internet para publicar.'));
    }
    try {
      final model = PropertyModel.fromEntity(property);
      final id = await remoteDataSource.publishProperty(model.toJson());
      return Right(id);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }
}
