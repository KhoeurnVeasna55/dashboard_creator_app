
class CloudinaryResponse {
  final String publicId;
  final String url;
  final String format;
  final int width;
  final int height;
  final int bytes;
  final String resourceType;

  CloudinaryResponse({
    required this.publicId,
    required this.url,
    required this.format,
    required this.width,
    required this.height,
    required this.bytes,
    required this.resourceType,
  });

  factory CloudinaryResponse.fromJson(Map<String, dynamic> json) {
    return CloudinaryResponse(
      publicId: json['public_id'] ?? '',
      url: json['url'] ?? '',
      format: json['format'] ?? '',
      width: json['width'] ?? 0,
      height: json['height'] ?? 0,
      bytes: json['bytes'] ?? 0,
      resourceType: json['resource_type'] ?? '',
    );
  }
  factory CloudinaryResponse.isEmpty() {
    return CloudinaryResponse(
      publicId: '',
      url: '',
      format: '',
      width: 0,
      height: 0,
      bytes: 0,
      resourceType: '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'public_id': publicId,
      'url': url,
      'format': format,
      'width': width,
      'height': height,
      'bytes': bytes,
      'resource_type': resourceType,
    };
  }
}

class CloudinaryException implements Exception {
  final String message;
  final int code;

  CloudinaryException({required this.message, required this.code});

  @override
  String toString() => 'CloudinaryException: $message (Code: $code)';
}
