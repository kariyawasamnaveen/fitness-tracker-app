// ignore_for_file: unused_local_variable, use_build_context_synchronously
import 'package:flutter/material.dart';

class PrimaryActionButton extends StatelessWidget {
  final bool isLoading;
  final VoidCallback? onPressed;
  final String text;
  final double height;
  final double width;

  const PrimaryActionButton({
    super.key,
    required this.isLoading,
    required this.onPressed,
    required this.text,
    this.height = 56,
    this.width = double.infinity,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: const LinearGradient(
          colors: [Color(0xFF254D7A), Color(0xFF0F2537)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0B192C).withValues(alpha: 0.6),
            blurRadius: 16,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              height: 2,
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
                gradient: LinearGradient(
                  colors: [
                    Colors.white.withValues(alpha: 0.1),
                    Colors.white.withValues(alpha: 0.5),
                    Colors.white.withValues(alpha: 0.1),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            top: 0,
            child: Container(
              width: 60,
              height: 3,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(1.5),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.white,
                    blurRadius: 8,
                    spreadRadius: 2,
                  ),
                  BoxShadow(
                    color: Color(0xFF00D2FF),
                    blurRadius: 12,
                    spreadRadius: 4,
                  ),
                ],
              ),
            ),
          ),
          ElevatedButton(
            onPressed: isLoading ? null : onPressed,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.transparent,
              shadowColor: Colors.transparent,
              minimumSize: Size(width, height),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: isLoading
                ? const SizedBox(
                    height: 22,
                    width: 22,
                    child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                  )
                : Text(
                    text,
                    style: TextStyle(
                      color: const Color(0xFFE5C583),
                      fontSize: 17,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.5,
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
