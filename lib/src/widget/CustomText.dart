import 'package:flutter/cupertino.dart';

class CustomText extends StatelessWidget {
  final String text;
  final double size;
  final Color color;
  final String fontFamily;
  final FontWeight weight;

  const CustomText({
    super.key,
    required this.text,
    required this.size,
    required this.color,
    required this.fontFamily,
    required this.weight,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        fontSize: size,
        color: color,
        fontWeight: weight,
        fontFamily: fontFamily,
      ),
    );
  }
}