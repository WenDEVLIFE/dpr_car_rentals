import 'package:dpr_car_rentals/src/helpers/ThemeHelper.dart';
import 'package:flutter/material.dart';

class CustomOutlinePassField extends StatefulWidget {
  final String labelText;
  final String hintText;
  final TextEditingController controller;

  const CustomOutlinePassField({
    super.key,
    required this.hintText,
    required this.labelText,
    required this.controller
  });

  @override
  State<CustomOutlinePassField> createState() => _CustomOutlinePassFieldState();
}

class _CustomOutlinePassFieldState extends State<CustomOutlinePassField> {
  bool _obscureText = true;
  String get labelText => widget.labelText;
  String get hintText => widget.hintText;


  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: widget.controller,
      obscureText: _obscureText,
      decoration: InputDecoration(
        fillColor: ThemeHelper.secondaryColor,
        labelText: labelText,
        hintText: hintText,
        labelStyle: TextStyle(
          color: Colors.black,
          fontSize: 16.0,
        ),
        hintStyle: TextStyle(
          color: ThemeHelper.textColor1,
          fontSize: 16.0,
        ),
          floatingLabelStyle: TextStyle(
            color: Colors.black,
            fontSize: 18.0,
          ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          borderSide: BorderSide(
            color: ThemeHelper.borderColor,
            width: 1.0,
          ),
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          borderSide: BorderSide(
            color:  ThemeHelper.borderColor,
            width: 1.0,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          borderSide: BorderSide(
            color:  ThemeHelper.borderColor,
            width: 1.0,
          ),
        ),
        contentPadding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        suffixIcon: IconButton(
          icon: Icon(
            _obscureText ? Icons.visibility_off : Icons.visibility,
            color: Colors.grey,
          ),
          onPressed: () {
            setState(() {
              _obscureText = !_obscureText;
            });
          },
        ),
      ),
    );
  }
}