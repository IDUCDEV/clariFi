// Based on the 'users' table in the design document
class UserModel {
  final String id;
  final String email;
  final String? userName;
  final String? fullName;
  final String locale;
  final String currency;
  final String? createdAt;
  final String? updatedAt;

  UserModel({
    required this.id,
    required this.email,
    required this.userName,
    required this.fullName,
    required this.locale,
    required this.currency,
    this.createdAt,
    this.updatedAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      email: json['email'],
      userName: json['user_name'],
      fullName: json['full_name'],
      locale: json['locale'],
      currency: json['currency'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'user_name': userName,
      'full_name': fullName,
      'locale': locale,
      'currency': currency,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }
}
