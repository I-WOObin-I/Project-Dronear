// import 'package:sms_advanced/sms_advanced.dart';
// import 'package:permission_handler/permission_handler.dart';

// class SmsServiceProvider {
//   Future<bool> _checkAndRequestPermission() async {
//     var status = await Permission.sms.status;
//     if (!status.isGranted) {
//       status = await Permission.sms.request();
//     }
//     return status.isGranted;
//   }

//   /// Sends an SMS automatically. Returns true if sent successfully, false otherwise.
//   Future<bool> sendSms(String phoneNumber, String message) async {
//     bool permissionGranted = await _checkAndRequestPermission();
//     if (!permissionGranted) {
//       throw Exception('SMS permission not granted');
//     }

//     try {
//       SmsSender sender = SmsSender();
//       sender.sendSms(SmsMessage(phoneNumber, message));
//       return true;
//     } catch (e) {
//       // Optionally log or handle the error
//       return false;
//     }
//   }
// }
