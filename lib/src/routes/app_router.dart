
import 'package:clarifi_app/src/viewmodels/auth_viewmodel.dart';
import 'package:clarifi_app/src/views/auth/change_password.dart';
import 'package:clarifi_app/src/views/auth/login_view.dart';
import 'package:clarifi_app/src/views/auth/recovery_password.dart';
import 'package:clarifi_app/src/views/auth/signup_view.dart';
import 'package:clarifi_app/src/views/home/home_view.dart';
import 'package:clarifi_app/src/views/home/accounts_view.dart';
import 'package:clarifi_app/src/views/accounts/accounts_list_view.dart';
import 'package:clarifi_app/src/views/onboarding/onboarding.dart';
import 'package:clarifi_app/src/views/splashScreen/splash_screen.dart';
import 'package:clarifi_app/src/views/navigation/main_navigation_view.dart';
import 'package:clarifi_app/src/views/budgets/budgets_view.dart';
//import 'package:clarifi_app/src/views/transactions/transactions_view.dart';
import 'package:clarifi_app/src/views/reports/reports_view.dart';
import 'package:clarifi_app/src/views/settings/settings_view.dart';
import 'package:clarifi_app/src/views/transactions/transactions_list_view.dart';
import 'package:clarifi_app/src/views/transactions/new_transaction_view.dart';


import 'package:go_router/go_router.dart';

class AppRouter {
  final AuthViewModel authViewModel;
  late final GoRouter router;

  AppRouter(this.authViewModel) {
    router = GoRouter(
      refreshListenable: authViewModel,
      initialLocation: '/',
      routes: [
        // Rutas sin NavigationBar
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
        
        // ShellRoute para mantener NavigationBar visible
        ShellRoute(
          builder: (context, state, child) {
            return MainNavigationView(child: child);
          },
          routes: [
            GoRoute(
              name: 'home',
              path: '/home',
              pageBuilder: (context, state) => NoTransitionPage(
                child: const HomeView(),
              ),
            ),
            GoRoute(
              name: 'budgets',
              path: '/budgets',
              pageBuilder: (context, state) => NoTransitionPage(
                child: const BudgetsView(),
              ),
            ),
            GoRoute(
              name: 'transactions',
              path: '/transactions',
              pageBuilder: (context, state) => NoTransitionPage(
                child: const TransactionsListView(),
              ),
            ),
            GoRoute(
              name: 'reports',
              path: '/reports',
              pageBuilder: (context, state) => NoTransitionPage(
                child: const ReportsView(),
              ),
            ),
            GoRoute(
              name: 'settings',
              path: '/settings',
              pageBuilder: (context, state) => NoTransitionPage(
                child: const SettingsView(),
              ),
            ),
            // Rutas anidadas que también muestran el NavigationBar
            GoRoute(
              name: 'accountsList',
              path: '/accounts/list',
              pageBuilder: (context, state) => NoTransitionPage(
                child: const AccountsListView(),
              ),
            ),
          ],
        ),
        
        // Rutas adicionales (sin NavigationBar)
        GoRoute(
          name: 'accounts',
          path: '/accounts',
          builder: (context, state) => const AccountsView(),
        ),
        // GoRoute(
        //   name: 'transactionForm',
        //   path: '/transactions/new',
        //   builder: (context, state) => const TransactionsListView(),
        // ),
        GoRoute(
          name: 'transactionsList',
          path: '/transactionsList',
          builder: (context, state) => const TransactionsListView(),
        ),
        GoRoute(
          name: 'transactionsAdd',
          path: '/transactionsAdd/:type',
          builder: (context, state) {
          final type = state.pathParameters['type'] ?? 'expense';
          return NewTransactionView(type: type);
        },
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
          return '/home';
        }

        return null;
      },
    );
  }
}
