import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../state/spectrogram_bitmap_state.dart';

class SpectrogramBitmapWidget extends StatelessWidget {
  final double width;
  final double height;

  const SpectrogramBitmapWidget({super.key, this.width = 400, this.height = 200});

  @override
  Widget build(BuildContext context) {
    return Consumer<SpectrogramBitmapState>(
      builder: (context, state, child) {
        if (state.image == null) {
          return Container(
            width: width,
            height: height,
            alignment: Alignment.center,
            child: const Text("Waiting for audio...", style: TextStyle(color: Colors.grey)),
          );
        }
        return SizedBox(
          width: width,
          height: height,
          child: RawImage(image: state.image, fit: BoxFit.fill, filterQuality: FilterQuality.low),
        );
      },
    );
  }
}
