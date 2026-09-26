import 'package:flutter/material.dart';

class AppColors {
  // Dashtrans Glassmorphic & Shadcn UI Theme Palette
  static const Color darkBackground = Color(0xFF090D16); // Deep slate background
  static const Color darkSurface = Color(0xFF0F172A);    // Glass surface
  static const Color darkCardBorder = Color(0xFF1E293B);  // Subtle card stroke
  static const Color darkBorderHighlight = Color(0xFF334155);

  // Vibrant Accents & Gradients
  static const Color primary = Color(0xFF10B981);       // Emerald Green
  static const Color primaryTeal = Color(0xFF14B8A6);   // Teal Accent
  static const Color secondary = Color(0xFF6366F1);     // Indigo
  static const Color accentCyan = Color(0xFF06B6D4);    // Cyan
  static const Color accentPurple = Color(0xFF8B5CF6);  // Violet
  static const Color accentGold = Color(0xFFF59E0B);    // Amber
  static const Color accentRose = Color(0xFFF43F5E);    // Crimson Rose

  // Light & Dark Text Aliases
  static const Color lightBackground = Color(0xFFF8FAFC);
  static const Color lightSurface = Colors.white;
  static const Color lightCardBorder = Color(0xFFE2E8F0);
  static const Color lightTextPrimary = Color(0xFFF8FAFC);
  static const Color lightTextSecondary = Color(0xFF94A3B8);

  // Text Colors
  static const Color textPrimary = Color(0xFFF8FAFC);
  static const Color textSecondary = Color(0xFF94A3B8);
  static const Color textMuted = Color(0xFF64748B);

  // Status Indicators
  static const Color success = Color(0xFF10B981);
  static const Color warning = Color(0xFFF59E0B);
  static const Color error = Color(0xFFEF4444);
  static const Color info = Color(0xFF06B6D4);

  // Gradient Decorations
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF10B981), Color(0xFF06B6D4)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient indigoGradient = LinearGradient(
    colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient glassCardGradient = LinearGradient(
    colors: [Color(0x1F1E293B), Color(0x0F0F172A)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
