import 'package:clarifi_app/src/repositories/budgets/supabase_budget_repository.dart';
import 'package:clarifi_app/src/routes/app_router.dart';
import 'package:clarifi_app/src/services/supabase_service.dart';
import 'package:clarifi_app/src/viewmodels/auth_viewmodel.dart';
import 'package:clarifi_app/src/viewmodels/budget_viewmodel.dart';
import 'package:clarifi_app/src/viewmodels/home_viewmodel.dart';
import 'package:clarifi_app/src/viewmodels/transaction_viewmodel.dart';
import 'package:clarifi_app/src/viewmodels/account_viewmodel.dart';
import 'package:clarifi_app/src/repositories/account/supabase_account_repository.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:app_links/app_links.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();


  // Initialize Supabase
  await Supabase.initialize(
    url: 'https://retwjrqfwsffbzogjaao.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InJldHdqcnFmd3NmZmJ6b2dqYWFvIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTkzMjM3MzMsImV4cCI6MjA3NDg5OTczM30.BD-202H6iaOD_7Q5uOY2ZpHOP0GGAlyC7qwSZvME8t8',
  );

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  GoRouter? _router;
  final _appLinks = AppLinks();

  @override
  void initState() {
    super.initState();
    _handleIncomingLinks();
  }

  void _handleIncomingLinks() {
    // Handle link stream
    _appLinks.uriLinkStream.listen((Uri? link) {
      if (link != null) {
        _handleLink(link.toString());
      }
    });
  }

  void _handleLink(String link) async {
    //print('Handling link: $link');
    final uri = Uri.parse(link);
    //print('Parsed URI: scheme=${uri.scheme}, host=${uri.host}, path=${uri.path}, query=${uri.query}, fragment=${uri.fragment}');
    if (uri.scheme == 'clarifi' && uri.host == 'reset-password') {
      final code = uri.queryParameters['code'];
      if (code != null) {
        try {
          //print('Exchanging code for session...');
          await Supabase.instance.client.auth.exchangeCodeForSession(code);
          //print('Session exchanged successfully');
        } catch (e) {
          //print('Error exchanging code: $e');
        }
      } else {
        // Fallback to fragment parsing if needed
        final fragmentParams = Uri.splitQueryString(uri.fragment);
        final accessToken = fragmentParams['access_token'];
        final type = fragmentParams['type'];

        if (accessToken != null && type == 'recovery') {
          try {
            //print('Setting session from fragment...');
            await Supabase.instance.client.auth.setSession(accessToken);
            //print('Session set successfully');
          } catch (e) {
            //print('Error setting session: $e');
          }
        }
      }

      //print('Navigating to /reset-password');
      _router?.go('/reset-password');
    } else {
      //print('Link does not match criteria');
    }
  }

  @override
  Widget build(BuildContext context) {
    // Using MultiProvider to set up the dependency injection for the ViewModels
    return MultiProvider(
      providers: [
        // The SupabaseService will be available to all ViewModels
        Provider<SupabaseService>(
          create: (_) => SupabaseService(Supabase.instance.client),
        ),
        // AuthViewModel depends on SupabaseService
        ChangeNotifierProvider<AuthViewModel>(
          create: (context) => AuthViewModel(context.read<SupabaseService>()),
        ),
        // HomeViewModel depends on SupabaseService
        ChangeNotifierProvider<HomeViewModel>(
          create: (context) => HomeViewModel(context.read<SupabaseService>()),
        ),
        // TransactionViewModel depends on SupabaseService
        ChangeNotifierProvider<TransactionViewModel>(
          create: (context) => TransactionViewModel(context.read<SupabaseService>()),
        ),
        // AccountViewModel depends on SupabaseAccountRepository
        ChangeNotifierProvider<AccountViewModel>(
          create: (context) => AccountViewModel(
            SupabaseAccountRepository(Supabase.instance.client),
          ),
        ),
        ChangeNotifierProvider(create: (context)=> BudgetViewModel(
          SupabaseBudgetRepository(Supabase.instance.client),
        )),
      ],
      child: Builder(
        builder: (context) {
          // The router needs access to the AuthViewModel for redirection
          _router = AppRouter(context.read<AuthViewModel>()).router;

          // Handle initial link after router is created
          WidgetsBinding.instance.addPostFrameCallback((_) async {
            final initialLink = await _appLinks.getInitialLink();
            if (initialLink != null) {
              _handleLink(initialLink.toString());
            }
          });

          return MaterialApp.router(
            title: 'Clarifi App',
            theme: ThemeData(
              primarySwatch: Colors.blue,
              visualDensity: VisualDensity.adaptivePlatformDensity,
            ),
            routerConfig: _router,
          );
        }
      ),
    );
  }
}