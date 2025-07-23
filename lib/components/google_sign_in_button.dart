import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class GoogleSignInButton extends StatelessWidget {
  const GoogleSignInButton({super.key});

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
      onPressed: () {
        // TODO: Integrasi Google Sign-In di sini
      },
      icon: Image.asset(
        'assets/icons/google.png', // 📍 Asset ini ada di baris ini
        width: 24,
        height: 24,
      ),
      label: Text(
        'Sign up with Google',
        style: GoogleFonts.inter(fontSize: 15),
      ),
    );
  }
}
