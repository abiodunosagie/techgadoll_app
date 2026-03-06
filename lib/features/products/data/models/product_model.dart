import 'package:equatable/equatable.dart';
import '../../../../core/utils/data_validators.dart';

class ProductModel extends Equatable {
  final int id;
  final String title;
  final String description;
  final String category;
  final double? price;
  final double discountPercentage;
  final double rating;
  final int stock;
  final String? brand;
  final String? thumbnail;
  final List<String> images;
  final String availabilityStatus;

  const ProductModel({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.price,
    required this.discountPercentage,
    required this.rating,
    required this.stock,
    this.brand,
    this.thumbnail,
    required this.images,
    required this.availabilityStatus,
  });

  double? get discountedPrice {
    if (price == null) return null;
    if (discountPercentage <= 0) return price;
    return price! * (1 - discountPercentage / 100);
  }

  bool get inStock => stock > 0;

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: json['id'] as int,
      title: DataValidators.safeString(json['title'] as String?, 'Untitled Product'),
      description: DataValidators.safeString(json['description'] as String?, ''),
      category: json['category'] as String? ?? '',
      price: DataValidators.safePrice(json['price']),
      discountPercentage: (json['discountPercentage'] as num?)?.toDouble() ?? 0.0,
      rating: DataValidators.safeRating(json['rating']),
      stock: json['stock'] as int? ?? 0,
      brand: json['brand'] as String?,
      thumbnail: DataValidators.safeImageUrl(json['thumbnail'] as String?),
      images: (json['images'] as List<dynamic>?)
              ?.map((e) => e as String)
              .where((url) => DataValidators.safeImageUrl(url) != null)
              .toList() ??
          [],
      availabilityStatus: json['availabilityStatus'] as String? ?? 'Unknown',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'category': category,
      'price': price,
      'discountPercentage': discountPercentage,
      'rating': rating,
      'stock': stock,
      'brand': brand,
      'thumbnail': thumbnail,
      'images': images,
      'availabilityStatus': availabilityStatus,
    };
  }

  @override
  List<Object?> get props => [id];
}
