import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';

class RouteLine extends StatelessWidget {
  final String pickup;
  final String dropoff;
  const RouteLine({super.key, required this.pickup, required this.dropoff});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              width: 11,
              height: 11,
              decoration: BoxDecoration(
                color: AppColors.bg,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.signal, width: 2.5),
              ),
            ),
            Container(width: 2, height: 34, color: AppColors.line),
            Icon(Icons.location_on, size: 15, color: AppColors.danger),
          ],
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'PICKUP',
                style: TextStyle(
                  color: AppColors.textFaint,
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                pickup,
                style: TextStyle(
                  color: AppColors.text,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'DROP-OFF',
                style: TextStyle(
                  color: AppColors.textFaint,
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                dropoff,
                style: TextStyle(
                  color: AppColors.text,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
