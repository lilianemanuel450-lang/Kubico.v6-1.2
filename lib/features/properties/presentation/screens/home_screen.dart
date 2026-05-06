import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shimmer/shimmer.dart';

import '../../../../core/theme/app_theme.dart';
import '../../domain/entities/property.dart';
import '../providers/property_provider.dart';
import '../widgets/property_card.dart';
import '../widgets/filter_bar.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    final propertiesAsync = ref.watch(propertyListNotifierProvider);

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: CustomScrollView(
        slivers: [
          _buildAppBar(context),
          SliverToBoxAdapter(child: FilterBar()),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  propertiesAsync.when(
                    data: (list) => Text(
                      '${list.length} imóveis encontrados',
                      style: const TextStyle(
                        color: AppTheme.textSecondary,
                        fontSize: 14,
                      ),
                    ),
                    loading: () => const SizedBox.shrink(),
                    error: (_, __) => const SizedBox.shrink(),
                  ),
                  TextButton.icon(
                    onPressed: () => context.push('/publish'),
                    icon: const Icon(Icons.add, size: 18),
                    label: const Text('Publicar'),
                    style: TextButton.styleFrom(
                      foregroundColor: AppTheme.primary,
                    ),
                  ),
                ],
              ),
            ),
          ),
          propertiesAsync.when(
            data: (properties) => _buildList(context, ref, properties),
            loading: () => _buildShimmer(),
            error: (error, _) => SliverToBoxAdapter(
              child: _buildError(context, ref, error.toString()),
            ),
          ),
        ],
      ),
    );
  }

  SliverAppBar _buildAppBar(BuildContext context) {
    return SliverAppBar(
      floating: true,
      snap: true,
      backgroundColor: AppTheme.surface,
      title: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: AppTheme.primary,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Center(
              child: Text('K',
                  style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 18)),
            ),
          ),
          const SizedBox(width: 8),
          const Text('Kubico',
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary)),
        ],
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.search, color: AppTheme.textPrimary),
          onPressed: () => context.push('/search'),
        ),
        IconButton(
          icon: const Icon(Icons.map_outlined, color: AppTheme.textPrimary),
          onPressed: () => context.push('/map'),
        ),
      ],
    );
  }

  SliverList _buildList(BuildContext context, WidgetRef ref, List<Property> properties) {
    if (properties.isEmpty) {
      return SliverList(
        delegate: SliverChildListDelegate([
          const SizedBox(height: 80),
          const Center(
            child: Column(
              children: [
                Icon(Icons.home_outlined, size: 64, color: AppTheme.textSecondary),
                SizedBox(height: 16),
                Text('Nenhum imóvel encontrado',
                    style: TextStyle(color: AppTheme.textSecondary, fontSize: 16)),
              ],
            ),
          ),
        ]),
      );
    }
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          if (index == properties.length) return const SizedBox(height: 100);
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: PropertyCard(
              property: properties[index],
              onTap: () => context.push('/property/${properties[index].id}', extra: properties[index]),
            ),
          );
        },
        childCount: properties.length + 1,
      ),
    );
  }

  Widget _buildShimmer() {
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) => Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Shimmer.fromColors(
            baseColor: Colors.grey[300]!,
            highlightColor: Colors.grey[100]!,
            child: Container(
              height: 260,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
        ),
        childCount: 5,
      ),
    );
  }

  Widget _buildError(BuildContext context, WidgetRef ref, String error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.wifi_off, size: 48, color: AppTheme.textSecondary),
            const SizedBox(height: 16),
            Text(
              'Erro ao carregar imóveis.',
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppTheme.textSecondary),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () => ref.read(propertyListNotifierProvider.notifier).refresh(),
              icon: const Icon(Icons.refresh),
              label: const Text('Tentar de novo'),
            ),
          ],
        ),
      ),
    );
  }
}
