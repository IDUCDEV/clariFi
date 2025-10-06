import 'package:clarifi_app/src/services/supabase_service.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthViewModel extends ChangeNotifier {
  final SupabaseService _supabaseService;
  bool _isAuthenticated = false;
  bool get isAuthenticated => _isAuthenticated;


  AuthViewModel(this._supabaseService) {
    // Check initial auth state
    _isAuthenticated = _supabaseService.supabase.auth.currentSession != null;
    _supabaseService.supabase.auth.onAuthStateChange.listen((authState) {
      _isAuthenticated = authState.session != null;
      notifyListeners();
    });
  }

  Future<AuthResponse?> signUp(
    String email,
    String password,
    String userName,
    String fullName,
    String country,
    String currency,
  ) async {
    try {
      final res = await _supabaseService.signUp(
        email,
        password,
        userName,
        fullName,
        country,
        currency,
      );
      return res;
    } catch (e) {
      return null;
    }
  }

  Future<AuthResponse?> login(String email, String password) async {
    try {
      final res = await _supabaseService.login(email, password);
      return res;
    } catch (e) {
      return null;
    }
  }

  Future<void> logout() async {
    await _supabaseService.logout();
  }

  Future<Map<String, dynamic>?> recoverPassword(String email) async {
    try {
      final res = await _supabaseService.recoverPassword(email);
      if (res) {
        return {
          'success': true,
          'message': 'Correo de recuperación enviado correctamente. Revisa tu bandeja de entrada.'
        };
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }

  Future<bool> updatePassword(String password) async {
    try {
      final res = await _supabaseService.updatePassword(password);
      return res;
    } catch (e) {
      return false;
    }
  }
}
