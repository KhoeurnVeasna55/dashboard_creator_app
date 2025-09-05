import 'dart:developer'; // for logging
import 'package:http/http.dart' as http;
import 'package:http/retry.dart';

class ApiClient {
  static final http.Client _client = _createClient();

  static http.Client _createClient() {
    final client = http.Client();
    return RetryClient(
      client,
      retries: 10,
      whenError: (error, stackTrace) {
        log('[RetryClient] Request failed with error: $error',name: "ApiClient");
        // retry on all errors
        return true;
      },
      onRetry: (request, response, retryCount) {
        log('[RetryClient] Retrying request #$retryCount → ${request.method} ${request.url}',name: "ApiClient");
        if (response != null) {
          log('[RetryClient] Previous attempt failed with status code: ${response.statusCode}',name: "ApiClient");
        }
      },
    );
  }

  static http.Client get instance => _client;
}
