import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../favorites/presentation/providers/favorites_provider.dart';
import '../../domain/entities/property.dart';
import '../providers/property_provider.dart';

class PropertyDetailScreen extends ConsumerWidget {
  final String propertyId;
  final Property? property;

  const PropertyDetailScreen({
    super.key,
    required this.propertyId,
    this.property,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Usa imóvel passado como extra, ou busca pelo ID
    final propToShow = property;

    if (propToShow == null) {
      return const Scaffold(
          body: Center(child: CircularProgressIndicator()));
    }

    final isFav = ref.watch(favoritesNotifierProvider).valueOrNull
            ?.contains(propToShow.id) ??
        false;

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
                decoration: const BoxDecoration(
                    color: Colors.white, shape: BoxShape.circle),
                child: const Icon(Icons.arrow_back, color: AppTheme.textPrimary),
              ),
            ),
            actions: [
              GestureDetector(
                onTap: () => ref
                    .read(favoritesNotifierProvider.notifier)
                    .toggle(propToShow.id),
                child: Container(
                  margin: const EdgeInsets.all(8),
                  padding: const EdgeInsets.all(6),
                  decoration: const BoxDecoration(
                      color: Colors.white, shape: BoxShape.circle),
                  child: Icon(
                    isFav ? Icons.favorite : Icons.favorite_border,
                    color: isFav ? Colors.red : AppTheme.textSecondary,
                  ),
                ),
              ),
              GestureDetector(
                onTap: () => Share.share(
                    'Ver imóvel no Kubico: ${propToShow.title} - ${propToShow.formattedPrice}'),
                child: Container(
                  margin: const EdgeInsets.all(8),
                  padding: const EdgeInsets.all(6),
                  decoration: const BoxDecoration(
                      color: Colors.white, shape: BoxShape.circle),
                  child: const Icon(Icons.share_outlined,
                      color: AppTheme.textSecondary),
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
                        errorWidget: (_, __, ___) => Container(
                            color: AppTheme.border,
                            child: const Icon(Icons.image_not_supported)),
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
                  // Badge + Título
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: propToShow.type == 'rent'
                              ? AppTheme.primary
                              : AppTheme.accent,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(propToShow.typeLabel,
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w600)),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppTheme.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(propToShow.propertyTypeLabel,
                            style: TextStyle(
                                color: AppTheme.primary,
                                fontSize: 12,
                                fontWeight: FontWeight.w600)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(propToShow.title,
                      style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textPrimary)),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.location_on_outlined,
                          size: 16, color: AppTheme.textSecondary),
                      const SizedBox(width: 4),
                      Expanded(
                          child: Text(propToShow.address,
                              style: const TextStyle(
                                  color: AppTheme.textSecondary, fontSize: 14))),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Preço
                  Text(propToShow.formattedPrice,
                      style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primary)),
                  const SizedBox(height: 20),
                  // Características
                  if (propToShow.bedrooms > 0 ||
                      propToShow.bathrooms > 0 ||
                      propToShow.area > 0)
                    _buildSpecs(propToShow),
                  const SizedBox(height: 20),
                  // Descrição
                  const Text('Descrição',
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.textPrimary)),
                  const SizedBox(height: 8),
                  Text(propToShow.description,
                      style: const TextStyle(
                          color: AppTheme.textSecondary,
                          fontSize: 15,
                          height: 1.5)),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ],
      ),
      // Botões de contacto (sem chat — apenas telefone e WhatsApp)
      bottomNavigationBar: _buildContactBar(propToShow),
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
          if (p.bedrooms > 0)
            _specItem(Icons.bed_outlined, '${p.bedrooms}', 'Quartos'),
          if (p.bathrooms > 0)
            _specItem(Icons.bathtub_outlined, '${p.bathrooms}', 'Casas de banho'),
          if (p.area > 0)
            _specItem(Icons.square_foot, '${p.area.toStringAsFixed(0)}m²', 'Área'),
        ],
      ),
    );
  }

  Widget _specItem(IconData icon, String value, String label) {
    return Column(
      children: [
        Icon(icon, color: AppTheme.primary, size: 24),
        const SizedBox(height: 4),
        Text(value,
            style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: AppTheme.textPrimary)),
        Text(label,
            style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
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
          // Botão Ligar
          Expanded(
            child: OutlinedButton.icon(
              onPressed: () => _call(p.ownerPhone),
              icon: const Icon(Icons.phone_outlined),
              label: const Text('Ligar'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppTheme.primary,
                side: const BorderSide(color: AppTheme.primary),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Botão WhatsApp
          Expanded(
            flex: 2,
            child: ElevatedButton.icon(
              onPressed: () => _whatsapp(p.ownerPhone, p.title),
              icon: const Icon(Icons.message_outlined),
              label: const Text('WhatsApp'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF25D366),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _call(String phone) async {
    final uri = Uri(scheme: 'tel', path: phone);
    if (await canLaunchUrl(uri)) launchUrl(uri);
  }

  Future<void> _whatsapp(String phone, String title) async {
    final digits = phone.replaceAll(RegExp(r'\D'), '');
    final normalized = digits.startsWith('244') ? digits : '244$digits';
    final msg = Uri.encodeComponent(
        'Olá! Tenho interesse no imóvel "$title" que vi no Kubico.');
    final uri = Uri.parse('https://wa.me/$normalized?text=$msg');
    if (await canLaunchUrl(uri)) launchUrl(uri, mode: LaunchMode.externalApplication);
  }
}
