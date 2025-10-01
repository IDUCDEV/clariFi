// Based on the 'exports' table
class ExportModel {
  final String id;
  final String userId;
  final String type;
  final String filePath;
  final Map<String, dynamic> params;
  final DateTime? createdAt;

  ExportModel({
    required this.id,
    required this.userId,
    required this.type,
    required this.filePath,
    required this.params,
    this.createdAt,
  });

  factory ExportModel.fromJson(Map<String, dynamic> json) {
    return ExportModel(
      id: json['id'],
      userId: json['user_id'],
      type: json['type'],
      filePath: json['file_path'],
      params: Map<String, dynamic>.from(json['params']),
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'type': type,
      'file_path': filePath,
      'params': params,
      'created_at': createdAt?.toIso8601String(),
    };
  }
}