import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class VoidSnackBar {
  static void show(
    BuildContext context, {
    required String message,
    IconData? icon,
    bool isError = false,
  }) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        padding: EdgeInsets.zero,
        duration: const Duration(seconds: 4),
        content: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: const Color(0xFF1E1E1E), // Solid greyish shade, no transparency
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white, width: 1.0), // Solid white border
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.4),
                blurRadius: 20,
                spreadRadius: 2,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            children: [
              if (icon != null || isError)
                Padding(
                  padding: const EdgeInsets.only(right: 12.0),
                  child: Icon(
                    isError ? Icons.error_outline : (icon ?? Icons.info_outline),
                    color: isError ? Colors.redAccent : Colors.white,
                    size: 20,
                  ),
                ),
              Expanded(
                child: Text(
                  message,
                  style: GoogleFonts.ibmPlexSans(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
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
