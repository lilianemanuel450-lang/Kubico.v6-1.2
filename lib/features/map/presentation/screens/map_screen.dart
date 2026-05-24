import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../properties/presentation/providers/property_provider.dart';
import '../../../properties/domain/entities/property.dart';

const _mockItems = [
  {
    'id': 'mock-1',
    'title': 'T3 em Talatona',
    'price': 'Kz 250.000/mês',
    'location': 'Talatona, Luanda Sul',
    'type': 'rent',
    'image': 'https://images.unsplash.com/photo-1564013799919-ab600027ffc6?w=600&q=80',
  },
  {
    'id': 'mock-2',
    'title': 'Vivenda em Benfica',
    'price': 'Kz 80.000.000',
    'location': 'Benfica, Luanda',
    'type': 'sell',
    'image': 'https://images.unsplash.com/photo-1580587771525-78b9dba3b914?w=600&q=80',
  },
  {
    'id': 'mock-3',
    'title': 'Apartamento T2 Miramar',
    'price': 'Kz 150.000/mês',
    'location': 'Miramar, Luanda',
    'type': 'rent',
    'image': 'https://images.unsplash.com/photo-1502672260266-1c1ef2d93688?w=600&q=80',
  },
  {
    'id': 'mock-4',
    'title': 'Villa T4 Camama',
    'price': 'Kz 45.000.000',
    'location': 'Camama, Luanda',
    'type': 'sell',
    'image': 'https://images.unsplash.com/photo-1613977257363-707ba9348227?w=600&q=80',
  },
];

