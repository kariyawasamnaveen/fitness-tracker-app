// ignore_for_file: unused_local_variable, use_build_context_synchronously
import 'package:flutter/material.dart';

class EliteTextField extends StatefulWidget {
  final TextEditingController controller;
  final String hint;
  final IconData icon;
  final String fieldKey;
  final bool obscureText;
  final TextInputType keyboardType;
  final Widget? suffixIcon;

  const EliteTextField({
    super.key,
    required this.controller,
    required this.hint,
    required this.icon,
    required this.fieldKey,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
    this.suffixIcon,
  });

  @override
  State<EliteTextField> createState() => _EliteTextFieldState();
}

class _EliteTextFieldState extends State<EliteTextField> {
  bool _isFocused = false;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFF14243B).withValues(alpha: 0.85),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _isFocused ? const Color(0xFF00D2FF) : Colors.white.withValues(alpha: 0.15),
          width: _isFocused ? 1.5 : 1,
        ),
        boxShadow: _isFocused
            ? [
                BoxShadow(
                  color: const Color(0xFF00D2FF).withValues(alpha: 0.4),
                  blurRadius: 20,
                  spreadRadius: 4,
                ),
              ]
            : [],
      ),
      child: Focus(
        onFocusChange: (hasFocus) {
          setState(() {
            _isFocused = hasFocus;
          });
        },
        child: Row(
          children: [
            Icon(
              widget.icon,
              color: _isFocused ? const Color(0xFF00D2FF) : Colors.white70,
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TextField(
                controller: widget.controller,
                obscureText: widget.obscureText,
                keyboardType: widget.keyboardType,
                style: const TextStyle(fontSize: 15, color: Colors.white, fontWeight: FontWeight.w600),
                decoration: InputDecoration(
                  hintText: widget.hint,
                  hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.5), fontSize: 14, fontWeight: FontWeight.w500),
                  border: InputBorder.none,
                  isDense: true,
                  contentPadding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),
            if (widget.suffixIcon != null) widget.suffixIcon!,
          ],
        ),
      ),
    );
  }
}
