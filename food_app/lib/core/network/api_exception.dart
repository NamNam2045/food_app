class ApiException implements Exception {
  ApiException({
    required this.message,
    this.errorCode,
    this.statusCode,
    this.details,
  });

  final String message;
  final String? errorCode;
  final int? statusCode;
  final List<String>? details;

  @override
  String toString() => message;
}
