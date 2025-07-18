import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../config/app_theme.dart';
import '../../../state/microphone_state.dart'; // <-- Update path as needed

class OnOffMainSwitchWidget extends StatelessWidget {
  const OnOffMainSwitchWidget({super.key});

  Future<void> _toggleMic(BuildContext context, bool isOn) async {
    final micState = Provider.of<MicrophoneState>(context, listen: false);

    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(isOn ? 'Disable Microphone?' : 'Enable Microphone?'),
        content: Text(
          isOn
              ? 'Are you sure you want to turn OFF the microphone?'
              : 'Are you sure you want to turn ON the microphone?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(isOn ? 'Turn OFF' : 'Turn ON'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      if (isOn) {
        await micState.stopRecording();
      } else {
        await micState.startRecording();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    context.watch<MicrophoneState>();

    return Consumer<MicrophoneState>(
      builder: (context, micState, child) {
        return Container(
          margin: const EdgeInsets.only(left: AppTheme.cardSideMargin),
          child: GestureDetector(
            onTap: () => _toggleMic(context, micState.isRecording),
            child: Container(
              width: 60,
              height: 120,
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: micState.isRecording ? Colors.green : Colors.grey,
                borderRadius: BorderRadius.circular(AppTheme.cardBorderRadius),
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: const [
                      Text(
                        'OFF',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        'ON',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                  AnimatedAlign(
                    duration: const Duration(milliseconds: 300),
                    alignment: micState.isRecording ? Alignment.topCenter : Alignment.bottomCenter,
                    curve: Curves.easeInOut,
                    child: Container(
                      margin: const EdgeInsets.symmetric(vertical: 3),
                      width: 48,
                      height: 24,
                      decoration: BoxDecoration(
                        color: const Color.fromARGB(255, 36, 36, 36),
                        shape: BoxShape.rectangle,
                        borderRadius: BorderRadius.circular(AppTheme.cardBorderRadius - 3),
                        boxShadow: const [
                          BoxShadow(color: Colors.black26, blurRadius: 4, offset: Offset(0, 4)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
