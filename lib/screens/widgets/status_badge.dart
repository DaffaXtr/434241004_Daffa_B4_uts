import 'package:flutter/material.dart';
import '../../models/ticket_model.dart';
import '../../core/constants/app_colors.dart';

class StatusBadge extends StatelessWidget {
  final TicketStatus status;

  const StatusBadge({super.key, required this.status});

  Color get _color {
    switch (status) {
      case TicketStatus.open:
        return AppColors.statusOpen;
      case TicketStatus.inProgress:
        return AppColors.statusInProgress;
      case TicketStatus.resolved:
        return AppColors.statusResolved;
      case TicketStatus.closed:
        return AppColors.statusClosed;
    }
  }

  String get _label {
    switch (status) {
      case TicketStatus.open:
        return 'Open';
      case TicketStatus.inProgress:
        return 'In Progress';
      case TicketStatus.resolved:
        return 'Resolved';
      case TicketStatus.closed:
        return 'Closed';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: _color.withValues(alpha: 0.1),
        border: Border.all(color: _color.withValues(alpha: 0.5), width: 0.5),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        _label,
        style: TextStyle(
          color: _color,
          fontWeight: FontWeight.w600,
          fontSize: 10,
        ),
      ),
    );
  }
}
