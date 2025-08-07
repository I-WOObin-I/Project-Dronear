import 'package:http/http.dart' as http;
import 'dart:convert';

class UserApiService {
  final String baseUrl;

  UserApiService({required this.baseUrl});

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

  /// Add other endpoint methods as needed...
}
