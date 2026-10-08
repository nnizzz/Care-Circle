import 'package:care_circle/auth/login_page.dart';
import 'package:care_circle/theme/colors.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';

class registerpage extends StatefulWidget {
  const registerpage({super.key});

  @override
  State<registerpage> createState() => _registerpageState();
}

class _registerpageState extends State<registerpage> {
  final TextEditingController uname = TextEditingController();
  final TextEditingController uemail = TextEditingController();
  final TextEditingController uphone = TextEditingController();
  final TextEditingController upass = TextEditingController();
  final TextEditingController uconfirmPass = TextEditingController();
  final TextEditingController orphanageAddress = TextEditingController();

  String selectedRole = 'user';
  String? selectedDistrict;
  String? selectedCategory;

  bool obscurePassword = true;
  bool obscureConfirmPassword = true;
  bool isLoading = false;

  final List<String> keralaDistricts = [
    'Alappuzha',
    'Ernakulam',
    'Idukki',
    'Kannur',
    'Kasaragod',
    'Kollam',
    'Kottayam',
    'Kozhikode',
    'Malappuram',
    'Palakkad',
    'Pathanamthitta',
    'Thiruvananthapuram',
    'Thrissur',
    'Wayanad',
  ];

  final List<String> orphanageCategories = [
    "Children's Home",
    'Old Age Home',
    'Special Needs Home',
    "Women's Shelter",
    'Rehabilitation Center',
    'Other',
  ];

  @override
  void dispose() {
    uname.dispose();
    uemail.dispose();
    uphone.dispose();
    upass.dispose();
    uconfirmPass.dispose();
    orphanageAddress.dispose();
    super.dispose();
  }

