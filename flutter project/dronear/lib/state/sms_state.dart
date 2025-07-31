// import 'package:flutter/foundation.dart';
// import '../services/sms_service.dart';

// enum SmsStatus { idle, sending, sent, failed, permissionDenied }

// class SmsState extends ChangeNotifier {
//   final SmsServiceProvider _smsService;
//   SmsStatus _status = SmsStatus.idle;
//   String? _error;
//   bool _lastSentSuccess = false;

//   SmsState(this._smsService);

//   SmsStatus get status => _status;
//   String? get error => _error;
//   bool get lastSentSuccess => _lastSentSuccess;

//   Future<void> sendSms(String phoneNumber, String message) async {
//     _status = SmsStatus.sending;
//     _error = null;
//     _lastSentSuccess = false;
//     notifyListeners();

//     try {
//       bool sent = await _smsService.sendSms(phoneNumber, message);
//       if (sent) {
//         _status = SmsStatus.sent;
//         _lastSentSuccess = true;
//       } else {
//         _status = SmsStatus.failed;
//         _error = 'SMS sending failed';
//       }
//     } on Exception catch (e) {
//       if (e.toString().contains('permission')) {
//         _status = SmsStatus.permissionDenied;
//         _error = 'Permission denied: unable to send SMS';
//       } else {
//         _status = SmsStatus.failed;
//         _error = e.toString();
//       }
//     }

//     notifyListeners();
//   }

//   void reset() {
//     _status = SmsStatus.idle;
//     _error = null;
//     _lastSentSuccess = false;
//     notifyListeners();
//   }
// }
