import 'package:flutter/material.dart';
import '../../../../models/resbite.dart';

/// A widget that displays a chip with the status of a resbite.
///
/// The chip's color and text change based on the status value.
class ResbiteStatusBadge extends StatelessWidget {
  final ResbiteStatus status;

  const ResbiteStatusBadge({required this.status, super.key});

  @override
  Widget build(BuildContext context) {
    return Chip(
      label: Text(_getStatusText()),
      labelStyle: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: _getStatusColor(context),
      ),
      backgroundColor: _getStatusColor(context).withOpacity(0.12),
      side: BorderSide.none,
      padding: EdgeInsets.zero,
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      visualDensity: VisualDensity.compact,
    );
  }

  Color _getStatusColor(BuildContext context) {
    switch (status) {
      case ResbiteStatus.planned:
        return Theme.of(context).colorScheme.primary;
      case ResbiteStatus.active:
        return Colors.orange.shade700;
      case ResbiteStatus.completed:
        return Theme.of(context).colorScheme.secondary;
      case ResbiteStatus.cancelled:
        return Theme.of(context).colorScheme.error;
    }
  }

  String _getStatusText() {
    switch (status) {
      case ResbiteStatus.planned:
        return 'Upcoming';
      case ResbiteStatus.active:
        return 'Ongoing';
      case ResbiteStatus.completed:
        return 'Finished';
      case ResbiteStatus.cancelled:
        return 'Cancelled';
    }
  }
}
