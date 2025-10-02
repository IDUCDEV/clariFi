import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  final SupabaseClient supabase = Supabase.instance.client;

  SupabaseService();

  /*
    authentication methods
  */
  Future<AuthResponse> signUp(
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
      //print('Error en registro: $e');
      rethrow;
    }
  }
}