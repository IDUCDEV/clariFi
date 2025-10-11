
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseBudgetRepository {

  final SupabaseClient _supabaseClient;

  SupabaseBudgetRepository(this._supabaseClient);

  // Example method using _supabaseClient
  Future<void> testConnection() async {
    await _supabaseClient.auth.refreshSession();
  }
}