  Future<void> register() async {
    if (uname.text.trim().isEmpty ||
        uemail.text.trim().isEmpty ||
        uphone.text.trim().isEmpty ||
        upass.text.isEmpty ||
        uconfirmPass.text.isEmpty) {
      showMessage(
        'All fields are required!',
        ThemeColors.error,
      );
      return;
    }

    if (selectedRole == 'orphanage') {
      if (selectedCategory == null ||
          orphanageAddress.text.trim().isEmpty ||
          selectedDistrict == null) {
        showMessage(
          'Please complete all orphanage details!',
          ThemeColors.error,
        );
        return;
      }
    }

    if (upass.text.length < 4) {
      showMessage(
        'Password must contain at least 4 characters!',
        ThemeColors.error,
      );
      return;
    }

    if (upass.text != uconfirmPass.text) {
      showMessage(
        'Passwords do not match!',
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

    final success = await authProvider.registerUser(
      name: uname.text.trim(),
      email: uemail.text.trim(),
      password: upass.text,
      phone: uphone.text.trim(),
      role: selectedRole,
      address: selectedRole == 'orphanage'
          ? orphanageAddress.text.trim()
          : null,
      district:
          selectedRole == 'orphanage' ? selectedDistrict : null,
      category:
          selectedRole == 'orphanage' ? selectedCategory : null,
    );

    if (!mounted) return;

    setState(() {
      isLoading = false;
    });

    if (success) {
      showMessage(
        selectedRole == 'orphanage'
            ? 'Account created! Your orphanage will require admin verification.'
            : 'Account created successfully!',
        ThemeColors.success,
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const loginpage(),
        ),
      );
    } else {
      showMessage(
        'An account with this email already exists!',
        ThemeColors.error,
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
            vertical: 24,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Column(
                  children: [
                    FaIcon(
                      FontAwesomeIcons.slideshare,
                      size: 60,
                      color: ThemeColors.lightCyan,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Care-Circle',
                      style: GoogleFonts.cookie(
                        fontSize: 46,
                        color: ThemeColors.textLight,
                      ),
                    ),
                    Text(
                      'Create your account',
                      style: GoogleFonts.poppins(
                        fontSize: 15,
                        color: ThemeColors.textMuted,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              Text(
                'I am registering as',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: ThemeColors.textLight,
                ),
              ),

              const SizedBox(height: 12),

              Row(
                children: [
                  Expanded(
                    child: roleCard(
                      role: 'user',
                      title: 'Donor',
                      subtitle: 'I want to help',
                      icon: Icons.volunteer_activism_rounded,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: roleCard(
                      role: 'orphanage',
                      title: 'Orphanage',
                      subtitle: 'I need support',
                      icon: Icons.home_rounded,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 28),

              Text(
                selectedRole == 'orphanage'
                    ? 'Orphanage Details'
                    : 'Personal Details',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: ThemeColors.lightCyan,
                ),
              ),

              const SizedBox(height: 16),

              TextField(
                controller: uname,
                keyboardType: TextInputType.name,
                style: TextStyle(
                  color: ThemeColors.textPrimary,
                ),
                decoration: fieldDecoration(
                  label: selectedRole == 'orphanage'
                      ? 'Orphanage Name'
                      : 'Full Name',
                  icon: selectedRole == 'orphanage'
                      ? Icons.home_work_rounded
                      : Icons.person_rounded,
                ),
              ),

              if (selectedRole == 'orphanage') ...[
                const SizedBox(height: 14),

                DropdownButtonFormField<String>(
                  value: selectedCategory,
                  dropdownColor: ThemeColors.card,
                  style: TextStyle(
                    color: ThemeColors.textPrimary,
                  ),
                  decoration: fieldDecoration(
                    label: 'Orphanage Type',
                    icon: Icons.category_rounded,
                  ),
                  items: orphanageCategories.map((category) {
                    return DropdownMenuItem<String>(
                      value: category,
                      child: Text(category),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedCategory = value;
                    });
                  },
                ),
              ],

              const SizedBox(height: 14),

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

              const SizedBox(height: 14),

              TextField(
                controller: uphone,
                keyboardType: TextInputType.phone,
                style: TextStyle(
                  color: ThemeColors.textPrimary,
                ),
                decoration: fieldDecoration(
                  label: 'Phone Number',
                  icon: Icons.phone_rounded,
                ),
              ),

              if (selectedRole == 'orphanage') ...[
                const SizedBox(height: 14),

                TextField(
                  controller: orphanageAddress,
                  keyboardType: TextInputType.streetAddress,
                  maxLines: 2,
                  style: TextStyle(
                    color: ThemeColors.textPrimary,
                  ),
                  decoration: fieldDecoration(
                    label: 'Orphanage Address',
                    icon: Icons.location_on_rounded,
                  ),
                ),

                const SizedBox(height: 14),

                DropdownButtonFormField<String>(
                  value: selectedDistrict,
                  dropdownColor: ThemeColors.card,
                  style: TextStyle(
                    color: ThemeColors.textPrimary,
                  ),
                  decoration: fieldDecoration(
                    label: 'District',
                    icon: Icons.map_rounded,
                  ),
                  items: keralaDistricts.map((district) {
                    return DropdownMenuItem<String>(
                      value: district,
                      child: Text(district),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedDistrict = value;
                    });
                  },
                ),

                const SizedBox(height: 12),

                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.transparent,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: ThemeColors.border,
                    ),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.verified_user_outlined,
                        color: ThemeColors.accentCyan,
                        size: 20,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Your orphanage will be reviewed by the admin before it becomes visible to donors.',
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            height: 1.5,
                            color: ThemeColors.textMuted,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              const SizedBox(height: 14),

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

              const SizedBox(height: 14),

              TextField(
                controller: uconfirmPass,
                obscureText: obscureConfirmPassword,
                style: TextStyle(
                  color: ThemeColors.textPrimary,
                ),
                decoration: fieldDecoration(
                  label: 'Confirm Password',
                  icon: Icons.lock_outline_rounded,
                  suffixIcon: IconButton(
                    onPressed: () {
                      setState(() {
                        obscureConfirmPassword =
                            !obscureConfirmPassword;
                      });
                    },
                    icon: Icon(
                      obscureConfirmPassword
                          ? Icons.visibility_off_rounded
                          : Icons.visibility_rounded,
                      color: ThemeColors.textMuted,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 26),

              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed: isLoading ? null : register,
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
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : Text(
                          selectedRole == 'orphanage'
                              ? 'Register Orphanage'
                              : 'Create Account',
                          style: GoogleFonts.poppins(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              ),

              const SizedBox(height: 18),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Already have an account?',
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      color: ThemeColors.textMuted,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              const loginpage(),
                        ),
                      );
                    },
                    child: Text(
                      'Log In',
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

          if (role == 'user') {
            orphanageAddress.clear();
            selectedDistrict = null;
            selectedCategory = null;
          }
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(
          vertical: 18,
          horizontal: 12,
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
              height: 45,
              width: 45,
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
            const SizedBox(height: 10),
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