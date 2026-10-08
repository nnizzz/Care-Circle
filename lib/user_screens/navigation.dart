
import 'package:care_circle/theme/colors.dart';
import 'package:care_circle/user_screens/donate_page.dart';
import 'package:care_circle/user_screens/profile.dart';
import 'package:care_circle/user_screens/requirments.dart';
import 'package:care_circle/user_screens/uhomepage.dart';
import 'package:flutter/material.dart';

class navixs extends StatefulWidget {
  const navixs({super.key});

  @override
  State<navixs> createState() => _navixsState();
}

class _navixsState extends State<navixs> {
  int selectedIndex = 0;

  final pages = [
    homeuser(),
    userrequire(),
    userdonations(),
    userprofile()
  ];

  void goBack() {
    if (selectedIndex != 0) {
      setState(() => selectedIndex = 0);
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: selectedIndex == 0,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) goBack();
      },
      child: Scaffold(
        body: pages[selectedIndex],
        bottomNavigationBar: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          backgroundColor: ThemeColors.background,
          currentIndex: selectedIndex,
          selectedItemColor: ThemeColors.backgroundLight,
          unselectedItemColor: ThemeColors.secondaryTeal,
          selectedFontSize: 13,
          onTap: (index) => setState(() => selectedIndex = index),
          items: [
            BottomNavigationBarItem(icon: Icon(Icons.home_rounded), label: 'Home'),
            BottomNavigationBarItem(icon: Icon(Icons.search_rounded), label: 'Needs'),
            BottomNavigationBarItem(icon: Icon(Icons.diversity_2_rounded), label: 'Donations'),
            BottomNavigationBarItem(icon: Icon(Icons.person_rounded), label: 'Profile')
          ],
        ),
      ),
    );
  }
}
