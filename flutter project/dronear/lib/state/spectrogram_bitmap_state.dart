import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/foundation.dart';
import '../utils/logger.dart';

class SpectrogramBitmapState extends ChangeNotifier {
  int _bitmapHeight = 0;
  int _bitmapWidth = 0;

  late Uint8List _spectrogramBitmap;
  int _bitmapCurrentCollumn = 0;
  ui.Image? _image;

  SpectrogramBitmapState();

  void init({required int bitmapHeight, required int bitmapWidth}) {
    _bitmapHeight = bitmapHeight;
    _bitmapWidth = bitmapWidth;
    _spectrogramBitmap = Uint8List(_bitmapWidth * _bitmapHeight * 4);
    _bitmapCurrentCollumn = 0;
    // Fill with opaque black pixels: ARGB = [0, 0, 0, 255]
    for (int i = 0; i < _spectrogramBitmap.length; i += 4) {
      _spectrogramBitmap[i + 0] = 0; // R
      _spectrogramBitmap[i + 1] = 0; // G
      _spectrogramBitmap[i + 2] = 0; // B
      _spectrogramBitmap[i + 3] = 255; // A
    }
    _image?.dispose();
    _image = null;
    _updateImage();
  }

  int get maxFrames => _bitmapWidth;

  void reset() {
    _bitmapCurrentCollumn = 0;
    // Fill with opaque black pixels: ARGB = [0, 0, 0, 255]
    for (int i = 0; i < _spectrogramBitmap.length; i += 4) {
      _spectrogramBitmap[i + 0] = 0; // R
      _spectrogramBitmap[i + 1] = 0; // G
      _spectrogramBitmap[i + 2] = 0; // B
      _spectrogramBitmap[i + 3] = 255; // A
    }
    _updateImage();
  }

  void addFrames(List<List<double>> frames) {
    // logger.d('Adding ${frames.length} frames to bitmap state with height ${frames[0].length}');
    if (_bitmapWidth == 0 || _bitmapHeight == 0) return;

    for (final frame in frames) {
      _putSpectrogramFrameToBitmap(frame);
    }
    _updateImage();
  }

  static int _colorForDb(double db) {
    final v = (db * 255).round();
    if (v < 128) {
      return (255 << 24) | ((v * 2) << 16);
    } else {
      int rv = 255;
      int gv = ((v - 128) * 2).clamp(0, 255).toInt();
      return (255 << 24) | (rv << 16) | (gv << 8) | gv;
    }
  }

  // Invert the y axis so that low freqs are on bottom (y = _bitmapHeight - 1) and high on top (y = 0)
  void _putSpectrogramFrameToBitmap(List<double> frame) {
    for (int y = 0; y < _bitmapHeight; y++) {
      int color = _colorForDb(frame[y]);
      int invertedY = _bitmapHeight - 1 - y; // Flip y-axis
      int pixelOffset = (invertedY * _bitmapWidth + _bitmapCurrentCollumn) * 4;
      _spectrogramBitmap[pixelOffset + 0] = (color >> 16) & 0xFF;
      _spectrogramBitmap[pixelOffset + 1] = (color >> 8) & 0xFF;
      _spectrogramBitmap[pixelOffset + 2] = color & 0xFF;
      _spectrogramBitmap[pixelOffset + 3] = (color >> 24) & 0xFF;
    }
    _bitmapCurrentCollumn = (_bitmapCurrentCollumn + 1) % _bitmapWidth;
  }

  Future<void> _updateImage() async {
    if (_bitmapWidth == 0 || _bitmapHeight == 0 || _spectrogramBitmap.isEmpty) {
      _image?.dispose();
      _image = null;
      notifyListeners();
      return;
    }
    final Uint8List linearPixels = Uint8List(_bitmapWidth * _bitmapHeight * 4);
    int outCol = 0;
    for (int i = 0; i < _bitmapWidth; i++) {
      int srcCol = (_bitmapCurrentCollumn + i) % _bitmapWidth;
      for (int y = 0; y < _bitmapHeight; y++) {
        int src = (y * _bitmapWidth + srcCol) * 4;
        int dst = (y * _bitmapWidth + outCol) * 4;
        linearPixels[dst + 0] = _spectrogramBitmap[src + 0];
        linearPixels[dst + 1] = _spectrogramBitmap[src + 1];
        linearPixels[dst + 2] = _spectrogramBitmap[src + 2];
        linearPixels[dst + 3] = _spectrogramBitmap[src + 3];
      }
      outCol++;
    }
    ui.decodeImageFromPixels(linearPixels, _bitmapWidth, _bitmapHeight, ui.PixelFormat.rgba8888, (
      ui.Image img,
    ) {
      _image?.dispose();
      _image = img;
      notifyListeners();
    });
  }

  Uint8List get bitmap => _spectrogramBitmap;
  int get bitmapCurrentCollumn => _bitmapCurrentCollumn;
  int get width => _bitmapWidth;
  int get height => _bitmapHeight;
  ui.Image? get image => _image;
}
