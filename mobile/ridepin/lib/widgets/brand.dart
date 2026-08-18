import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';

class BrandMark extends StatelessWidget {
  final double size;
  const BrandMark({super.key, this.size = 44});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: AppColors.signal,
            borderRadius: BorderRadius.circular(size * 0.28),
          ),
          child: Icon(
            Icons.navigation_rounded,
            color: const Color(0xFF1A1206),
            size: size * 0.55,
          ),
        ),
        SizedBox(width: size * 0.32),
        Text(
          'RidePin',
          style: TextStyle(
            color: AppColors.text,
            fontSize: size * 0.62,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.5,
          ),
        ),
      ],
    );
  }
}
