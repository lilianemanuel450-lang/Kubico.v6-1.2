import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/network/network_info.dart';
import '../../data/datasources/property_local_datasource.dart';
import '../../data/datasources/property_remote_datasource.dart';
import '../../data/repositories/property_repository_impl.dart';
import '../../domain/entities/property.dart';
import '../../domain/repositories/property_repository.dart';
import '../../domain/usecases/property_usecases.dart';

// ── Infraestrutura ─────────────────────────────────────────────────────────

final networkInfoProvider = Provider<NetworkInfo>((ref) {
  return NetworkInfoImpl(Connectivity());
});

final propertyRemoteDataSourceProvider = Provider<PropertyRemoteDataSource>((ref) {
  return PropertyRemoteDataSourceImpl(Supabase.instance.client);
});

final propertyLocalDataSourceProvider = Provider<PropertyLocalDataSource>((ref) {
  return PropertyLocalDataSourceImpl();
});

final propertyRepositoryProvider = Provider<PropertyRepository>((ref) {
  return PropertyRepositoryImpl(
    remoteDataSource: ref.watch(propertyRemoteDataSourceProvider),
    localDataSource: ref.watch(propertyLocalDataSourceProvider),
    networkInfo: ref.watch(networkInfoProvider),
  );
});

// ── UseCases ───────────────────────────────────────────────────────────────

final getPropertiesUseCaseProvider = Provider<GetProperties>((ref) {
  return GetProperties(ref.watch(propertyRepositoryProvider));
});

final searchPropertiesUseCaseProvider = Provider<SearchProperties>((ref) {
  return SearchProperties(ref.watch(propertyRepositoryProvider));
});

final getNearbyPropertiesUseCaseProvider = Provider<GetNearbyProperties>((ref) {
  return GetNearbyProperties(ref.watch(propertyRepositoryProvider));
});

final publishPropertyUseCaseProvider = Provider<PublishProperty>((ref) {
  return PublishProperty(ref.watch(propertyRepositoryProvider));
});

// ── Filtros ────────────────────────────────────────────────────────────────

class PropertyFilters {
  final String? type;
  final String? propertyType;
  final double? minPrice;
  final double? maxPrice;
  final String? neighborhood;

  const PropertyFilters({
    this.type,
    this.propertyType,
    this.minPrice,
    this.maxPrice,
    this.neighborhood,
  });

  PropertyFilters copyWith({
    String? type,
    String? propertyType,
    double? minPrice,
    double? maxPrice,
    String? neighborhood,
  }) => PropertyFilters(
    type: type ?? this.type,
    propertyType: propertyType ?? this.propertyType,
    minPrice: minPrice ?? this.minPrice,
    maxPrice: maxPrice ?? this.maxPrice,
    neighborhood: neighborhood ?? this.neighborhood,
  );

  PropertyFilters clear() => const PropertyFilters();
}

class PropertyFiltersNotifier extends StateNotifier<PropertyFilters> {
  PropertyFiltersNotifier() : super(const PropertyFilters());

  void setType(String? type) => state = state.copyWith(type: type);
  void setPropertyType(String? t) => state = state.copyWith(propertyType: t);
  void setPriceRange(double? min, double? max) =>
      state = state.copyWith(minPrice: min, maxPrice: max);
  void setNeighborhood(String? n) => state = state.copyWith(neighborhood: n);
  void clearAll() => state = state.clear();
}

final propertyFiltersNotifierProvider =
    StateNotifierProvider<PropertyFiltersNotifier, PropertyFilters>(
  (ref) => PropertyFiltersNotifier(),
);

// ── Lista de Imóveis ───────────────────────────────────────────────────────

class PropertyListNotifier extends StateNotifier<AsyncValue<List<Property>>> {
  final Ref _ref;

  PropertyListNotifier(this._ref) : super(const AsyncValue.loading()) {
    _fetch();
  }

  Future<void> _fetch() async {
    state = const AsyncValue.loading();
    try {
      final filters = _ref.read(propertyFiltersNotifierProvider);
      final useCase = _ref.read(getPropertiesUseCaseProvider);
      final result = await useCase(
        type: filters.type,
        propertyType: filters.propertyType,
        minPrice: filters.minPrice,
        maxPrice: filters.maxPrice,
        neighborhood: filters.neighborhood,
      );
      state = result.fold(
        (failure) => AsyncValue.error(failure.message, StackTrace.current),
        (properties) => AsyncValue.data(properties),
      );
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> refresh() => _fetch();

  Future<void> applyFilters(PropertyFilters filters) => _fetch();
}

final propertyListNotifierProvider =
    StateNotifierProvider<PropertyListNotifier, AsyncValue<List<Property>>>(
  (ref) => PropertyListNotifier(ref),
);

// ── Pesquisa com Debounce ──────────────────────────────────────────────────

class PropertySearchNotifier extends StateNotifier<AsyncValue<List<Property>>> {
  final Ref _ref;
  Timer? _debounce;

  PropertySearchNotifier(this._ref) : super(const AsyncValue.data([]));

  void search(String query) {
    _debounce?.cancel();
    if (query.trim().isEmpty) {
      state = const AsyncValue.data([]);
      return;
    }
    _debounce = Timer(const Duration(milliseconds: 500), () async {
      state = const AsyncValue.loading();
      try {
        final useCase = _ref.read(searchPropertiesUseCaseProvider);
        final result = await useCase(query.trim());
        state = result.fold(
          (failure) => AsyncValue.error(failure.message, StackTrace.current),
          (properties) => AsyncValue.data(properties),
        );
      } catch (e, st) {
        state = AsyncValue.error(e, st);
      }
    });
  }

  void clear() {
    _debounce?.cancel();
    state = const AsyncValue.data([]);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }
}

final propertySearchNotifierProvider =
    StateNotifierProvider<PropertySearchNotifier, AsyncValue<List<Property>>>(
  (ref) => PropertySearchNotifier(ref),
);
