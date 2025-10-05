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


Future<Map<String, dynamic>> recoverPassword(String email) async {
  try {
    await supabase.auth.resetPasswordForEmail(email);

    return {
      'success': true,
      'message': 'Correo de recuperación enviado correctamente.'
    };
  } on AuthException catch (e) {
    // Errores conocidos de Supabase (por ejemplo, email no registrado)
    return {
      'success': false,
      'message': e.message,
    };
  } catch (e) {
    // Otros errores (red, configuración, etc.)
    return {
      'success': false,
      'message': 'Ha ocurrido un error inesperado. Inténtalo más tarde.',
    };
  }
}

}