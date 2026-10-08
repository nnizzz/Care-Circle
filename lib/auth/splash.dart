import 'package:care_circle/auth/register_page.dart';
import 'package:care_circle/theme/colors.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';

class onboardingscrn extends StatefulWidget {
  const onboardingscrn({super.key});

  @override
  State<onboardingscrn> createState() => _onboardingscrnState();
}

class _onboardingscrnState extends State<onboardingscrn> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: ThemeColors.primaryGradient
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              FaIcon(
                FontAwesomeIcons.slideshare,
                size: 80,
                color: Colors.white,
              ),
              SizedBox(height: 20),
              Text(
                'Care-Circle',
                style: GoogleFonts.cookie(fontSize: 50, color: Colors.white),
              ),
              Text(
                'Care. Support. Hope. Together 🤗',
                style: GoogleFonts.cormorantGaramond(
                  fontSize: 20,
                  color: Colors.white70,
                ),
              ),

              SizedBox(height: 30),

              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => registerpage()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: ThemeColors.backgroundLight,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Text(
                  'Get Started',
                  style: GoogleFonts.poppins(
                    color: Color.fromARGB(255, 5, 20, 40),
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
