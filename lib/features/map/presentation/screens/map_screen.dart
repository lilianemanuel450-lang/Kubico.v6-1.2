import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';
import '../../../../core/theme/app_theme.dart';

const _mockItems = [
  {'title': 'T3 em Talatona', 'price': 'Kz 250.000/mês', 'location': 'Talatona', 'image': 'https://picsum.photos/id/164/400/300', 'lat': -8.9167, 'lng': 13.1833},
  {'title': 'Vivenda em Benfica', 'price': 'Kz 80.000.000', 'location': 'Benfica', 'image': 'https://picsum.photos/id/188/400/300', 'lat': -8.8667, 'lng': 13.2333},
  {'title': 'Apto T2 Miramar', 'price': 'Kz 150.000/mês', 'location': 'Miramar', 'image': 'https://picsum.photos/id/42/400/300', 'lat': -8.8100, 'lng': 13.2300},
  {'title': 'Villa T4 Camama', 'price': 'Kz 45.000.000', 'location': 'Camama', 'image': 'https://picsum.photos/id/106/400/300', 'lat': -8.9000, 'lng': 13.2000},
  {'title': 'T3 em Viana', 'price': 'Kz 180.000/mês', 'location': 'Viana', 'image': 'https://picsum.photos/id/56/400/300', 'lat': -8.9035, 'lng': 13.3740},
  {'title': 'T4 Kilamba', 'price': 'Kz 35.000.000', 'location': 'Kilamba', 'image': 'https://picsum.photos/id/96/400/300', 'lat': -8.9900, 'lng': 13.2700},
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
      body: Stack(
        children: [
          FlutterMap(
            options: const MapOptions(
              initialCenter: LatLng(-8.8390, 13.2894),
              initialZoom: 11.5,
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
                    width: 40,
                    height: 40,
                    child: Container(
                      decoration: BoxDecoration(
                        color: AppTheme.primary,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2.5),
                        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 6)],
                      ),
                      child: const Icon(Icons.home, color: Colors.white, size: 20),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
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
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      child: Container(
                        width: 40, height: 4,
                        decoration: BoxDecoration(color: const Color(0xFFCCCCCC), borderRadius: BorderRadius.circular(2)),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                      child: Row(
                        children: [
                          const Text('Imóveis na área', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                          const Spacer(),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(color: AppTheme.primary.withOpacity(0.1), borderRadius: BorderRadius.circular(20)),
                            child: Text('${_mockItems.length} imóveis', style: TextStyle(color: AppTheme.primary, fontSize: 12, fontWeight: FontWeight.w600)),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: GridView.builder(
                        controller: scrollController,
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2, crossAxisSpacing: 10, mainAxisSpacing: 10, childAspectRatio: 0.85,
                        ),
                        itemCount: _mockItems.length,
                        itemBuilder: (context, i) => _card(_mockItems[i]),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
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
                  const Text('Luanda, Angola', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _card(Map<String, Object> item) {
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
                Text(item['title'] as String, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF1A1A1A)), maxLines: 1, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 2),
                Row(children: [
                  Icon(Icons.location_on, size: 11, color: AppTheme.primary),
                  const SizedBox(width: 2),
                  Text(item['location'] as String, style: const TextStyle(color: Color(0xFF888888), fontSize: 11)),
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
}
