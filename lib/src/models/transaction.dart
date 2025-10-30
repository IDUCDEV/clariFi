class TransactionModel {
  final String id;
  final String? accountId;
  final String? budgetId;
  final String? categoryId;
  final String type;
  final double amount;
  final DateTime date;
  final String? note;
  final String? currency;
  final String? recurringRule;
  final Map<String, dynamic>? metadata;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final String? transferId;
  final String? accountName;
  final String? categoryName;

  TransactionModel({
    required this.id,
    this.accountId,
    this.budgetId,
    this.type = "expense",
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
    this.transferId,
  });

  TransactionModel copyWith({
    String? id,
    String? accountId,
    String? budgetId,
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
    String? transferId,
  }) {
    return TransactionModel(
      id: id ?? this.id,
      accountId: accountId ?? this.accountId,
      budgetId: budgetId ?? this.budgetId,
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
      transferId: transferId ?? this.transferId,
    );
  }

  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    String? accountName;
    String? categoryName;

    try {
      if (json['accounts'] is Map) {
        accountName = json['accounts']['name']?.toString();
      }
    } catch (_) {}

    try {
      if (json['categories'] is Map) {
        categoryName = json['categories']['name']?.toString();
      }
    } catch (_) {}

    return TransactionModel(
      id: json['id'] ?? '',
      accountId: json['account_id'],
      budgetId: json['budget_id'],
      categoryId: json['category_id'],
      type: json['type'],
      amount: (json['amount'] as num).toDouble(),
      date: _parseDate(json['date']),
      note: json['note'],
      currency: json['currency'],
      recurringRule: json['recurring_rule'],
      metadata: json['metadata'] != null
          ? Map<String, dynamic>.from(json['metadata'])
          : null,
      createdAt: _parseNullableDate(json['created_at']),
      updatedAt: _parseNullableDate(json['updated_at']),
      accountName: accountName,
      categoryName: categoryName,
      transferId: json['transfer_id'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'account_id': accountId,
      'budget_id': budgetId,
      'category_id': categoryId,
      'type': type,
      'amount': amount,
      'date': date.toIso8601String(),
      'note': note,
      'currency': currency,
      'recurring_rule': recurringRule,
      'metadata': metadata,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'transfer_id': transferId,
    };
  }

  static DateTime _parseDate(dynamic val) {
    if (val is DateTime) return val;
    if (val is String) return DateTime.parse(val);
    return DateTime.now();
  }

  static DateTime? _parseNullableDate(dynamic val) {
    if (val == null) return null;
    return _parseDate(val);
  }
}
