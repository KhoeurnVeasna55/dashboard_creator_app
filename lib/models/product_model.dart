import 'package:dashboard_admin/models/category_model.dart';

class ProductModel {
  final String? id;
  final String? name;
  final String? description;
  final double? price;
  final List<String>? imageUrls;
  final int? stock;
  final String? brand;
  final CategoryModel? category;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  ProductModel({
    this.id,
    this.name,
    this.description,
    this.price,
    this.imageUrls,
    this.stock,
    this.brand,
    this.category,
    this.createdAt,
    this.updatedAt,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: json['_id'],
      name: json['name'],
      description: json['description'],
      price: (json['price'] as num?)?.toDouble(),
      imageUrls: json['imageUrl'] != null
          ? List<String>.from(json['imageUrl'])
          : null,

      stock: (json['stock'] as num?)?.toInt(),
      brand: json['brand'] as String?,
      category: json['categoryId'] != null
          ? CategoryModel.fromJson(json['categoryId'])
          : null,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'])
          : null,
    );
  }
}
