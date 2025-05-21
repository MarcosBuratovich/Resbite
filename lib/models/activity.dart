import 'package:freezed_annotation/freezed_annotation.dart';

import 'category.dart';

part 'activity.freezed.dart';
part 'activity.g.dart';

@freezed
abstract class Activity with _$Activity {
  const factory Activity({
    required String id,
    required String title,
    String? description,
    String? emoji,
    String? imageUrl,
    int? duration,
    @Default([]) List<String> benefits,
    @Default([]) List<String> tips,
    int? minAge,
    int? maxAge,
    String? difficulty,
    double? estimatedCost,
    @Default(true) bool isActive,
    @Default(false) bool featured,
    String? createdById,
    String? createdByName,
    DateTime? createdAt,
    DateTime? updatedAt,
    @Default([]) List<Category> categories,
    @Default({}) Map<String, String> details,
  }) = _Activity;

  factory Activity.fromJson(Map<String, dynamic> json) =>
      _$ActivityFromJson(json);

  static Activity fromFirebase(Map<String, dynamic> json, String id) {
    // Convert Firebase arrays to List<String>
    List<String> benefitsList = [];
    if (json['benefits'] != null && json['benefits'] is List) {
      benefitsList = List<String>.from(json['benefits']);
    }

    List<String> tipsList = [];
    if (json['tips'] != null && json['tips'] is List) {
      tipsList = List<String>.from(json['tips']);
    }

    return Activity(
      id: id,
      title: json['title'] ?? '',
      description: json['description'],
      emoji: json['emoji'],
      imageUrl: json['imageUrl'],
      duration: json['duration'],
      benefits: benefitsList,
      tips: tipsList,
      minAge: json['minAge'],
      maxAge: json['maxAge'],
      difficulty: json['difficulty'],
      estimatedCost: json['estimatedCost']?.toDouble(),
      isActive: json['isActive'] ?? true,
      createdById: json['userId']?.id,
      createdAt:
          json['createdAt'] != null
              ? (json['createdAt'] as dynamic).toDate()
              : DateTime.now(),
    );
  }

  static Activity fromSupabase(
    Map<String, dynamic> json, [
    List<Category>? categories,
  ]) {
    // Parse benefits and tips from JSON or String
    List<String> benefitsList = [];
    if (json['benefits'] != null) {
      if (json['benefits'] is List) {
        benefitsList = List<String>.from(json['benefits']);
      } else if (json['benefits'] is String) {
        // If benefits is stored as a string, parse it
        final String benefitsStr = json['benefits'];
        if (benefitsStr.startsWith('[') && benefitsStr.endsWith(']')) {
          benefitsList = List<String>.from(
            benefitsStr
                .substring(1, benefitsStr.length - 1)
                .split(',')
                .map((e) => e.trim()),
          );
        }
      }
    }

    List<String> tipsList = [];
    if (json['tips'] != null) {
      if (json['tips'] is List) {
        tipsList = List<String>.from(json['tips']);
      } else if (json['tips'] is String) {
        // If tips is stored as a string, parse it
        final String tipsStr = json['tips'];
        if (tipsStr.startsWith('[') && tipsStr.endsWith(']')) {
          tipsList = List<String>.from(
            tipsStr
                .substring(1, tipsStr.length - 1)
                .split(',')
                .map((e) => e.trim()),
          );
        }
      }
    }

    return Activity(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'],
      emoji: json['emoji'],
      imageUrl: json['image_url'],
      duration: json['duration'],
      benefits: benefitsList,
      tips: tipsList,
      minAge: json['min_age'],
      maxAge: json['max_age'],
      difficulty: json['difficulty'],
      estimatedCost: json['estimated_cost']?.toDouble(),
      isActive: json['is_active'] ?? true,
      createdById: json['created_by'],
      createdAt:
          json['created_at'] != null
              ? DateTime.parse(json['created_at'])
              : null,
      updatedAt:
          json['updated_at'] != null
              ? DateTime.parse(json['updated_at'])
              : null,
      categories: categories ?? [],
    );
  }
}
