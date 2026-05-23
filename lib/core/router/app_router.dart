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
import '../../features/profile/presentation/screens/profile_screen.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authNotifierProvider);

  return GoRouter(
    initialLocation: '/',
    redirect: (context, state) {
      final isAuth = authState.isAuthenticated;
      final isOnAuth = state.matchedLocation == '/login' ||
          state.matchedLocation == '/otp';
      if (!isAuth && !isOnAuth) return '/login';
      if (isAuth && isOnAuth) return '/';
      return null;
    },
    routes: [
      ShellRoute(
        builder: (context, state, child) => MainShell(child: child),
        routes: [
          GoRoute(path: '/', builder: (c, s) => const HomeScreen()),
          GoRoute(path: '/search', builder: (c, s) => const SearchScreen()),
          GoRoute(path: '/favorites', builder: (c, s) => const FavoritesScreen()),
          GoRoute(path: '/profile', builder: (c, s) => const ProfileScreen()),
        ],
      ),
      GoRoute(path: '/login', builder: (c, s) => const LoginScreen()),
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
      GoRoute(path: '/map', builder: (c, s) => const MapScreen()),
      GoRoute(path: '/publish', builder: (c, s) => const PublishScreen()),
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
      bottomNavigationBar: const _BottomNav(),
    );
  }
}

class _BottomNav extends ConsumerWidget {
  const _BottomNav();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final location = GoRouterState.of(context).matchedLocation;

    int currentIndex = 0;
    if (location == '/search') currentIndex = 1;
    if (location == '/favorites') currentIndex = 2;
    if (location == '/profile') currentIndex = 3;

    return BottomNavigationBar(
      currentIndex: currentIndex,
      selectedItemColor: const Color(0xFF2E7D32),
      unselectedItemColor: const Color(0xFF888888),
      backgroundColor: Colors.white,
      type: BottomNavigationBarType.fixed,
      elevation: 8,
      onTap: (i) {
        switch (i) {
          case 0: context.go('/'); break;
          case 1: context.go('/search'); break;
          case 2: context.go('/favorites'); break;
          case 3: context.go('/profile'); break;
        }
      },
      items: const [
        BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Inicio'),
        BottomNavigationBarItem(
            icon: Icon(Icons.search_outlined),
            activeIcon: Icon(Icons.search),
            label: 'Buscar'),
        BottomNavigationBarItem(
            icon: Icon(Icons.favorite_border),
            activeIcon: Icon(Icons.favorite),
            label: 'Favoritos'),
        BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Conta'),
      ],
    );
  }
}
