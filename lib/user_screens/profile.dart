import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:care_circle/auth/login_page.dart';
import 'package:care_circle/providers/auth_provider.dart';
import 'package:care_circle/theme/colors.dart';
import 'package:care_circle/widgets/usermodule_widgets.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class userprofile extends StatefulWidget {
  const userprofile({super.key});

  @override
  State<userprofile> createState() => _userprofileState();
}

class _userprofileState extends State<userprofile> {
  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final user = auth.currentUser;

    return Scaffold(
      backgroundColor: ThemeColors.background,

      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Text(
          'My Profile',
          style: GoogleFonts.poppins(
            color: ThemeColors.textLight,
            fontSize: 22,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: false,
      ),

      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            if (user != null) await FirebaseFirestore.instance.collection('donations').where('donorId', isEqualTo: user.id).get();
          },

          child: SingleChildScrollView(
            physics:  AlwaysScrollableScrollPhysics(),
            padding:  EdgeInsets.fromLTRB( 16,5,16,30,),
            child: Column(
              children: [
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(22),
                  decoration: BoxDecoration(
                    color: ThemeColors.card,
                    borderRadius:
                        BorderRadius.circular(22),
                    border: Border.all(
                      color: ThemeColors.border,
                    ),
                  ),
                  child: Column(
                    children: [
                      Container(
                        height: 90,
                        width: 90,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient:ThemeColors.softGradient,
                          border: Border.all(
                            color:ThemeColors.accentCyan,
                            width: 2,
                          ),
                        ),
                        child: Center(
                          child: Text(
                            _getInitial(user?.name),
                            style: GoogleFonts.poppins(
                              color: ThemeColors.textLight,
                              fontSize: 32,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),

                      SizedBox(height: 14),

                      Text(
                        user?.name ?? 'User',
                        style: GoogleFonts.poppins(
                          color: ThemeColors.textLight,
                          fontSize: 21,
                          fontWeight: FontWeight.w600,
                        ),
                      ),

                      SizedBox(height: 4),

                      Text(
                        user?.email ??
                            'No email available',
                        style: GoogleFonts.poppins(
                          color:  ThemeColors.textSecondary,
                          fontSize: 12,
                        ),
                      ),

                      const SizedBox(height: 10),

                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: ThemeColors.accentCyan.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          _formatRole(user?.role),
                          style: GoogleFonts.poppins(
                            color: ThemeColors.accentCyan,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

               SizedBox(height: 20),

                ProfileSectionTitle(
                  title: 'Personal Information',
                ),

                SizedBox(height: 10),

                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: ThemeColors.card,
                    borderRadius:
                        BorderRadius.circular(18),
                    border: Border.all(
                      color: ThemeColors.border,
                    ),
                  ),
                  child: Column(
                    children: [
                      ProfileInfoTile(
                        icon: Icons.person_outline,
                        title: 'Full Name',
                        value:
                            user?.name ?? 'Not available',
                      ),

                      const ProfileDivider(),

                      ProfileInfoTile(
                        icon: Icons.email_outlined,
                        title: 'Email',
                        value:
                            user?.email ?? 'Not available',
                      ),

                      const ProfileDivider(),

                      ProfileInfoTile(
                        icon: Icons.phone_outlined,
                        title: 'Phone',
                        value:
                            user?.phone ?? 'Not available',
                      ),

                      const ProfileDivider(),

                      ProfileInfoTile(
                        icon: Icons.badge_outlined,
                        title: 'Account Type',
                        value:
                            _formatRole(user?.role),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 22),

                const ProfileSectionTitle(
                  title: 'My Impact',
                ),
                const SizedBox(height: 10),
                StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                  stream: user == null ? null : FirebaseFirestore.instance.collection('donations').where('donorId', isEqualTo: user.id).snapshots(),
                  builder: (context, snapshot) {
                    final donations = snapshot.data?.docs ?? [];
                    final confirmed = donations.where((doc) => (doc.data()['status']?.toString() ?? '').toLowerCase() == 'confirmed').toList();
                    final orphanagesHelped = confirmed.map((doc) => doc.data()['orphanageId']?.toString() ?? '').where((id) => id.isNotEmpty).toSet().length;
                    return Row(children: [
                      Expanded(child: ProfileImpactCard(icon: Icons.volunteer_activism_outlined, value: '${donations.length}', title: 'Donations')),
                      SizedBox(width: 12),
                      Expanded(child: ProfileImpactCard(icon: Icons.check_circle_outline, value: '${confirmed.length}', title: 'Completed')),
                      SizedBox(width: 12),
                      Expanded(child: ProfileImpactCard(icon: Icons.favorite_border, value: '$orphanagesHelped', title: 'Lives Helped')),
                    ]);
                  },
                ),

                const SizedBox(height: 22),

                const ProfileSectionTitle(
                  title: 'Account',
                ),

                const SizedBox(height: 10),

                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: ThemeColors.card,
                    borderRadius:
                        BorderRadius.circular(18),
                    border: Border.all(
                      color: ThemeColors.border,
                    ),
                  ),
                  child: Column(
                    children: [
                      ProfileActionTile(
                        icon: Icons.edit_outlined,
                        title: 'Edit Profile',
                        subtitle:
                            'Update your personal information',
                        onTap: () {},
                      ),

                      const ProfileDivider(),

                      ProfileActionTile(
                        icon: Icons.settings_outlined,
                        title: 'Settings',
                        subtitle:
                            'Manage your preferences',
                        onTap: () {},
                      ),

                      const ProfileDivider(),

                      ProfileActionTile(
                        icon: Icons
                            .notifications_none_outlined,
                        title: 'Notifications',
                        subtitle:
                            'Manage your notifications',
                        onTap: () {},
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 22),

                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () {
                      _showLogoutDialog(context);
                    },
                    icon: const Icon(
                      Icons.logout,
                      size: 19,
                    ),
                    label: Text(
                      'Logout',
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor:
                          Colors.redAccent,
                      side: BorderSide(
                        color: Colors.redAccent
                            .withOpacity(0.5),
                      ),
                      padding:
                          const EdgeInsets.symmetric(
                        vertical: 14,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(14),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 15),

                Text(
                  'Care:Circle',
                  style: GoogleFonts.poppins(
                    color: ThemeColors.textSecondary,
                    fontSize: 11,
                  ),
                ),

                const SizedBox(height: 3),

                Text(
                  'Making every contribution count',
                  style: GoogleFonts.poppins(
                    color: ThemeColors.textSecondary,
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _getInitial(String? name) {
    if (name == null || name.trim().isEmpty) {
      return 'U';
    }

    return name.trim()[0].toUpperCase();
  }

  String _formatRole(String? role) {
    if (role == null || role.trim().isEmpty) {
      return 'DONOR';
    }

    return role.toUpperCase();
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: ThemeColors.card,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          title: Text(
            'Logout',
            style: GoogleFonts.poppins(
              color: ThemeColors.textLight,
              fontWeight: FontWeight.w600,
            ),
          ),
          content: Text(
            'Are you sure you want to logout?',
            style: GoogleFonts.poppins(
              color: ThemeColors.textSecondary,
              fontSize: 13,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
              },
              child: Text(
                'Cancel',
                style: GoogleFonts.poppins(
                  color: ThemeColors.textSecondary,
                ),
              ),
            ),

            ElevatedButton(
              onPressed: () async {
                Navigator.pop(dialogContext);
                await Provider.of<AuthProvider>(context, listen: false).logout();
                if (!context.mounted) return;
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        const loginpage(),
                  ),
                  (route) => false,
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(10),
                ),
              ),
              child: Text(
                'Logout',
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}