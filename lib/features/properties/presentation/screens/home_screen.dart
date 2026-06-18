import 'dart:ui' as ui;
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';

import '../../../../core/theme/app_theme.dart';
import '../../domain/entities/property.dart';
import '../providers/property_provider.dart';

const _mockItems = [
  {'title': 'T3 em Talatona', 'price': 'Kz 250.000/mês', 'location': 'Talatona', 'type': 'rent', 'image': 'https://picsum.photos/id/164/400/300', 'lat': -8.9167, 'lng': 13.1833},
  {'title': 'Vivenda em Benfica', 'price': 'Kz 80.000.000', 'location': 'Benfica', 'type': 'sell', 'image': 'https://picsum.photos/id/188/400/300', 'lat': -8.8667, 'lng': 13.2333},
  {'title': 'Apto T2 Miramar', 'price': 'Kz 150.000/mês', 'location': 'Miramar', 'type': 'rent', 'image': 'https://picsum.photos/id/42/400/300', 'lat': -8.8100, 'lng': 13.2300},
  {'title': 'Villa T4 Camama', 'price': 'Kz 45.000.000', 'location': 'Camama', 'type': 'sell', 'image': 'https://picsum.photos/id/106/400/300', 'lat': -8.9000, 'lng': 13.2000},
  {'title': 'T3 em Viana', 'price': 'Kz 180.000/mês', 'location': 'Viana', 'type': 'rent', 'image': 'https://picsum.photos/id/56/400/300', 'lat': -8.9035, 'lng': 13.3740},
  {'title': 'T4 Kilamba', 'price': 'Kz 35.000.000', 'location': 'Kilamba', 'type': 'sell', 'image': 'https://picsum.photos/id/96/400/300', 'lat': -8.9900, 'lng': 13.2700},
];

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int _selectedTab = 0;

  @override
  Widget build(BuildContext context) {
    final propertiesAsync = ref.watch(propertyListNotifierProvider);

    return Scaffold(
      body: Stack(
        children: [
          // ── Mapa OpenStreetMap em cima ─────────────────────
          Positioned.fill(
            child: FlutterMap(
              options: const MapOptions(
                initialCenter: LatLng(-8.9000, 13.2500),
                initialZoom: 13.0,
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.kubico.app',
                ),
                MarkerLayer(
                  markers: _mockItems.map((item) {
                    return Marker(
                      point: LatLng(item['lat'] as double, item['lng'] as double),
                      width: 44,
                      height: 54,
                      child: CustomPaint(
                        painter: _PinPainter(),
                        child: const Padding(
                          padding: EdgeInsets.only(bottom: 14),
                          child: Icon(Icons.home, color: Colors.white, size: 18),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),

          // ── Header no topo ────────────────────────────────
          Positioned(
            top: MediaQuery.of(context).padding.top + 8,
            left: 16,
            right: 16,
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.15), blurRadius: 8)],
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 28, height: 28,
                        decoration: BoxDecoration(color: AppTheme.primary, borderRadius: BorderRadius.circular(7)),
                        child: const Icon(Icons.home, color: Colors.white, size: 18),
                      ),
                      const SizedBox(width: 8),
                      Text('Kubico', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.primary)),
                    ],
                  ),
                ),
                const Spacer(),
                GestureDetector(
                  onTap: () => context.push('/publish'),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppTheme.primary,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 6)],
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.add, color: Colors.white, size: 16),
                        SizedBox(width: 4),
                        Text('Publicar', style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ── Barra de pesquisa ─────────────────────────────
          Positioned(
            top: MediaQuery.of(context).padding.top + 65,
            left: 16,
            right: 16,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 8)],
              ),
              child: Row(
                children: [
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 12),
                    child: Icon(Icons.search, color: Color(0xFF888888), size: 20),
                  ),
                  const Expanded(
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: 'Pesquisar localização...',
                        hintStyle: TextStyle(color: Color(0xFFAAAAAA), fontSize: 14),
                        border: InputBorder.none,
                        isDense: true,
                        contentPadding: EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () => context.push('/search'),
                    child: Container(
                      margin: const EdgeInsets.all(6),
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        border: Border.all(color: AppTheme.primary),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text('Filtros >', style: TextStyle(color: AppTheme.primary, fontSize: 13, fontWeight: FontWeight.w600)),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ── Sheet arrastável com casas ─────────────────────
          DraggableScrollableSheet(
            initialChildSize: 0.42,
            minChildSize: 0.08,
            maxChildSize: 1.0,
            expand: true,
            builder: (context, scrollController) {
              return Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                  boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 16, offset: Offset(0, -4))],
                ),
                child: Column(
                  children: [
                    // Handle
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      child: Container(
                        width: 40, height: 4,
                        decoration: BoxDecoration(color: const Color(0xFFCCCCCC), borderRadius: BorderRadius.circular(2)),
                      ),
                    ),
                    // Tabs Arrendar / Comprar
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                      child: Row(
                        children: [
                          Expanded(
                            child: Container(
                              decoration: BoxDecoration(
                                color: const Color(0xFFEEEEEE),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Row(
                                children: [
                                  Expanded(child: _tab('Arrendar', 0)),
                                  Expanded(child: _tab('Comprar', 1)),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppTheme.primary.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: propertiesAsync.when(
                              data: (list) => Text('${list.length} imóveis', style: TextStyle(color: AppTheme.primary, fontSize: 12, fontWeight: FontWeight.w600)),
                              loading: () => Text('... imóveis', style: TextStyle(color: AppTheme.primary, fontSize: 12)),
                              error: (_, __) => Text('${_mockItems.length} imóveis', style: TextStyle(color: AppTheme.primary, fontSize: 12, fontWeight: FontWeight.w600)),
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Grid casas
                    Expanded(
                      child: propertiesAsync.when(
                        data: (list) {
                          final type = _selectedTab == 0 ? 'rent' : 'sell';
                          final filtered = list.where((p) => p.type == type).toList();
                          if (filtered.isEmpty) return _buildMockGrid(scrollController);
                          return _buildRealGrid(filtered, scrollController);
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

  Widget _tab(String label, int index) {
    final selected = _selectedTab == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedTab = index),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: selected ? AppTheme.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(label, textAlign: TextAlign.center,
            style: TextStyle(color: selected ? Colors.white : const Color(0xFF888888), fontWeight: FontWeight.w600, fontSize: 14)),
      ),
    );
  }

  Widget _buildMockGrid(ScrollController scrollController) {
    final type = _selectedTab == 0 ? 'rent' : 'sell';
    final items = _mockItems.where((m) => m['type'] == type).toList();
    return GridView.builder(
      controller: scrollController,
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2, crossAxisSpacing: 10, mainAxisSpacing: 10, childAspectRatio: 0.85,
      ),
      itemCount: items.length,
      itemBuilder: (context, i) => _mockCard(items[i]),
    );
  }

  Widget _buildRealGrid(List<Property> properties, ScrollController scrollController) {
    return GridView.builder(
      controller: scrollController,
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2, crossAxisSpacing: 10, mainAxisSpacing: 10, childAspectRatio: 0.85,
      ),
      itemCount: properties.length,
      itemBuilder: (context, i) => _realCard(properties[i]),
    );
  }

  Widget _mockCard(Map<String, Object> item) {
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
                imageUrl: item['image'] as String,
                width: double.infinity,
                fit: BoxFit.cover,
                errorWidget: (_, __, ___) => Container(color: const Color(0xFFE0E0E0), child: const Icon(Icons.home, size: 36, color: Colors.grey)),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item['title'] as String, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF1A1A1A)), maxLines: 1, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 2),
                Row(children: [
                  Icon(Icons.location_on, size: 11, color: AppTheme.primary),
                  const SizedBox(width: 2),
                  Expanded(child: Text(item['location'] as String, style: const TextStyle(color: Color(0xFF888888), fontSize: 11), maxLines: 1, overflow: TextOverflow.ellipsis)),
                ]),
                const SizedBox(height: 3),
                Text(item['price'] as String, style: TextStyle(color: AppTheme.primary, fontWeight: FontWeight.bold, fontSize: 12)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _realCard(Property property) {
    return GestureDetector(
      onTap: () => context.push('/property/${property.id}', extra: property),
      child: Container(
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
                  imageUrl: property.mainImage,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorWidget: (_, __, ___) => Container(color: const Color(0xFFE0E0E0), child: const Icon(Icons.home, size: 36, color: Colors.grey)),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(property.title, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF1A1A1A)), maxLines: 1, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 2),
                  Row(children: [
                    Icon(Icons.location_on, size: 11, color: AppTheme.primary),
                    const SizedBox(width: 2),
                    Expanded(child: Text(property.neighborhood, style: const TextStyle(color: Color(0xFF888888), fontSize: 11), maxLines: 1, overflow: TextOverflow.ellipsis)),
                  ]),
                  const SizedBox(height: 3),
                  Text(property.formattedPrice, style: TextStyle(color: AppTheme.primary, fontWeight: FontWeight.bold, fontSize: 12)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PinPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = const Color(0xFF3DBE2A);
    final borderPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5;

    final path = ui.Path();
    final w = size.width;
    final h = size.height;

    path.addOval(Rect.fromCircle(center: Offset(w / 2, w / 2), radius: w / 2 - 2));
    path.moveTo(w / 2 - 8, h - 16);
    path.lineTo(w / 2, h - 2);
    path.lineTo(w / 2 + 8, h - 16);
    path.close();

    canvas.drawShadow(path, Colors.black.withOpacity(0.3), 3, false);
    canvas.drawPath(path, paint);
    canvas.drawOval(Rect.fromCircle(center: Offset(w / 2, w / 2), radius: w / 2 - 2), borderPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
