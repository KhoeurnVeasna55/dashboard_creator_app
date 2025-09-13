import 'package:dashboard_admin/models/pagination_meta.dart';

class AttributesModel {
  final List<Item> items;
  final PaginationMeta meta;

  AttributesModel({required this.items, required this.meta});

  factory AttributesModel.fromJson(Map<String, dynamic> json) {
    return AttributesModel(
      items: (json['items'] as List<dynamic>? ?? [])
          .map((x) => Item.fromJson(x as Map<String, dynamic>))
          .toList(),
      meta: PaginationMeta.fromJson(json["meta"] ?? {}),
    );
  }
}

class Item {
  final String id;
  final String name;
  final String code;
  final String type;
  final List<Value> values;
  final bool isActive;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Item({
    required this.id,
    required this.name,
    required this.code,
    required this.type,
    required this.values,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Item.fromJson(Map<String, dynamic> json) {
    return Item(
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
      code: json['code'] ?? '',
      type: json['type'] ?? '',
      values: (json['values'] as List<dynamic>? ?? [])
          .where((v) => v != null)
          .map((v) => Value.fromJson(v as Map<String, dynamic>))
          .toList(),
      isActive: json['isActive'] ?? false,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'])
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.tryParse(json['updatedAt'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'name': name,
      'code': code,
      'type': type,
      'values': values.map((x) => x.toJson()).toList(),
      'isActive': isActive,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }
}

class Value {
  final String id;
  final String label;
  final String value;
  final Meta? meta;

  Value({
    required this.id,
    required this.label,
    required this.value,
    this.meta,
  });

  factory Value.fromJson(Map<String, dynamic> json) {
    return Value(
      id: json['_id'] ?? '',
      label: json['label'] ?? '',
      value: json['value'] ?? '',
      meta: json['meta'] != null ? Meta.fromJson(json['meta']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'label': label,
      'value': value,
      if (meta != null) 'meta': meta!.toJson(),
    };
  }
}

class Meta {
  final dynamic swatch;

  Meta({this.swatch});

  factory Meta.fromJson(Map<String, dynamic> json) {
    return Meta(swatch: json['swatch']);
  }

  Map<String, dynamic> toJson() {
    return {'swatch': swatch};
  }
}
