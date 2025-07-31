import 'package:flutter/foundation.dart';
import '../services/backend_api_service.dart';

enum ApiStatus { idle, loading, success, error }

class BackendApiState extends ChangeNotifier {
  final BackendApiService api;
  ApiStatus _status = ApiStatus.idle;
  String? _error;
  dynamic _lastData;

  ApiStatus get status => _status;
  String? get error => _error;
  dynamic get lastData => _lastData;

  BackendApiState(this.api);

  /// Example: Trigger sending email
  Future<void> sendEmail({
    required String recipient,
    required String subject,
    required String body,
  }) async {
    _status = ApiStatus.loading;
    _error = null;
    _lastData = null;
    notifyListeners();

    try {
      bool result = await api.sendEmail(recipient: recipient, subject: subject, body: body);
      if (result) {
        _status = ApiStatus.success;
        _lastData = result;
      } else {
        _status = ApiStatus.error;
        _error = 'Email sending failed';
      }
    } catch (e) {
      _status = ApiStatus.error;
      _error = e.toString();
    }
    notifyListeners();
  }

  /// Generic GET request
  Future<void> get(String endpoint) async {
    _status = ApiStatus.loading;
    _error = null;
    _lastData = null;
    notifyListeners();

    try {
      final data = await api.get(endpoint);
      _status = ApiStatus.success;
      _lastData = data;
    } catch (e) {
      _status = ApiStatus.error;
      _error = e.toString();
    }
    notifyListeners();
  }

  /// Generic POST request
  Future<void> post(String endpoint, {Map<String, dynamic>? body}) async {
    _status = ApiStatus.loading;
    _error = null;
    _lastData = null;
    notifyListeners();

    try {
      final data = await api.post(endpoint, body: body);
      _status = ApiStatus.success;
      _lastData = data;
    } catch (e) {
      _status = ApiStatus.error;
      _error = e.toString();
    }
    notifyListeners();
  }

  void reset() {
    _status = ApiStatus.idle;
    _error = null;
    _lastData = null;
    notifyListeners();
  }
}
