import 'package:clarifi_app/src/services/supabase_service.dart';
import 'package:flutter/material.dart';


class NotificationsViewmodel extends ChangeNotifier {
  final SupabaseService _supabaseService;
  NotificationsViewmodel(this._supabaseService);
}