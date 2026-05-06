import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// ── Auth Entity ────────────────────────────────────────────────────────────

class AppUser extends Equatable {
  final String id;
  final String phone;
  final String? name;
  final String? avatarUrl;

  const AppUser({
    required this.id,
    required this.phone,
    this.name,
    this.avatarUrl,
  });

  factory AppUser.fromSupabase(User user) => AppUser(
    id: user.id,
    phone: user.phone ?? '',
    name: user.userMetadata?['name'] as String?,
    avatarUrl: user.userMetadata?['avatar_url'] as String?,
  );

  @override
  List<Object?> get props => [id, phone, name, avatarUrl];
}

// ── Auth State ─────────────────────────────────────────────────────────────

enum AuthStatus { initial, loading, authenticated, unauthenticated, error }

class AuthState {
  final AuthStatus status;
  final AppUser? user;
  final String? errorMessage;

  const AuthState({
    this.status = AuthStatus.initial,
    this.user,
    this.errorMessage,
  });

  bool get isAuthenticated => status == AuthStatus.authenticated;

  AuthState copyWith({
    AuthStatus? status,
    AppUser? user,
    String? errorMessage,
  }) => AuthState(
    status: status ?? this.status,
    user: user ?? this.user,
    errorMessage: errorMessage ?? this.errorMessage,
  );
}

// ── Auth Notifier ──────────────────────────────────────────────────────────

class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier() : super(const AuthState()) {
    _init();
  }

  void _init() {
    Supabase.instance.client.auth.onAuthStateChange.listen((data) {
      final session = data.session;
      if (session != null) {
        state = AuthState(
          status: AuthStatus.authenticated,
          user: AppUser.fromSupabase(session.user),
        );
      } else {
        state = const AuthState(status: AuthStatus.unauthenticated);
      }
    });

    final currentUser = Supabase.instance.client.auth.currentUser;
    if (currentUser != null) {
      state = AuthState(
        status: AuthStatus.authenticated,
        user: AppUser.fromSupabase(currentUser),
      );
    } else {
      state = const AuthState(status: AuthStatus.unauthenticated);
    }
  }

  Future<void> sendOtp(String phone) async {
    state = state.copyWith(status: AuthStatus.loading);
    try {
      final normalized = _normalizePhone(phone);
      await Supabase.instance.client.auth.signInWithOtp(phone: normalized);
      state = state.copyWith(status: AuthStatus.unauthenticated);
    } catch (e) {
      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: 'Erro ao enviar OTP: $e',
      );
    }
  }

  Future<void> verifyOtp(String phone, String token) async {
    state = state.copyWith(status: AuthStatus.loading);
    try {
      final normalized = _normalizePhone(phone);
      final response = await Supabase.instance.client.auth.verifyOTP(
        phone: normalized,
        token: token,
        type: OtpType.sms,
      );
      if (response.user != null) {
        state = AuthState(
          status: AuthStatus.authenticated,
          user: AppUser.fromSupabase(response.user!),
        );
      } else {
        state = state.copyWith(
          status: AuthStatus.error,
          errorMessage: 'Código inválido.',
        );
      }
    } catch (e) {
      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: 'Código incorreto. Tenta novamente.',
      );
    }
  }

  Future<void> signOut() async {
    await Supabase.instance.client.auth.signOut();
    state = const AuthState(status: AuthStatus.unauthenticated);
  }

  String _normalizePhone(String phone) {
    final digits = phone.replaceAll(RegExp(r'\D'), '');
    if (digits.startsWith('244')) return '+$digits';
    if (digits.startsWith('9') && digits.length == 9) return '+244$digits';
    return '+$digits';
  }
}

final authNotifierProvider =
    StateNotifierProvider<AuthNotifier, AuthState>(
  (ref) => AuthNotifier(),
);
