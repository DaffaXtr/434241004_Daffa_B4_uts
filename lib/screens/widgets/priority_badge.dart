import 'package:flutter/material.dart';
import '../../models/ticket_model.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_sizes.dart';

class PriorityBadge extends StatelessWidget {
  final TicketPriority priority;

  const PriorityBadge({super.key, required this.priority});

  Color get _color {
    switch (priority) {
      case TicketPriority.low:
        return AppColors.priorityLow;
      case TicketPriority.medium:
        return AppColors.priorityMedium;
      case TicketPriority.high:
        return AppColors.priorityHigh;
      case TicketPriority.critical:
        return AppColors.priorityCritical;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSizes.md,
        vertical: AppSizes.sm,
      ),
      decoration: BoxDecoration(
        color: _color.withOpacity(0.1),
        border: Border.all(color: _color, width: 1),
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
      ),
      child: Text(
        priority.toString().split('.').last.toUpperCase(),
        style: TextStyle(
          color: _color,
          fontWeight: FontWeight.w600,
          fontSize: AppSizes.fontSm,
        ),
      ),
    );
  }
}
