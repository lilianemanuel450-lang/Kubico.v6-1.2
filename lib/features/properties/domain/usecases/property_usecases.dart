import 'package:fpdart/fpdart.dart';
import '../../../../core/errors/failures.dart';
import '../entities/property.dart';
import '../repositories/property_repository.dart';

/// Busca imóveis com filtros opcionais
class GetProperties {
  final PropertyRepository repository;
  GetProperties(this.repository);

  Future<Either<Failure, List<Property>>> call({
    String? type,
    String? propertyType,
    double? minPrice,
    double? maxPrice,
    String? neighborhood,
    double? latitude,
    double? longitude,
    double? radiusKm,
  }) {
    return repository.getProperties(
      type: type,
      propertyType: propertyType,
      minPrice: minPrice,
      maxPrice: maxPrice,
      neighborhood: neighborhood,
      latitude: latitude,
      longitude: longitude,
      radiusKm: radiusKm,
    );
  }
}

/// Busca imóvel por ID
class GetPropertyById {
  final PropertyRepository repository;
  GetPropertyById(this.repository);

  Future<Either<Failure, Property>> call(String id) {
    return repository.getPropertyById(id);
  }
}

/// Pesquisa por texto livre
class SearchProperties {
  final PropertyRepository repository;
  SearchProperties(this.repository);

  Future<Either<Failure, List<Property>>> call(String query) {
    if (query.trim().isEmpty) {
      return Future.value(const Right([]));
    }
    return repository.searchProperties(query.trim());
  }
}

/// Imóveis próximos por geolocalização
class GetNearbyProperties {
  final PropertyRepository repository;
  GetNearbyProperties(this.repository);

  Future<Either<Failure, List<Property>>> call(
    double latitude,
    double longitude,
    double radiusMeters,
  ) {
    return repository.getNearbyProperties(latitude, longitude, radiusMeters);
  }
}

/// Publica novo imóvel
class PublishProperty {
  final PropertyRepository repository;
  PublishProperty(this.repository);

  Future<Either<Failure, String>> call(Property property) {
    return repository.publishProperty(property);
  }
}
