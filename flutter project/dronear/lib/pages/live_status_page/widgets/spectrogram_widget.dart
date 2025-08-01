import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../state/microphone_state.dart';

class SpectrogramWidget extends StatefulWidget {
  final double height;
  final double width;

  const SpectrogramWidget({super.key, this.height = 200, this.width = 400});

  @override
  State<SpectrogramWidget> createState() => _SpectrogramWidgetState();
}

class _SpectrogramWidgetState extends State<SpectrogramWidget> {
  ui.Image? _spectrogramImage;
  int _lastWriteX = -1;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Listen to MicrophoneState and generate image if needed
    final micState = Provider.of<MicrophoneState>(context);
    _tryUpdateBitmap(micState);
  }

  @override
  void didUpdateWidget(covariant SpectrogramWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    final micState = Provider.of<MicrophoneState>(context, listen: false);
    _tryUpdateBitmap(micState);
  }

  // Try to update the bitmap if the buffer changed
  void _tryUpdateBitmap(MicrophoneState micState) {
    final int writeX = micState.getSpectrogramBitmapWriteX();
    if (_lastWriteX != writeX) {
      _lastWriteX = writeX;
      _generateBitmap(micState);
    }
  }

  Future<void> _generateBitmap(MicrophoneState micState) async {
    final Uint8List buffer = micState.getSpectrogramBitmap();
    final int width = micState.getSpectrogramBitmapWidth();
    final int height = micState.getSpectrogramBitmapHeight();
    final int writeX = micState.getSpectrogramBitmapWriteX();

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
    return Consumer<MicrophoneState>(
      builder: (context, micState, child) {
        // Re-generate image if buffer changed
        _tryUpdateBitmap(micState);

        if (_spectrogramImage == null) {
          return Container(
            height: widget.height,
            width: widget.width,
            alignment: Alignment.center,
            child: const Text("Waiting for audio...", style: TextStyle(color: Colors.grey)),
          );
        }

        return SizedBox(
          height: widget.height,
          width: widget.width,
          child: RawImage(
            image: _spectrogramImage,
            fit: BoxFit.fill,
            filterQuality: FilterQuality.low,
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _spectrogramImage?.dispose();
    super.dispose();
  }
}
