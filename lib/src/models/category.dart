// Based on the 'categories' table
class CategoryModel {
  final String id;
  final String name;
  final String type;
  final String userId;
  final String color;
  final String icon;
  

  CategoryModel({
    required this.id,
    required this.name,
    required this.type,
    required this.userId,
    required this.color,
    required this.icon,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['id'],
      name: json['name'],
      type: json['type'],
      userId: json['user_id'],
      color: json['color'],
      icon: json['icon'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'type': type,
      'user_id': userId,
      'color': color,
      'icon': icon,
    };
  }
}
