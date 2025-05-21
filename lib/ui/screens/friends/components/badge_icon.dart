import 'package:flutter/material.dart';
import 'package:resbite_app/styles/tailwind_theme.dart';

/// Badge with member count and lock icon for circle item
class BadgeIcon extends StatelessWidget {
  final int memberCount;
  final bool isPrivate;
  
  const BadgeIcon({
    super.key,
    required this.memberCount,
    required this.isPrivate,
  });
  
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.people,
            size: 16,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(width: 4),
          Text(
            '$memberCount',
            style: TwTypography.bodyXs(context).copyWith(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
          if (isPrivate) ...[
            const SizedBox(width: 4),
            Icon(
              Icons.lock,
              size: 14,
              color: Theme.of(context).colorScheme.primary,
            ),
          ],
        ],
      ),
    );
  }
}
