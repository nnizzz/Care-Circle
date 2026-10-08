import 'package:care_circle/orphanage_screens/manage_require.dart';
import 'package:care_circle/orphanage_screens/orp_profile.dart';
import 'package:care_circle/orphanage_screens/orphanage_home.dart';
import 'package:care_circle/orphanage_screens/received_donations.dart';
import 'package:care_circle/theme/colors.dart';
import 'package:flutter/material.dart';

class navigation extends StatefulWidget {
  const navigation({super.key});

  @override
  State<navigation> createState() => _navigationState();
}

class _navigationState extends State<navigation> {
  int selectedIndex = 0;

  final List<Widget> pages = const [
    orphanagehome(),
    managerequirements(),
    receiveddonations(),
    orphanageprofile(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: pages[selectedIndex],

      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: ThemeColors.background,
        currentIndex: selectedIndex,
        selectedItemColor: ThemeColors.backgroundLight,
        unselectedItemColor: ThemeColors.secondaryTeal,
        selectedFontSize: 13,

        onTap: (index) {
          setState(() {
            selectedIndex = index;
          });
        },

        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_rounded),
            label: 'Home',
          ),

          BottomNavigationBarItem(
            icon: Icon(Icons.assignment_outlined),
            label: 'Requirements',
          ),

          BottomNavigationBarItem(
            icon: Icon(Icons.diversity_2_rounded),
            label: 'Donations',
          ),

          BottomNavigationBarItem(
            icon: Icon(Icons.person_rounded),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}