import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'services/event_service.dart';

/// Simple list screen to display events relevant to the current user.
class EventsScreen extends ConsumerWidget {
  const EventsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final eventsAsync = ref.watch(relevantEventsProvider);

    return eventsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, st) => Center(child: Text('Error: $err')),
      data: (events) => events.isEmpty
          ? const _EmptyEventsState()
          : ListView.separated(
              itemCount: events.length,
              separatorBuilder: (context, index) => const Divider(height: 0),
              itemBuilder: (context, i) {
                final event = events[i];
                return ListTile(
                  title: Text(event.title),
                  subtitle: Text(
                    '${_formatDate(event.startAt)} - ${_formatDate(event.endAt)}',
                  ),
                  leading: const Icon(Icons.event),
                  onTap: () {
                    // TODO: navigate to details when implemented
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Open event ${event.title}')),
                    );
                  },
                );
              },
            ),
    );
  }

  String _formatDate(DateTime dt) {
    return '${dt.month}/${dt.day} ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }
}

class _EmptyEventsState extends StatelessWidget {
  const _EmptyEventsState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.event_busy, size: 72, color: Colors.grey),
          const SizedBox(height: 16),
          Text(
            'No events yet',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Text(
            'Tap the + button to create your first event.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
