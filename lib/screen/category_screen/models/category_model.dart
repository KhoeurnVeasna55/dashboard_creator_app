
import 'package:dashboard_admin/models/pagination_meta.dart';

class Category {
  final String id;
  final String name;
  final String? description;
  final String slug;
  final bool isActive;
  final String? imageUrl;
  final DateTime createdAt;
  final DateTime updatedAt;

  Category({
    required this.id,
    required this.name,
    this.description,
    required this.slug,
    required this.isActive,
    this.imageUrl,
    required this.createdAt,
    required this.updatedAt,
  });

  Category copyWith(
      {bool? isActive, String? name, String? description, String? imageUrl}) {
    return Category(
      id: id,
      name: name ?? this.name,
      description: description ?? this.description,
      slug: slug,
      isActive: isActive ?? this.isActive,
      imageUrl: imageUrl ?? this.imageUrl,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  factory Category.fromJson(Map<String, dynamic> j) => Category(
        id: j["_id"] as String,
        name: j["name"] as String,
        description: j["description"] as String?,
        slug: j["slug"] as String,
        isActive: j["isActive"] as bool,
        imageUrl: j["imageUrl"] as String?,
        createdAt: DateTime.parse(j["createdAt"] as String),
        updatedAt: DateTime.parse(j["updatedAt"] as String),
      );
}

class PaginatedCategories {
  final List<Category> items;
  final PaginationMeta meta;

  PaginatedCategories({required this.items, required this.meta});

  factory PaginatedCategories.fromJson(Map<String, dynamic> j) =>
      PaginatedCategories(
        items: (j["items"] as List).map((e) => Category.fromJson(e)).toList(),
        meta: PaginationMeta.fromJson(j["meta"]),
      );
}
