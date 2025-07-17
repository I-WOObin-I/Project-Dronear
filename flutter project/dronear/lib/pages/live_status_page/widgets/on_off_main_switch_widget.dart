import 'package:flutter/material.dart';
import '../../../config/app_theme.dart';

class OnOffMainSwitchWidget extends StatefulWidget {
  final bool isOn;
  final ValueChanged<bool> onConfirmedToggle;

  const OnOffMainSwitchWidget({
    super.key,
    required this.isOn,
    required this.onConfirmedToggle,
  });

  @override
  State<OnOffMainSwitchWidget> createState() => _OnOffMainSwitchWidgetState();
}

class _OnOffMainSwitchWidgetState extends State<OnOffMainSwitchWidget>
    with SingleTickerProviderStateMixin {
  late bool _isOn;

  @override
  void initState() {
    super.initState();
    _isOn = widget.isOn;
  }

  void _toggle() async {
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(_isOn ? 'Disable Detection?' : 'Enable Detection?'),
        content: Text(
          _isOn
              ? 'Are you sure you want to turn OFF detection?'
              : 'Are you sure you want to turn ON detection?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(_isOn ? 'Turn OFF' : 'Turn ON'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      setState(() {
        _isOn = !_isOn;
      });
      widget.onConfirmedToggle(_isOn);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(left: AppTheme.cardSideMargin),
      child: GestureDetector(
        onTap: _toggle,
        child: Container(
          width: 60,
          height: 120,
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: _isOn ? Colors.green : Colors.grey,
            borderRadius: BorderRadius.circular(AppTheme.cardBorderRadius),
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              // ON and OFF labels
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
              // Circular sliding thumb
              AnimatedAlign(
                duration: const Duration(milliseconds: 300),
                alignment: _isOn ? Alignment.topCenter : Alignment.bottomCenter,
                curve: Curves.easeInOut,
                child: Container(
                  margin: const EdgeInsets.symmetric(vertical: 3),
                  width: 48,
                  height: 24,
                  decoration: BoxDecoration(
                    color: const Color.fromARGB(255, 36, 36, 36),
                    shape: BoxShape.rectangle,
                    borderRadius: BorderRadius.circular(
                      AppTheme.cardBorderRadius - 3,
                    ),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 4,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
