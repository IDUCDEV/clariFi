
// Based on the 'budgets' table
class BudgetModel {
  final String? id;
  final String? name;
  final double? amount;
  final String? period;
  final String? userId;
  final String? categoryId;
  final DateTime? startDate;
  final DateTime? endDate;
  final double? alertThreshold;
  final DateTime? createdAt;

  BudgetModel({
    this.id,
    this.name,
    this.amount,
    this.period,
    this.userId,
    this.categoryId,
    this.startDate,
    this.endDate,
    this.alertThreshold,
    this.createdAt,
  });

  factory BudgetModel.fromJson(Map<String, dynamic> json) {
    return BudgetModel(
      id: json['id'] != null ? json['id'] as String : null,
      name: json['name'] != null ? json['name'] as String : null,
      amount: json['amount'] != null ? (json['amount'] as num).toDouble() : null,
      period: json['period'] != null ? json['period'] as String : null,
      userId: json['user_id'] != null ? json['user_id'] as String : null,
      categoryId: json['category_id'] != null ? json['category_id'] as String : null,
      startDate: json['start_date'] != null ? DateTime.parse(json['start_date'] as String) : null,
      endDate: json['end_date'] != null ? DateTime.parse(json['end_date'] as String) : null,
      alertThreshold: json['alert_threshold'] != null ? (json['alert_threshold'] as num).toDouble() : null,
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at'] as String) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'amount': amount,
      'period': period,
      'user_id': userId,
      'category_id': categoryId,
      'start_date': startDate?.toIso8601String().split('T').first,
      'end_date': endDate?.toIso8601String().split('T').first,
      'alert_threshold': alertThreshold,
      'created_at': createdAt?.toIso8601String().split('T').first,
    };
  }
}
