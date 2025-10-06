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
      final response = await supabase.auth.resetPasswordForEmail(
        email,
        redirectTo: 'clarifi://reset-password',
      );

      return true;
    } catch (e) {
      //print('Error in recoverPassword: $e');
      return false;
    }
  }

  Future<bool> updatePassword(String password) async {
    try {
      await supabase.auth.updateUser(UserAttributes(password: password));
      return true;
    } catch (e) {
      //print('Error in updatePassword: $e');
      return false;
    }
  }
}
