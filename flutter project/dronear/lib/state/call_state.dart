import 'package:flutter/foundation.dart';
import '../services/call_service.dart';

enum CallStatus { idle, calling, success, failed, permissionDenied }

class CallState extends ChangeNotifier {
  final CallServiceProvider _callService;
  CallStatus _status = CallStatus.idle;
  String? _error;
  bool _lastCallSuccess = false;

  CallState(this._callService);

  CallStatus get status => _status;
  String? get error => _error;
  bool get lastCallSuccess => _lastCallSuccess;

  Future<void> makeCall(String phoneNumber) async {
    _status = CallStatus.calling;
    _error = null;
    _lastCallSuccess = false;
    notifyListeners();

    try {
      bool called = await _callService.makeCall(phoneNumber);
      if (called) {
        _status = CallStatus.success;
        _lastCallSuccess = true;
      } else {
        _status = CallStatus.failed;
        _error = 'Call initiation failed';
      }
    } on Exception catch (e) {
      if (e.toString().contains('permission')) {
        _status = CallStatus.permissionDenied;
        _error = 'Permission denied: unable to make call';
      } else {
        _status = CallStatus.failed;
        _error = e.toString();
      }
    }

    notifyListeners();
  }

  void reset() {
    _status = CallStatus.idle;
    _error = null;
    _lastCallSuccess = false;
    notifyListeners();
  }
}
