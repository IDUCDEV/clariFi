import 'package:clarifi_app/src/routes/app_router.dart';
import 'package:clarifi_app/src/services/supabase_service.dart';
import 'package:clarifi_app/src/viewmodels/auth_viewmodel.dart';
import 'package:clarifi_app/src/viewmodels/home_viewmodel.dart';
import 'package:clarifi_app/src/viewmodels/transaction_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Load environment variables
  await dotenv.load(fileName: ".env");

  // Initialize Supabase
  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL']!,
    anonKey: dotenv.env['SUPABASE_ANON_KEY']!,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

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
      ],
      child: Builder(
        builder: (context) {
          // The router needs access to the AuthViewModel for redirection
          final router = AppRouter(context.read<AuthViewModel>()).router;
          
          return MaterialApp.router(
            title: 'Clarifi App',
            theme: ThemeData(
              primarySwatch: Colors.blue,
              visualDensity: VisualDensity.adaptivePlatformDensity,
            ),
            routerConfig: router,
          );
        }
      ),
    );
  }
}