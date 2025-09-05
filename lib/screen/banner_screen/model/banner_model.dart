import 'package:dashboard_admin/models/pagination_meta.dart';

class BannerModel {
  final String? title;
  final String? subtitle;
  final String? description;
  final String? imageUrl;
  final String? linkUrl;
  final int? position;
  final bool? isActive;
  final DateTime? startDate;
  final DateTime? endDate;

  const BannerModel({
    this.title,
    this.subtitle,
    this.description,
    this.imageUrl,
    this.linkUrl,
    this.position,
    this.isActive,
    this.startDate,
    this.endDate,
  });

  factory BannerModel.fromJson(Map<String, dynamic> json) {
    return BannerModel(
      title: json["title"],
      subtitle: json["subtitle"],
      description: json["description"],
      imageUrl: json["imageUrl"],
      linkUrl: json["linkUrl"],
      position: json["position"],
      isActive: json["isActive"],
      startDate: json["startDate"] == null
          ? null
          : DateTime.tryParse(json["startDate"]),
      endDate: json["endDate"] == null
          ? null
          : DateTime.tryParse(json["endDate"]),
    );
  }
}

class PaginatedBanner {
  final List<BannerModel> items;
  final PaginationMeta meta;

  PaginatedBanner({required this.items, required this.meta});

  factory PaginatedBanner.fromJson(Map<String, dynamic> j) => PaginatedBanner(
    items: (j["items"] as List).map((e) => BannerModel.fromJson(e)).toList(),
    meta: PaginationMeta.fromJson(j["meta"]),
  );
}
