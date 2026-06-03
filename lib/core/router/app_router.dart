import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '/providers/auth_provider.dart';
import '/screens/splash/splash_screen.dart';
import '/screens/auth/login_screen.dart';
import '/screens/auth/register_screen.dart';
import '/screens/auth/forgot_password_screen.dart';
import '/screens/dashboard/dashboard_screen.dart';
import '/screens/ticket/ticket_list_screen.dart';
import '/screens/ticket/ticket_detail_screen.dart';
import '/screens/ticket/create_ticket_screen.dart';
import '/screens/notification/notification_screen.dart';
import '/screens/profile/profile_screen.dart';
import '/screens/layout/main_layout.dart';
final routerProvider = Provider<GoRouter>((ref) {
  final isLoggedIn = ref.watch(authProvider.select((state) => state.isLoggedIn));

  return GoRouter(
    initialLocation: '/splash',
    redirect: (context, state) {
      final isAtSplash = state.matchedLocation == '/splash';
      final isAtLogin = state.matchedLocation == '/login';
      final isAtRegister = state.matchedLocation == '/register';
      final isAtForgotPass = state.matchedLocation == '/forgot-password';

      if (isAtSplash) return null;

      if (!isLoggedIn && !isAtLogin && !isAtRegister && !isAtForgotPass) {
        return '/login';
      }

      if (isLoggedIn && (isAtLogin || isAtRegister || isAtForgotPass)) {
        return '/dashboard';
      }

      return null;
    },
    routes: [
      GoRoute(
        path: '/splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: '/forgot-password',
        builder: (context, state) => const ForgotPasswordScreen(),
      ),
      ShellRoute(
        builder: (context, state, child) => MainLayout(child: child),
        routes: [
          GoRoute(
            path: '/dashboard',
            pageBuilder: (context, state) => CustomTransitionPage(
              child: const DashboardScreen(),
              transitionsBuilder: (context, animation, secondaryAnimation, child) {
                return FadeTransition(opacity: animation, child: child);
              },
            ),
          ),
          GoRoute(
            path: '/tickets',
            pageBuilder: (context, state) => CustomTransitionPage(
              child: const TicketListScreen(),
              transitionsBuilder: (context, animation, secondaryAnimation, child) {
                return FadeTransition(opacity: animation, child: child);
              },
            ),
          ),
          GoRoute(
            path: '/profile',
            pageBuilder: (context, state) => CustomTransitionPage(
              child: const ProfileScreen(),
              transitionsBuilder: (context, animation, secondaryAnimation, child) {
                return FadeTransition(opacity: animation, child: child);
              },
            ),
          ),
        ],
      ),
      GoRoute(
        path: '/tickets/:id',
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return TicketDetailScreen(ticketId: id);
        },
      ),
      GoRoute(
        path: '/create-ticket',
        builder: (context, state) => const CreateTicketScreen(),
      ),
      GoRoute(
        path: '/notifications',
        builder: (context, state) => const NotificationScreen(),
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      appBar: AppBar(title: const Text('Error')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error, size: 48, color: Colors.red),
            const SizedBox(height: 16),
            Text(state.error.toString()),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => context.go('/dashboard'),
              child: const Text('Kembali ke Dashboard'),
            ),
          ],
        ),
      ),
    ),
  );
});
