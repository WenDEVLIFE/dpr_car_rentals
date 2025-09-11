import 'package:dpr_car_rentals/src/helpers/ThemeHelper.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class OTPInputField extends StatefulWidget {
  final TextEditingController controller;
  final FocusNode? focusNode;
  final bool autoFocus;
  final Function(String) onChanged;
  final Function()? onCompleted;

  const OTPInputField({
    super.key,
    required this.controller,
    this.focusNode,
    required this.autoFocus,
    required this.onChanged,
    this.onCompleted,
  });

  @override
  State<OTPInputField> createState() => _OTPInputFieldState();
}

class _OTPInputFieldState extends State<OTPInputField>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.1,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.elasticOut,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _animateInput() {
    _animationController.forward().then((_) {
      _animationController.reverse();
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: widget.controller.text.isNotEmpty
                  ? ThemeHelper.accentColor.withOpacity(0.1)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: _hasError
                    ? Colors.red
                    : widget.controller.text.isNotEmpty
                        ? ThemeHelper.accentColor
                        : ThemeHelper.borderColor,
                width: widget.controller.text.isNotEmpty ? 2 : 1,
              ),
              boxShadow: widget.controller.text.isNotEmpty
                  ? [
                      BoxShadow(
                        color: ThemeHelper.accentColor.withOpacity(0.2),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ]
                  : null,
            ),
            child: TextField(
              controller: widget.controller,
              focusNode: widget.focusNode,
              autofocus: widget.autoFocus,
              textAlign: TextAlign.center,
              keyboardType: TextInputType.number,
              maxLength: 1,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w600,
                color: Colors.black,
                fontFamily: 'Inter',
              ),
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
              ],
              decoration: const InputDecoration(
                counterText: '',
                border: InputBorder.none,
                contentPadding: EdgeInsets.zero,
              ),
              onChanged: (value) {
                setState(() {
                  _hasError = false;
                });

                if (value.isNotEmpty) {
                  _animateInput();
                  widget.onChanged(value);
                  if (widget.onCompleted != null) {
                    widget.onCompleted!();
                  }
                } else {
                  widget.onChanged(value);
                }
              },
            ),
          ),
        );
      },
    );
  }

  void setError(bool hasError) {
    setState(() {
      _hasError = hasError;
    });
  }
}
