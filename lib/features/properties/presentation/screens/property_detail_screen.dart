import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../../core/theme/app_theme.dart';
import '../../../favorites/presentation/providers/favorites_provider.dart';
import '../../domain/entities/property.dart';

class PropertyDetailScreen extends ConsumerStatefulWidget {
  final String propertyId;
  final Property? property;
  const PropertyDetailScreen({super.key, required this.propertyId, this.property});

  @override
  ConsumerState<PropertyDetailScreen> createState() => _PropertyDetailScreenState();
}

class _PropertyDetailScreenState extends ConsumerState<PropertyDetailScreen> {
  List<LatLng> _routePoints = [];
  bool _loadingRoute = false;
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  Position? _userPosition;
  String _routeStatus = '';

  @override
  void initState() {
    super.initState();
    _getUserLocation();
  }

  Future<void> _getUserLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) return;

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) return;
      }
      if (permission == LocationPermission.deniedForever) return;

      final position = await Geolocator.getCurrentPosition();
      setState(() => _userPosition = position);
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.property;
    if (p == null) return const Scaffold(body: Center(child: CircularProgressIndicator()));
    final isFav = ref.watch(favoritesNotifierProvider).valueOrNull?.contains(p.id) ?? false;

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: CustomScrollView(slivers: [
        SliverAppBar(
          expandedHeight: 280,
          pinned: true,
          backgroundColor: AppTheme.surface,
          leading: GestureDetector(
            onTap: () => context.pop(),
            child: Container(margin: const EdgeInsets.all(8), decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle), child: const Icon(Icons.arrow_back, color: AppTheme.textPrimary)),
          ),
          actions: [
            GestureDetector(
              onTap: () => ref.read(favoritesNotifierProvider.notifier).toggle(p.id),
              child: Container(margin: const EdgeInsets.all(8), padding: const EdgeInsets.all(6), decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle), child: Icon(isFav ? Icons.favorite : Icons.favorite_border, color: isFav ? Colors.red : AppTheme.textSecondary)),
            ),
            GestureDetector(
              onTap: () => Share.share('Ver imovel no Kubico: ' + p.title),
              child: Container(margin: const EdgeInsets.all(8), padding: const EdgeInsets.all(6), decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle), child: const Icon(Icons.share_outlined, color: AppTheme.textSecondary)),
            ),
          ],
          flexibleSpace: FlexibleSpaceBar(
            background: p.images.isNotEmpty
                ? CachedNetworkImage(imageUrl: p.images[0], fit: BoxFit.cover, errorWidget: (_, __, ___) => Container(color: AppTheme.border))
                : Container(color: AppTheme.border),
          ),
        ),

        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4), decoration: BoxDecoration(color: p.type == 'rent' ? AppTheme.primary : AppTheme.accent, borderRadius: BorderRadius.circular(8)), child: Text(p.typeLabel, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600))),
                const SizedBox(width: 8),
                Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4), decoration: BoxDecoration(color: AppTheme.primary.withOpacity(0.1), borderRadius: BorderRadius.circular(8)), child: Text(p.propertyTypeLabel, style: TextStyle(color: AppTheme.primary, fontSize: 12, fontWeight: FontWeight.w600))),
              ]),
              const SizedBox(height: 12),
              Text(p.title, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppTheme.textPrimary)),
              const SizedBox(height: 8),
              Row(children: [const Icon(Icons.location_on_outlined, size: 16, color: AppTheme.textSecondary), const SizedBox(width: 4), Expanded(child: Text(p.address, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 14)))]),
              const SizedBox(height: 16),
              Text(p.formattedPrice, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: AppTheme.primary)),
              const SizedBox(height: 20),
              if (p.bedrooms > 0 || p.bathrooms > 0 || p.area > 0)
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(color: AppTheme.primary.withOpacity(0.05), borderRadius: BorderRadius.circular(12), border: Border.all(color: AppTheme.primary.withOpacity(0.1))),
                  child: Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
                    if (p.bedrooms > 0) Column(children: [Icon(Icons.bed_outlined, color: AppTheme.primary, size: 24), const SizedBox(height: 4), Text('\${p.bedrooms}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)), const Text('Quartos', style: TextStyle(color: AppTheme.textSecondary, fontSize: 12))]),
                    if (p.bathrooms > 0) Column(children: [Icon(Icons.bathtub_outlined, color: AppTheme.primary, size: 24), const SizedBox(height: 4), Text('\${p.bathrooms}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)), const Text('WC', style: TextStyle(color: AppTheme.textSecondary, fontSize: 12))]),
                    if (p.area > 0) Column(children: [Icon(Icons.square_foot, color: AppTheme.primary, size: 24), const SizedBox(height: 4), Text('\${p.area.toStringAsFixed(0)}m2', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)), const Text('Area', style: TextStyle(color: AppTheme.textSecondary, fontSize: 12))]),
                  ]),
                ),
              const SizedBox(height: 20),
              const Text('Descricao', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: AppTheme.textPrimary)),
              const SizedBox(height: 8),
              Text(p.description, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 15, height: 1.5)),
              const SizedBox(height: 24),
              const Text('Localizacao', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: AppTheme.textPrimary)),
              const SizedBox(height: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: SizedBox(height: 220, child: FlutterMap(
                  options: MapOptions(initialCenter: LatLng(p.latitude, p.longitude), initialZoom: 14),
                  children: [
                    TileLayer(urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png', userAgentPackageName: 'com.kubico.app'),
                    if (_routePoints.isNotEmpty) PolylineLayer(polylines: [Polyline(points: _routePoints, strokeWidth: 4, color: AppTheme.primary)]),
                    MarkerLayer(markers: [
                      Marker(point: LatLng(p.latitude, p.longitude), width: 40, height: 40, child: Container(decoration: BoxDecoration(color: AppTheme.primary, shape: BoxShape.circle, border: Border.all(color: Colors.white, width: 2.5)), child: const Icon(Icons.home, color: Colors.white, size: 20))),
                      if (_userPosition != null) Marker(point: LatLng(_userPosition!.latitude, _userPosition!.longitude), width: 36, height: 36, child: Container(decoration: BoxDecoration(color: Colors.blue, shape: BoxShape.circle, border: Border.all(color: Colors.white, width: 3)), child: const Icon(Icons.person, color: Colors.white, size: 18))),
                    ]),
                  ],
                )),
              ),
              if (_routeStatus.isNotEmpty) Padding(padding: const EdgeInsets.only(top: 8), child: Text(_routeStatus, style: TextStyle(color: AppTheme.primary, fontSize: 12, fontWeight: FontWeight.w500))),

              const SizedBox(height: 24),
              const Text('Marcar Visita', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: AppTheme.textPrimary)),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFFEEEEEE)), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8)]),
                child: Column(children: [
                  Row(children: [
                    Expanded(child: GestureDetector(onTap: () => _pickDate(context), child: Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12), decoration: BoxDecoration(border: Border.all(color: const Color(0xFFDDDDDD)), borderRadius: BorderRadius.circular(10)), child: Row(children: [Icon(Icons.calendar_today, size: 16, color: AppTheme.primary), const SizedBox(width: 8), Text(_selectedDate == null ? 'Data' : _selectedDate!.day.toString() + '/' + _selectedDate!.month.toString() + '/' + _selectedDate!.year.toString(), style: TextStyle(color: _selectedDate == null ? AppTheme.textSecondary : AppTheme.textPrimary, fontSize: 14))])))),
                    const SizedBox(width: 12),
                    Expanded(child: GestureDetector(onTap: () => _pickTime(context), child: Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12), decoration: BoxDecoration(border: Border.all(color: const Color(0xFFDDDDDD)), borderRadius: BorderRadius.circular(10)), child: Row(children: [Icon(Icons.access_time, size: 16, color: AppTheme.primary), const SizedBox(width: 8), Text(_selectedTime == null ? 'Hora' : _selectedTime!.format(context), style: TextStyle(color: _selectedTime == null ? AppTheme.textSecondary : AppTheme.textPrimary, fontSize: 14))])))),
                  ]),
                  const SizedBox(height: 12),
                  SizedBox(width: double.infinity, child: ElevatedButton.icon(
                    onPressed: (_selectedDate != null && _selectedTime != null) ? () => _confirmarVisita(p) : null,
                    icon: _loadingRoute ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) : const Icon(Icons.check_circle_outline),
                    label: const Text('Confirmar Visita'),
                    style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primary, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                  )),
                ]),
              ),
              const SizedBox(height: 100),
            ]),
          ),
        ),
      ]),
      bottomNavigationBar: _buildContactBar(p),
    );
  }

  Future<void> _getRoute(Property p) async {
    setState(() { _loadingRoute = true; _routeStatus = 'A calcular rota...'; });
    try {
      if (_userPosition == null) {
        await _getUserLocation();
      }
      if (_userPosition == null) {
        setState(() { _routeStatus = 'Activa o GPS para ver a rota'; _loadingRoute = false; });
        return;
      }
      final startLat = _userPosition!.latitude;
      final startLng = _userPosition!.longitude;
      final url = Uri.parse('https://router.project-osrm.org/route/v1/driving/' + startLng.toString() + ',' + startLat.toString() + ';' + p.longitude.toString() + ',' + p.latitude.toString() + '?overview=full&geometries=geojson');
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final coords = data['routes'][0]['geometry']['coordinates'] as List;
        final distanceKm = (data['routes'][0]['distance'] as num) / 1000;
        final durationMin = (data['routes'][0]['duration'] as num) / 60;
        setState(() {
          _routePoints = coords.map((c) => LatLng(c[1] as double, c[0] as double)).toList();
          _routeStatus = distanceKm.toStringAsFixed(1) + ' km - ' + durationMin.toStringAsFixed(0) + ' min de carro';
        });
      }
    } catch (_) {
      setState(() => _routeStatus = 'Nao foi possivel calcular a rota');
    }
    setState(() => _loadingRoute = false);
  }

  Future<void> _pickDate(BuildContext context) async {
    final picked = await showDatePicker(context: context, initialDate: DateTime.now().add(const Duration(days: 1)), firstDate: DateTime.now(), lastDate: DateTime.now().add(const Duration(days: 30)), builder: (ctx, child) => Theme(data: Theme.of(ctx).copyWith(colorScheme: ColorScheme.light(primary: AppTheme.primary)), child: child!));
    if (picked != null) setState(() => _selectedDate = picked);
  }

  Future<void> _pickTime(BuildContext context) async {
    final picked = await showTimePicker(context: context, initialTime: const TimeOfDay(hour: 10, minute: 0), builder: (ctx, child) => Theme(data: Theme.of(ctx).copyWith(colorScheme: ColorScheme.light(primary: AppTheme.primary)), child: child!));
    if (picked != null) setState(() => _selectedTime = picked);
  }

  void _confirmarVisita(Property p) {
    _getRoute(p);
    final date = _selectedDate!.day.toString() + '/' + _selectedDate!.month.toString() + '/' + _selectedDate!.year.toString();
    final time = _selectedTime!.format(context);
    showDialog(context: context, builder: (_) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Row(children: [Icon(Icons.check_circle, color: AppTheme.primary), const SizedBox(width: 8), const Text('Visita Marcada!')]),
      content: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('Imovel: ' + p.title, style: const TextStyle(fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        Text('Data: ' + date + ' as ' + time),
        const SizedBox(height: 8),
        Text('Contacto: ' + p.ownerPhone, style: TextStyle(color: AppTheme.primary, fontWeight: FontWeight.w600)),
        const SizedBox(height: 12),
        Row(children: [Icon(Icons.directions, color: AppTheme.primary, size: 16), const SizedBox(width: 4), const Text('Rota calculada no mapa', style: TextStyle(color: Colors.grey, fontSize: 13))]),
      ]),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Fechar')),
        ElevatedButton.icon(onPressed: () { Navigator.pop(context); _whatsapp(p.ownerPhone, p.title, date, time); }, icon: const Icon(Icons.message, size: 16), label: const Text('WhatsApp'), style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF25D366), foregroundColor: Colors.white)),
      ],
    ));
  }

  Widget _buildContactBar(Property p) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
      decoration: const BoxDecoration(color: AppTheme.surface, border: Border(top: BorderSide(color: AppTheme.border))),
      child: Row(children: [
        Expanded(child: OutlinedButton.icon(onPressed: () => _call(p.ownerPhone), icon: const Icon(Icons.phone_outlined), label: const Text('Ligar'), style: OutlinedButton.styleFrom(foregroundColor: AppTheme.primary, side: const BorderSide(color: AppTheme.primary), padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))))),
        const SizedBox(width: 12),
        Expanded(flex: 2, child: ElevatedButton.icon(onPressed: () => _whatsapp(p.ownerPhone, p.title, '', ''), icon: const Icon(Icons.message_outlined), label: const Text('WhatsApp'), style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF25D366), foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))))),
      ]),
    );
  }

  Future<void> _call(String phone) async {
    final uri = Uri(scheme: 'tel', path: phone);
    if (await canLaunchUrl(uri)) launchUrl(uri);
  }

  Future<void> _whatsapp(String phone, String title, String date, String time) async {
    final digits = phone.replaceAll(RegExp(r'[^0-9]'), '');
    final normalized = digits.startsWith('244') ? digits : '244' + digits;
    final text = date.isEmpty ? 'Ola! Tenho interesse no imovel ' + title + ' que vi no Kubico.' : 'Ola! Quero confirmar a visita ao imovel ' + title + ' no dia ' + date + ' as ' + time + '. Vi no Kubico.';
    final uri = Uri.parse('https://wa.me/' + normalized + '?text=' + Uri.encodeComponent(text));
    if (await canLaunchUrl(uri)) launchUrl(uri, mode: LaunchMode.externalApplication);
  }
}
