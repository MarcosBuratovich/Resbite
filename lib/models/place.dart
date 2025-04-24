import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:json_annotation/json_annotation.dart';

part 'place.freezed.dart';
part 'place.g.dart';

@freezed
class Place with _$Place {
  const factory Place({
    required String id,
    required String name,
    String? address,
    double? latitude,
    double? longitude,
    String? description,
    @Default([]) List<String> amenities,
    String? website,
    String? phone,
    Map<String, dynamic>? openingHours,
    @Default([]) List<String> images,
    String? addedById,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) = _Place;

  factory Place.fromJson(Map<String, dynamic> json) => _$PlaceFromJson(json);
  
  static Place fromFirebase(Map<String, dynamic> json, String id) {
    // Handle latitude and longitude from Firebase GeoPoint
    double? lat;
    double? lng;
    if (json['latLng'] != null) {
      lat = json['latLng'].latitude;
      lng = json['latLng'].longitude;
    }
    
    // Convert Firebase arrays to List<String>
    List<String> amenitiesList = [];
    if (json['amenities'] != null && json['amenities'] is List) {
      amenitiesList = List<String>.from(json['amenities']);
    }
    
    List<String> imagesList = [];
    if (json['images'] != null && json['images'] is List) {
      imagesList = List<String>.from(json['images']);
    }
    
    return Place(
      id: id,
      name: json['name'] ?? '',
      address: json['address'],
      latitude: lat,
      longitude: lng,
      description: json['description'],
      amenities: amenitiesList,
      website: json['website'],
      phone: json['phone'],
      openingHours: json['openingHours'],
      images: imagesList,
      addedById: json['addedBy']?.id,
      createdAt: json['createdAt'] != null 
          ? (json['createdAt'] as dynamic).toDate() 
          : DateTime.now(),
    );
  }
  
  static Place fromSupabase(Map<String, dynamic> json) {
    // Parse location from PostGIS point if available
    double? lat;
    double? lng;
    if (json['location'] != null) {
      // Check if it's already parsed as an object
      if (json['location'] is Map) {
        lat = json['location']['coordinates'][1];
        lng = json['location']['coordinates'][0];
      } 
      // Or if it's a string like POINT(lng lat)
      else if (json['location'] is String && json['location'].startsWith('POINT')) {
        final pointStr = json['location'].replaceAll('POINT(', '').replaceAll(')', '');
        final coords = pointStr.split(' ');
        if (coords.length == 2) {
          lng = double.tryParse(coords[0]);
          lat = double.tryParse(coords[1]);
        }
      }
    }
    
    // Handle explicit lat/lng fields
    if (lat == null && json['latitude'] != null) {
      lat = json['latitude'].toDouble();
    }
    if (lng == null && json['longitude'] != null) {
      lng = json['longitude'].toDouble();
    }
    
    // Parse amenities from JSON
    List<String> amenitiesList = [];
    if (json['amenities'] != null) {
      if (json['amenities'] is List) {
        amenitiesList = List<String>.from(json['amenities']);
      }
    }
    
    // Parse images from JSON
    List<String> imagesList = [];
    if (json['images'] != null) {
      if (json['images'] is List) {
        imagesList = List<String>.from(json['images']);
      }
    }
    
    return Place(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      address: json['address'],
      latitude: lat,
      longitude: lng,
      description: json['description'],
      amenities: amenitiesList,
      website: json['website'],
      phone: json['phone'],
      openingHours: json['opening_hours'],
      images: imagesList,
      addedById: json['added_by'],
      createdAt: json['created_at'] != null 
          ? DateTime.parse(json['created_at']) 
          : null,
      updatedAt: json['updated_at'] != null 
          ? DateTime.parse(json['updated_at']) 
          : null,
    );
  }
}