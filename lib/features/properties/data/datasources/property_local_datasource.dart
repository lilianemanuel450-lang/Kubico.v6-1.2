import '../../../../core/errors/exceptions.dart';
import '../models/property_model.dart';

abstract class PropertyLocalDataSource {
  Future<List<PropertyModel>> getCachedProperties();
  Future<List<PropertyModel>> searchCachedProperties(String query);
  Future<PropertyModel?> getCachedPropertyById(String id);
  Future<void> cacheProperties(List<PropertyModel> properties);
  Future<void> cacheProperty(PropertyModel property);
  Future<void> clearCache();
  Future<void> removeOldCache(Duration maxAge);
}

// Cache em memória simples — sem Isar, sem code generation
class PropertyLocalDataSourceImpl implements PropertyLocalDataSource {
  final List<PropertyModel> _cache = [];

  @override
  Future<List<PropertyModel>> getCachedProperties() async {
    try {
      return List.from(_cache);
    } catch (e) {
      throw CacheException('Erro ao ler cache: $e');
    }
  }

  @override
  Future<List<PropertyModel>> searchCachedProperties(String query) async {
    try {
      final q = query.toLowerCase();
      return _cache.where((p) =>
        p.title.toLowerCase().contains(q) ||
        p.neighborhood.toLowerCase().contains(q) ||
        p.address.toLowerCase().contains(q) ||
        p.description.toLowerCase().contains(q)
      ).toList();
    } catch (e) {
      throw CacheException('Erro na pesquisa local: $e');
    }
  }

  @override
  Future<PropertyModel?> getCachedPropertyById(String id) async {
    try {
      return _cache.where((p) => p.propertyId == id).firstOrNull;
    } catch (e) {
      throw CacheException('Erro ao buscar imóvel no cache: $e');
    }
  }

  @override
  Future<void> cacheProperties(List<PropertyModel> properties) async {
    try {
      _cache.clear();
      _cache.addAll(properties);
    } catch (e) {
      throw CacheException('Erro ao guardar no cache: $e');
    }
  }

  @override
  Future<void> cacheProperty(PropertyModel property) async {
    try {
      final idx = _cache.indexWhere((p) => p.propertyId == property.propertyId);
      if (idx >= 0) {
        _cache[idx] = property;
      } else {
        _cache.add(property);
      }
    } catch (e) {
      throw CacheException('Erro ao guardar imóvel no cache: $e');
    }
  }

  @override
  Future<void> clearCache() async {
    _cache.clear();
  }

  @override
  Future<void> removeOldCache(Duration maxAge) async {
    final cutoff = DateTime.now().subtract(maxAge);
    _cache.removeWhere((p) => p.cachedAt.isBefore(cutoff));
  }
}
