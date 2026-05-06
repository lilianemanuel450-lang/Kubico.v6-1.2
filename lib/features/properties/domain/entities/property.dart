import 'package:equatable/equatable.dart';

class Property extends Equatable {
  final String id;
  final String title;
  final String description;
  final double price;
  final String type; // 'rent' | 'sell'
  final String propertyType; // 'house' | 'apartment' | 'land' | 'commercial'
  final double latitude;
  final double longitude;
  final String address;
  final String neighborhood;
  final List<String> images;
  final int bedrooms;
  final int bathrooms;
  final double area; // m²
  final String ownerId;
  final String ownerPhone;
  final bool isAvailable;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const Property({
    required this.id,
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
    this.isAvailable = true,
    required this.createdAt,
    this.updatedAt,
  });

  String get formattedPrice {
    final kz = price.toStringAsFixed(0).replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (m) => '${m[1]}.',
        );
    return '$kz Kz${type == 'rent' ? '/mês' : ''}';
  }

  String get typeLabel => type == 'rent' ? 'Arrendamento' : 'Venda';

  String get propertyTypeLabel {
    switch (propertyType) {
      case 'house':
        return 'Casa';
      case 'apartment':
        return 'Apartamento';
      case 'land':
        return 'Terreno';
      case 'commercial':
        return 'Comercial';
      default:
        return propertyType;
    }
  }

  String get mainImage =>
      images.isNotEmpty ? images.first : 'https://via.placeholder.com/400x300';

  @override
  List<Object?> get props => [
        id,
        title,
        description,
        price,
        type,
        propertyType,
        latitude,
        longitude,
        address,
        neighborhood,
        images,
        bedrooms,
        bathrooms,
        area,
        ownerId,
        ownerPhone,
        isAvailable,
        createdAt,
        updatedAt,
      ];
}
