import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';

import '../../../../config/routes.dart';
import '../../../../models/resbite.dart';
import 'resbite_action_button.dart';
import 'resbite_detail_row.dart';
import 'resbite_status_badge.dart';

/// A card displaying a resbite's key information and interactive elements.
///
/// This component handles the overall card layout and navigation while
/// delegating specific UI elements to specialized components.
class ResbiteCard extends ConsumerWidget {
  final Resbite resbite;

  const ResbiteCard({required this.resbite, super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 0,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: InkWell(
        onTap: () {
          Navigator.of(context).pushNamed(
            AppRoutes.resbiteDetails,
            arguments: {'id': resbite.id},
          );
        },
        borderRadius: BorderRadius.circular(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Resbite header
            _buildHeader(context),
            // Resbite details
            _buildDetails(context, ref),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer.withOpacity(0.5),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: Row(
        children: [
          // Activity image
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Theme.of(context).colorScheme.outline.withOpacity(0.1),
                width: 1,
              ),
            ),
            clipBehavior: Clip.antiAlias,
            child: resbite.images.isNotEmpty
                ? Image.network(
                    resbite.images.first,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Icon(
                        Icons.event, // Placeholder icon
                        size: 30,
                        color: Theme.of(context).colorScheme.primary,
                      );
                    },
                  )
                : Icon(
                    Icons.event, // Placeholder icon
                    size: 30,
                    color: Theme.of(context).colorScheme.primary,
                  ),
          ),
          const SizedBox(width: 16),
          // Resbite info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  resbite.title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                if (resbite.activity != null)
                  Text(
                    resbite.activity!.title,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.8),
                        ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                const SizedBox(height: 8),
                // Use computedStatus to reflect ongoing/completed based on current time
                ResbiteStatusBadge(status: resbite.computedStatus),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetails(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Date and time
          ResbiteDetailRow(
            icon: Icons.calendar_today,
            text: _formatDate(context, resbite.startDate),
          ),
          const SizedBox(height: 12),
          // Location
          ResbiteDetailRow(
            icon: Icons.location_on_outlined,
            text: resbite.place?.name ?? resbite.meetingPoint ?? 'Location not specified',
          ),
          const SizedBox(height: 12),
          // Participants
          ResbiteDetailRow(
            icon: Icons.people_outline,
            text: 'Participants: ',
            trailing: Badge(
              backgroundColor: resbite.attendanceLimit != null &&
                      resbite.attendanceLimit! > 0 &&
                      resbite.currentAttendance >= resbite.attendanceLimit!
                  ? Theme.of(context).colorScheme.error
                  : Theme.of(context).colorScheme.primary,
              label: Text(
                '${resbite.currentAttendance}/${resbite.attendanceLimit != null && resbite.attendanceLimit! > 0 ? resbite.attendanceLimit : '∞'}',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 8),
            ),
          ),
          // Description
          if (resbite.description != null && resbite.description!.isNotEmpty) ...[
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 8),
            Text(
              resbite.description!,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.8),
                  ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
          const SizedBox(height: 16),
          // Action buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              FilledButton.tonal(
                onPressed: () {
                  Share.share(
                    'Join me at ${resbite.title}! View details: ${AppRoutes.resbiteDetails}?id=${resbite.id}'
                  );
                },
                style: FilledButton.styleFrom(
                  visualDensity: VisualDensity.compact,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.share_outlined, size: 16),
                    SizedBox(width: 8),
                    Text('Share'),
                  ],
                ),
              ),
              ResbiteActionButton(resbite: resbite),
            ],
          ),
        ],
      ),
    );
  }

  /// Format the date in a human-readable way (Today, Tomorrow, or date)
  String _formatDate(BuildContext context, DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));
    final dateToCheck = DateTime(date.year, date.month, date.day);

    if (dateToCheck == today) {
      return 'Today, ${TimeOfDay.fromDateTime(date).format(context)}';
    } else if (dateToCheck == tomorrow) {
      return 'Tomorrow, ${TimeOfDay.fromDateTime(date).format(context)}';
    } else {
      // Use a standard format
      return '${date.day}/${date.month}/${date.year}, ${TimeOfDay.fromDateTime(date).format(context)}';
    }
  }
}
