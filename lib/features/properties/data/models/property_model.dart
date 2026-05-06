import '../../domain/entities/property.dart';

// Cache model simples - sem Isar, sem code generation
class PropertyModel {
  final String propertyId;
  final String title;
  final String description;
  final double price;
  final String type;
  final String propertyType;
  final double latitude;
  final double longitude;
  final String address;
  final String neighborhood;
  final List<String> images;
  final int bedrooms;
  final int bathrooms;
  final double area;
  final String ownerId;
  final String ownerPhone;
  final bool isAvailable;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final DateTime cachedAt;

  PropertyModel({
    required this.propertyId,
    required this.title,
    required this.description,
    required this.price,
    required this.type,
    required this.propertyType,
    required this.latitude,
    required this.longitude,
    required this.address,
    required this.neighborhood,
    required this.images,
    required this.bedrooms,
    required this.bathrooms,
    required this.area,
    required this.ownerId,
    required this.ownerPhone,
    required this.isAvailable,
    required this.createdAt,
    this.updatedAt,
    required this.cachedAt,
  });

  factory PropertyModel.fromEntity(Property entity) => PropertyModel(
    propertyId: entity.id,
    title: entity.title,
    description: entity.description,
    price: entity.price,
    type: entity.type,
    propertyType: entity.propertyType,
    latitude: entity.latitude,
    longitude: entity.longitude,
    address: entity.address,
    neighborhood: entity.neighborhood,
    images: List<String>.from(entity.images),
    bedrooms: entity.bedrooms,
    bathrooms: entity.bathrooms,
    area: entity.area,
    ownerId: entity.ownerId,
    ownerPhone: entity.ownerPhone,
    isAvailable: entity.isAvailable,
    createdAt: entity.createdAt,
    updatedAt: entity.updatedAt,
    cachedAt: DateTime.now(),
  );

  factory PropertyModel.fromJson(Map<String, dynamic> json) => PropertyModel(
    propertyId: json['id'] as String,
    title: json['title'] as String,
    description: json['description'] as String? ?? '',
    price: (json['price'] as num).toDouble(),
    type: json['type'] as String,
    propertyType: json['property_type'] as String,
    latitude: (json['latitude'] as num).toDouble(),
    longitude: (json['longitude'] as num).toDouble(),
    address: json['address'] as String? ?? '',
    neighborhood: json['neighborhood'] as String? ?? '',
    images: List<String>.from(json['images'] as List? ?? []),
    bedrooms: json['bedrooms'] as int? ?? 0,
    bathrooms: json['bathrooms'] as int? ?? 0,
    area: (json['area'] as num?)?.toDouble() ?? 0.0,
    ownerId: json['owner_id'] as String,
    ownerPhone: json['owner_phone'] as String? ?? '',
    isAvailable: json['is_available'] as bool? ?? true,
    createdAt: DateTime.parse(json['created_at'] as String),
    updatedAt: json['updated_at'] != null ? DateTime.parse(json['updated_at'] as String) : null,
    cachedAt: DateTime.now(),
  );

  Property toEntity() => Property(
    id: propertyId,
    title: title,
    description: description,
    price: price,
    type: type,
    propertyType: propertyType,
    latitude: latitude,
    longitude: longitude,
    address: address,
    neighborhood: neighborhood,
    images: images,
    bedrooms: bedrooms,
    bathrooms: bathrooms,
    area: area,
    ownerId: ownerId,
    ownerPhone: ownerPhone,
    isAvailable: isAvailable,
    createdAt: createdAt,
    updatedAt: updatedAt,
  );

  Map<String, dynamic> toJson() => {
    'id': propertyId,
    'title': title,
    'description': description,
    'price': price,
    'type': type,
    'property_type': propertyType,
    'latitude': latitude,
    'longitude': longitude,
    'address': address,
    'neighborhood': neighborhood,
    'images': images,
    'bedrooms': bedrooms,
    'bathrooms': bathrooms,
    'area': area,
    'owner_id': ownerId,
    'owner_phone': ownerPhone,
    'is_available': isAvailable,
    'created_at': createdAt.toIso8601String(),
    if (updatedAt != null) 'updated_at': updatedAt!.toIso8601String(),
  };
}
