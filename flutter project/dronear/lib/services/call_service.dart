import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart';

class CallServiceProvider {
  Future<bool> _checkAndRequestPermission() async {
    var status = await Permission.phone.status;
    if (!status.isGranted) {
      status = await Permission.phone.request();
    }
    return status.isGranted;
  }

  /// Initiates a phone call automatically. Returns true if call was launched, false otherwise.
  Future<bool> makeCall(String phoneNumber) async {
    bool permissionGranted = await _checkAndRequestPermission();
    if (!permissionGranted) {
      throw Exception('Phone call permission not granted');
    }

    try {
      bool? res = await FlutterPhoneDirectCaller.callNumber(phoneNumber);
      return res ?? false;
    } catch (e) {
      // Optionally log or handle the error
      return false;
    }
  }
}
