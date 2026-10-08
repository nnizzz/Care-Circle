import 'package:care_circle/auth/login_page.dart';
import 'package:care_circle/theme/colors.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class adminprofile extends StatelessWidget {
  final VoidCallback onBack;

  const adminprofile({
    super.key,
    required this.onBack,
  });

  Future<void> logoutAdmin(BuildContext context) async {
  final confirm = await showDialog<bool>(
    context: context,
    builder: (context) {
      return AlertDialog(
        backgroundColor: ThemeColors.darkTeal,
        title: Text(
          'Logout?',
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        content: Text(
          'Are you sure you want to logout from the admin account?',
          style: GoogleFonts.poppins(
            color: Colors.white70,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context, false);
            },
            child: Text(
              'Cancel',
              style: GoogleFonts.poppins(
                color: Colors.white70,
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context, true);
            },
            child: Text(
              'Logout',
              style: GoogleFonts.poppins(
                color: Colors.redAccent,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      );
    },
  );

  if (confirm != true) return;

  if (!context.mounted) return;

  Navigator.pushAndRemoveUntil(
    context,
    MaterialPageRoute(
      builder: (context) =>  loginpage(),
    ),
    (route) => false,
  );
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ThemeColors.background,
      appBar: AppBar(
  backgroundColor: ThemeColors.background,
  elevation: 0,
  automaticallyImplyLeading: false,

  leading: IconButton(
    onPressed: onBack,
    icon: const Icon(
      Icons.arrow_back,
      color: Colors.white,
    ),
  ),

  title: Text(
    'Admin Profile',
    style: GoogleFonts.poppins(
      color: Colors.white,
      fontWeight: FontWeight.w600,
    ),
  ),
),

      body: SingleChildScrollView(
        padding: EdgeInsets.all(18),
        child: Column(
          children: [
               SizedBox(height: 15),
            Container(
              height: 100,
              width: 100,
              decoration: BoxDecoration(
                color: ThemeColors.primaryTeal,
                shape: BoxShape.circle,
                border: Border.all(
                  color: ThemeColors.accentCyan,
                  width: 3,
                ),
              ),
              child: const Icon(
                Icons.admin_panel_settings_outlined,
                color: Colors.white,
                size: 50,
              ),
            ),

            SizedBox(height: 15),

            Text(
              'Care:Circle Administrator',
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),

            SizedBox(height: 5),

            Text(
              'System Administrator',
              style: GoogleFonts.poppins(
                color: ThemeColors.accentCyan,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),

            SizedBox(height: 30),

            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Account Information',
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),

            SizedBox(height: 12),

            Container(
              width: double.infinity,
              padding: EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: ThemeColors.darkTeal,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Container(
                        height: 42,
                        width: 42,
                        decoration: BoxDecoration(
                          color: ThemeColors.primaryTeal,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(
                          Icons.person_outline,
                          color: Colors.white,
                          size: 21,
                        ),
                      ),

                      SizedBox(width: 13),

                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Name',
                              style: GoogleFonts.poppins(
                                color: Colors.white54,
                                fontSize: 10,
                              ),
                            ),
                            Text(
                              'Care:Circle Administrator',
                              style: GoogleFonts.poppins(
                                color: Colors.white,
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 14),
                    child: Divider(
                      color: Colors.white12,
                      height: 1,
                    ),
                  ),
                  Row(
                    children: [
                      Container(
                        height: 42,
                        width: 42,
                        decoration: BoxDecoration(
                          color: ThemeColors.primaryTeal,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(
                          Icons.email_outlined,
                          color: Colors.white,
                          size: 21,
                        ),
                      ),

                      SizedBox(width: 13),

                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Email',
                              style: GoogleFonts.poppins(
                                color: Colors.white54,
                                fontSize: 10,
                              ),
                            ),
                            Text(
                              'admin@carecircle.com',
                              style: GoogleFonts.poppins(
                                color: Colors.white,
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 14),
                    child: Divider(
                      color: Colors.white12,
                      height: 1,
                    ),
                  ),
                  Row(
                    children: [
                      Container(
                        height: 42,
                        width: 42,
                        decoration: BoxDecoration(
                          color: ThemeColors.primaryTeal,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(
                          Icons.admin_panel_settings_outlined,
                          color: Colors.white,
                          size: 21,
                        ),
                      ),

                     SizedBox(width: 13),

                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Role',
                              style: GoogleFonts.poppins(
                                color: Colors.white54,
                                fontSize: 10,
                              ),
                            ),
                            Text(
                              'Administrator',
                              style: GoogleFonts.poppins(
                                color: Colors.white,
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            SizedBox(height: 25),

            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Admin Access',
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),

            SizedBox(height: 12),

            Container(
              width: double.infinity,
              padding: EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: ThemeColors.darkTeal,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.people_outline,
                        color: ThemeColors.accentCyan,
                        size: 21,
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Manage Users',
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontSize: 13,
                          ),
                        ),
                      ),
                      Icon(
                        Icons.check_circle,
                        color: Colors.greenAccent,
                        size: 18,
                      ),
                    ],
                  ),

                  SizedBox(height: 17),

                  Row(
                    children: [
                      Icon(
                        Icons.home_work_outlined,
                        color: ThemeColors.accentCyan,
                        size: 21,
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Manage Orphanages',
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontSize: 13,
                          ),
                        ),
                      ),
                      Icon(
                        Icons.check_circle,
                        color: Colors.greenAccent,
                        size: 18,
                      ),
                    ],
                  ),

                  SizedBox(height: 17),

                  Row(
                    children: [
                      Icon(
                        Icons.inventory_2_outlined,
                        color: ThemeColors.accentCyan,
                        size: 21,
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Manage Requirements',
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontSize: 13,
                          ),
                        ),
                      ),
                      Icon(
                        Icons.check_circle,
                        color: Colors.greenAccent,
                        size: 18,
                      ),
                    ],
                  ),

                SizedBox(height: 17),

                  Row(
                    children: [
                      Icon(
                        Icons.volunteer_activism_outlined,
                        color: ThemeColors.accentCyan,
                        size: 21,
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Monitor Donations',
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontSize: 13,
                          ),
                        ),
                      ),
                      Icon(
                        Icons.check_circle,
                        color: Colors.greenAccent,
                        size: 18,
                      ),
                    ],
                  ),
                ],
              ),
            ),

            SizedBox(height: 30),

            SizedBox(
              width: double.infinity,
              height: 50,
              child: OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  side: BorderSide(
                    color: Colors.redAccent,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(13),
                  ),
                ),
                onPressed: () {
                  logoutAdmin(context);
                },
                icon: Icon(
                  Icons.logout,
                  color: Colors.redAccent,
                ),
                label: Text(
                  'Logout',
                  style: GoogleFonts.poppins(
                    color: Colors.redAccent,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),

            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}