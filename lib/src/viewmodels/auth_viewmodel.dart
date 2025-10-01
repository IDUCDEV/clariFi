
import 'package:clarifi_app/src/services/supabase_service.dart';
import 'package:flutter/material.dart';

class AuthViewModel extends ChangeNotifier {
  final SupabaseService _supabaseService;
  bool _isAuthenticated = false;

  AuthViewModel(this._supabaseService) {
    // Check initial auth state
    _isAuthenticated = _supabaseService.client.auth.currentSession != null;
    _supabaseService.client.auth.onAuthStateChange.listen((authState) {
      _isAuthenticated = authState.session != null;
      notifyListeners();
    });
  }

  bool get isAuthenticated => _isAuthenticated;

  Future<void> signUp(String email, String password) async {
    try {
      await _supabaseService.client.auth.signUp(email: email, password: password);
    } catch (e) {
      // Handle error
      print(e);
    }
  }

  Future<void> login(String email, String password) async {
    try {
      await _supabaseService.client.auth.signInWithPassword(email: email, password: password);
    } catch (e) {
      // Handle error
      print(e);
    }
  }

  Future<void> signOut() async {
    await _supabaseService.client.auth.signOut();
  }
}
