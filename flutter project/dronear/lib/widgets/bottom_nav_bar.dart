import 'package:flutter/material.dart';
import '../nav/page_nav_info.dart';

class BottomNavBar extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onDestinationSelected;
  final List<NavPage> pages;

  const BottomNavBar({
    super.key,
    required this.selectedIndex,
    required this.onDestinationSelected,
    required this.pages,
  });

  @override
  Widget build(BuildContext context) {
    return NavigationBar(
      selectedIndex: selectedIndex,
      onDestinationSelected: onDestinationSelected,
      destinations: [
        for (final page in pages)
          NavigationDestination(
            icon: Icon(page.pageIcon),
            label: page.pageLabel,
          ),
      ],
    );
  }
}
