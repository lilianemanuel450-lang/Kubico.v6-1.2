import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;

import '../../../../core/theme/app_theme.dart';
import '../../../properties/presentation/providers/property_provider.dart';
import '../../../properties/presentation/widgets/property_card.dart';

const _bairros = [
  'Talatona', 'Benfica', 'Miramar', 'Viana', 'Kilamba', 'Cacuaco',
  'Cazenga', 'Maianga', 'Ingombota', 'Rangel', 'Sambizanga',
  'Morro Bento', 'Camama', 'Golf', 'Sequele', 'Futungo de Belas',
  'Hoji-ya-Henda', 'Palanca', 'Calumbo', 'Petrangol', 'Sapu',
  'Kikolo', 'Quifangondo', 'Funda', 'Mulenvos',
];

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final _controller = TextEditingController();
  List<Map<String, dynamic>> _suggestions = [];
  bool _loadingSuggestions = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  List<String> _getBairroSuggestions(String query) {
    if (query.isEmpty) return _bairros.take(8).toList();
    return _bairros
        .where((b) => b.toLowerCase().contains(query.toLowerCase()))
        .take(6)
        .toList();
  }

  Future<void> _searchNominatim(String query) async {
    if (query.length < 3) return;
    setState(() => _loadingSuggestions = true);
    try {
      final url = Uri.parse(
        'https://nominatim.openstreetmap.org/search?q=$query+Luanda+Angola&format=json&limit=5&addressdetails=1',
      );
      final response = await http.get(url, headers: {'User-Agent': 'KubicoApp/1.0'});
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as List;
        setState(() {
          _suggestions = data.map((e) => {
            'name': e['display_name'].toString().split(',').first,
            'full': e['display_name'],
            'lat': double.parse(e['lat'].toString()),
            'lng': double.parse(e['lon'].toString()),
          }).toList();
        });
      }
    } catch (_) {}
    setState(() => _loadingSuggestions = false);
  }

  @override
  Widget build(BuildContext context) {
    final searchAsync = ref.watch(propertySearchNotifierProvider);
    final bairroSuggestions = _getBairroSuggestions(_controller.text);

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: TextField(
          controller: _controller,
          autofocus: true,
          decoration: InputDecoration(
            hintText: 'Pesquisar bairro, rua, município...',
            hintStyle: const TextStyle(color: AppTheme.textSecondary),
            border: InputBorder.none,
            suffixIcon: _controller.text.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.close, color: AppTheme.textSecondary),
                    onPressed: () {
                      _controller.clear();
                      setState(() => _suggestions = []);
                      ref.read(propertySearchNotifierProvider.notifier).clear();
                    },
                  )
                : null,
          ),
          onChanged: (q) {
            setState(() {});
            ref.read(propertySearchNotifierProvider.notifier).search(q);
            _searchNominatim(q);
          },
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        backgroundColor: AppTheme.surface,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Sugestões de bairros ──────────────────────────
          if (_controller.text.isEmpty || bairroSuggestions.isNotEmpty) ...[
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: Text(
                _controller.text.isEmpty ? 'Bairros populares' : 'Bairros',
                style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textSecondary),
              ),
            ),
            SizedBox(
              height: 38,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: bairroSuggestions.length,
                itemBuilder: (_, i) => GestureDetector(
                  onTap: () {
                    _controller.text = bairroSuggestions[i];
                    ref.read(propertySearchNotifierProvider.notifier).search(bairroSuggestions[i]);
                    setState(() {});
                  },
                  child: Container(
                    margin: const EdgeInsets.only(right: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppTheme.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppTheme.primary.withOpacity(0.3)),
                    ),
                    child: Text(bairroSuggestions[i],
                        style: TextStyle(
                            color: AppTheme.primary,
                            fontSize: 13,
                            fontWeight: FontWeight.w500)),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
          ],

          // ── Sugestões do Nominatim ────────────────────────
          if (_suggestions.isNotEmpty) ...[
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
              child: Text('Localizações',
                  style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textSecondary)),
            ),
            ...(_suggestions.map((s) => ListTile(
                  leading: Icon(Icons.location_on, color: AppTheme.primary, size: 20),
                  title: Text(s['name'], style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
                  subtitle: Text(s['full'], style: const TextStyle(fontSize: 11), maxLines: 1, overflow: TextOverflow.ellipsis),
                  onTap: () {
                    _controller.text = s['name'];
                    ref.read(propertySearchNotifierProvider.notifier).search(s['name']);
                    setState(() => _suggestions = []);
                  },
                ))),
            const Divider(),
          ],

          // ── Resultados ────────────────────────────────────
          Expanded(
            child: searchAsync.when(
              data: (results) {
                if (_controller.text.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.search, size: 64, color: AppTheme.textSecondary),
                        const SizedBox(height: 16),
                        const Text('Pesquisa imóveis em Luanda',
                            style: TextStyle(color: AppTheme.textSecondary, fontSize: 16)),
                        const SizedBox(height: 8),
                        const Text('Ex: "Talatona", "T3", "piscina"',
                            style: TextStyle(color: AppTheme.textSecondary, fontSize: 13)),
                      ],
                    ),
                  );
                }
                if (results.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.home_outlined, size: 64, color: AppTheme.textSecondary),
                        const SizedBox(height: 16),
                        Text('Sem resultados para "${_controller.text}"',
                            style: const TextStyle(color: AppTheme.textSecondary, fontSize: 15)),
                      ],
                    ),
                  );
                }
                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: results.length,
                  itemBuilder: (_, i) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: PropertyCard(
                      property: results[i],
                      onTap: () => context.push('/property/${results[i].id}', extra: results[i]),
                    ),
                  ),
                );
              },
              loading: () => const Center(child: CircularProgressIndicator(color: AppTheme.primary)),
              error: (e, _) => Center(child: Text('Erro: $e')),
            ),
          ),
        ],
      ),
    );
  }
}
