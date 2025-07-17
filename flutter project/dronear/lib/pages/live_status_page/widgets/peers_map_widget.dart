import 'package:flutter/material.dart';
import '../../../config/app_theme.dart';

class PeersMapWidget extends StatelessWidget {
  const PeersMapWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        margin: EdgeInsets.symmetric(
          vertical: 10.0,
          horizontal: AppTheme.cardSideMargin,
        ),
        padding: AppTheme.cardPadding,
        decoration: BoxDecoration(
          border: Border.all(color: AppTheme.boxBorderColor),
          borderRadius: BorderRadius.circular(AppTheme.cardBorderRadius),
        ),
        child: const Center(
          child: Text("peers map", style: TextStyle(fontSize: 18)),
        ),
      ),
    );
  }
}
