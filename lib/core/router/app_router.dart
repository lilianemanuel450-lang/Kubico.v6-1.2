import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/auth/presentation/providers/auth_provider.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/otp_screen.dart';
import '../../features/properties/domain/entities/property.dart';
import '../../features/properties/presentation/screens/home_screen.dart';
import '../../features/properties/presentation/screens/property_detail_screen.dart';
import '../../features/properties/presentation/screens/publish_screen.dart';
import '../../features/map/presentation/screens/map_screen.dart';
import '../../features/favorites/presentation/screens/favorites_screen.dart';
import '../../features/search/presentation/screens/search_screen.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authNotifierProvider);

  return GoRouter(
    initialLocation: '/',
    redirect: (context, state) {
      final isAuth = authState.isAuthenticated;
      final isOnAuth = state.matchedLocation == '/login' || state.matchedLocation == '/otp';
      if (!isAuth && !isOnAuth) return '/login';
      if (isAuth && isOnAuth) return '/';
      return null;
    },
    routes: [
      ShellRoute(
        builder: (context, state, child) => MainShell(child: child),
        routes: [
          GoRoute(path: '/', builder: (c, s) => HomeScreen()),
          GoRoute(path: '/map', builder: (c, s) => MapScreen()),
          GoRoute(path: '/search', builder: (c, s) => SearchScreen()),
          GoRoute(path: '/favorites', builder: (c, s) => FavoritesScreen()),
        ],
      ),
      GoRoute(path: '/login', builder: (c, s) => LoginScreen()),
      GoRoute(
        path: '/otp',
        builder: (c, s) {
          final phone = s.uri.queryParameters['phone'] ?? '';
          return OtpScreen(phone: phone);
        },
      ),
      GoRoute(
        path: '/property/:id',
        builder: (c, s) {
          final property = s.extra as Property?;
          final id = s.pathParameters['id']!;
          return PropertyDetailScreen(propertyId: id, property: property);
        },
      ),
      GoRoute(path: '/publish', builder: (c, s) => PublishScreen()),
    ],
  );
});

class MainShell extends StatelessWidget {
  final Widget child;
  const MainShell({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: child,
      bottomNavigationBar: _BottomNav(),
    );
  }
}

class _BottomNav extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final location = GoRouterState.of(context).matchedLocation;

    int currentIndex = 0;
    if (location == '/map') currentIndex = 1;
    if (location == '/search') currentIndex = 2;
    if (location == '/favorites') currentIndex = 3;

    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: (i) {
        switch (i) {
          case 0: context.go('/'); break;
          case 1: context.go('/map'); break;
          case 2: context.go('/search'); break;
          case 3: context.go('/favorites'); break;
        }
      },
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home_outlined), activeIcon: Icon(Icons.home), label: 'Início'),
        BottomNavigationBarItem(icon: Icon(Icons.map_outlined), activeIcon: Icon(Icons.map), label: 'Mapa'),
        BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Pesquisar'),
        BottomNavigationBarItem(icon: Icon(Icons.favorite_border), activeIcon: Icon(Icons.favorite), label: 'Guardados'),
      ],
    );
  }
}
