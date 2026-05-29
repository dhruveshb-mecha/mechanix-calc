import 'package:flutter/material.dart';

class CalculatorButton extends StatelessWidget {
  final String text;
  final IconData? icon;
  final VoidCallback onTap;
  final Color? color;
  final Color? textColor;

  const CalculatorButton({
    super.key,
    required this.text,
    this.icon,
    required this.onTap,
    this.color,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black, width: 0.5),
        color: color ?? const Color(0xFF1A1A1A),
      ),
      margin: const EdgeInsets.all(0),
      child: icon != null
          ? IconButton(
              onPressed: onTap,
              icon: Icon(icon, color: textColor ?? Colors.white),
            )
          : TextButton(
              onPressed: onTap,
              child: Text(
                text,
                style: TextStyle(
                  fontSize: 28,
                  color: textColor ?? Colors.white,
                  fontWeight: FontWeight.w300,
                ),
              ),
            ),
    );
  }
}
