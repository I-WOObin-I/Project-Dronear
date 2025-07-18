import 'dart:async';
import 'dart:typed_data';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:permission_handler/permission_handler.dart';

class MicrophoneService {
  final FlutterSoundRecorder _recorder = FlutterSoundRecorder();

  bool _isRecording = false;
  StreamController<Uint8List>? _pcmStreamController;

  Future<void> init() async {
    _pcmStreamController = StreamController<Uint8List>();
    await _requestPermission();
  }

  Future<bool> _requestPermission() async {
    var status = await Permission.microphone.request();
    return status.isGranted;
  }

  Future<Stream<Uint8List>?> startRecording() async {
    if (_isRecording) return _pcmStreamController?.stream;

    if (!await _requestPermission()) {
      throw Exception('Microphone permission not granted');
    }

    _pcmStreamController?.close(); // ensure clean state
    _pcmStreamController = StreamController<Uint8List>();

    await _recorder.openRecorder();
    await _recorder.startRecorder(
      codec: Codec.pcm16,
      numChannels: 1,
      sampleRate: 48000,
      toStream: _pcmStreamController!.sink,
    );

    _isRecording = true;
    return _pcmStreamController!.stream;
  }

  Future<void> stopRecording() async {
    if (_isRecording) {
      await _recorder.stopRecorder();
      await _recorder.closeRecorder();
      _isRecording = false;
      await _pcmStreamController?.close();
      _pcmStreamController = null;
    }
  }
}
