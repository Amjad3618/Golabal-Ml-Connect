import 'package:flutter/material.dart';

class AppColors {
  static const Color primary = Colors.blue;
  static const Color secondary = Colors.green;
  static const Color accent = Colors.orange;
  static const Color error = Colors.red;
  static const Color warning = Colors.orange;
  static const Color success = Colors.green;
  static const Color info = Colors.blue;
  
  static Color get primaryLight => primary.withOpacity(0.1);
  static Color get secondaryLight => secondary.withOpacity(0.1);
  static Color get accentLight => accent.withOpacity(0.1);
  
  static const Color textPrimary = Colors.black87;
  static const Color textSecondary = Colors.grey;
  static const Color background = Color(0xFFF5F5F5);
  static const Color cardBackground = Colors.white;
}

class AppConstants {
  static const double defaultPadding = 16.0;
  static const double defaultMargin = 16.0;
  static const double defaultBorderRadius = 12.0;
  
  static const EdgeInsets defaultScreenPadding = EdgeInsets.all(24.0);
  static const EdgeInsets defaultCardPadding = EdgeInsets.all(16.0);
  
  static const Duration defaultAnimationDuration = Duration(milliseconds: 200);
}
