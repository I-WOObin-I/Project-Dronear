import 'package:flutter/foundation.dart';
import '../services/sms_service.dart';
import 'alerts_state.dart';
import '../utils/logger.dart';

enum SmsStatus { idle, sending, success, failed, permissionDenied }

class SmsState extends ChangeNotifier {
  AlertsState alertsState;
  final SmsService _smsService = SmsService();

  SmsStatus _status = SmsStatus.idle;
  String? _error;
  bool _lastSmsSuccess = false;

  SmsState(this.alertsState);

  SmsStatus get status => _status;
  String? get error => _error;
  bool get lastSmsSuccess => _lastSmsSuccess;

  Future<void> _sendSms() async {
    _error = 'implementation not working';
    notifyListeners();

    String phoneNumber = alertsState.getField(AlertsState.smsAlertNumberKey);
    String message = alertsState.getField(AlertsState.smsAlertContentKey);

    _status = SmsStatus.sending;
    _error = null;
    notifyListeners();

    _lastSmsSuccess = false;
    try {
      bool sent = await _smsService.sendSms(phoneNumber, message);
      if (sent) {
        _status = SmsStatus.success;
        _lastSmsSuccess = true;
        alertsState.setField(AlertsState.smsAlertLastKey, DateTime.now().toIso8601String());
      } else {
        _status = SmsStatus.failed;
        _error = 'SMS sending failed';
      }
    } on Exception catch (e) {
      if (e.toString().contains('permission')) {
        _status = SmsStatus.permissionDenied;
        _error = 'Permission denied: unable to send SMS';
      } else {
        _status = SmsStatus.failed;
        _error = e.toString();
      }
    }

    notifyListeners();
  }

  void reset() {
    _status = SmsStatus.idle;
    _error = null;
    _lastSmsSuccess = false;
  }

  Future<void> testSms() async {
    await _sendSms();
  }

  Future<void> alertSms() async {
    if (!isSmsEnabled()) return;
    await _sendSms();
  }

  bool isSmsEnabled() {
    bool smsEnabled = alertsState.getValue(AlertsState.smsAlertEnabledKey);
    if (!smsEnabled) {
      _status = SmsStatus.idle;
      _error = 'SMS alert is not enabled';
      notifyListeners();
      return false;
    }
    return true;
  }
}
