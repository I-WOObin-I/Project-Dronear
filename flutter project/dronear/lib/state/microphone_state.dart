import 'dart:async';
import 'dart:math';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../services/microphone_service.dart';
import 'package:fftea/fftea.dart';
import '../utils/logger.dart';

class MicrophoneState extends ChangeNotifier {
  final MicrophoneService _microphoneService = MicrophoneService();

  bool _isRecording = false;
  double _lastVolume = -100.0;

  // Spectrogram configuration
  final int sampleRate = 48000;
  final int nFft = 1024;
  final int hopLength = 512;

  final List<double> _pcmBuffer = [];
  final List<List<double>> _spectrogram = [];

  // Store the latest computed spectrum
  List<double> _currentFrequencySpectrum = [];

  StreamSubscription<Uint8List>? _pcmSubscription;

  Future<void> init() async {
    await _microphoneService.init();
  }

  Future<bool> requestPermission() async {
    var status = await Permission.microphone.request();
    return status.isGranted;
  }

  Future<void> startRecording() async {
    if (_isRecording) return;

    if (!await requestPermission()) {
      throw Exception('Microphone permission not granted');
    }

    _spectrogram.clear();
    _pcmBuffer.clear();
    _currentFrequencySpectrum = [];

    final stream = await _microphoneService.startRecording();
    if (stream != null) {
      _isRecording = true;
      notifyListeners();

      _pcmSubscription = stream.listen((data) {
        _lastVolume = _calculateVolumeDb(data);
        _appendToBuffer(data);
        _computeCurrentFrequencySpectrum();
        notifyListeners();
      });
    }
  }

  Future<void> stopRecording() async {
    if (_isRecording) {
      await _pcmSubscription?.cancel();
      await _microphoneService.stopRecording();
      _isRecording = false;
      _lastVolume = -100.0;
      _currentFrequencySpectrum = [];
      notifyListeners();
    }
  }

  /// Calculate volume in dBFS (decibels relative to full scale), typical of sound tools.
  /// - 0 dBFS = max amplitude, silence is a large negative number (e.g., -90 dB).
  /// - For 16-bit PCM, full scale is 32768.
  double _calculateVolumeDb(Uint8List data) {
    if (data.isEmpty) return -100.0;

    double sum = 0.0;
    int sampleCount = data.length ~/ 2;

    for (int i = 0; i < data.length - 1; i += 2) {
      int sample = data[i] | (data[i + 1] << 8);
      if (sample >= 0x8000) sample -= 0x10000;
      sum += sample * sample;
    }

    double rms = sqrt(sum / sampleCount);
    // dBFS: 0 dB is max, silence is -infinity (we clamp for display)
    // To avoid log(0), add a tiny value
    double dbfs = 20 * log(rms / 32768.0 + 1e-10) / ln10;
    return dbfs.isFinite ? double.parse(dbfs.toStringAsFixed(2)) : -100.0;
  }

  void _appendToBuffer(Uint8List data) {
    for (int i = 0; i < data.length - 1; i += 2) {
      int sample = data[i] | (data[i + 1] << 8);
      if (sample >= 0x8000) sample -= 0x10000;
      _pcmBuffer.add(sample.toDouble());
    }
    // Always keep only the last nFft samples for current spectrum calculation
    if (_pcmBuffer.length > nFft) {
      _pcmBuffer.removeRange(0, _pcmBuffer.length - nFft);
    }
  }

  List<double> _applyHannWindow(List<double> frame) {
    return List.generate(
      frame.length,
      (i) => frame[i] * (0.5 - 0.5 * cos(2 * pi * i / (frame.length - 1))),
    );
  }

  /// Use fftea package for FFT, return magnitude spectrum
  List<double> _computeFFT(List<double> input) {
    final fft = FFT(nFft);
    final spectrum = fft.realFft(input);
    // Calculate magnitude
    final mag = List<double>.generate(nFft ~/ 2, (i) {
      final re = spectrum[i].x;
      final im = spectrum[i].y;
      return sqrt(re * re + im * im);
    });
    return mag;
  }

  /// Computes and stores the current frequency spectrum (magnitude in dB) of the latest audio frame.
  void _computeCurrentFrequencySpectrum() {
    logger.i(
      'Computing current frequency spectrum from PCM buffer of length: ${_pcmBuffer.length}',
    );
    if (_pcmBuffer.length < nFft) {
      _currentFrequencySpectrum = [];
      return;
    }
    final window = _pcmBuffer.sublist(_pcmBuffer.length - nFft, _pcmBuffer.length);
    final windowed = _applyHannWindow(window);

    final fft = FFT(nFft);
    final spectrum = fft.realFft(windowed);

    _currentFrequencySpectrum = List.generate(nFft ~/ 2, (i) {
      final re = spectrum[i].x;
      final im = spectrum[i].y;
      final mag = sqrt(re * re + im * im);
      // dBFS: 0 dB is max, so spectrum is negative for most signals
      return 20 * log(mag / (nFft * 32768.0) + 1e-10) / ln10; // dBFS
    });
    logger.i('Computed current frequency spectrum: $_currentFrequencySpectrum');
  }

  /// Returns the most recently computed frequency spectrum (magnitude in dB).
  /// Returns an empty list if there is not enough data.
  List<double> getCurrentFrequencySpectrum() => _currentFrequencySpectrum;

  // Accessors
  double get getVolume => _lastVolume;
  bool get isRecording => _isRecording;
  List<List<double>> get spectrogram => _spectrogram;
}
