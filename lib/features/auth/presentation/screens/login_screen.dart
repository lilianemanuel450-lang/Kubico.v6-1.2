import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_theme.dart';
import '../providers/auth_provider.dart';

// ── Login Screen ───────────────────────────────────────────────────────────

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _phoneController = TextEditingController(text: '+244 ');

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authNotifierProvider);
    final isLoading = authState.status == AuthStatus.loading;

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 40),
              // Logo
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: AppTheme.primary,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Center(
                  child: Text('K',
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 28)),
                ),
              ),
              const SizedBox(height: 24),
              const Text('Bem-vindo\nao Kubico',
                  style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textPrimary,
                      height: 1.2)),
              const SizedBox(height: 8),
              const Text('O melhor imobiliário de Angola',
                  style:
                      TextStyle(color: AppTheme.textSecondary, fontSize: 16)),
              const SizedBox(height: 48),
              const Text('Número de telefone',
                  style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textPrimary,
                      fontSize: 14)),
              const SizedBox(height: 8),
              TextField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  hintText: '+244 9XX XXX XXX',
                  prefixIcon: Icon(Icons.phone_outlined, color: AppTheme.primary),
                ),
              ),
              if (authState.errorMessage != null) ...[
                const SizedBox(height: 12),
                Text(authState.errorMessage!,
                    style: const TextStyle(color: AppTheme.error, fontSize: 13)),
              ],
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: isLoading ? null : _sendOtp,
                  child: isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                              color: Colors.white, strokeWidth: 2))
                      : const Text('Receber código SMS'),
                ),
              ),
              const SizedBox(height: 16),
              Center(
                child: Text(
                  'Ao continuar, aceitas os nossos\nTermos de Serviço e Política de Privacidade.',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      color: AppTheme.textSecondary, fontSize: 12),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _sendOtp() async {
    final phone = _phoneController.text.trim();
    if (phone.length < 10) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Insere um número válido')),
      );
      return;
    }
    await ref.read(authNotifierProvider.notifier).sendOtp(phone);
    if (mounted &&
        ref.read(authNotifierProvider).status != AuthStatus.error) {
      context.push('/otp?phone=${Uri.encodeComponent(phone)}');
    }
  }
}
