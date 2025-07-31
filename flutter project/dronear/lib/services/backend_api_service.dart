import 'package:http/http.dart' as http;
import 'dart:convert';

class BackendApiService {
  final String baseUrl;

  BackendApiService({required this.baseUrl});

  /// Generic POST request
  Future<Map<String, dynamic>> post(
    String endpoint, {
    Map<String, String>? headers,
    Map<String, dynamic>? body,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl$endpoint'),
      headers: headers ?? {'Content-Type': 'application/json'},
      body: json.encode(body ?? {}),
    );
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return json.decode(response.body);
    } else {
      throw Exception('POST to $endpoint failed: ${response.statusCode} ${response.body}');
    }
  }

  /// Generic GET request
  Future<Map<String, dynamic>> get(String endpoint, {Map<String, String>? headers}) async {
    final response = await http.get(
      Uri.parse('$baseUrl$endpoint'),
      headers: headers ?? {'Content-Type': 'application/json'},
    );
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return json.decode(response.body);
    } else {
      throw Exception('GET from $endpoint failed: ${response.statusCode} ${response.body}');
    }
  }

  /// Example: Send email through backend API
  Future<bool> sendEmail({
    required String recipient,
    required String subject,
    required String body,
  }) async {
    final result = await post(
      '/send-email',
      body: {'recipient': recipient, 'subject': subject, 'body': body},
    );
    // Adjust according to your backend's response structure
    return result['success'] == true;
  }

  /// Add other endpoint methods as needed...
}
