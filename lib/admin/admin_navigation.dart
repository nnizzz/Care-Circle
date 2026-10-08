import 'package:care_circle/admin/admin_dashboard.dart';
import 'package:care_circle/admin/admin_donations.dart';
import 'package:care_circle/admin/admin_orphanages.dart';
import 'package:care_circle/admin/admin_profile.dart';
import 'package:care_circle/admin/admin_requirements.dart';
import 'package:care_circle/theme/colors.dart';
import 'package:flutter/material.dart';

class adminnavigation extends StatefulWidget {
  const adminnavigation({super.key});

  @override
  State<adminnavigation> createState() => _adminnavigationState();
}

class _adminnavigationState extends State<adminnavigation> {
  int selectedIndex = 0;

  void goToDashboard() {
    setState(() {
      selectedIndex = 0;
    });
  }

  void changeTab(int index) {
    setState(() {
      selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = [
      dashboards(
        onTabChange: changeTab,
      ),

      adminorphanages(
        onBack: goToDashboard,
      ),

      adminrequirements(
        onBack: goToDashboard,
      ),

      admindonations(
        onBack: goToDashboard,
      ),

      adminprofile(
        onBack: goToDashboard,
      ),
    ];

    return Scaffold(
      backgroundColor: ThemeColors.background,

      body: IndexedStack(
        index: selectedIndex,
        children: pages,
      ),

      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: ThemeColors.darkTeal,
        currentIndex: selectedIndex,
        selectedItemColor: ThemeColors.accentCyan,
        unselectedItemColor: Colors.white54,
        selectedFontSize: 11,
        unselectedFontSize: 10,

        onTap: changeTab,

        items: const [
          BottomNavigationBarItem(
            icon: Icon(
              Icons.dashboard_outlined,
            ),
            activeIcon: Icon(
              Icons.dashboard,
            ),
            label: 'Home',
          ),

          BottomNavigationBarItem(
            icon: Icon(
              Icons.home_work_outlined,
            ),
            activeIcon: Icon(
              Icons.home_work,
            ),
            label: 'Orphanages',
          ),

          BottomNavigationBarItem(
            icon: Icon(
              Icons.inventory_2_outlined,
            ),
            activeIcon: Icon(
              Icons.inventory_2,
            ),
            label: 'Needs',
          ),

          BottomNavigationBarItem(
            icon: Icon(
              Icons.volunteer_activism_outlined,
            ),
            activeIcon: Icon(
              Icons.volunteer_activism,
            ),
            label: 'Donations',
          ),

          BottomNavigationBarItem(
            icon: Icon(
              Icons.person_outline,
            ),
            activeIcon: Icon(
              Icons.person,
            ),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}