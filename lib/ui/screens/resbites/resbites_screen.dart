import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../models/resbite.dart';
import '../../../services/providers.dart';

class ResbitesScreen extends ConsumerStatefulWidget {
  const ResbitesScreen({super.key});

  @override
  ConsumerState<ResbitesScreen> createState() => _ResbitesScreenState();
}

class _ResbitesScreenState extends ConsumerState<ResbitesScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  
  @override
  void initState() {
    super.initState();
    
    // Initialize tab controller
    _tabController = TabController(length: 2, vsync: this);
  }
  
  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Resbites'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Upcoming'),
            Tab(text: 'Past'),
          ],
          dividerColor: Colors.transparent,
          indicatorSize: TabBarIndicatorSize.tab,
          labelColor: Theme.of(context).colorScheme.primary,
          unselectedLabelColor: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
          overlayColor: MaterialStateProperty.resolveWith<Color>(
            (Set<MaterialState> states) {
              if (states.contains(MaterialState.pressed)) {
                return Theme.of(context).colorScheme.primary.withOpacity(0.1);
              }
              return Colors.transparent;
            },
          ),
        ),
        scrolledUnderElevation: 2,
        shadowColor: Theme.of(context).colorScheme.shadow,
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Upcoming resbites
          _buildResbitesTab(upcoming: true),
          
          // Past resbites
          _buildResbitesTab(upcoming: false),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Navigate to create resbite screen
          Navigator.of(context).pushNamed('/start-resbite');
        },
        elevation: 3,
        backgroundColor: Theme.of(context).colorScheme.tertiary,
        foregroundColor: Theme.of(context).colorScheme.onTertiary,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(16)),
        ),
        child: const Icon(Icons.add),
      ),
    );
  }
  
  Widget _buildResbitesTab({required bool upcoming}) {
    // Watch resbites data
    final resbites = ref.watch(resbitesProvider(upcoming));
    
    return RefreshIndicator(
      onRefresh: () async {
        final _ = ref.refresh(resbitesProvider(upcoming));
      },
      child: resbites.when(
        data: (data) {
          if (data.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
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
                      FilledButton.icon(
                        onPressed: () {
                          // Navigate to create resbite screen
                          Navigator.of(context).pushNamed('/start-resbite');
                        },
                        icon: const Icon(Icons.add),
                        label: const Text('Create a Resbite'),
                        style: FilledButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 12,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            );
          }
          
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: data.length,
            itemBuilder: (context, index) {
              return _buildResbiteItem(data[index]);
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('Error: $error')),
      ),
    );
  }
  
  Widget _buildResbiteItem(Resbite resbite) {
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
            '/resbites/details',
            arguments: {'id': resbite.id},
          );
        },
        borderRadius: BorderRadius.circular(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Resbite header with Material Design elevation
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer.withOpacity(0.5),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              ),
              child: Row(
                children: [
                  // Activity image with Material Design container styling
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
                                Icons.event,
                                size: 30,
                                color: Theme.of(context).colorScheme.primary,
                              );
                            },
                          )
                        : Icon(
                            Icons.event,
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
                        // Title with MD3 typography
                        Text(
                          resbite.title,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        
                        // Activity name
                        if (resbite.activity != null)
                          Text(
                            resbite.activity!.title,
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.8),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          
                        // Status chip (Material Design 3 styling)
                        const SizedBox(height: 8),
                        Chip(
                          label: Text(_getStatusText(resbite.status)),
                          labelStyle: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: _getStatusColor(context, resbite.status),
                          ),
                          backgroundColor: _getStatusColor(context, resbite.status).withOpacity(0.12),
                          side: BorderSide.none,
                          padding: EdgeInsets.zero,
                          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          visualDensity: VisualDensity.compact,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            
            // Resbite details
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Date and time
                  _buildDetailRow(
                    context,
                    icon: Icons.calendar_today,
                    text: _formatDate(resbite.startDate),
                  ),
                  const SizedBox(height: 12),
                  
                  // Location
                  _buildDetailRow(
                    context,
                    icon: Icons.location_on_outlined,
                    text: resbite.place?.name ?? resbite.meetingPoint ?? 'Location not specified',
                  ),
                  const SizedBox(height: 12),
                  
                  // Participants with Material Design badge styling
                  _buildDetailRow(
                    context,
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
                  
                  // Description with improved typography
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
                  
                  // Action button row with Material Design 3 buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Share button as FilledButton.tonal
                      FilledButton.tonal(
                        onPressed: () {
                          // TODO: Share resbite
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
                      
                      // Join/Leave button with proper Material Design styling
                      _buildActionButton(context, resbite),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildDetailRow(
    BuildContext context, {
    required IconData icon,
    required String text,
    Widget? trailing,
  }) {
    return Row(
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            size: 16,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.8),
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        if (trailing != null) trailing,
      ],
    );
  }
  
  Widget _buildActionButton(BuildContext context, Resbite resbite) {
    // Check if user is the owner
    final user = ref.watch(currentUserProvider).valueOrNull;
    final isOwner = user != null && resbite.ownerId == user.id;
    
    // Check if user is a participant
    final isParticipant = user != null && 
        resbite.participants.any((participant) => participant.id == user.id);
    
    // Check if resbite is in the past
    final isPast = resbite.startDate.isBefore(DateTime.now());
    
    // Check if resbite is full
    final isFull = resbite.attendanceLimit != null && resbite.attendanceLimit! > 0 && 
        resbite.currentAttendance >= resbite.attendanceLimit!;
    
    if (isPast) {
      // Past resbite - use FilledButton with disabled state
      return FilledButton.icon(
        onPressed: null,
        icon: const Icon(Icons.check_circle),
        label: const Text('Completed'),
        style: FilledButton.styleFrom(
          backgroundColor: Theme.of(context).colorScheme.surfaceVariant,
          foregroundColor: Theme.of(context).colorScheme.onSurfaceVariant,
          disabledBackgroundColor: Theme.of(context).colorScheme.surfaceVariant,
          disabledForegroundColor: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
      );
    } else if (isOwner) {
      // User is owner - use FilledButton with primary colors
      return FilledButton.icon(
        onPressed: () {
          // Navigate to manage resbite screen
          Navigator.of(context).pushNamed(
            '/resbites/manage',
            arguments: {'id': resbite.id},
          );
        },
        icon: const Icon(Icons.edit, size: 18),
        label: const Text('Manage'),
        style: FilledButton.styleFrom(
          backgroundColor: Theme.of(context).colorScheme.primary,
          foregroundColor: Theme.of(context).colorScheme.onPrimary,
          visualDensity: VisualDensity.compact,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        ),
      );
    } else if (isParticipant) {
      // User is participant - use OutlinedButton with error colors
      return OutlinedButton.icon(
        onPressed: () async {
          // Leave resbite
          final databaseService = ref.read(databaseServiceProvider);
          try {
            await databaseService.leaveResbite(resbite.id, user.id);
            final _ = ref.refresh(resbitesProvider(true));
          } catch (e) {
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Error: $e'),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            }
          }
        },
        icon: const Icon(Icons.exit_to_app, size: 18),
        label: const Text('Leave'),
        style: OutlinedButton.styleFrom(
          foregroundColor: Theme.of(context).colorScheme.error,
          side: BorderSide(
            color: Theme.of(context).colorScheme.error,
            width: 1,
          ),
          visualDensity: VisualDensity.compact,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        ),
      );
    } else if (isFull) {
      // Resbite is full - use FilledButton with disabled state and warning color
      return FilledButton.icon(
        onPressed: null,
        icon: const Icon(Icons.block, size: 18),
        label: const Text('Full'),
        style: FilledButton.styleFrom(
          backgroundColor: Theme.of(context).colorScheme.error.withOpacity(0.1),
          foregroundColor: Theme.of(context).colorScheme.error,
          disabledBackgroundColor: Theme.of(context).colorScheme.error.withOpacity(0.1),
          disabledForegroundColor: Theme.of(context).colorScheme.error,
          visualDensity: VisualDensity.compact,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        ),
      );
    } else {
      // User can join - use FilledButton with tertiary colors
      return FilledButton.icon(
        onPressed: () async {
          if (user == null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text('You need to be logged in to join a resbite'),
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            );
            return;
          }
          
          // Join resbite
          final databaseService = ref.read(databaseServiceProvider);
          try {
            await databaseService.joinResbite(resbite.id, user.id);
            final _ = ref.refresh(resbitesProvider(true));
          } catch (e) {
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Error: $e'),
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              );
            }
          }
        },
        icon: const Icon(Icons.person_add, size: 18),
        label: const Text('Join'),
        style: FilledButton.styleFrom(
          backgroundColor: Theme.of(context).colorScheme.tertiary,
          foregroundColor: Theme.of(context).colorScheme.onTertiary,
          visualDensity: VisualDensity.compact,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        ),
      );
    }
  }
  
  // Format date
  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));
    final dateToCheck = DateTime(date.year, date.month, date.day);
    
    if (dateToCheck == today) {
      return 'Today, ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
    } else if (dateToCheck == tomorrow) {
      return 'Tomorrow, ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
    } else {
      return '${date.day}/${date.month}/${date.year}, ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
    }
  }
  
  // Get status color
  Color _getStatusColor(BuildContext context, ResbiteStatus status) {
    switch (status) {
      case ResbiteStatus.planned:
        return Theme.of(context).colorScheme.primary;
      case ResbiteStatus.active:
        return Colors.green;
      case ResbiteStatus.cancelled:
        return Theme.of(context).colorScheme.error;
      case ResbiteStatus.completed:
        return Colors.grey;
    }
  }
  
  // Get status text
  String _getStatusText(ResbiteStatus status) {
    switch (status) {
      case ResbiteStatus.planned:
        return 'Planned';
      case ResbiteStatus.active:
        return 'Active';
      case ResbiteStatus.cancelled:
        return 'Cancelled';
      case ResbiteStatus.completed:
        return 'Completed';
    }
  }
}