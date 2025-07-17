import 'package:flutter/material.dart';
import '../../../config/app_theme.dart';

class StatusButtonsWidget extends StatelessWidget {
  final Map<String, bool> featureStatus; // true = armed, false = offline

  const StatusButtonsWidget({super.key, required this.featureStatus});

  @override
  Widget build(BuildContext context) {
    final statusList = [
      {'key': 'CALL', 'icon': Icons.phone},
      {'key': 'SMS', 'icon': Icons.sms},
      {'key': 'MAIL', 'icon': Icons.mail},
      {'key': 'HTTP API', 'icon': Icons.settings_ethernet},
    ];

    final double screenWidth = MediaQuery.of(context).size.width;
    final double totalHorizontalPadding = 8 * 2 + 6 * (statusList.length - 1);
    final double availableWidth =
        screenWidth - (AppTheme.cardSideMargin * 2) - totalHorizontalPadding;
    final double buttonWidth = availableWidth / statusList.length;

    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: AppTheme.cardSideMargin,
        vertical: 8,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: statusList.map((status) {
          final key = status['key'] as String;
          final bool isArmed = featureStatus[key] ?? false;

          final Color color = isArmed ? Colors.orange : Colors.grey;
          final String statusText = isArmed ? 'ARMED' : 'off';

          return SizedBox(
            width: buttonWidth,
            child: OutlinedButton(
              style: OutlinedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(
                    AppTheme.cardBorderRadius,
                  ),
                ),
                side: BorderSide(color: color),
                foregroundColor: color,
                padding: AppTheme.buttonPadding,
              ),
              onPressed: () {},
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(status['icon'] as IconData, size: 18, color: color),
                      const SizedBox(width: 4),
                      Flexible(
                        child: Text(
                          key,
                          style: TextStyle(fontSize: 13, color: color),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    statusText,
                    style: TextStyle(fontSize: 16, color: color),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
