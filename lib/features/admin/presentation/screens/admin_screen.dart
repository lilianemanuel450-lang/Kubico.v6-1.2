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
