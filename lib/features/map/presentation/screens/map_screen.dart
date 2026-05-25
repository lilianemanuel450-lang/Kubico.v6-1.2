import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../properties/presentation/providers/property_provider.dart';

const _mockItems = [
  {
    'title': 'T3 em Talatona',
    'price': 'Kz 250.000/mês',
    'location': 'Talatona',
    'type': 'rent',
    'image': 'https://images.unsplash.com/photo-1564013799919-ab600027ffc6?w=400&q=80',
  },
  {
    'title': 'Vivenda em Benfica',
    'price': 'Kz 80.000.000',
    'location': 'Benfica',
    'type': 'sell',
    'image': 'https://images.unsplash.com/photo-1580587771525-78b9dba3b914?w=400&q=80',
  },
  {
    'title': 'Apto T2 Miramar',
    'price': 'Kz 150.000/mês',
    'location': 'Miramar',
    'type': 'rent',
    'image': 'https://images.unsplash.com/photo-1502672260266-1c1ef2d93688?w=400&q=80',
  },
  {
    'title': 'Villa T4 Camama',
    'price': 'Kz 45.000.000',
    'location': 'Camama',
    'type': 'sell',
    'image': 'https://images.unsplash.com/photo-1613977257363-707ba9348227?w=400&q=80',
  },
  {
    'title': 'T2 em Viana',
    'price': 'Kz 120.000/mês',
    'location': 'Viana',
    'type': 'rent',
    'image': 'https://images.unsplash.com/photo-1512917774080-9991f1c4c750?w=400&q=80',
  },
  {
    'title': 'Moradia Talatona',
    'price': 'Kz 60.000.000',
    'location': 'Talatona',
    'type': 'sell',
    'image': 'https://images.unsplash.com/photo-1600596542815-ffad4c1539a9?w=400&q=80',
  },
];

class MapScreen extends ConsumerStatefulWidget {
  const MapScreen({super.key});

  @override
  ConsumerState<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends ConsumerState<MapScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: DraggableScrollableSheet(
        initialChildSize: 0.5,
        minChildSize: 0.08,
        maxChildSize: 1.0,
        expand: true,
        builder: (context, scrollController) {
          return Stack(
            children: [
              // ── MAPA ocupa tela toda por baixo ──────────────
              Positioned.fill(
                child: _buildMap(),
              ),

              // ── SHEET branco vem de baixo ───────────────────
              Align(
                alignment: Alignment.bottomCenter,
                child: DraggableScrollableSheet(
                  initialChildSize: 0.5,
                  minChildSize: 0.08,
                  maxChildSize: 1.0,
                  expand: false,
                  builder: (ctx, ctrl) => Container(
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                      boxShadow: [
                        BoxShadow(color: Colors.black26, blurRadius: 20, offset: Offset(0, -4)),
                      ],
                    ),
                    child: Column(
                      children: [
                        // Handle
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          child: Container(
                            width: 40, height: 4,
                            decoration: BoxDecoration(
                              color: const Color(0xFFCCCCCC),
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                        ),
                        // Cabeçalho
                        Padding(
                          padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                          child: Row(
                            children: [
                              const Text('Imóveis na área',
                                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                              const Spacer(),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: AppTheme.primary.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text('${_mockItems.length} imóveis',
                                    style: TextStyle(
                                        color: AppTheme.primary,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600)),
                              ),
                            ],
                          ),
                        ),
                        // Grid
                        Expanded(
                          child: GridView.builder(
                            controller: ctrl,
                            padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              crossAxisSpacing: 10,
                              mainAxisSpacing: 10,
                              childAspectRatio: 0.85,
                            ),
                            itemCount: _mockItems.length,
                            itemBuilder: (c, i) => _card(_mockItems[i]),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // ── Título no topo ──────────────────────────────
              Positioned(
                top: MediaQuery.of(context).padding.top + 12,
                left: 16,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.15), blurRadius: 8)],
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.location_on, color: AppTheme.primary, size: 16),
                      const SizedBox(width: 4),
                      const Text('Luanda, Angola',
                          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildMap() {
    return Container(
      color: const Color(0xFFEAE6DC),
      child: Stack(
        children: [
          // Oceano
          Positioned(left: 0, top: 0, bottom: 0,
              child: Container(width: 55, color: const Color(0xFFB8D4E8).withOpacity(0.85))),
          // Estradas horizontais
          Positioned(left: 55, right: 0, top: 100,
              child: Container(height: 9, color: const Color(0xFFD4C9A8))),
          Positioned(left: 55, right: 0, top: 180,
              child: Container(height: 7, color: const Color(0xFFD4C9A8).withOpacity(0.8))),
          Positioned(left: 55, right: 0, top: 260,
              child: Container(height: 6, color: const Color(0xFFD4C9A8).withOpacity(0.7))),
          Positioned(left: 55, right: 0, top: 340,
              child: Container(height: 5, color: const Color(0xFFD4C9A8).withOpacity(0.6))),
          // Estradas verticais
          Positioned(left: 140, top: 0, bottom: 0,
              child: Container(width: 7, color: const Color(0xFFD4C9A8))),
          Positioned(left: 240, top: 0, bottom: 0,
              child: Container(width: 6, color: const Color(0xFFD4C9A8).withOpacity(0.8))),
          Positioned(left: 340, top: 0, bottom: 0,
              child: Container(width: 5, color: const Color(0xFFD4C9A8).withOpacity(0.7))),
          // Bairros
          const Positioned(top: 70, left: 65,
              child: Text('Luanda', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF555555)))),
          const Positioned(top: 55, right: 50,
              child: Text('Viana', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF555555)))),
          const Positioned(top: 290, left: 65,
              child: Text('Benfica', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF555555)))),
          const Positioned(top: 330, right: 50,
              child: Text('Talatona', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF555555)))),
          // Pins
          _pin(top: 90, left: 100),
          _pin(top: 120, left: 190),
          _pin(top: 75, right: 110),
          _pin(top: 195, left: 85),
          _pin(top: 220, left: 160),
          _pin(top: 170, right: 95),
          _pin(top: 300, right: 120),
          // Ponto azul
          Positioned(
            top: 175, left: 245,
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

  Widget _card(Map<String, String> item) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 8)],
        border: Border.all(color: const Color(0xFFEEEEEE)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(14)),
              child: CachedNetworkImage(
                imageUrl: item['image']!,
                width: double.infinity,
                fit: BoxFit.cover,
                errorWidget: (_, __, ___) => Container(
                  color: const Color(0xFFE0E0E0),
                  child: const Icon(Icons.home, size: 36, color: Colors.grey),
                ),
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
                Row(children: [
                  Icon(Icons.location_on, size: 11, color: AppTheme.primary),
                  const SizedBox(width: 2),
                  Text(item['location']!,
                      style: const TextStyle(color: Color(0xFF888888), fontSize: 11)),
                ]),
                const SizedBox(height: 3),
                Text(item['price']!,
                    style: TextStyle(color: AppTheme.primary, fontWeight: FontWeight.bold, fontSize: 12)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
