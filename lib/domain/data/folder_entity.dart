import 'package:dart_scope_functions/dart_scope_functions.dart';

final class FolderEntity {
  final int? id;
  final String name;
  final DateTime createdAt;

  const FolderEntity({
    this.id,
    required this.name,
    required this.createdAt,
  });

  factory FolderEntity.fromJson(Map<String, Object?> json) {
    return FolderEntity(
      id: json['id'] as int?,
      name: json['name'] as String,
      createdAt: (json['created_at'] as String).let(DateTime.parse),
    );
  }

  Map<String, Object?> toJson() {
    return {
      if (id != null) 'id': id,
      'name': name,
      'created_at': createdAt.toIso8601String(),
    };
  }

  FolderEntity copyWith({
    int? id,
    String? name,
    DateTime? createdAt,
  }) {
    return FolderEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
