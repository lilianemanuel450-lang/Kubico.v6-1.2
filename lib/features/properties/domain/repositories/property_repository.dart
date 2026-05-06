import 'package:fpdart/fpdart.dart';
import '../../../../core/errors/failures.dart';
import '../entities/property.dart';

abstract class PropertyRepository {
  Future<Either<Failure, List<Property>>> getProperties({
    String? type,
    String? propertyType,
    double? minPrice,
    double? maxPrice,
    String? neighborhood,
    double? latitude,
    double? longitude,
    double? radiusKm,
  });

  Future<Either<Failure, Property>> getPropertyById(String id);

  Future<Either<Failure, List<Property>>> searchProperties(String query);

  Future<Either<Failure, List<Property>>> getNearbyProperties(
    double latitude,
    double longitude,
    double radiusMeters,
  );

  Future<Either<Failure, List<Property>>> getCachedProperties();

  Future<Either<Failure, void>> cacheProperties(List<Property> properties);

  Future<Either<Failure, String>> publishProperty(Property property);
}
