import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  final SupabaseClient supabase = Supabase.instance.client;

  SupabaseService();

  /*
    authentication methods
  */
  Future<AuthResponse?> signUp(
    String email,
    String password,
    String userName,
    String fullName,
    String country,
    String currency,
  ) async {
    try {
      final res = await supabase.auth.signUp(
        email: email,
        password: password,
        data: {
          'user_name': userName,
          'full_name': fullName,
          'locale': country,
          'currency': currency,
        },
      );
      return res;
    } catch (e) {
      return null;
    }
  }

  Future<AuthResponse?> login(String email, String password) async {
    try {
      final res = await supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );
      return res;
    } catch (e) {
      return null;
    }
  }

  Future<void> logout() async {
    await supabase.auth.signOut();
  }


  Future<bool> recoverPassword(String email) async {
    try {
      await supabase.auth.resetPasswordForEmail(email);
      return true;
    } catch (e) {
      // Consider logging the error or handling it appropriately
      return false;
    }
  }
}