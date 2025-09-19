import 'package:dpr_car_rentals/src/helpers/ThemeHelper.dart';
import 'package:flutter/material.dart';

class ModernSearchBar extends StatefulWidget {
  final String hintText;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onClear;
  final bool autofocus;
  final EdgeInsetsGeometry? padding;
  final double borderRadius;
  final Color? backgroundColor;
  final Color? textColor;
  final Color? hintColor;
  final TextEditingController? controller;

  const ModernSearchBar({
    super.key,
    this.hintText = 'Search...',
    this.onChanged,
    this.onClear,
    this.autofocus = false,
    this.padding,
    this.borderRadius = 16.0,
    this.backgroundColor,
    this.textColor,
    this.hintColor,
    this.controller,
  });

  @override
  State<ModernSearchBar> createState() => _ModernSearchBarState();
}

class _ModernSearchBarState extends State<ModernSearchBar> {
  late TextEditingController _controller;
  bool _hasText = false;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? TextEditingController();
    _controller.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    if (widget.controller == null) {
      _controller.dispose();
    } else {
      _controller.removeListener(_onTextChanged);
    }
    super.dispose();
  }

  void _onTextChanged() {
    final hasText = _controller.text.isNotEmpty;
    if (hasText != _hasText) {
      setState(() {
        _hasText = hasText;
      });
    }
    widget.onChanged?.call(_controller.text);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: widget.padding ??
          const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      decoration: BoxDecoration(
        color: widget.backgroundColor ??
            ThemeHelper.secondaryColor.withOpacity(0.8),
        borderRadius: BorderRadius.circular(widget.borderRadius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(
            Icons.search,
            color: widget.hintColor ?? ThemeHelper.textColor1,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: TextField(
              controller: _controller,
              autofocus: widget.autofocus,
              style: TextStyle(
                color: widget.textColor ?? ThemeHelper.textColor,
                fontSize: 16,
                fontFamily: 'Inter',
                fontWeight: FontWeight.w400,
              ),
              decoration: InputDecoration(
                hintText: widget.hintText,
                hintStyle: TextStyle(
                  color: widget.hintColor ?? ThemeHelper.textColor1,
                  fontSize: 16,
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w400,
                ),
                border: InputBorder.none,
                contentPadding: EdgeInsets.zero,
              ),
              cursorColor: ThemeHelper.buttonColor,
            ),
          ),
          if (_hasText) ...[
            const SizedBox(width: 12),
            GestureDetector(
              onTap: () {
                _controller.clear();
                widget.onClear?.call();
              },
              child: Icon(
                Icons.clear,
                color: widget.hintColor ?? ThemeHelper.textColor1,
                size: 20,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
