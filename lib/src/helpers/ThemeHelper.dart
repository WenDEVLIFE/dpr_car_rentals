import 'dart:ui';

class ThemeHelper {

  static final Color primaryColor = Color.lerp(
    const Color(0xFFE3F2FD),
    const Color(0xFFFFFFFF),
    0.50,
  )!;
  static const Color secondaryColor = Color(0xFFCBD5E0);
  static const Color backgroundColor = Color(0xFFF7FAFC);
  static const Color textColor = Color(0xFF333333);
  static const Color textColor1 = Color(0xFFA0AEC0);
  static const Color accentColor = Color(0xFF00C853);
  static const Color buttonColor = Color(0xFF6C63FF);
  static const Color borderColor = Color(0xFFCBD5E0);
}