import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart'; 
import 'package:resbite_app/components/ui/button.dart'; 

class EmptyResbitesState extends StatelessWidget {
  final bool upcoming;

  const EmptyResbitesState({required this.upcoming, super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: Icon(
                upcoming ? Icons.event_available : Icons.history,
                size: 48,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              upcoming ? 'No Upcoming Resbites' : 'No Past Resbites',
              style: Theme.of(context).textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              upcoming
                  ? 'You don\'t have any planned resbites yet'
                  : 'Your completed resbites will appear here',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            if (upcoming)
              ShadButton.primary( // Assuming ShadButton.primary exists and matches FilledButton.icon styling
                onPressed: () {
                  // Navigate to create resbite screen
                  Navigator.of(context).pushNamed('/start-resbite');
                },
                icon: Icons.add,  // Fixed: Pass IconData directly, not Icon widget
                text: 'Create a Resbite',
                // Apply similar padding if needed via button style or wrapper
              ),
          ],
        ),
      ),
    );
  }
}
