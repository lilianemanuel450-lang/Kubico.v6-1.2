import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

import '../../../../core/theme/app_theme.dart';
import '../../../favorites/presentation/providers/favorites_provider.dart';
import '../../domain/entities/property.dart';

class PropertyDetailScreen extends ConsumerStatefulWidget {
  final String propertyId;
  final Property? property;

  const PropertyDetailScreen({
    super.key,
    required this.propertyId,
    this.property,
  });

  @override
  ConsumerState<PropertyDetailScreen> createState() => _PropertyDetailScreenState();
}

class _PropertyDetailScreenState extends ConsumerState<PropertyDetailScreen> {
  List<LatLng> _routePoints = [];
  bool _loadingRoute = false;
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;

  @override
  Widget build(BuildContext context) {
    final propToShow = widget.property;
    if (propToShow == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final isFav = ref.watch(favoritesNotifierProvider).valueOrNull?.contains(propToShow.id) ?? false;

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            backgroundColor: AppTheme.surface,
            leading: GestureDetector(
              onTap: () => context.pop(),
              child: Container(
                margin: const EdgeInsets.all(8),
                decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                child: const Icon(Icons.arrow_back, color: AppTheme.textPrimary),
              ),
            ),
            actions: [
              GestureDetector(
                onTap: () => ref.read(favoritesNotifierProvider.notifier).toggle(propToShow.id),
                child: Container(
                  margin: const EdgeInsets.all(8),
                  padding: const EdgeInsets.all(6),
                  decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                  child: Icon(isFav ? Icons.favorite : Icons.favorite_border, color: isFav ? Colors.red : AppTheme.textSecondary),
                ),
              ),
              GestureDetector(
                onTap: () => Share.share('Ver imóvel no Kubico: ${propToShow.title} - ${propToShow.formattedPrice}'),
                child: Container(
                  margin: const EdgeInsets.all(8),
                  padding: const EdgeInsets.all(6),
                  decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                  child: const Icon(Icons.share_outlined, color: AppTheme.textSecondary),
                ),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: propToShow.images.isNotEmpty
                  ? PageView.builder(
                      itemCount: propToShow.images.length,
                      itemBuilder: (_, i) => CachedNetworkImage(
                        imageUrl: propToShow.images[i],
                        fit: BoxFit.cover,
                        errorWidget: (_, __, ___) => Container(color: AppTheme.border, child: const Icon(Icons.image_not_supported)),
                      ),
                    )
                  : Container(color: AppTheme.border),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: propToShow.type == 'rent' ? AppTheme.primary : AppTheme.accent,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(propToShow.typeLabel, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600)),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(color: AppTheme.primary.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                        child: Text(propToShow.propertyTypeLabel, style: TextStyle(color: AppTheme.primary, fontSize: 12, fontWeight: FontWeight.w600)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(propToShow.title, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppTheme.textPrimary)),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.location_on_outlined, size: 16, color: AppTheme.textSecondary),
                      const SizedBox(width: 4),
                      Expanded(child: Text(propToShow.address, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 14))),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(propToShow.formattedPrice, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: AppTheme.primary)),
                  const SizedBox(height: 20),
                  if (propToShow.bedrooms > 0 || propToShow.bathrooms > 0 || propToShow.area > 0)
                    _buildSpecs(propToShow),
                  const SizedBox(height: 20),
                  const Text('Descrição', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: AppTheme.textPrimary)),
                  const SizedBox(height: 8),
                  Text(propToShow.description, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 15, height: 1.5)),
                  const SizedBox(height: 24),

                  // ── Mapa ──────────────────────────────────
                  const Text('Localização', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: AppTheme.textPrimary)),
                  const SizedBox(height: 12),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: SizedBox(
                      height: 220,
                      child: FlutterMap(
                        options: MapOptions(
                          initialCenter: LatLng(propToShow.latitude, propToShow.longitude),
                          initialZoom: 15,
                        ),
                        children: [
                          TileLayer(
                            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                            userAgentPackageName: 'com.kubico.app',
                          ),
                          if (_routePoints.isNotEmpty)
                            PolylineLayer(
                              polylines: [
                                Polyline(points: _routePoints, strokeWidth: 4, color: AppTheme.primary),
                              ],
                            ),
                          MarkerLayer(
                            markers: [
                              Marker(
                                point: LatLng(propToShow.latitude, propToShow.longitude),
                                width: 40, height: 40,
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: AppTheme.primary,
                                    shape: BoxShape.circle,
                                    border: Border.all(color: Colors.white, width: 2.5),
                                  ),
                                  child: const Icon(Icons.home, color: Colors.white, size: 20),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // ── Marcar Visita ──────────────────────────
                  const Text('Marcar Visita', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: AppTheme.textPrimary)),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFEEEEEE)),
                      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8)],
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: GestureDetector(
                                onTap: () => _pickDate(context),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                                  decoration: BoxDecoration(border: Border.all(color: const Color(0xFFDDDDDD)), borderRadius: BorderRadius.circular(10)),
                                  child: Row(
                                    children: [
                                      Icon(Icons.calendar_today, size: 16, color: AppTheme.primary),
                                      const SizedBox(width: 8),
                                      Text(
                                        _selectedDate == null ? 'Data' : '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}',
                                        style: TextStyle(color: _selectedDate == null ? AppTheme.textSecondary : AppTheme.textPrimary, fontSize: 14),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: GestureDetector(
                                onTap: () => _pickTime(context),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                                  decoration: BoxDecoration(border: Border.all(color: const Color(0xFFDDDDDD)), borderRadius: BorderRadius.circular(10)),
                                  child: Row(
                                    children: [
                                      Icon(Icons.access_time, size: 16, color: AppTheme.primary),
                                      const SizedBox(width: 8),
                                      Text(
                                        _selectedTime == null ? 'Hora' : _selectedTime!.format(context),
                                        style: TextStyle(color: _selectedTime == null ? AppTheme.textSecondary : AppTheme.textPrimary, fontSize: 14),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: (_selectedDate != null && _selectedTime != null) ? () => _confirmarVisita(propToShow) : null,
                            icon: _loadingRoute
                                ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                                : const Icon(Icons.check_circle_outline),
                            label: const Text('Confirmar Visita'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.primary,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildContactBar(propToShow),
    );
  }

  Future<void> _getRoute(Property p) async {
    setState(() => _loadingRoute = true);
    try {
      const startLat = -8.8390;
      const startLng = 13.2894;
      final url = Uri.parse(
        'https://router.project-osrm.org/route/v1/driving/$startLng,$startLat;${p.longitude},${p.latitude}?overview=full&geometries=geojson',
      );
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final coords = data['routes'][0]['geometry']['coordinates'] as List;
        setState(() {
          _routePoints = coords.map((c) => LatLng(c[1] as double, c[0] as double)).toList();
        });
      }
    } catch (_) {}
    setState(() => _loadingRoute = false);
  }

  Future<void> _pickDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 30)),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(colorScheme: ColorScheme.light(primary: AppTheme.primary)),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  Future<void> _pickTime(BuildContext context) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: const TimeOfDay(hour: 10, minute: 0),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(colorScheme: ColorScheme.light(primary: AppTheme.primary)),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _selectedTime = picked);
  }

  void _confirmarVisita(Property p) {
    // Rota automática ao confirmar visita
    _getRoute(p);
    final date = '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}';
    final time = _selectedTime!.format(context);
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.check_circle, color: AppTheme.primary),
            const SizedBox(width: 8),
            const Text('Visita Marcada!'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Imóvel: ${p.title}', style: const TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Text('Data: $date às $time'),
            const SizedBox(height: 8),
            Text('Contacto: ${p.ownerPhone}', style: TextStyle(color: AppTheme.primary, fontWeight: FontWeight.w600)),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(Icons.directions, color: AppTheme.primary, size: 16),
                const SizedBox(width: 4),
                const Text('Rota a ser calculada...', style: TextStyle(color: Colors.grey, fontSize: 13)),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Fechar')),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.pop(context);
              _whatsapp(p.ownerPhone, p.title, date, time);
            },
            icon: const Icon(Icons.message, size: 16),
            label: const Text('Confirmar via WhatsApp'),
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF25D366), foregroundColor: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _buildSpecs(Property p) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.primary.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.primary.withOpacity(0.1)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          if (p.bedrooms > 0) _specItem(Icons.bed_outlined, '${p.bedrooms}', 'Quartos'),
          if (p.bathrooms > 0) _specItem(Icons.bathtub_outlined, '${p.bathrooms}', 'WC'),
          if (p.area > 0) _specItem(Icons.square_foot, '${p.area.toStringAsFixed(0)}m²', 'Área'),
        ],
      ),
    );
  }

  Widget _specItem(IconData icon, String value, String label) {
    return Column(
      children: [
        Icon(icon, color: AppTheme.primary, size: 24),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppTheme.textPrimary)),
        Text(label, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
      ],
    );
  }

  Widget _buildContactBar(Property p) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
      decoration: const BoxDecoration(
        color: AppTheme.surface,
        border: Border(top: BorderSide(color: AppTheme.border)),
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton.icon(
              onPressed: () => _call(p.ownerPhone),
              icon: const Icon(Icons.phone_outlined),
              label: const Text('Ligar'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppTheme.primary,
                side: const BorderSide(color: AppTheme.primary),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 2,
            child: ElevatedButton.icon(
              onPressed: () => _whatsapp(p.ownerPhone, p.title, '', ''),
              icon: const Icon(Icons.message_outlined),
              label: const Text('WhatsApp'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF25D366),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
        ],
      ),
    );
  
cd ~/kubico && git add -A && git commit -m "feat: detalhe com rota automática após visita" && git push origin main --force
cd ~/kubico && git add -A && git commit -m "feat: detalhe com rota automatica" && git push origin main --force
cd ~/kubico && git add -A && git commit -m "feat: detalhe com rota automatica" && git push origin main --force
mkdir -p ~/kubico/lib/features/admin/presentation/screens && cat > ~/kubico/lib/features/admin/presentation/screens/admin_screen.dart << 'EOF'
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

class AdminScreen extends ConsumerStatefulWidget {
  const AdminScreen({super.key});

  @override
  ConsumerState<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends ConsumerState<AdminScreen> {
  final _passwordController = TextEditingController();
  bool _authenticated = false;
  bool _loading = false;
  List<Map<String, dynamic>> _properties = [];
  List<Map<String, dynamic>> _reservations = [];

  @override
  void dispose() {
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    setState(() => _loading = true);
    try {
      final user = ref.read(authNotifierProvider).user;
      final result = await Supabase.instance.client
          .from('profiles')
          .select()
          .eq('phone', user?.phone ?? '')
          .eq('is_admin', true)
          .eq('admin_password', _passwordController.text.trim())
          .maybeSingle();

      if (result != null) {
        setState(() => _authenticated = true);
        await _loadData();
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Senha incorrecta!'), backgroundColor: Colors.red),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro: $e'), backgroundColor: Colors.red),
        );
      }
    }
    setState(() => _loading = false);
  }

  Future<void> _loadData() async {
    final props = await Supabase.instance.client.from('properties').select().order('created_at', ascending: false);
    final res = await Supabase.instance.client.from('reservations').select().order('created_at', ascending: false);
    setState(() {
      _properties = List<Map<String, dynamic>>.from(props);
      _reservations = List<Map<String, dynamic>>.from(res);
    });
  }

  Future<void> _deleteProperty(String id) async {
    await Supabase.instance.client.from('properties').delete().eq('id', id);
    await _loadData();
  }

  @override
  Widget build(BuildContext context) {
    if (!_authenticated) return _buildLoginPage();
    return _buildAdminPage();
  }

  Widget _buildLoginPage() {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 80, height: 80,
                decoration: BoxDecoration(color: AppTheme.primary, borderRadius: BorderRadius.circular(20)),
                child: const Icon(Icons.admin_panel_settings, color: Colors.white, size: 44),
              ),
              const SizedBox(height: 24),
              const Text('Painel Admin', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              const Text('Kubico', style: TextStyle(fontSize: 16, color: Colors.grey)),
              const SizedBox(height: 40),
              TextField(
                controller: _passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'Senha de administrador',
                  prefixIcon: Icon(Icons.lock_outline, color: AppTheme.primary),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: AppTheme.primary, width: 2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _loading ? null : _login,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: _loading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('Entrar', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                ),
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () => context.go('/'),
                child: const Text('Voltar ao app'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAdminPage() {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F5F5),
        appBar: AppBar(
          backgroundColor: AppTheme.primary,
          foregroundColor: Colors.white,
          title: const Text('Painel Admin', style: TextStyle(fontWeight: FontWeight.bold)),
          actions: [
            IconButton(icon: const Icon(Icons.refresh), onPressed: _loadData),
            IconButton(icon: const Icon(Icons.logout), onPressed: () => setState(() => _authenticated = false)),
          ],
          bottom: const TabBar(
            indicatorColor: Colors.white,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            tabs: [
              Tab(icon: Icon(Icons.home), text: 'Imóveis'),
              Tab(icon: Icon(Icons.calendar_today), text: 'Reservas'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildPropertiesTab(),
            _buildReservationsTab(),
          ],
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () => context.push('/publish'),
          backgroundColor: AppTheme.primary,
          icon: const Icon(Icons.add, color: Colors.white),
          label: const Text('Novo Imóvel', style: TextStyle(color: Colors.white)),
        ),
      ),
    );
  }

  Widget _buildPropertiesTab() {
    if (_properties.isEmpty) {
      return const Center(child: Text('Nenhum imóvel publicado'));
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _properties.length,
      itemBuilder: (_, i) {
        final p = _properties[i];
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 8)],
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.all(12),
            leading: Container(
              width: 50, height: 50,
              decoration: BoxDecoration(color: AppTheme.primary.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
              child: Icon(Icons.home, color: AppTheme.primary),
            ),
            title: Text(p['title'] ?? '', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(p['neighborhood'] ?? '', style: const TextStyle(fontSize: 12)),
                Text('${p['price']} Kz', style: TextStyle(color: AppTheme.primary, fontWeight: FontWeight.w600, fontSize: 12)),
              ],
            ),
            trailing: IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.red),
              onPressed: () => _confirmDelete(p['id']),
            ),
          ),
        );
      },
    );
  }

  Widget _buildReservationsTab() {
    if (_reservations.isEmpty) {
      return const Center(child: Text('Nenhuma reserva ainda'));
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _reservations.length,
      itemBuilder: (_, i) {
        final r = _reservations[i];
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 8)],
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.all(12),
            leading: Container(
              width: 50, height: 50,
              decoration: BoxDecoration(color: Colors.orange.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
              child: const Icon(Icons.calendar_today, color: Colors.orange),
            ),
            title: Text('Visita: ${r['visit_date']} às ${r['visit_time']}',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
            subtitle: Text('Tel: ${r['user_phone']}', style: const TextStyle(fontSize: 12)),
            trailing: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: r['status'] == 'pending' ? Colors.orange.withOpacity(0.1) : Colors.green.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                r['status'] == 'pending' ? 'Pendente' : 'Confirmada',
                style: TextStyle(
                  color: r['status'] == 'pending' ? Colors.orange : Colors.green,
                  fontSize: 11, fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  void _confirmDelete(String id) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Apagar imóvel?'),
        content: const Text('Esta acção não pode ser desfeita.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
          ElevatedButton(
            onPressed: () { Navigator.pop(context); _deleteProperty(id); },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
            child: const Text('Apagar'),
          ),
        ],
      ),
    );
  }
}
