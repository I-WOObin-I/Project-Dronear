import 'dart:async';
import 'package:flutter/foundation.dart';
import '../services/call_service.dart';
import 'alerts_state.dart';
import 'recogniser_state.dart';
import '../utils/logger.dart';

enum CallStatus { idle, calling, success, failed, permissionDenied, cooldown }

class CallState extends ChangeNotifier {
  RecogniserState recogniserState;
  AlertsState alertsState;
  final CallServiceProvider _callService = CallServiceProvider();

  CallStatus _status = CallStatus.idle;
  String? _error;
  bool _lastCallSuccess = false;
  bool _callInProgress = false;
  DateTime? _lastCallTime;
  Timer? _cooldownTimer;
  final Duration cooldownDuration;

  CallState(
    this.alertsState,
    this.recogniserState, {
    this.cooldownDuration = const Duration(seconds: 10),
  }) {
    recogniserState.addListener(_onRecognitionChanged);
  }

  CallStatus get status => _status;
  String? get error => _error;
  bool get lastCallSuccess => _lastCallSuccess;
  bool get isCoolingDown => _cooldownTimer?.isActive ?? false;

  void _onRecognitionChanged() async {
    if (recogniserState.recognitionPositive && isCallEnabled()) {
      if (_callInProgress || isCoolingDown) return;
      _callInProgress = true;
      _status = CallStatus.calling;
      notifyListeners();

      await alertCall();

      // Start cooldown after call attempt, regardless of result
      _startCooldown();
      _callInProgress = false;
    }
  }

  void _startCooldown() {
    _cooldownTimer?.cancel();
    _status = CallStatus.cooldown;
    notifyListeners();
    _cooldownTimer = Timer(cooldownDuration, () {
      _status = CallStatus.idle;
      notifyListeners();
    });
    _lastCallTime = DateTime.now();
  }

  Future<void> _makeCall() async {
    String phoneNumber = alertsState.getField(AlertsState.callAlertNumberKey);

    _error = null;
    notifyListeners();

    _lastCallSuccess = false;
    try {
      bool called = await _callService.makeCall(phoneNumber);
      if (called) {
        _status = CallStatus.success;
        _lastCallSuccess = true;
        alertsState.setField(AlertsState.callAlertLastKey, DateTime.now().toIso8601String());
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
    _callInProgress = false;
    _cooldownTimer?.cancel();
    notifyListeners();
  }

  Future<void> testCall() async {
    await _makeCall();
  }

  Future<void> alertCall() async {
    if (!isCallEnabled()) return;
    await _makeCall();
  }

  bool isCallEnabled() {
    bool callEnabled = alertsState.getValue(AlertsState.callAlertEnabledKey);
    if (!callEnabled) {
      _status = CallStatus.idle;
      _error = 'Call alert is not enabled';
      notifyListeners();
      return false;
    }
    return true;
  }

  @override
  void dispose() {
    recogniserState.removeListener(_onRecognitionChanged);
    _cooldownTimer?.cancel();
    super.dispose();
  }
}
