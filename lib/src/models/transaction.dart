// lib/src/models/transaction.dart

// Modelo basado en la tabla 'transactions' y soportando joins para accounts/categories
class TransactionModel {
  final String id;
  final String userId;
  final String accountId;
  final String type;
  final double amount;
  final DateTime date;
  final String? categoryId;
  final String? note;
  final String? currency;
  final String? recurringRule;
  final Map<String, dynamic>? metadata;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  // Campos adicionales (provistos por joins: accounts(name), categories(name))
  final String? accountName;
  final String? categoryName;

  TransactionModel({
    required this.id,
    required this.userId,
    required this.accountId,
    required this.type,
    required this.amount,
    required this.date,
    this.categoryId,
    this.note,
    this.currency,
    this.recurringRule,
    this.metadata,
    this.createdAt,
    this.updatedAt,
    this.accountName,
    this.categoryName,
  });

  /// Permite crear una copia modificada (útil para editar localmente antes de enviar)
  TransactionModel copyWith({
    String? id,
    String? userId,
    String? accountId,
    String? type,
    double? amount,
    DateTime? date,
    String? categoryId,
    String? note,
    String? currency,
    String? recurringRule,
    Map<String, dynamic>? metadata,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? accountName,
    String? categoryName,
  }) {
    return TransactionModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      accountId: accountId ?? this.accountId,
      type: type ?? this.type,
      amount: amount ?? this.amount,
      date: date ?? this.date,
      categoryId: categoryId ?? this.categoryId,
      note: note ?? this.note,
      currency: currency ?? this.currency,
      recurringRule: recurringRule ?? this.recurringRule,
      metadata: metadata ?? this.metadata,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      accountName: accountName ?? this.accountName,
      categoryName: categoryName ?? this.categoryName,
    );
  }

  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    // Si Supabase devuelve joins como maps: 'accounts': {'name': '...'}
    String? accountName;
    String? categoryName;

    try {
      if (json['accounts'] != null && json['accounts'] is Map) {
        accountName = (json['accounts'] as Map)['name']?.toString();
      }
    } catch (_) {}

    try {
      if (json['categories'] != null && json['categories'] is Map) {
        categoryName = (json['categories'] as Map)['name']?.toString();
      }
    } catch (_) {}

    return TransactionModel(
      id: json['id']?.toString() ?? '',
      userId: json['user_id']?.toString() ?? '',
      accountId: json['account_id']?.toString() ?? '',
      type: json['type']?.toString() ?? '',
      amount: (json['amount'] is num) ? (json['amount'] as num).toDouble() : double.tryParse('${json['amount']}') ?? 0.0,
      date: _parseDate(json['date']),
      categoryId: json['category_id']?.toString(),
      note: json['note']?.toString(),
      currency: json['currency']?.toString(),
      recurringRule: json['recurring_rule']?.toString(),
      metadata: json['metadata'] != null ? Map<String, dynamic>.from(json['metadata']) : null,
      createdAt: _parseNullableDate(json['created_at']),
      updatedAt: _parseNullableDate(json['updated_at']),
      accountName: accountName,
      categoryName: categoryName,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'account_id': accountId,
      'type': type,
      'amount': amount,
      'date': date.toIso8601String(),
      'category_id': categoryId,
      'note': note,
      'currency': currency,
      'recurring_rule': recurringRule,
      'metadata': metadata,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      // NOTA: accountName y categoryName vienen de joins, no se deben enviar al servidor
    };
  }

  // Helpers para parseo seguro de fechas
  static DateTime _parseDate(dynamic val) {
    if (val is DateTime) return val;
    if (val is int) return DateTime.fromMillisecondsSinceEpoch(val);
    if (val is String) {
      try {
        return DateTime.parse(val);
      } catch (_) {
        // fallback: try parse as int string
        final i = int.tryParse(val);
        if (i != null) return DateTime.fromMillisecondsSinceEpoch(i);
      }
    }
    return DateTime.now();
  }

  static DateTime? _parseNullableDate(dynamic val) {
    if (val == null) return null;
    try {
      return _parseDate(val);
    } catch (_) {
      return null;
    }
  }
}
