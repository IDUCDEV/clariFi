import 'dart:developer' as developer;

import 'package:supabase_flutter/supabase_flutter.dart';
import '../../models/account.dart';
import '../../services/currency_conversion_service.dart';
import 'account_repository.dart';

/// Implementación del repositorio de cuentas usando Supabase
/// Maneja todas las operaciones CRUD con la base de datos
class SupabaseAccountRepository implements AccountRepository {
  final SupabaseClient _supabase;
  
  SupabaseAccountRepository(this._supabase);
  
  /// Obtiene el ID del usuario actual autenticado
  String? get _currentUserId => _supabase.auth.currentUser?.id;
  
  @override
  Future<List<AccountModel>> getAccounts() async {
    try {
      final userId = _currentUserId;
      if (userId == null) {
        throw Exception('Usuario no autenticado');
      }
      
      final response = await _supabase
          .from('accounts')
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false);
      
      return (response as List)
          .map((json) => AccountModel.fromJson(json))
          .toList();
          
    } catch (e) {
      throw Exception('Error al obtener cuentas: $e');
    }
  }
  
  @override
  Future<void> createAccount({
    required String name,
    required String type,
    required String currency,
    double balance = 0.0,
    bool isDefault = false,
  }) async {
    try {
      final userId = _currentUserId;
      
      if (userId == null) {
        throw Exception('Usuario no autenticado');
      }
      
      // Verificar si el nombre ya existe
      final nameExists = await accountNameExists(name);
      if (nameExists) {
        throw Exception('Ya existe una cuenta con el nombre "$name"');
      }
      
      // Si esta cuenta se marca como predeterminada, desmarcar las demás
      if (isDefault) {
        await _unsetOtherDefaultAccounts(userId);
      }
      
      // Crear la cuenta
      await _supabase.from('accounts').insert({
        'user_id': userId,
        'name': name,
        'type': type,
        'currency': currency,
        'balance': balance,
        'is_default': isDefault,
      });
      
    } on PostgrestException catch (e) {
      if (e.code == '23505') {
        throw Exception('Ya existe una cuenta con ese nombre');
      }
      throw Exception('Error al crear cuenta: ${e.message}');
    } catch (e) {
      developer.log('❌ DEBUG - Exception: $e', name: 'SupabaseAccountRepository', level: 800);
      rethrow;
    }
  }
  
  @override
  Future<bool> accountNameExists(String name) async {
    try {
      final userId = _currentUserId;
      if (userId == null) {
        return false;
      }
      
      final response = await _supabase
          .from('accounts')
          .select('id')
          .eq('user_id', userId)
          .ilike('name', name)
          .maybeSingle();
      
      return response != null;
      
    } catch (e) {
      // Si hay error, asumimos que no existe
      return false;
    }
  }
  
  @override
  Future<void> updateAccount(AccountModel account) async {
    try {
      final userId = _currentUserId;
      if (userId == null) {
        throw Exception('Usuario no autenticado');
      }
      
      // Si esta cuenta se marca como predeterminada, desmarcar las demás
      if (account.isDefault == true) {
        await _unsetOtherDefaultAccounts(userId, exceptAccountId: account.id);
      }
      
      // Si el usuario cambió la moneda de la cuenta, debemos ajustar el balance
      // para preservar el valor real (no cambiar el monto consolidado).
      final existing = await getAccountById(account.id);
      Map<String, dynamic> updateData = account.toJson();

      if (existing != null && existing.currency != account.currency) {
  developer.log('🔁 updateAccount - currency change detected: ${existing.currency} -> ${account.currency}', name: 'SupabaseAccountRepository');

        // Si el usuario no modificó explícitamente el campo balance (el valor
        // numérico llegó igual), entonces convertimos el balance existente a la
        // nueva moneda para preservar el monto consolidado.
  double newBalance = account.balance;

  // Comparar valores redondeados a 2 decimales para evitar falsos
  // positivos por diferencias de punto flotante o formatos.
  int providedCents = (account.balance * 100).round();
  int existingCents = (existing.balance * 100).round();
  final bool balanceEdited = providedCents != existingCents;

  if (!balanceEdited) {
          final converter = CurrencyConversionService();
          try {
            await converter.updateExchangeRates();
          } catch (e) {
            developer.log('⚠️ updateAccount - No se pudieron actualizar tasas: $e', name: 'SupabaseAccountRepository', level: 900);
          }

          newBalance = converter.convert(
            amount: existing.balance,
            fromCurrency: existing.currency,
            toCurrency: account.currency,
          );
          newBalance = double.parse(newBalance.toStringAsFixed(2));
          developer.log('🔁 updateAccount - converted balance: $newBalance ${account.currency}', name: 'SupabaseAccountRepository');
        } else {
          // El usuario cambió el balance manualmente; respetamos su elección.
          developer.log('🔁 updateAccount - balance was edited by user; keeping provided value: ${account.balance} ${account.currency}', name: 'SupabaseAccountRepository');
        }

        updateData['balance'] = newBalance;
      }

      await _supabase
          .from('accounts')
          .update(updateData)
          .eq('id', account.id)
          .eq('user_id', userId); // Seguridad: solo puede actualizar sus propias cuentas
      
    } catch (e) {
      throw Exception('Error al actualizar cuenta: $e');
    }
  }
  
  @override
  Future<void> deleteAccount(String accountId) async {
    try {
      final userId = _currentUserId;
      if (userId == null) {
        throw Exception('Usuario no autenticado');
      }
      // Verificar que el usuario tenga más de una cuenta; no permitir eliminar
      // la única cuenta del usuario.
      try {
        final accountsResp = await _supabase
            .from('accounts')
            .select('id')
            .eq('user_id', userId)
            .limit(2); // Solo necesitamos saber si hay más de 1

        final accountsList = accountsResp as List;
        if (accountsList.length <= 1) {
          throw Exception('No se puede eliminar la única cuenta del usuario.');
        }
      } catch (e) {
        // Si detectamos que no hay otra cuenta, re-lanzamos la excepción para
        // que el flujo superior la maneje y muestre mensaje al usuario.
        if (e.toString().contains('No se puede eliminar la única cuenta')) rethrow;
        // Si la consulta falló por otra razón, seguimos (la validación más
        // estricta será aplicada por otras comprobaciones más abajo).
      }
      // Verificar si la cuenta tiene transacciones asociadas: si es así, no permitir eliminación
      try {
        final txResp = await _supabase
            .from('transactions')
            .select()
            .eq('account_id', accountId)
            .limit(1);

        final txList = txResp as List;
        if (txList.isNotEmpty) {
          throw Exception('La cuenta tiene transacciones asociadas y no puede ser eliminada.');
        }
      } catch (e) {
        // Si la consulta falla por cualquier razón, asumimos que no hay transacciones
        // y continuamos. Errores reales serán reportados por la llamada principal.
      }

      // Si la cuenta a eliminar es la cuenta por defecto, promover otra cuenta automáticamente
      try {
        final existing = await getAccountById(accountId);
        if (existing != null && (existing.isDefault ?? false) == true) {
          // Buscar otra cuenta del usuario para promover
          final others = await _supabase
              .from('accounts')
              .select()
              .eq('user_id', userId)
              .neq('id', accountId)
              .order('created_at', ascending: false)
              .limit(1);

          final othersList = others as List;
          if (othersList.isNotEmpty) {
            final promoteId = othersList.first['id'] as String;
            await _supabase
                .from('accounts')
                .update({'is_default': true})
                .eq('id', promoteId)
                .eq('user_id', userId);
            developer.log('🔁 deleteAccount - promoted account $promoteId as default', name: 'SupabaseAccountRepository');
          }
        }
      } catch (e) {
        developer.log('⚠️ deleteAccount - error while promoting default: $e', name: 'SupabaseAccountRepository', level: 900);
      }
      
      await _supabase
          .from('accounts')
          .delete()
          .eq('id', accountId)
          .eq('user_id', userId); // Seguridad: solo puede eliminar sus propias cuentas
      
    } catch (e) {
      throw Exception('Error al eliminar cuenta: $e');
    }
  }
  
  @override
  Future<AccountModel?> getAccountById(String accountId) async {
    try {
      final userId = _currentUserId;
      if (userId == null) {
        throw Exception('Usuario no autenticado');
      }
      
      final response = await _supabase
          .from('accounts')
          .select()
          .eq('id', accountId)
          .eq('user_id', userId)
          .maybeSingle();
      
      if (response == null) return null;
      
      return AccountModel.fromJson(response);
      
    } catch (e) {
      throw Exception('Error al obtener cuenta: $e');
    }
  }
  
  @override
  Future<void> transferBalance({
    required String fromAccountId,
    required String toAccountId,
  }) async {
    try {
      final userId = _currentUserId;
      if (userId == null) {
        throw Exception('Usuario no autenticado');
      }
      
      // Obtener ambas cuentas
      final fromAccount = await getAccountById(fromAccountId);
      final toAccount = await getAccountById(toAccountId);
      
      if (fromAccount == null) {
        throw Exception('Cuenta origen no encontrada');
      }
      
      if (toAccount == null) {
        throw Exception('Cuenta destino no encontrada');
      }
      
      // Calcular monto a sumar en la moneda de la cuenta destino.
      double amountToAdd = fromAccount.balance;
      if (fromAccount.currency != toAccount.currency) {
        final converter = CurrencyConversionService();
        try {
          await converter.updateExchangeRates();
        } catch (e) {
          developer.log('⚠️ transferBalance - No se pudieron actualizar tasas de cambio: $e', name: 'SupabaseAccountRepository', level: 900);
        }

        amountToAdd = converter.convert(
          amount: fromAccount.balance,
          fromCurrency: fromAccount.currency,
          toCurrency: toAccount.currency,
        );
  amountToAdd = double.parse(amountToAdd.toStringAsFixed(2));
  developer.log('🔁 transferBalance - converted amountToAdd=$amountToAdd ${toAccount.currency}', name: 'SupabaseAccountRepository');
      }

      // Calcular nuevo balance de la cuenta destino
      final newBalance = toAccount.balance + amountToAdd;

      // Actualizar el balance de la cuenta destino
      await _supabase
          .from('accounts')
          .update({'balance': newBalance})
          .eq('id', toAccountId)
          .eq('user_id', userId);
      
      // Nota: La cuenta origen se elimina después por el método deleteAccount
      
    } catch (e) {
      throw Exception('Error al transferir saldo: $e');
    }
  }
  
  /// Método privado para desmarcar otras cuentas como predeterminadas
  Future<void> _unsetOtherDefaultAccounts(
    String userId, {
    String? exceptAccountId,
  }) async {
    try {
      final query = _supabase
          .from('accounts')
          .update({'is_default': false})
          .eq('user_id', userId)
          .eq('is_default', true);
      
      // Si hay una cuenta a excluir, no actualizarla
      if (exceptAccountId != null) {
        query.neq('id', exceptAccountId);
      }
      
      await query;
      } catch (e) {
      // Si falla, no es crítico, continuamos
      developer.log('Advertencia: No se pudieron actualizar cuentas predeterminadas: $e', name: 'SupabaseAccountRepository', level: 900);
    }
  }
}
