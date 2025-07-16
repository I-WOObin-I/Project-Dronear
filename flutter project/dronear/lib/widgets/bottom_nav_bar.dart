import 'package:flutter/material.dart';
import '../nav/page_nav_info.dart';

class BottomNavBar extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onDestinationSelected;
  final List<String> pageLabels;
  final List<IconData> pageIcons;

  const BottomNavBar({
    super.key,
    required this.selectedIndex,
    required this.onDestinationSelected,
    required this.pageLabels,
    required this.pageIcons,
  });

  @override
  Widget build(BuildContext context) {
    return NavigationBar(
      selectedIndex: selectedIndex,
      onDestinationSelected: onDestinationSelected,
      destinations: [
        for (int i = 0; i < pageLabels.length; i++)
          NavigationDestination(icon: Icon(pageIcons[i]), label: pageLabels[i]),
      ],
    );
  }
}
