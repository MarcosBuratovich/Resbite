import 'package:freezed_annotation/freezed_annotation.dart';

import 'activity.dart';
import 'place.dart';
import 'user.dart';

part 'resbite.freezed.dart';
part 'resbite.g.dart';

enum ResbiteStatus { planned, active, completed, cancelled }

@freezed
abstract class Resbite with _$Resbite {
  const factory Resbite({
    required String id,
    required String title,
    String? description,
    required DateTime startDate,
    required DateTime endDate,
    @Default(false) bool isMultiDay,
    String? meetingPoint,
    double? meetingLatitude,
    double? meetingLongitude,
    int? attendanceLimit,
    @Default(0) int currentAttendance,
    String? note,
    @Default(ResbiteStatus.planned) ResbiteStatus status,
    @Default(false) bool isPrivate,
    @Default([]) List<String> images,
    String? activityId,
    Activity? activity,
    String? ownerId,
    User? owner,
    String? placeId,
    Place? place,
    DateTime? createdAt,
    DateTime? updatedAt,
    @Default([]) List<User> participants,
  }) = _Resbite;

  factory Resbite.fromJson(Map<String, dynamic> json) =>
      _$ResbiteFromJson(json);

  static Resbite fromFirebase(
    Map<String, dynamic> json,
    String id, {
    Activity? activity,
    User? owner,
    Place? place,
    List<User>? participants,
  }) {
    // Handle meeting location if available
    double? meetingLat;
    double? meetingLng;
    if (json['placeLatLong'] != null) {
      meetingLat = json['placeLatLong'].latitude;
      meetingLng = json['placeLatLong'].longitude;
    }

    // Convert Firebase arrays to List<String>
    List<String> imagesList = [];
    if (json['images'] != null && json['images'] is List) {
      imagesList = List<String>.from(json['images']);
    }

    // Parse dates
    DateTime startDate;
    if (json['startDate'] != null) {
      startDate = (json['startDate'] as dynamic).toDate();
    } else {
      startDate = DateTime.now();
    }

    DateTime endDate;
    if (json['endDate'] != null) {
      endDate = (json['endDate'] as dynamic).toDate();
    } else {
      endDate = startDate.add(const Duration(hours: 2));
    }

    // Parse status
    ResbiteStatus status = ResbiteStatus.planned;
    if (json['status'] != null) {
      switch (json['status'].toString().toLowerCase()) {
        case 'active':
          status = ResbiteStatus.active;
          break;
        case 'completed':
          status = ResbiteStatus.completed;
          break;
        case 'cancelled':
          status = ResbiteStatus.cancelled;
          break;
        default:
          status = ResbiteStatus.planned;
      }
    }

    return Resbite(
      id: id,
      title: json['title'] ?? 'Resbite',
      description: json['description'],
      startDate: startDate,
      endDate: endDate,
      isMultiDay: json['isMultiDay'] ?? false,
      meetingPoint: json['meetingPoint'],
      meetingLatitude: meetingLat,
      meetingLongitude: meetingLng,
      attendanceLimit: json['attendanceLimit'],
      note: json['note'],
      status: status,
      isPrivate: json['isPrivate'] ?? false,
      images: imagesList,
      activityId: json['activityId']?.id,
      activity: activity,
      ownerId: json['ownerId']?.id,
      owner: owner,
      placeId: json['placeResbite']?.id,
      place: place,
      createdAt:
          json['createdAt'] != null
              ? (json['createdAt'] as dynamic).toDate()
              : DateTime.now(),
      participants: participants ?? [],
    );
  }

  static Resbite fromSupabase(
    Map<String, dynamic> json, {
    Activity? activity,
    User? owner,
    Place? place,
    List<User>? participants,
  }) {
    // Parse meeting location from PostGIS point if available
    double? meetingLat;
    double? meetingLng;
    if (json['meeting_location'] != null) {
      // Check if it's already parsed as an object
      if (json['meeting_location'] is Map) {
        meetingLat = json['meeting_location']['coordinates'][1];
        meetingLng = json['meeting_location']['coordinates'][0];
      }
      // Or if it's a string like POINT(lng lat)
      else if (json['meeting_location'] is String &&
          json['meeting_location'].startsWith('POINT')) {
        final pointStr = json['meeting_location']
            .replaceAll('POINT(', '')
            .replaceAll(')', '');
        final coords = pointStr.split(' ');
        if (coords.length == 2) {
          meetingLng = double.tryParse(coords[0]);
          meetingLat = double.tryParse(coords[1]);
        }
      }
    }

    // Parse images from JSON
    List<String> imagesList = [];
    if (json['images'] != null) {
      if (json['images'] is List) {
        imagesList = List<String>.from(json['images']);
      }
    }

    // Parse dates
    DateTime startDate;
    if (json['start_date'] != null) {
      startDate = DateTime.parse(json['start_date']);
    } else {
      startDate = DateTime.now();
    }

    DateTime endDate;
    if (json['end_date'] != null) {
      endDate = DateTime.parse(json['end_date']);
    } else {
      endDate = startDate.add(const Duration(hours: 2));
    }

    // Parse status
    ResbiteStatus status = ResbiteStatus.planned;
    if (json['status'] != null) {
      switch (json['status'].toString().toLowerCase()) {
        case 'active':
          status = ResbiteStatus.active;
          break;
        case 'completed':
          status = ResbiteStatus.completed;
          break;
        case 'cancelled':
          status = ResbiteStatus.cancelled;
          break;
        default:
          status = ResbiteStatus.planned;
      }
    }

    return Resbite(
      id: json['id'] ?? '',
      title: json['title'] ?? 'Resbite',
      description: json['description'],
      startDate: startDate,
      endDate: endDate,
      isMultiDay: json['is_multi_day'] ?? false,
      meetingPoint: json['meeting_point'],
      meetingLatitude: meetingLat,
      meetingLongitude: meetingLng,
      attendanceLimit: json['attendance_limit'],
      currentAttendance: json['current_attendance'] ?? 0,
      note: json['note'],
      status: status,
      isPrivate: json['is_private'] ?? false,
      images: imagesList,
      activityId: json['activity_id'],
      activity: activity,
      ownerId: json['owner_id'],
      owner: owner,
      placeId: json['place_id'],
      place: place,
      createdAt:
          json['created_at'] != null
              ? DateTime.parse(json['created_at'])
              : DateTime.now(),
      updatedAt:
          json['updated_at'] != null
              ? DateTime.parse(json['updated_at'])
              : DateTime.now(),
      participants: participants ?? [],
    );
  }
}
