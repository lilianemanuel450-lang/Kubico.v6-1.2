import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_theme.dart';
import '../../domain/entities/property.dart';
import '../providers/property_provider.dart';

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
      backgroundColor: const Color(0xFFF5F5F5),
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(child: _buildHeader()),
            SliverToBoxAdapter(child: _buildSearchBar()),
            SliverToBoxAdapter(child: _buildMap()),
            SliverToBoxAdapter(child: _buildTabs()),
            propertiesAsync.when(
              data: (list) {
                final type = _selectedTab == 0 ? 'rent' : 'sell';
                final filtered = list.where((p) => p.type == type).toList();
                if (filtered.isEmpty) return _buildMockList();
                return _buildRealList(filtered);
              },
              loading: () => _buildMockList(),
              error: (_, __) => _buildMockList(),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 100)),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppTheme.primary,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.home, color: Colors.white, size: 22),
          ),
          const SizedBox(width: 8),
          Text('Kubico',
              style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primary)),
          const Spacer(),
          GestureDetector(
            onTap: () => context.push('/publish'),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
              decoration: BoxDecoration(
                color: AppTheme.primary,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Row(
                children: [
                  Icon(Icons.add, color: Colors.white, size: 16),
                  SizedBox(width: 4),
                  Text('Publicar',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.w600)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Encontre sua casa ideal em Angola',
              style: TextStyle(color: Color(0xFF888888), fontSize: 13)),
          const SizedBox(height: 10),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFFE0E0E0)),
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
                    child: Text('Filtros >',
                        style: TextStyle(
                            color: AppTheme.primary,
                            fontSize: 13,
                            fontWeight: FontWeight.w600)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMap() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      height: 200,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: const Color(0xFFEAE6DC),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 8,
              offset: const Offset(0, 2))
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          children: [
            Container(color: const Color(0xFFEAE6DC)),
            Positioned(
                left: 0, top: 0, bottom: 0,
                child: Container(width: 35, color: const Color(0xFFB8D4E8).withOpacity(0.7))),
            Positioned(left: 35, right: 0, top: 70,
                child: Container(height: 7, color: const Color(0xFFD4C9A8).withOpacity(0.8))),
            Positioned(left: 35, right: 0, top: 110,
                child: Container(height: 5, color: const Color(0xFFD4C9A8).withOpacity(0.6))),
            Positioned(left: 35, right: 0, top: 150,
                child: Container(height: 4, color: const Color(0xFFD4C9A8).withOpacity(0.5))),
            Positioned(left: 110, top: 0, bottom: 0,
                child: Container(width: 6, color: const Color(0xFFD4C9A8).withOpacity(0.6))),
            Positioned(left: 200, top: 0, bottom: 0,
                child: Container(width: 4, color: const Color(0xFFD4C9A8).withOpacity(0.5))),
            Positioned(left: 290, top: 0, bottom: 0,
                child: Container(width: 4, color: const Color(0xFFD4C9A8).withOpacity(0.4))),
            const Positioned(top: 18, left: 55,
                child: Text('Luanda', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF555555)))),
            const Positioned(top: 25, right: 35,
                child: Text('Viana', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF555555)))),
            const Positioned(bottom: 45, left: 55,
                child: Text('Benfica', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF555555)))),
            const Positioned(bottom: 25, right: 45,
                child: Text('Talatona', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF555555)))),
            _pin(top: 30, left: 70),
            _pin(top: 55, left: 140),
            _pin(top: 25, right: 90),
            _pin(bottom: 65, left: 90),
            _pin(bottom: 55, right: 70),
            _pin(top: 85, left: 55),
            Positioned(
              top: 82, left: 175,
              child: Container(
                width: 18, height: 18,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFF2196F3),
                  border: Border.all(color: Colors.white, width: 2.5),
                  boxShadow: [BoxShadow(color: Colors.blue.withOpacity(0.4), blurRadius: 8, spreadRadius: 3)],
                ),
              ),
            ),
            Positioned(
              bottom: 10, right: 10,
              child: Container(
                width: 34, height: 34,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.15), blurRadius: 4)],
                ),
                child: const Icon(Icons.my_location, size: 18, color: Color(0xFF555555)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _pin({double? top, double? bottom, double? left, double? right}) {
    return Positioned(
      top: top, bottom: bottom, left: left, right: right,
      child: Container(
        width: 28, height: 28,
        decoration: BoxDecoration(
          color: AppTheme.primary,
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white, width: 2),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.25), blurRadius: 4)],
        ),
        child: const Icon(Icons.home, color: Colors.white, size: 15),
      ),
    );
  }

  Widget _buildTabs() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
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
    );
  }

  Widget _tab(String label, int index) {
    final selected = _selectedTab == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedTab = index),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 11),
        decoration: BoxDecoration(
          color: selected ? AppTheme.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: selected ? Colors.white : const Color(0xFF888888),
            fontWeight: FontWeight.w600,
            fontSize: 15,
          ),
        ),
      ),
    );
  }

  SliverGrid _buildMockList() {
    final type = _selectedTab == 0 ? 'rent' : 'sell';
    final items = _mockItems.where((m) => m['type'] == type).toList();
    return SliverGrid(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 0.85,
      ),
      delegate: SliverChildBuilderDelegate(
        (context, i) => Padding(
          padding: EdgeInsets.only(
            left: i % 2 == 0 ? 16 : 0,
            right: i % 2 == 1 ? 16 : 0,
          ),
          child: _mockCard(items[i]),
        ),
        childCount: items.length,
      ),
    );
  }

  SliverGrid _buildRealList(List<Property> properties) {
    return SliverGrid(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 0.85,
      ),
      delegate: SliverChildBuilderDelegate(
        (context, i) => Padding(
          padding: EdgeInsets.only(
            left: i % 2 == 0 ? 16 : 0,
            right: i % 2 == 1 ? 16 : 0,
          ),
          child: _realCard(properties[i]),
        ),
        childCount: properties.length,
      ),
    );
  }

  Widget _mockCard(Map<String, String> item) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 10, offset: const Offset(0, 2))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            child: CachedNetworkImage(
              imageUrl: item['image']!,
              height: 120,
              width: double.infinity,
              fit: BoxFit.cover,
              errorWidget: (_, __, ___) => Container(
                height: 120,
                color: const Color(0xFFE0E0E0),
                child: const Icon(Icons.home, size: 48, color: Colors.grey),
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
                const SizedBox(height: 3),
                Row(children: [
                  Icon(Icons.location_on, size: 11, color: AppTheme.primary),
                  const SizedBox(width: 2),
                  Expanded(child: Text(item['location']!,
                      style: const TextStyle(color: Color(0xFF888888), fontSize: 11),
                      maxLines: 1, overflow: TextOverflow.ellipsis)),
                ]),
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
    return GestureDetector(
      onTap: () => context.push('/property/${property.id}', extra: property),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 10, offset: const Offset(0, 2))
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              child: CachedNetworkImage(
                imageUrl: property.mainImage,
                height: 120,
                width: double.infinity,
                fit: BoxFit.cover,
                errorWidget: (_, __, ___) => Container(
                  height: 120,
                  color: const Color(0xFFE0E0E0),
                  child: const Icon(Icons.home, size: 48, color: Colors.grey),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(property.title,
                            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF1A1A1A)),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis),
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            Icon(Icons.location_on, size: 13, color: AppTheme.primary),
                            const SizedBox(width: 2),
                            Text(property.neighborhood,
                                style: const TextStyle(color: Color(0xFF888888), fontSize: 12)),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppTheme.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(property.formattedPrice,
                        style: TextStyle(color: AppTheme.primary, fontWeight: FontWeight.bold, fontSize: 12)),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
