import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:dronear/state/spectrogram_bitmap_state.dart';
import '../../../utils/logger.dart';

class SpectrogramWidget extends StatefulWidget {
  final double width;
  final double height;

  const SpectrogramWidget({super.key, this.width = 400, this.height = 200});

  @override
  State<SpectrogramWidget> createState() => _SpectrogramWidgetState();
}

class _SpectrogramWidgetState extends State<SpectrogramWidget> {
  ui.Image? _spectrogramImage;

  @override
  void dispose() {
    _spectrogramImage?.dispose();
    super.dispose();
  }

  Future<void> _generateBitmap(SpectrogramBitmapState specBitmapState) async {
    logger.d('Generating spectrogram bitmap at writeX: ${specBitmapState.bitmapWriteX}');
    final Uint8List buffer = specBitmapState.bitmap;
    final int width = specBitmapState.width;
    final int height = specBitmapState.height;
    final int writeX = specBitmapState.bitmapWriteX;

    if (width == 0 || height == 0 || buffer.isEmpty) return;

    final Uint8List linearPixels = Uint8List(width * height * 4);

    int outCol = 0;
    for (int i = 0; i < width; i++) {
      int srcCol = (writeX + i) % width;
      for (int y = 0; y < height; y++) {
        int src = ((height - 1 - y) * width + srcCol) * 4; // FLIP Y
        int dst = (y * width + outCol) * 4;
        linearPixels[dst + 0] = buffer[src + 0];
        linearPixels[dst + 1] = buffer[src + 1];
        linearPixels[dst + 2] = buffer[src + 2];
        linearPixels[dst + 3] = buffer[src + 3];
      }
      outCol++;
    }

    ui.decodeImageFromPixels(linearPixels, width, height, ui.PixelFormat.rgba8888, (ui.Image img) {
      if (mounted) {
        setState(() {
          _spectrogramImage?.dispose();
          _spectrogramImage = img;
        });
      } else {
        img.dispose();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // This will rebuild EVERY time notifyListeners is called on SpectrogramBitmapState
    return Consumer<SpectrogramBitmapState>(
      builder: (context, specBitmapState, child) {
        // Always regenerate on any change for robustness
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) _generateBitmap(specBitmapState);
        });

        if (_spectrogramImage == null) {
          return Container(
            width: widget.width,
            height: widget.height,
            alignment: Alignment.center,
            child: const Text("Waiting for audio...", style: TextStyle(color: Colors.grey)),
          );
        }

        return SizedBox(
          width: widget.width,
          height: widget.height,
          child: RawImage(
            image: _spectrogramImage,
            fit: BoxFit.fill,
            filterQuality: FilterQuality.low,
          ),
        );
      },
    );
  }
}
