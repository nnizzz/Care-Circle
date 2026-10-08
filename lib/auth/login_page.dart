import 'package:care_circle/admin/admin_login.dart';
import 'package:care_circle/auth/register_page.dart';
import 'package:care_circle/orphanage_screens/orp_navigation.dart';
import 'package:care_circle/theme/colors.dart';
import 'package:care_circle/user_screens/navigation.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';

class loginpage extends StatefulWidget {
  const loginpage({super.key});

  @override
  State<loginpage> createState() => _loginpageState();
}

class _loginpageState extends State<loginpage> {
  final TextEditingController uemail = TextEditingController();
  final TextEditingController upass = TextEditingController();

  String selectedRole = 'user';

  bool isLoading = false;
  bool obscurePassword = true;

  @override
  void dispose() {
    uemail.dispose();
    upass.dispose();
    super.dispose();
  }

  Future<void> login() async {
    if (uemail.text.trim().isEmpty || upass.text.isEmpty) {
      showMessage(
        'Email and password are required!',
        ThemeColors.error,
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    final authProvider = Provider.of<AuthProvider>(
      context,
      listen: false,
    );

    final success = await authProvider.loginUser(
      email: uemail.text.trim(),
      password: upass.text,
    );

    if (!mounted) return;

    setState(() {
      isLoading = false;
    });

    if (!success) {
      showMessage(
        'Email or Password is incorrect!',
        ThemeColors.error,
      );
      return;
    }

    final actualRole = authProvider.userRole;

    showMessage(
      'Log In Successful!',
      ThemeColors.success,
    );

    if (actualRole == 'user') {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (context) => const navixs(),
        ),
        (route) => false,
      );
    } else if (actualRole == 'orphanage') {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (context) => const navigation(),
        ),
        (route) => false,
      );
    }
  }

  void showMessage(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
      ),
    );
  }

  InputDecoration fieldDecoration({
    required String label,
    required IconData icon,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(
        color: ThemeColors.textMuted,
      ),
      prefixIcon: Icon(
        icon,
        color: ThemeColors.secondaryTeal,
      ),
      suffixIcon: suffixIcon,
      filled: true,
      fillColor: ThemeColors.card,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 18,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(
          color: ThemeColors.border,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(
          color: ThemeColors.accentCyan,
          width: 1.5,
        ),
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ThemeColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(
            horizontal: 24,
            vertical: 18,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ADMIN PANEL - TOP RIGHT
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  IconButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              const adminlogin(),
                        ),
                      );
                    },
                    icon: Icon(
                      Icons.admin_panel_settings_rounded,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 25),

              // LOGO
              Center(
                child: Column(
                  children: [
                    Container(
                      height: 85,
                      width: 85,
                      decoration: BoxDecoration(
                        color:
                            ThemeColors.primaryTeal.withOpacity(0.18),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color:
                              ThemeColors.accentCyan.withOpacity(0.5),
                        ),
                      ),
                      child: Center(
                        child: FaIcon(
                          FontAwesomeIcons.slideshare,
                          size: 45,
                          color: ThemeColors.lightCyan,
                        ),
                      ),
                    ),

                    const SizedBox(height: 12),

                    Text(
                      'Care-Circle',
                      style: GoogleFonts.cookie(
                        fontSize: 50,
                        color: ThemeColors.textLight,
                      ),
                    ),

                    Text(
                      'Together, we can make a difference',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        color: ThemeColors.textMuted,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 40),

              Text(
                'Welcome Back!',
                style: GoogleFonts.poppins(
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                  color: ThemeColors.textLight,
                ),
              ),
              const SizedBox(height: 24),

              Text(
                'Login here,',
                style: GoogleFonts.poppins(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: ThemeColors.lightCyan,
                ),
              ),

              const SizedBox(height: 12),

              // EMAIL
              TextField(
                controller: uemail,
                keyboardType: TextInputType.emailAddress,
                style: TextStyle(
                  color: ThemeColors.textPrimary,
                ),
                decoration: fieldDecoration(
                  label: 'Email Address',
                  icon: Icons.email_rounded,
                ),
              ),

              const SizedBox(height: 15),

              // PASSWORD
              TextField(
                controller: upass,
                obscureText: obscurePassword,
                style: TextStyle(
                  color: ThemeColors.textPrimary,
                ),
                decoration: fieldDecoration(
                  label: 'Password',
                  icon: Icons.lock_rounded,
                  suffixIcon: IconButton(
                    onPressed: () {
                      setState(() {
                        obscurePassword = !obscurePassword;
                      });
                    },
                    icon: Icon(
                      obscurePassword
                          ? Icons.visibility_off_rounded
                          : Icons.visibility_rounded,
                      color: ThemeColors.textMuted,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 28),

              // LOGIN BUTTON
              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed: isLoading ? null : login,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: ThemeColors.primaryTeal,
                    foregroundColor: ThemeColors.textLight,
                    disabledBackgroundColor:
                        ThemeColors.primaryTeal.withOpacity(0.5),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: isLoading
                      ? const SizedBox(
                          height: 22,
                          width: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : Text(
                          'Log In',
                          style: GoogleFonts.poppins(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              ),

              const SizedBox(height: 22),

              // REGISTER
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Don't have an account?",
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      color: ThemeColors.textMuted,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              const registerpage(),
                        ),
                      );
                    },
                    child: Text(
                      'Register',
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w600,
                        color: ThemeColors.accentCyan,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget roleCard({
    required String role,
    required String title,
    required String subtitle,
    required IconData icon,
  }) {
    final bool selected = selectedRole == role;

    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: () {
        setState(() {
          selectedRole = role;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(
          horizontal: 10,
          vertical: 17,
        ),
        decoration: BoxDecoration(
          color: selected
              ? ThemeColors.primaryTeal.withOpacity(0.25)
              : ThemeColors.card,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: selected
                ? ThemeColors.accentCyan
                : ThemeColors.border,
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Column(
          children: [
            Container(
              height: 44,
              width: 44,
              decoration: BoxDecoration(
                color: selected
                    ? ThemeColors.primaryTeal
                    : ThemeColors.darkTeal,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: selected
                    ? Colors.white
                    : ThemeColors.secondaryTeal,
              ),
            ),

            const SizedBox(height: 9),

            Text(
              title,
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: selected
                    ? ThemeColors.lightCyan
                    : ThemeColors.textLight,
              ),
            ),

            const SizedBox(height: 2),

            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 10,
                color: ThemeColors.textMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }
}