// Based on the 'accounts' table
class AccountModel {
  final String id;
  final String userId;
  final String name;
  final String type;
  final String currency;
  final double balance;
  final bool? isDefault;
  final String? createdAt;

  AccountModel({
    required this.id,
    required this.userId,
    required this.name,
    required this.type,
    required this.currency,
    required this.balance,
    this.createdAt,
    this.isDefault,
  });

  factory AccountModel.fromJson(Map<String, dynamic> json) {
    return AccountModel(
      id: json['id'],
      userId: json['user_id'],
      name: json['name'],
      type: json['type'],
      currency: json['currency'],
      balance: (json['balance'] as num).toDouble(),
      isDefault: json['is_default'],
      createdAt: json['created_at'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'name': name,
      'type': type,
      'currency': currency,
      'balance': balance,
      'is_default': isDefault,
      'created_at': createdAt,
    };
  }
  
  AccountModel copyWith({
    String? id,
    String? userId,
    String? name,
    String? type,
    String? currency,
    double? balance,
    bool? isDefault,
    String? createdAt,
  }) {
    return AccountModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      type: type ?? this.type,
      currency: currency ?? this.currency,
      balance: balance ?? this.balance,
      isDefault: isDefault ?? this.isDefault,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
