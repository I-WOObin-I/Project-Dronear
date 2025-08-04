import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import '../utils/logger.dart';

/// Holds only bitmap data for UI widgets, and cyclic buffer for current spectrogram frames.
/// - No stateful spectrogram logic except for pixel calculation and cyclic buffer.
/// - Use [addFrames] to add a batch of frames (e.g. 32 at a time).
class SpectrogramBitmapState extends ChangeNotifier {
  int _bitmapHeight = 0;
  int _bitmapWidth = 0;

  late Uint8List _spectrogramBitmap;
  int _bitmapWriteX = 0;

  // Rolling cyclic buffer of spectrogram frames (for UI/hover, not for audio logic)
  final List<List<double>> _spectrogram = [];

  SpectrogramBitmapState();

  /// Dynamically initialize dimensions and buffers.
  void init({required int bitmapHeight, required int bitmapWidth}) {
    _bitmapHeight = bitmapHeight;
    _bitmapWidth = bitmapWidth;
    _spectrogramBitmap = Uint8List(_bitmapWidth * _bitmapHeight * 4);
    _bitmapWriteX = 0;
    _spectrogram.clear();
    notifyListeners();
  }

  int get maxFrames => _bitmapWidth;

  /// Clears bitmap and spectrogram buffers.
  void reset() {
    _bitmapWriteX = 0;
    if (_spectrogramBitmap.isNotEmpty) {
      _spectrogramBitmap.fillRange(0, _spectrogramBitmap.length, 0);
    }
    _spectrogram.clear();
    notifyListeners();
  }

  /// Add a batch of frames (each [frame] is List<double> length bitmapHeight).
  void addFrames(List<List<double>> frames) {
    logger.d('Adding ${frames.length} frames to bitmap state with length ${frames[0].length}');

    if (_bitmapWidth == 0 || _bitmapHeight == 0) return; // Not initialized
    for (final frame in frames) {
      // Update cyclic buffer: keep at most bitmapWidth frames
      _spectrogram.add(List.from(frame));
      if (_spectrogram.length > _bitmapWidth) {
        _spectrogram.removeRange(0, _spectrogram.length - _bitmapWidth);
      }
      _putSpectrogramFrameToBitmap(frame);
    }
    notifyListeners();
  }

  /// Converts a normalized dB value to ARGB color.
  static int _colorForDb(double db) {
    // final norm = ((db + 80) / 80).clamp(0.0, 1.0);
    final v = (db * 255).round();
    if (v < 128) {
      return (255 << 24) | ((v * 2) << 16); // Red shades
    } else {
      int rv = 255;
      int gv = ((v - 128) * 2).clamp(0, 255).toInt();
      return (255 << 24) | (rv << 16) | (gv << 8) | gv;
    }
  }

  /// Writes a single spectrogram frame into the bitmap at current X, then advances X cyclically.
  void _putSpectrogramFrameToBitmap(List<double> frame) {
    for (int y = 0; y < _bitmapHeight; y++) {
      int color = _colorForDb(frame[y]);
      int pixelOffset = (y * _bitmapWidth + _bitmapWriteX) * 4;
      _spectrogramBitmap[pixelOffset + 0] = (color >> 16) & 0xFF; // R
      _spectrogramBitmap[pixelOffset + 1] = (color >> 8) & 0xFF; // G
      _spectrogramBitmap[pixelOffset + 2] = color & 0xFF; // B
      _spectrogramBitmap[pixelOffset + 3] = (color >> 24) & 0xFF; // A
    }
    _bitmapWriteX = (_bitmapWriteX + 1) % _bitmapWidth;
  }

  /// Expose current bitmap for UI.
  Uint8List get bitmap => _spectrogramBitmap;
  int get bitmapWriteX => _bitmapWriteX;
  int get width => _bitmapWidth;
  int get height => _bitmapHeight;

  /// Expose the current rolling buffer of frames (for hover/highlight UI).
  List<List<double>> get frames => _spectrogram;
}
