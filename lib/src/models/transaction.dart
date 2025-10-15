class TransactionModel {
  final String id;
  final String userId;
  final String accountId;
  final String type; // 'income' o 'expense'
  final double amount;
  final DateTime date;
  final String? categoryId;
  final String? note;
  final String? currency;
  final String? recurringRule;
  final Map<String, dynamic>? metadata;
  final DateTime? createdAt;
  final DateTime? updatedAt;

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

  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    return TransactionModel(
      id: json['id'],
      userId: json['user_id'],
      accountId: json['account_id'],
      type: json['type'],
      amount: (json['amount'] as num).toDouble(),
      date: DateTime.parse(json['date']),
      categoryId: json['category_id'],
      note: json['note'],
      currency: json['currency'],
      recurringRule: json['recurring_rule'],
      metadata: json['metadata'] != null ? Map<String, dynamic>.from(json['metadata']) : null,
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at']) : null,
      updatedAt: json['updated_at'] != null ? DateTime.parse(json['updated_at']) : null,
      // 🧩 Aquí vienen los nombres desde Supabase JOIN
      accountName: (json['accounts'] is Map) ? json['accounts']['name'] : null,
      categoryName: (json['categories'] is Map) ? json['categories']['name'] : null,
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
    };
  }
}
