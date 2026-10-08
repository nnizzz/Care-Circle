import 'package:care_circle/admin/admin_navigation.dart';
import 'package:care_circle/auth/login_page.dart';
import 'package:care_circle/theme/colors.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';

class adminlogin extends StatefulWidget {
  const adminlogin({super.key});

  @override
  State<adminlogin> createState() => _adminloginState();
}

class _adminloginState extends State<adminlogin> {
  final TextEditingController adminEmail = TextEditingController();
  final TextEditingController adminPassword = TextEditingController();

  bool obscurePassword = true;
  bool isLoading = false;

  final String presetEmail = 'admin@carecircle.com';
  final String presetPassword = 'admin123';

  @override
  void dispose() {
    adminEmail.dispose();
    adminPassword.dispose();
    super.dispose();
  }

  Future<void> loginAdmin() async {
    if (adminEmail.text.trim().isEmpty || adminPassword.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Fields must not be empty!'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    await Future.delayed(const Duration(milliseconds: 500));

    if (!mounted) return;

    final email = adminEmail.text.trim();
    final password = adminPassword.text.trim();

    if (email == presetEmail && password == presetPassword) {
      setState(() {
        isLoading = false;
      });
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const adminnavigation()),
        (route) => false,
      );
    } else {
      setState(() {
        isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Invalid Admin Email or Password!'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ThemeColors.background,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(25),
              child: Column(
                children: [
                  Container(
                    height: 100,
                    width: 100,
                    decoration: BoxDecoration(
                      color: ThemeColors.primaryTeal,
                      borderRadius: BorderRadius.circular(25),
                    ),
                    child: const Center(
                      child: FaIcon(
                        FontAwesomeIcons.userShield,
                        size: 48,
                        color: Colors.white,
                      ),
                    ),
                  ),

                  SizedBox(height: 20),
                  Text(
                    'Care-Circle',
                    style: GoogleFonts.cookie(
                      fontSize: 50,
                      color: Colors.white,
                    ),
                  ),

                  SizedBox(height: 5),
                  Text(
                    'Admin Portal',
                    style: GoogleFonts.poppins(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: ThemeColors.lightCyan,
                    ),
                  ),

                  SizedBox(height: 5),

                  Text(
                    'Sign in to manage Care-Circle',
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      color: Colors.white60,
                    ),
                  ),

                  SizedBox(height: 35),

                  TextField(
                    controller: adminEmail,
                    keyboardType: TextInputType.emailAddress,
                    style: GoogleFonts.poppins(color: Colors.white),
                    decoration: InputDecoration(
                      labelText: 'Admin Email',
                      labelStyle: GoogleFonts.poppins(color: Colors.white70),
                      prefixIcon: const Icon(
                        Icons.email_outlined,
                        color: Colors.white70,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: Colors.white54),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(
                          color: ThemeColors.accentCyan,
                          width: 2,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 15),

                  // Password field
                  TextField(
                    controller: adminPassword,
                    obscureText: obscurePassword,
                    style: GoogleFonts.poppins(color: Colors.white),
                    decoration: InputDecoration(
                      labelText: 'Admin Password',
                      labelStyle: GoogleFonts.poppins(color: Colors.white70),
                      prefixIcon: const Icon(
                        Icons.lock_outline,
                        color: Colors.white70,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: Colors.white54),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(
                          color: ThemeColors.accentCyan,
                          width: 2,
                        ),
                      ),
                      suffixIcon: IconButton(
                        onPressed: () {
                          setState(() {
                            obscurePassword = !obscurePassword;
                          });
                        },
                        icon: Icon(
                          obscurePassword
                              ? Icons.visibility_off
                              : Icons.visibility,
                          color: Colors.white70,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 25),

                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: ThemeColors.primaryTeal,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                      onPressed: isLoading ? null : loginAdmin,
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
                              'Admin Login',
                              style: GoogleFonts.poppins(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  TextButton.icon(
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const loginpage(),
                        ),
                      );
                    },
                    icon: const Icon(
                      Icons.arrow_back,
                      color: Colors.white70,
                      size: 18,
                    ),
                    label: Text(
                      'Back to User Login',
                      style: GoogleFonts.poppins(color: Colors.white70),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
