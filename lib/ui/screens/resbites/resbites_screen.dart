import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'providers/tab_provider.dart';
import 'components/index.dart';

class ResbitesScreen extends ConsumerWidget {
  const ResbitesScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tabController = ref.watch(resbiteTabControllerProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Resbites'),
        bottom: TabBar(
          controller: tabController,
          tabs: const [Tab(text: 'Upcoming'), Tab(text: 'Past')],
          dividerColor: Colors.transparent,
          indicatorSize: TabBarIndicatorSize.tab,
          labelColor: Theme.of(context).colorScheme.primary,
          unselectedLabelColor: Theme.of(
            context,
          ).colorScheme.onSurface.withOpacity(0.7),
          overlayColor: MaterialStateProperty.resolveWith<Color>((states) {
            if (states.contains(MaterialState.pressed)) {
              return Theme.of(context).colorScheme.primary.withOpacity(0.1);
            }
            return Colors.transparent;
          }),
        ),
      ),
      body: TabBarView(
        controller: tabController,
        children: [
          const ResbitesTabContent(upcoming: true),
          const ResbitesTabContent(upcoming: false),
        ],
      ),
      floatingActionButton: const ResbiteFAB(),
    );
  }
}
