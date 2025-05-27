import 'package:go_router/go_router.dart';
import 'package:academia_unifor/screens.dart';

class NoTransitionPage extends CustomTransitionPage {
  NoTransitionPage({required super.child})
    : super(
        transitionDuration: Duration.zero,
        reverseTransitionDuration: Duration.zero,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return child;
        },
      );
}

final GoRouter router = GoRouter(
  routes: [
    GoRoute(
      path: '/',
      pageBuilder:
          (context, state) => NoTransitionPage(child: const LoginScreen()),
    ),
    GoRoute(
      path: '/register',
      pageBuilder:
          (context, state) => NoTransitionPage(child: const RegisterScreen()),
    ),
    GoRoute(
      path: '/forgot-password',
      pageBuilder:
          (context, state) =>
              NoTransitionPage(child: const ForgotPasswordScreen()),
    ),
    GoRoute(
      path: '/home',
      pageBuilder:
          (context, state) => NoTransitionPage(child: const HomeScreen()),
    ),
    GoRoute(
      path: '/workouts',
      pageBuilder:
          (context, state) => NoTransitionPage(child: const WorkoutsScreen()),
    ),
    GoRoute(
      path: '/profile',
      pageBuilder:
          (context, state) => NoTransitionPage(child: const ProfileScreen()),
    ),
    GoRoute(
      path: '/admin',
      pageBuilder:
          (context, state) => NoTransitionPage(child: const AdminScreen()),
    ),
    GoRoute(
      path: '/admin/equipments',
      pageBuilder:
          (context, state) => NoTransitionPage(child: const EquipmentsScreen()),
    ),
    GoRoute(
      path: '/admin/exercises',
      pageBuilder:
          (context, state) => NoTransitionPage(child: AdminWorkoutsScreen()),
    ),
    GoRoute(
      path: '/admin/students',
      pageBuilder:
          (context, state) => NoTransitionPage(child: StudentsScreen()),
    ),
    GoRoute(
      path: '/admin/notifications',
      builder: (context, state) => const AdminNotificationScreen(),
    ),
    GoRoute(
      path: '/admin/classes',
      builder: (context, state) => const ClassAdminScreen(),
    ),
  ],
);
