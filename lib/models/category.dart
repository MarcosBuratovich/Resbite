import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:json_annotation/json_annotation.dart';

part 'category.freezed.dart';
part 'category.g.dart';

@freezed
class Category with _$Category {
  const factory Category({
    required String id,
    required String name,
    String? description,
    String? emoji,
    String? color,
    String? icon,
    int? displayOrder,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) = _Category;

  factory Category.fromJson(Map<String, dynamic> json) => _$CategoryFromJson(json);
  
  static Category fromFirebase(Map<String, dynamic> json, String id) {
    return Category(
      id: id,
      name: json['name'] ?? '',
      description: json['description'],
      emoji: json['emoji'],
      color: json['color'],
      displayOrder: json['displayOrder'] ?? json['order'],
      createdAt: json['createdAt'] != null 
          ? (json['createdAt'] as dynamic).toDate() 
          : DateTime.now(),
    );
  }
  
  static Category fromSupabase(Map<String, dynamic> json) {
    return Category(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'],
      emoji: json['emoji'],
      color: json['color'],
      icon: json['icon'],
      displayOrder: json['display_order'],
      createdAt: json['created_at'] != null 
          ? DateTime.parse(json['created_at']) 
          : null,
      updatedAt: json['updated_at'] != null 
          ? DateTime.parse(json['updated_at']) 
          : null,
    );
  }
}