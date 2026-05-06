import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_theme.dart';
import '../providers/property_provider.dart';

class FilterBar extends ConsumerWidget {
  const FilterBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filters = ref.watch(propertyFiltersNotifierProvider);
    final notifier = ref.read(propertyFiltersNotifierProvider.notifier);

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          // Filtro: Tipo (Arrendamento / Venda)
          _FilterChip(
            label: 'Todos',
            isSelected: filters.type == null,
            onTap: () {
              notifier.setType(null);
              _refresh(ref);
            },
          ),
          const SizedBox(width: 8),
          _FilterChip(
            label: 'Arrendamento',
            isSelected: filters.type == 'rent',
            onTap: () {
              notifier.setType('rent');
              _refresh(ref);
            },
          ),
          const SizedBox(width: 8),
          _FilterChip(
            label: 'Venda',
            isSelected: filters.type == 'sell',
            onTap: () {
              notifier.setType('sell');
              _refresh(ref);
            },
          ),
          const SizedBox(width: 8),
          const VerticalDivider(width: 1, thickness: 1, color: AppTheme.border),
          const SizedBox(width: 8),
          // Filtro: Tipo de imóvel
          _FilterChip(
            label: 'Casa',
            icon: Icons.home_outlined,
            isSelected: filters.propertyType == 'house',
            onTap: () {
              notifier.setPropertyType(
                  filters.propertyType == 'house' ? null : 'house');
              _refresh(ref);
            },
          ),
          const SizedBox(width: 8),
          _FilterChip(
            label: 'Apartamento',
            icon: Icons.apartment_outlined,
            isSelected: filters.propertyType == 'apartment',
            onTap: () {
              notifier.setPropertyType(
                  filters.propertyType == 'apartment' ? null : 'apartment');
              _refresh(ref);
            },
          ),
          const SizedBox(width: 8),
          _FilterChip(
            label: 'Terreno',
            icon: Icons.landscape_outlined,
            isSelected: filters.propertyType == 'land',
            onTap: () {
              notifier.setPropertyType(
                  filters.propertyType == 'land' ? null : 'land');
              _refresh(ref);
            },
          ),
          // Botão limpar filtros
          if (filters.type != null || filters.propertyType != null) ...[
            const SizedBox(width: 8),
            GestureDetector(
              onTap: () {
                notifier.clearAll();
                _refresh(ref);
              },
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: AppTheme.error.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppTheme.error.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.close, size: 14, color: AppTheme.error),
                    const SizedBox(width: 4),
                    Text('Limpar',
                        style: TextStyle(
                            color: AppTheme.error,
                            fontSize: 13,
                            fontWeight: FontWeight.w500)),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  void _refresh(WidgetRef ref) {
    ref.read(propertyListNotifierProvider.notifier).refresh();
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final IconData? icon;

  const _FilterChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primary : AppTheme.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppTheme.primary : AppTheme.border,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 14,
                  color: isSelected ? Colors.white : AppTheme.textSecondary),
              const SizedBox(width: 4),
            ],
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : AppTheme.textPrimary,
                fontSize: 13,
                fontWeight:
                    isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
