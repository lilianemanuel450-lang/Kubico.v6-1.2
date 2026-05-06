import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../properties/presentation/providers/property_provider.dart';
import '../../../properties/presentation/widgets/property_card.dart';
import '../providers/favorites_provider.dart';

class FavoritesScreen extends ConsumerWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final favoritesAsync = ref.watch(favoritesNotifierProvider);
    final propertiesAsync = ref.watch(propertyListNotifierProvider);

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('Imóveis Guardados'),
        backgroundColor: AppTheme.surface,
        foregroundColor: AppTheme.textPrimary,
        elevation: 0,
      ),
      body: favoritesAsync.when(
        data: (favoriteIds) {
          if (favoriteIds.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.favorite_border,
                      size: 64, color: AppTheme.textSecondary),
                  SizedBox(height: 16),
                  Text('Ainda não guardaste nenhum imóvel',
                      style: TextStyle(
                          color: AppTheme.textSecondary, fontSize: 16)),
                  SizedBox(height: 8),
                  Text('Toca no ❤ para guardar imóveis',
                      style: TextStyle(
                          color: AppTheme.textSecondary, fontSize: 14)),
                ],
              ),
            );
          }

          return propertiesAsync.when(
            data: (allProps) {
              final favorites = allProps
                  .where((p) => favoriteIds.contains(p.id))
                  .toList();
              if (favorites.isEmpty) {
                return const Center(
                    child: Text('Imóveis guardados não disponíveis offline',
                        style:
                            TextStyle(color: AppTheme.textSecondary)));
              }
              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: favorites.length,
                itemBuilder: (_, i) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: PropertyCard(
                    property: favorites[i],
                    onTap: () => context.push(
                      '/property/${favorites[i].id}',
                      extra: favorites[i],
                    ),
                  ),
                ),
              );
            },
            loading: () =>
                const Center(child: CircularProgressIndicator(color: AppTheme.primary)),
            error: (e, _) =>
                Center(child: Text('Erro: $e')),
          );
        },
        loading: () =>
            const Center(child: CircularProgressIndicator(color: AppTheme.primary)),
        error: (e, _) =>
            Center(child: Text('Erro: $e')),
      ),
    );
  }
}
