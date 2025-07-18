import 'package:flutter/material.dart';
import '../../../config/app_theme.dart';
import 'package:provider/provider.dart';
import '../../../state/alerts_state.dart';

class StatusButtonsWidget extends StatelessWidget {
  final List<Widget> alertPages;

  const StatusButtonsWidget({super.key, required this.alertPages});

  @override
  Widget build(BuildContext context) {
    final alertsState = context.watch<AlertsState>();

    final double screenWidth = MediaQuery.of(context).size.width;
    final double totalHorizontalPadding = 8 * 2 + 6 * 3;
    final double availableWidth =
        screenWidth - (AppTheme.cardSideMargin * 2) - totalHorizontalPadding;
    final double buttonWidth = availableWidth / 4;

    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: AppTheme.cardSideMargin,
        vertical: 8,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          buildStatusButton(
            label: 'CALL',
            icon: Icons.phone,
            isArmed: alertsState.isCallEnabled,
            width: buttonWidth,
            onPressed: () => _navigateToPage(context, 0),
          ),
          buildStatusButton(
            label: 'SMS',
            icon: Icons.sms,
            isArmed: alertsState.isSmsEnabled,
            width: buttonWidth,
            onPressed: () => _navigateToPage(context, 1),
          ),
          buildStatusButton(
            label: 'EMAIL',
            icon: Icons.mail,
            isArmed: alertsState.isEmailEnabled,
            width: buttonWidth,
            onPressed: () => _navigateToPage(context, 2),
          ),
          buildStatusButton(
            label: 'HTTP API',
            icon: Icons.settings_ethernet,
            isArmed: alertsState.isHttpApiEnabled,
            width: buttonWidth,
            onPressed: () => _navigateToPage(context, 3),
          ),
        ],
      ),
    );
  }

  void _navigateToPage(BuildContext context, int i) {
    final Widget? targetPage = alertPages[i];
    if (targetPage != null) {
      Navigator.of(context).push(MaterialPageRoute(builder: (_) => targetPage));
    }
  }

  Widget buildStatusButton({
    required String label,
    required IconData icon,
    required bool isArmed,
    required VoidCallback onPressed,
    required double width,
  }) {
    final Color color = isArmed ? Colors.orange : Colors.grey;
    final String statusText = isArmed ? 'ARMED' : 'off';

    return SizedBox(
      width: width,
      child: OutlinedButton(
        style: OutlinedButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppTheme.cardBorderRadius),
          ),
          side: BorderSide(color: color),
          foregroundColor: color,
          padding: AppTheme.buttonPadding,
        ),
        onPressed: onPressed,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, size: 18, color: color),
                const SizedBox(width: 4),
                Flexible(
                  child: Text(
                    label,
                    style: TextStyle(fontSize: 13, color: color),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(statusText, style: TextStyle(fontSize: 16, color: color)),
          ],
        ),
      ),
    );
  }
}
