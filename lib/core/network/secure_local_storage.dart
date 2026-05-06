import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Armazenamento seguro para tokens Supabase.
/// Usa flutter_secure_storage (Keychain no iOS, Keystore no Android)
/// em vez de SharedPreferences (texto plano).
class SecureLocalStorage extends LocalStorage {
  final FlutterSecureStorage _storage;

  SecureLocalStorage(this._storage);

  @override
  Future<void> initialize() async {}

  @override
  Future<String?> accessToken() async {
    return _storage.read(key: 'supabase_access_token');
  }

  @override
  Future<bool> hasAccessToken() async {
    final token = await _storage.read(key: 'supabase_access_token');
    return token != null;
  }

  @override
  Future<void> persistSession(String persistSessionString) async {
    await _storage.write(
      key: 'supabase_access_token',
      value: persistSessionString,
    );
  }

  @override
  Future<void> removePersistedSession() async {
    await _storage.delete(key: 'supabase_access_token');
  }
}
