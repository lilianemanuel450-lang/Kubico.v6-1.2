import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/errors/exceptions.dart';
import '../models/property_model.dart';

abstract class PropertyRemoteDataSource {
  Future<List<PropertyModel>> getProperties({
    String? type,
    String? propertyType,
    double? minPrice,
    double? maxPrice,
    String? neighborhood,
    double? latitude,
    double? longitude,
    double? radiusKm,
  });

  Future<PropertyModel> getPropertyById(String id);
  Future<List<PropertyModel>> searchProperties(String query);
  Future<List<PropertyModel>> getNearbyProperties(
    double latitude,
    double longitude,
    double radiusMeters,
  );
  Future<String> publishProperty(Map<String, dynamic> data);
}

class PropertyRemoteDataSourceImpl implements PropertyRemoteDataSource {
  final SupabaseClient supabase;
  static const String _table = 'properties';

  PropertyRemoteDataSourceImpl(this.supabase);

  @override
  Future<List<PropertyModel>> getProperties({
    String? type,
    String? propertyType,
    double? minPrice,
    double? maxPrice,
    String? neighborhood,
    double? latitude,
    double? longitude,
    double? radiusKm,
  }) async {
    try {
      // Caso tenha coordenadas, usa RPC PostGIS para busca geoespacial
      if (latitude != null && longitude != null && radiusKm != null) {
        final response = await supabase.rpc('get_properties_nearby', params: {
          'lat': latitude,
          'lng': longitude,
          'radius_km': radiusKm,
          if (type != null) 'p_type': type,
          if (propertyType != null) 'p_property_type': propertyType,
          if (minPrice != null) 'p_min_price': minPrice,
          if (maxPrice != null) 'p_max_price': maxPrice,
        });
        final list = response as List<dynamic>;
        return list
            .map((e) => PropertyModel.fromJson(e as Map<String, dynamic>))
            .toList();
      }

      // Busca normal com filtros
      dynamic query = supabase
          .from(_table)
          .select()
          .eq('is_available', true);

      if (type != null) {
        query = query.eq('type', type);
      }
      if (propertyType != null) {
        query = query.eq('property_type', propertyType);
      }
      if (minPrice != null) {
        query = query.gte('price', minPrice);
      }
      if (maxPrice != null) {
        query = query.lte('price', maxPrice);
      }
      if (neighborhood != null && neighborhood.isNotEmpty) {
        query = query.ilike('neighborhood', '%$neighborhood%');
      }

      query = query.order('created_at', ascending: false).limit(100);

      final response = await query;
      final list = response as List<dynamic>;
      return list
          .map((e) => PropertyModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } on PostgrestException catch (e) {
      throw ServerException('Erro Supabase: ${e.message}');
    } catch (e) {
      throw ServerException('Erro ao buscar imóveis: $e');
    }
  }

  @override
  Future<PropertyModel> getPropertyById(String id) async {
    try {
      final response =
          await supabase.from(_table).select().eq('id', id).single();
      return PropertyModel.fromJson(response);
    } on PostgrestException catch (e) {
      throw ServerException('Imóvel não encontrado: ${e.message}');
    } catch (e) {
      throw ServerException('Erro ao buscar imóvel: $e');
    }
  }

  @override
  Future<List<PropertyModel>> searchProperties(String query) async {
    try {
      // Full-text search com tsvector no Supabase
      final response = await supabase
          .from(_table)
          .select()
          .or('title.ilike.%$query%,description.ilike.%$query%,address.ilike.%$query%,neighborhood.ilike.%$query%')
          .eq('is_available', true)
          .order('created_at', ascending: false)
          .limit(50);

      final list = response as List<dynamic>;
      return list
          .map((e) => PropertyModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } on PostgrestException catch (e) {
      throw ServerException('Erro na pesquisa: ${e.message}');
    } catch (e) {
      throw ServerException('Erro ao pesquisar: $e');
    }
  }

  @override
  Future<List<PropertyModel>> getNearbyProperties(
    double latitude,
    double longitude,
    double radiusMeters,
  ) async {
    try {
      final radiusKm = radiusMeters / 1000;
      final response = await supabase.rpc('get_properties_nearby', params: {
        'lat': latitude,
        'lng': longitude,
        'radius_km': radiusKm,
      });
      final list = response as List<dynamic>;
      return list
          .map((e) => PropertyModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } on PostgrestException catch (e) {
      throw ServerException('Erro ao buscar imóveis próximos: ${e.message}');
    } catch (e) {
      throw ServerException('Erro geoespacial: $e');
    }
  }

  @override
  Future<String> publishProperty(Map<String, dynamic> data) async {
    try {
      final response =
          await supabase.from(_table).insert(data).select('id').single();
      return response['id'] as String;
    } on PostgrestException catch (e) {
      throw ServerException('Erro ao publicar imóvel: ${e.message}');
    } catch (e) {
      throw ServerException('Erro ao publicar: $e');
    }
  }
}
