import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authNotifierProvider).user;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text('Minha Conta',
            style: TextStyle(
                color: Color(0xFF1A1A1A), fontWeight: FontWeight.bold)),
      ),
      body: Column(
        children: [
          const SizedBox(height: 32),
          CircleAvatar(
            radius: 48,
            backgroundColor: AppTheme.primary,
            child: const Icon(Icons.person, size: 48, color: Colors.white),
          ),
          const SizedBox(height: 16),
          Text(
            user?.name ?? 'Utilizador',
            style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1A1A1A)),
          ),
          const SizedBox(height: 4),
          Text(
            user?.phone ?? '',
            style: const TextStyle(color: Color(0xFF888888), fontSize: 14),
          ),
          const SizedBox(height: 40),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () =>
                    ref.read(authNotifierProvider.notifier).signOut(),
                icon: const Icon(Icons.logout),
                label: const Text('Terminar sessão'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
