import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/app_providers.dart';
import '../screens/auth/account_suspended_screen.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/verification_screen.dart';
import '../screens/collection_point/collection_point_screen.dart';
import '../screens/community/follow_list_screen.dart';
import '../screens/community/post_detail_screen.dart';
import '../screens/community/user_profile_screen.dart';
import '../screens/notifications/notifications_screen.dart';
import '../screens/onboarding/onboarding_screen.dart';
import '../screens/settings/settings_screen.dart';
import '../screens/shell/main_shell_screen.dart';
import '../screens/splash/splash_screen.dart';
import '../screens/support/support_screen.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  final authService = ref.watch(authServiceProvider);
  final householdAsync = ref.watch(currentHouseholdProvider);

  return GoRouter(
    initialLocation: '/splash',
    redirect: (context, state) {
      final loc = state.matchedLocation;
      final isAuth = authService.isSignedIn;

      // Allow public/auth routes without redirects
      final isPublicRoute = loc == '/splash' ||
          loc == '/onboarding' ||
          loc == '/login' ||
          loc == '/verification' ||
          loc == '/suspended';

      if (!isAuth && !isPublicRoute) {
        return '/login';
      }

      if (isAuth) {
        // If household is loaded, inspect state
        final household = householdAsync.value;
        if (household != null) {
          if (household.isSuspended && loc != '/suspended') {
            return '/suspended';
          }
          if (!household.emailVerified && loc != '/verification' && loc != '/suspended') {
            return '/verification';
          }
        }

        // If authenticated and on login/splash, go to home
        if (loc == '/login' || loc == '/splash') {
          return '/';
        }
      }

      return null;
    },
    routes: [
      GoRoute(
        path: '/splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/verification',
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>?;
          final hid = extra?['householdId'] as String? ?? '';
          final email = extra?['email'] as String? ?? '';
          return VerificationScreen(
            householdId: hid,
            initialEmail: email,
          );
        },
      ),
      GoRoute(
        path: '/suspended',
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>?;
          final hid = extra?['householdId'] as String? ?? '';
          final reason = extra?['reason'] as String?;
          return AccountSuspendedScreen(
            householdId: hid,
            reason: reason,
          );
        },
      ),
      GoRoute(
        path: '/',
        builder: (context, state) => const MainShellScreen(initialIndex: 0),
      ),
      GoRoute(
        path: '/schedule',
        builder: (context, state) => const MainShellScreen(initialIndex: 1),
      ),
      GoRoute(
        path: '/guide',
        builder: (context, state) => const MainShellScreen(initialIndex: 2),
      ),
      GoRoute(
        path: '/community',
        builder: (context, state) => const MainShellScreen(initialIndex: 3),
      ),
      GoRoute(
        path: '/profile',
        builder: (context, state) => const MainShellScreen(initialIndex: 4),
      ),
      GoRoute(
        path: '/collection-point',
        builder: (context, state) => const CollectionPointScreen(),
      ),
      GoRoute(
        path: '/notifications',
        builder: (context, state) => const NotificationsScreen(),
      ),
      GoRoute(
        path: '/support',
        builder: (context, state) => const SupportScreen(),
      ),
      GoRoute(
        path: '/settings',
        builder: (context, state) => const SettingsScreen(),
      ),
      GoRoute(
        path: '/community/post/:id',
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return PostDetailScreen(postId: id);
        },
      ),
      GoRoute(
        path: '/community/user/:uid',
        builder: (context, state) {
          final uid = state.pathParameters['uid']!;
          return UserProfileScreen(uid: uid);
        },
      ),
      GoRoute(
        path: '/community/network/:uid',
        builder: (context, state) {
          final uid = state.pathParameters['uid']!;
          final tabStr = state.uri.queryParameters['tab'];
          final initialTab = tabStr == '1' ? 1 : 0;
          return FollowListScreen(uid: uid, initialTabIndex: initialTab);
        },
      ),
    ],
  );
});
