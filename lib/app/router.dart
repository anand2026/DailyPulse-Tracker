import 'package:go_router/go_router.dart';
import 'route_endpoints.dart';
import '../features/auth/presentation/login_screen.dart';
import '../features/auth/presentation/signup_screen.dart';
import '../features/mood_tracker/presentation/home_screen.dart';
import '../features/mood_tracker/presentation/mood_log_screen.dart';
import '../features/mood_tracker/presentation/mood_history_screen.dart';
import '../features/mood_tracker/presentation/analytics_screen.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: AppRouteEndpoints.home,
  routes: [
    GoRoute(
      path: AppRouteEndpoints.login,
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: AppRouteEndpoints.signup,
      builder: (context, state) => const SignupScreen(),
    ),
    GoRoute(
      path: AppRouteEndpoints.home,
      builder: (context, state) => const HomeScreen(),
    ),
    GoRoute(
      path: AppRouteEndpoints.moodLog,
      builder: (context, state) => const MoodLogScreen(),
    ),
    GoRoute(
      path: AppRouteEndpoints.moodHistory,
      builder: (context, state) => const MoodHistoryScreen(),
    ),
    GoRoute(
      path: AppRouteEndpoints.analytics,
      builder: (context, state) => const AnalyticsScreen(),
    ),
  ],
);
