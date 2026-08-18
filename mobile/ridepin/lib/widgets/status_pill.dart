import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';
import '../models/ride.dart';

class StatusPill extends StatelessWidget {
  final String status;
  const StatusPill({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    final (color, label) = switch (status) {
      RideStatus.pending => (AppColors.signal, 'Searching'),
      RideStatus.accepted => (AppColors.info, 'Driver assigned'),
      RideStatus.started => (AppColors.info, 'On the way'),
      RideStatus.completed => (AppColors.success, 'Completed'),
      RideStatus.cancelled => (AppColors.danger, 'Cancelled'),
      _ => (AppColors.textDim, status),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: 0.35)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 7),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
