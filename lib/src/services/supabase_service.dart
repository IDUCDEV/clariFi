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
      final response = await supabase.auth.resetPasswordForEmail(
        email,
        redirectTo: 'clarifi://reset-password',
      );

      return {
        'success': true,
        'message': 'Correo de recuperación enviado correctamente. Revisa tu bandeja de entrada.'
      };
    } on AuthException catch (e) {
      // Errores específicos de Supabase
      String errorMessage;
      
      switch (e.message) {
        case 'User not found':
          errorMessage = 'No existe una cuenta con este email.';
          break;
        case 'Email rate limit exceeded':
          errorMessage = 'Demasiados intentos. Espera unos minutos.';
          break;
        default:
          errorMessage = e.message;
      }
      
      return {
        'success': false,
        'message': errorMessage,
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Error de conexión. Verifica tu internet e intenta nuevamente.',
      };
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