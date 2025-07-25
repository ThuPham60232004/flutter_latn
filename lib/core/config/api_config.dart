class ApiConfig {
  static const String baseUrl =
      'https://fastapi-service-748034725478.europe-west4.run.app/api';

  static const String createCheckProcess = '/create-check-process';
  static const String trackCheckProcess = '/track-check-process';
  static const Duration connectionTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);
  static const Map<String, String> defaultHeaders = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };
  static String buildUrl(String endpoint) {
    return '$baseUrl$endpoint';
  }
}