class MapScreen extends ConsumerWidget {
  const MapScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final propertiesAsync = ref.watch(propertyListNotifierProvider);
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      body: Stack(
        children: [
          // ── Mapa em cima ──────────────────────────────────────
          Positioned.fill(
            child: _buildFakeMap(),
          ),

          // ── Botão voltar ──────────────────────────────────────
          Positioned(
            top: MediaQuery.of(context).padding.top + 12,
            left: 16,
            child: GestureDetector(
              onTap: () => context.go('/'),
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(0.15), blurRadius: 8)
                  ],
                ),
                child: const Icon(Icons.arrow_back, color: Color(0xFF1A1A1A), size: 20),
              ),
            ),
          ),

          // ── Sheet arrastável com casas ────────────────────────
          DraggableScrollableSheet(
            initialChildSize: 0.45,
            minChildSize: 0.15,
            maxChildSize: 1.0,
            builder: (context, scrollController) {
              return Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                  boxShadow: [
                    BoxShadow(color: Colors.black26, blurRadius: 16, offset: Offset(0, -4)),
                  ],
                ),
                child: Column(
                  children: [
                    // Handle
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      child: Container(
                        width: 40, height: 4,
                        decoration: BoxDecoration(
                          color: const Color(0xFFDDDDDD),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    // Título
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                      child: Row(
                        children: [
                          Text(
                            'Imóveis na área',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.textPrimary,
                            ),
                          ),
                          const Spacer(),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppTheme.primary.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              '${_mockItems.length} imóveis',
                              style: TextStyle(
                                color: AppTheme.primary,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Grid de casas
                    Expanded(
                      child: propertiesAsync.when(
                        data: (list) {
                          if (list.isEmpty) return _buildMockGrid(scrollController);
                          return _buildRealGrid(list, scrollController);
                        },
                        loading: () => _buildMockGrid(scrollController),
                        error: (_, __) => _buildMockGrid(scrollController),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildFakeMap() {
    return Container(
      color: const Color(0xFFEAE6DC),
      child: Stack(
        children: [
          // Oceano
          Positioned(
            left: 0, top: 0, bottom: 0,
            child: Container(width: 60, color: const Color(0xFFB8D4E8).withOpacity(0.8)),
          ),
          // Estradas
          Positioned(left: 60, right: 0, top: 120,
              child: Container(height: 10, color: const Color(0xFFD4C9A8).withOpacity(0.9))),
          Positioned(left: 60, right: 0, top: 200,
              child: Container(height: 7, color: const Color(0xFFD4C9A8).withOpacity(0.7))),
          Positioned(left: 60, right: 0, top: 280,
              child: Container(height: 6, color: const Color(0xFFD4C9A8).withOpacity(0.6))),
          Positioned(left: 60, right: 0, top: 360,
              child: Container(height: 5, color: const Color(0xFFD4C9A8).withOpacity(0.5))),
          Positioned(left: 160, top: 0, bottom: 0,
              child: Container(width: 8, color: const Color(0xFFD4C9A8).withOpacity(0.7))),
          Positioned(left: 280, top: 0, bottom: 0,
              child: Container(width: 6, color: const Color(0xFFD4C9A8).withOpacity(0.6))),
          Positioned(left: 380, top: 0, bottom: 0,
              child: Container(width: 5, color: const Color(0xFFD4C9A8).withOpacity(0.5))),
          // Bairros
          const Positioned(top: 80, left: 80,
              child: Text('Luanda', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF555555)))),
          const Positioned(top: 60, right: 60,
              child: Text('Viana', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF555555)))),
          const Positioned(top: 280, left: 80,
              child: Text('Benfica', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF555555)))),
          const Positioned(top: 320, right: 60,
              child: Text('Talatona', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF555555)))),
          // Pins
          _pin(top: 100, left: 120),
          _pin(top: 140, left: 220),
          _pin(top: 80, right: 130),
          _pin(top: 200, left: 100),
          _pin(top: 240, left: 180),
          _pin(top: 180, right: 100),
          _pin(top: 300, right: 130),
          // Localização actual
          Positioned(
            top: 190, left: 260,
            child: Container(
              width: 20, height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF2196F3),
                border: Border.all(color: Colors.white, width: 3),
                boxShadow: [BoxShadow(color: Colors.blue.withOpacity(0.4), blurRadius: 10, spreadRadius: 4)],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _pin({double? top, double? bottom, double? left, double? right}) {
    return Positioned(
      top: top, bottom: bottom, left: left, right: right,
      child: Container(
        width: 36, height: 36,
        decoration: BoxDecoration(
          color: AppTheme.primary,
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white, width: 2.5),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 6)],
        ),
        child: const Icon(Icons.home, color: Colors.white, size: 18),
      ),
    );
  }

  Widget _buildMockGrid(ScrollController scrollController) {
    return GridView.builder(
      controller: scrollController,
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 0.78,
      ),
      itemCount: _mockItems.length,
      itemBuilder: (context, i) => _mockCard(_mockItems[i]),
    );
  }

  Widget _buildRealGrid(List<Property> properties, ScrollController scrollController) {
    return GridView.builder(
      controller: scrollController,
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 0.78,
      ),
      itemCount: properties.length,
      itemBuilder: (context, i) => _realCard(properties[i]),
    );
  }

  Widget _mockCard(Map<String, String> item) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 8, offset: const Offset(0, 2))
        ],
        border: Border.all(color: const Color(0xFFEEEEEE)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(14)),
            child: CachedNetworkImage(
              imageUrl: item['image']!,
              height: 110,
              width: double.infinity,
              fit: BoxFit.cover,
              errorWidget: (_, __, ___) => Container(
                height: 110,
                color: const Color(0xFFE0E0E0),
                child: const Icon(Icons.home, size: 36, color: Colors.grey),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item['title']!,
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF1A1A1A)),
                    maxLines: 1, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Icon(Icons.location_on, size: 11, color: AppTheme.primary),
                    const SizedBox(width: 2),
                    Expanded(
                      child: Text(item['location']!,
                          style: const TextStyle(color: Color(0xFF888888), fontSize: 11),
                          maxLines: 1, overflow: TextOverflow.ellipsis),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(item['price']!,
                    style: TextStyle(color: AppTheme.primary, fontWeight: FontWeight.bold, fontSize: 12)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _realCard(Property property) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 8, offset: const Offset(0, 2))
        ],
        border: Border.all(color: const Color(0xFFEEEEEE)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(14)),
            child: CachedNetworkImage(
              imageUrl: property.mainImage,
              height: 110,
              width: double.infinity,
              fit: BoxFit.cover,
              errorWidget: (_, __, ___) => Container(
                height: 110,
                color: const Color(0xFFE0E0E0),
                child: const Icon(Icons.home, size: 36, color: Colors.grey),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(property.title,
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF1A1A1A)),
                    maxLines: 1, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Icon(Icons.location_on, size: 11, color: AppTheme.primary),
                    const SizedBox(width: 2),
                    Expanded(
                      child: Text(property.neighborhood,
                          style: const TextStyle(color: Color(0xFF888888), fontSize: 11),
                          maxLines: 1, overflow: TextOverflow.ellipsis),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(property.formattedPrice,
                    style: TextStyle(color: AppTheme.primary, fontWeight: FontWeight.bold, fontSize: 12)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
