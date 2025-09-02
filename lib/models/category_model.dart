class CategoryModel {
  final String? id;
  final String? name;
  final String? description;
  final bool? isActive;
  final String? imageUrl;
  final String? slug;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final int? version;

  CategoryModel({
    this.id,
    this.name,
    this.description,
    this.isActive,
    this.imageUrl,
    this.slug,
    this.createdAt,
    this.updatedAt,
    this.version,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['_id'],
      name: json['name'],
      description: json['description'],
      isActive: json['isActive'],
      imageUrl: json['imageUrl'],
      slug: json['slug'],
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
      updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
      version: json['__v'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'name': name,
      'description': description,
      'isActive': isActive,
      'imageUrl': imageUrl,
      'slug': slug,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      '__v': version,
    };
  }
}

class CategoriesResponseModel {
  final List<CategoryModel>? items;
  final int? page;
  final int? limit;
  final int? total;
  final int? pages;

  CategoriesResponseModel({
    this.items,
    this.page,
    this.limit,
    this.total,
    this.pages,
  });

  factory CategoriesResponseModel.fromJson(Map<String, dynamic> json) {
    return CategoriesResponseModel(
      items: json['items'] != null
          ? (json['items'] as List<dynamic>)
              .map((item) => CategoryModel.fromJson(item as Map<String, dynamic>))
              .toList()
          : null,
      page: json['page'],
      limit: json['limit'],
      total: json['total'],
      pages: json['pages'],
    );
  }
}