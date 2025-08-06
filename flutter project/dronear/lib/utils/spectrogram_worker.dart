import 'dart:isolate';
import 'dart:math';
import 'package:fftea/fftea.dart';

/// Spectrogram Worker PCM Data Message
class SWPcmDataMessage {
  final List<int> pcmBytes;
  SWPcmDataMessage(this.pcmBytes);
}

/// Spectrogram Worker Stop Message <br>
/// used to stop the worker gracefully.
class SWStopMessage {}

/// Spectrogram Worker Spectrogram Frame Message
class SWSpectrogramFrameMessage {
  final List<List<double>> window;
  SWSpectrogramFrameMessage(this.window);
}

/// Spectrogram Worker Configuration
class SWConfig {
  final SendPort masterReceivePort;
  final int nFft;
  final int hopLength;
  final int targetFrameHeight;
  final int targetFrameWidth;
  SWConfig(
    this.masterReceivePort,
    this.nFft,
    this.hopLength,
    this.targetFrameHeight,
    this.targetFrameWidth,
  );
}

void spectrogramWorker(SWConfig config) async {
  final workerReceivePort = ReceivePort();
  config.masterReceivePort.send(workerReceivePort.sendPort);

  final int nFft = config.nFft;
  final int hopLength = config.hopLength;
  final int targetFrameHeight = config.targetFrameHeight;
  final int targetFrameWidth = config.targetFrameWidth;

  final List<double> pcmBuffer = [];
  final List<List<double>> frameBuffer = [];

  int framesGenerated = 0; // Track how many frames have been generated

  await for (final message in workerReceivePort) {
    if (message is SWPcmDataMessage) {
      _appendRawPcmToBuffer(pcmBuffer, message.pcmBytes);

      // Ensure enough data for at least one frame
      int maxStart = pcmBuffer.length - nFft;
      if (maxStart < 0) continue; // Not enough samples for a single frame

      // Calculate total possible frames from buffer
      int totalFrames = (maxStart ~/ hopLength) + 1;

      // Generate only the new frames
      for (int frameIdx = framesGenerated; frameIdx < totalFrames; frameIdx++) {
        final start = frameIdx * hopLength;
        if (start + nFft > pcmBuffer.length) break; // Safety check
        final window = pcmBuffer.sublist(start, start + nFft);
        final frame = _stftNormFrame(window, nFft, targetFrameHeight);

        frameBuffer.add(frame);

        // Keep frameBuffer length at most targetFrameWidth (scrolling window)
        if (frameBuffer.length > targetFrameWidth) {
          frameBuffer.removeAt(0);
        }
      }

      // Update framesGenerated to totalFrames
      if (totalFrames > framesGenerated) {
        framesGenerated = totalFrames;

        // Only send if we have enough frames to fill the display
        if (frameBuffer.length == targetFrameWidth) {
          config.masterReceivePort.send(
            SWSpectrogramFrameMessage(List<List<double>>.from(frameBuffer)),
          );
        }
      }

      // Limit pcmBuffer size for safety (keep about 10 seconds of audio)
      const int maxPcmBuffer = 48000 * 10;
      if (pcmBuffer.length > maxPcmBuffer) {
        int removeCount = pcmBuffer.length - maxPcmBuffer;
        pcmBuffer.removeRange(0, removeCount);

        // Adjust framesGenerated accordingly
        int possibleFramesAfterTrim = ((pcmBuffer.length - nFft) ~/ hopLength) + 1;
        framesGenerated = framesGenerated - (totalFrames - possibleFramesAfterTrim);
        if (framesGenerated < 0) framesGenerated = 0;
      }
    } else if (message is SWStopMessage) {
      break;
    }
  }
  workerReceivePort.close();
}

/// Appends raw PCM bytes as signed 16-bit to pcmBuffer.
void _appendRawPcmToBuffer(List<double> pcmBuffer, List<int> bytes) {
  for (int i = 0; i < bytes.length - 1; i += 2) {
    int sample = bytes[i] | (bytes[i + 1] << 8);
    if (sample >= 0x8000) sample -= 0x10000;
    pcmBuffer.add(sample.toDouble());
  }
}

/// Computes a normalized spectrogram frame from a window of PCM data.
/// Returns a list of normalized [0,1] dB-magnitude values, padded/cropped to targetFrameHeight.
List<double> _stftNormFrame(List<double> window, int nFft, int targetFrameHeight) {
  final windowed = List<double>.generate(
    nFft,
    (i) => window[i] * (0.5 - 0.5 * cos(2 * pi * i / (nFft - 1))),
  );
  final fft = FFT(nFft);
  final spectrum = fft.realFft(windowed);

  final mags = List<double>.generate(nFft ~/ 2, (i) {
    final re = spectrum[i].x;
    final im = spectrum[i].y;
    return sqrt(re * re + im * im);
  });

  final maxMag = mags.fold<double>(1e-12, max);
  final dbs = mags.map((mag) {
    return 20 * log((mag / maxMag).clamp(1e-12, double.infinity)) / ln10;
  }).toList();

  final minDb = dbs.reduce(min);
  List<double> norm = dbs.map((v) => (v - minDb) / (0 - minDb)).toList();

  if (norm.length > targetFrameHeight) {
    norm = norm.sublist(0, targetFrameHeight);
  } else {
    norm = List<double>.from(norm)..addAll(List.filled(targetFrameHeight - norm.length, 0.0));
  }
  return norm;
}
