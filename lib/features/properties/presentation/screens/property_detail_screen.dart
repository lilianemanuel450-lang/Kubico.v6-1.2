import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../favorites/presentation/providers/favorites_provider.dart';
import '../../domain/entities/property.dart';

class PropertyDetailScreen extends ConsumerWidget {
  final String propertyId;
  final Property? property;
  const PropertyDetailScreen({super.key, required this.propertyId, this.property});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final p = property;
    if (p == null) return const Scaffold(body: Center(child: CircularProgressIndicator()));
    final isFav = ref.watch(favoritesNotifierProvider).valueOrNull?.contains(p.id) ?? false;
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: AppTheme.surface,
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => context.pop()),
        actions: [
          IconButton(icon: Icon(isFav ? Icons.favorite : Icons.favorite_border, color: isFav ? Colors.red : null), onPressed: () => ref.read(favoritesNotifierProvider.notifier).toggle(p.id)),
          IconButton(icon: const Icon(Icons.share_outlined), onPressed: () => Share.share('Ver imovel no Kubico: ' + p.title)),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          p.images.isNotEmpty ? CachedNetworkImage(imageUrl: p.images[0], height: 280, width: double.infinity, fit: BoxFit.cover) : Container(height: 280, color: AppTheme.border),
          Padding(padding: const EdgeInsets.all(20), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(p.title, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppTheme.textPrimary)),
            const SizedBox(height: 8),
            Row(children: [const Icon(Icons.location_on_outlined, size: 16, color: AppTheme.textSecondary), const SizedBox(width: 4), Expanded(child: Text(p.address, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 14)))]),
            const SizedBox(height: 16),
            Text(p.formattedPrice, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: AppTheme.primary)),
            const SizedBox(height: 16),
            Text(p.description, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 15, height: 1.5)),
            const SizedBox(height: 24),
            Row(children: [
              Expanded(child: OutlinedButton.icon(onPressed: () async { final uri = Uri(scheme: 'tel', path: p.ownerPhone); if (await canLaunchUrl(uri)) launchUrl(uri); }, icon: const Icon(Icons.phone_outlined), label: const Text('Ligar'), style: OutlinedButton.styleFrom(foregroundColor: AppTheme.primary, side: const BorderSide(color: AppTheme.primary), padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))))),
              const SizedBox(width: 12),
              Expanded(flex: 2, child: ElevatedButton.icon(onPressed: () async { final digits = p.ownerPhone.replaceAll(RegExp(r'[^0-9]'), ''); final n = digits.startsWith('244') ? digits : '244' + digits; final uri = Uri.parse('https://wa.me/' + n + '?text=' + Uri.encodeComponent('Ola! Tenho interesse no imovel ' + p.title + ' que vi no Kubico.')); if (await canLaunchUrl(uri)) launchUrl(uri, mode: LaunchMode.externalApplication); }, icon: const Icon(Icons.message_outlined), label: const Text('WhatsApp'), style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF25D366), foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))))),
            ]),
          ])),
        ]),
      ),
    );
  }
}
