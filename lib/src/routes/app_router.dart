
import 'package:clarifi_app/src/viewmodels/auth_viewmodel.dart';
import 'package:clarifi_app/src/views/auth/change_password.dart';
import 'package:clarifi_app/src/views/auth/login_view.dart';
import 'package:clarifi_app/src/views/auth/recovery_password.dart';
import 'package:clarifi_app/src/views/auth/signup_view.dart';
import 'package:clarifi_app/src/views/home/home_view.dart';
import 'package:clarifi_app/src/views/onboarding/onboarding.dart';
import 'package:clarifi_app/src/views/splashScreen/splash_screen.dart';
import 'package:go_router/go_router.dart';


class AppRouter {
  final AuthViewModel authViewModel;
  late final GoRouter router;

  AppRouter(this.authViewModel) {
    router = GoRouter(
      refreshListenable: authViewModel,
      initialLocation: '/',
      routes: [
        GoRoute(
          name: 'splashScreen',
          path: '/',
          builder: (context, state) => const SplashScreen(),
        ),
        GoRoute(
          name: 'onboarding',
          path: '/onboarding',
          builder: (context, state) => const OnboardingScreen(),
        ),
        GoRoute(
          name: 'login',
          path: '/login',
          builder: (context, state) => const LoginView(),
        ),
        GoRoute(
          name: 'signup',
          path: '/signup',
          builder: (context, state) => const SignupView(),
        ),
        GoRoute(
          name: 'recovery',
          path: '/recovery',
          builder: (context, state) => const RecoveryPassword(),
        ),
        GoRoute(
          name: 'changePassword',
          path: '/reset-password',
          builder: (context, state) => const ChangePassword(),
        ),
        GoRoute(
          name: 'dashboard',
          path: '/dashboard',
          builder: (context, state) => const HomeView(),
        ),
      ],
      redirect: (context, state) {
        final bool loggedIn = authViewModel.isAuthenticated;
        final String location = state.matchedLocation;

        if (!loggedIn) {
          return location == '/login' || location == '/signup' || location == '/onboarding' || location == '/' || location == '/recovery' || location == '/reset-password'
              ? null
              : '/login';
        }

        if (location == '/login' || location == '/signup' || location == '/' || location == '/onboarding') {
          return '/dashboard';
        }

        return null;
      },
    );
  }
}
