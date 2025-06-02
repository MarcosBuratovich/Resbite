import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../config/routes.dart';
import '../../../models/resbite.dart';
import '../../../services/providers.dart';
import '../../../utils/logger.dart';
import '../../dialogs/select_people_dialog.dart';

class ResbiteDetailsScreen extends ConsumerWidget {
  final String resbiteId;

  const ResbiteDetailsScreen({super.key, required this.resbiteId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch resbite data
    final resbiteAsync = ref.watch(resbiteDetailProvider(resbiteId));

    return Scaffold(
      body: resbiteAsync.when(
        data: (resbite) {
          if (resbite == null) {
            return const Center(child: Text('Resbite not found'));
          }

          return _buildResbiteDetails(context, ref, resbite);
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Error: $error')),
      ),
    );
  }

  Widget _buildResbiteDetails(
    BuildContext context,
    WidgetRef ref,
    Resbite resbite,
  ) {
    // Check if user is the owner
    final user = ref.watch(currentUserProvider).valueOrNull;
    final isOwner = user != null && resbite.ownerId == user.id;

    // Check if user is a participant
    final isParticipant =
        user != null &&
        resbite.participants.any((participant) => participant.id == user.id);

    return CustomScrollView(
      slivers: [
        // App bar with image (Material Design 3 style)
        SliverAppBar.large(
          expandedHeight: 240,
          pinned: true,
          backgroundColor: Theme.of(context).colorScheme.surface,
          surfaceTintColor: Colors.transparent,
          scrolledUnderElevation: 3,
          leadingWidth: 56,
          actions: [
            // Share button - using filled tonal icon button style
            IconButton.filledTonal(
              icon: const Icon(Icons.share, size: 20),
              onPressed: () {
                // TODO: Share resbite
              },
              tooltip: 'Share',
              style: IconButton.styleFrom(
                backgroundColor:
                    Theme.of(context).colorScheme.secondaryContainer,
                foregroundColor:
                    Theme.of(context).colorScheme.onSecondaryContainer,
              ),
            ),
            const SizedBox(width: 8),

            // Invite button - using filled tonal icon button style
            IconButton.filledTonal(
              icon: const Icon(Icons.person_add, size: 20),
              onPressed: () async {
                final users = await SelectPeopleDialog.show(context, ref);
                if (users == null || users.isEmpty) return;
                try {
                  final service = ref.read(resbiteServiceProvider);
                  await service.inviteUsers(resbite.id, users.map((e) => e.id).toList());
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Invited ${users.length} people!'),
                      ),
                    );
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Error inviting: $e')),
                    );
                  }
                }
              },
              tooltip: 'Invite',
              style: IconButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
                foregroundColor: Theme.of(context).colorScheme.onSecondaryContainer,
              ),
            ),
            const SizedBox(width: 8),

            // Menu button (for owner) - using Material Design 3 popup styles
            if (isOwner)
              PopupMenuButton<String>(
                onSelected: (value) {
                  if (value == 'edit') {
                    Navigator.of(context)
                        .pushNamed(AppRoutes.editResbite, arguments: {'id': resbite.id})
                        .then((result) {
                      // Refresh details after editing
                      ref.refresh(resbiteDetailProvider(resbite.id));
                    });
                  } else if (value == 'cancel') {
                    _showCancelDialog(context, ref, resbite);
                  }
                },
                position: PopupMenuPosition.under,
                elevation: 3,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                icon: Icon(
                  Icons.more_vert,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
                itemBuilder:
                    (context) => [
                      PopupMenuItem(
                        value: 'edit',
                        child: Row(
                          children: [
                            Icon(
                              Icons.edit,
                              size: 20,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                            const SizedBox(width: 12),
                            Text(
                              'Edit Resbite',
                              style: Theme.of(context).textTheme.labelLarge,
                            ),
                          ],
                        ),
                      ),
                      PopupMenuItem(
                        value: 'cancel',
                        child: Row(
                          children: [
                            Icon(
                              Icons.cancel_outlined,
                              size: 20,
                              color: Theme.of(context).colorScheme.error,
                            ),
                            const SizedBox(width: 12),
                            Text(
                              'Cancel Resbite',
                              style: Theme.of(
                                context,
                              ).textTheme.labelLarge?.copyWith(
                                color: Theme.of(context).colorScheme.error,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
              ),
            const SizedBox(width: 8),
          ],
          flexibleSpace: FlexibleSpaceBar(
            expandedTitleScale: 1.5,
            titlePadding: const EdgeInsets.only(
              left: 16,
              right: 16,
              bottom: 16,
            ),
            title: Text(
              resbite.title,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onSurface,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            background: Stack(
              fit: StackFit.expand,
              children: [
                // Background image or placeholder
                resbite.images.isNotEmpty
                    ? Image.network(
                      resbite.images.first,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: Theme.of(context).colorScheme.primaryContainer,
                          child: Icon(
                            Icons.event,
                            size: 80,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        );
                      },
                    )
                    : Container(
                      color: Theme.of(context).colorScheme.primaryContainer,
                      child: Icon(
                        Icons.event,
                        size: 80,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),

                // Gradient overlay for better text visibility
                Positioned.fill(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withOpacity(0.5),
                        ],
                        stops: const [0.7, 1.0],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        // Content
        SliverToBoxAdapter(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Status bar with Material Design 3 chips
              Container(
                padding: const EdgeInsets.symmetric(
                  vertical: 12,
                  horizontal: 16,
                ),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainerLow,
                  border: Border(
                    bottom: BorderSide(
                      color: Theme.of(context).colorScheme.outlineVariant,
                      width: 1,
                    ),
                  ),
                ),
                child: Row(
                  children: [
                    // Status chip
                    ActionChip(
                      avatar: Icon(
                        _getStatusIcon(resbite.status),
                        size: 18,
                        color: _getStatusColor(context, resbite.status),
                      ),
                      label: Text(_getStatusText(resbite.status)),
                      labelStyle: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: _getStatusColor(context, resbite.status),
                      ),
                      backgroundColor: _getStatusColor(
                        context,
                        resbite.status,
                      ).withOpacity(0.1),
                      side: BorderSide(
                        color: _getStatusColor(
                          context,
                          resbite.status,
                        ).withOpacity(0.3),
                        width: 1,
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      onPressed: () {},
                    ),
                    const Spacer(),

                    // Participants chip
                    ActionChip(
                      avatar: const Icon(Icons.people, size: 18),
                      label: Text(
                        '${resbite.currentAttendance}/${resbite.attendanceLimit != null && resbite.attendanceLimit! > 0 ? resbite.attendanceLimit : '∞'}',
                      ),
                      labelStyle: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color:
                            resbite.attendanceLimit != null &&
                                    resbite.attendanceLimit! > 0 &&
                                    resbite.currentAttendance >=
                                        resbite.attendanceLimit!
                                ? Theme.of(context).colorScheme.error
                                : Theme.of(
                                  context,
                                ).colorScheme.onSurfaceVariant,
                      ),
                      backgroundColor:
                          Theme.of(context).colorScheme.surfaceVariant,
                      side: BorderSide(
                        color: Theme.of(
                          context,
                        ).colorScheme.outline.withOpacity(0.3),
                        width: 1,
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      onPressed: () {},
                    ),
                  ],
                ),
              ),

              // Main content
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Activity info (if available) - Material Design 3 Card
                    if (resbite.activity != null)
                      Card(
                        elevation: 0,
                        surfaceTintColor: Colors.transparent,
                        color: Theme.of(
                          context,
                        ).colorScheme.primaryContainer.withOpacity(0.5),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                          side: BorderSide(
                            color: Theme.of(
                              context,
                            ).colorScheme.primary.withOpacity(0.2),
                            width: 1,
                          ),
                        ),
                        margin: EdgeInsets.zero,
                        child: InkWell(
                          onTap: () {
                            // Navigate to activity details
                            Navigator.of(context).pushNamed(
                              '/activities/details',
                              arguments: {'id': resbite.activity!.id},
                            );
                          },
                          borderRadius: BorderRadius.circular(16),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Row(
                              children: [
                                // Activity image with Material Design container
                                Container(
                                  width: 60,
                                  height: 60,
                                  decoration: BoxDecoration(
                                    color:
                                        Theme.of(context).colorScheme.surface,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.outline.withOpacity(0.2),
                                      width: 1,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Theme.of(
                                          context,
                                        ).colorScheme.shadow.withOpacity(0.1),
                                        blurRadius: 4,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  clipBehavior: Clip.antiAlias,
                                  child:
                                      resbite.activity!.imageUrl != null
                                          ? Image.network(
                                            resbite.activity!.imageUrl!,
                                            fit: BoxFit.cover,
                                            errorBuilder: (
                                              context,
                                              error,
                                              stackTrace,
                                            ) {
                                              return Icon(
                                                Icons.category,
                                                size: 24,
                                                color:
                                                    Theme.of(
                                                      context,
                                                    ).colorScheme.primary,
                                              );
                                            },
                                          )
                                          : Icon(
                                            Icons.category,
                                            size: 24,
                                            color:
                                                Theme.of(
                                                  context,
                                                ).colorScheme.primary,
                                          ),
                                ),
                                const SizedBox(width: 16),

                                // Activity information with Material Design 3 typography
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Activity',
                                        style: Theme.of(
                                          context,
                                        ).textTheme.labelMedium?.copyWith(
                                          color:
                                              Theme.of(
                                                context,
                                              ).colorScheme.primary,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        resbite.activity!.title,
                                        style: Theme.of(
                                          context,
                                        ).textTheme.titleMedium?.copyWith(
                                          fontWeight: FontWeight.bold,
                                        ),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      // Activity categories if available
                                      if (resbite
                                          .activity!
                                          .categories
                                          .isNotEmpty) ...[
                                        const SizedBox(height: 4),
                                        Text(
                                          resbite
                                              .activity!
                                              .categories
                                              .first
                                              .name,
                                          style: Theme.of(
                                            context,
                                          ).textTheme.bodySmall?.copyWith(
                                            color:
                                                Theme.of(
                                                  context,
                                                ).colorScheme.onSurfaceVariant,
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                ),

                                // Arrow icon
                                Container(
                                  width: 32,
                                  height: 32,
                                  decoration: BoxDecoration(
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.primary.withOpacity(0.1),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    Icons.arrow_forward,
                                    size: 16,
                                    color:
                                        Theme.of(context).colorScheme.primary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),

                    if (resbite.activity != null) const SizedBox(height: 24),

                    // Details header with Material Design 3 typography
                    Row(
                      children: [
                        Icon(
                          Icons.info_outline,
                          size: 20,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Details',
                          style: Theme.of(
                            context,
                          ).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Material Design 3 List Tiles
                    Card(
                      elevation: 0,
                      color: Theme.of(context).colorScheme.surfaceContainerLow,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                        side: BorderSide(
                          color: Theme.of(context).colorScheme.outlineVariant,
                          width: 1,
                        ),
                      ),
                      margin: EdgeInsets.zero,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Column(
                          children: [
                            // Date and time
                            ListTile(
                              leading: Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color:
                                      Theme.of(
                                        context,
                                      ).colorScheme.primaryContainer,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Icon(
                                  Icons.calendar_today,
                                  size: 20,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                              ),
                              title: Text(
                                'Date',
                                style: Theme.of(
                                  context,
                                ).textTheme.bodyMedium?.copyWith(
                                  fontWeight: FontWeight.w500,
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onSurface.withOpacity(0.8),
                                ),
                              ),
                              subtitle: Text(
                                _formatDate(resbite.startDate),
                                style: Theme.of(context).textTheme.bodyLarge
                                    ?.copyWith(fontWeight: FontWeight.w500),
                              ),
                            ),

                            if (resbite.isMultiDay)
                              ListTile(
                                leading: Container(
                                  width: 40,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    color:
                                        Theme.of(
                                          context,
                                        ).colorScheme.primaryContainer,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Icon(
                                    Icons.event,
                                    size: 20,
                                    color:
                                        Theme.of(context).colorScheme.primary,
                                  ),
                                ),
                                title: Text(
                                  'End Date',
                                  style: Theme.of(
                                    context,
                                  ).textTheme.bodyMedium?.copyWith(
                                    fontWeight: FontWeight.w500,
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.onSurface.withOpacity(0.8),
                                  ),
                                ),
                                subtitle: Text(
                                  _formatDate(resbite.endDate),
                                  style: Theme.of(context).textTheme.bodyLarge
                                      ?.copyWith(fontWeight: FontWeight.w500),
                                ),
                              ),

                            const Divider(indent: 72, endIndent: 16),

                            // Location
                            ListTile(
                              leading: Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color:
                                      Theme.of(
                                        context,
                                      ).colorScheme.secondaryContainer,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Icon(
                                  Icons.location_on_outlined,
                                  size: 20,
                                  color:
                                      Theme.of(context).colorScheme.secondary,
                                ),
                              ),
                              title: Text(
                                'Location',
                                style: Theme.of(
                                  context,
                                ).textTheme.bodyMedium?.copyWith(
                                  fontWeight: FontWeight.w500,
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onSurface.withOpacity(0.8),
                                ),
                              ),
                              subtitle: Text(
                                resbite.place?.name ??
                                    resbite.meetingPoint ??
                                    'Location not specified',
                                style: Theme.of(context).textTheme.bodyLarge
                                    ?.copyWith(fontWeight: FontWeight.w500),
                              ),
                              trailing:
                                  resbite.place != null
                                      ? Icon(
                                        Icons.map_outlined,
                                        color:
                                            Theme.of(
                                              context,
                                            ).colorScheme.primary,
                                      )
                                      : null,
                              onTap:
                                  resbite.place != null
                                      ? () {
                                        // TODO: Open map with place
                                      }
                                      : null,
                            ),

                            // Meeting point
                            if (resbite.meetingPoint != null &&
                                resbite.meetingPoint!.isNotEmpty) ...[
                              const Divider(indent: 72, endIndent: 16),
                              ListTile(
                                leading: Container(
                                  width: 40,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    color:
                                        Theme.of(
                                          context,
                                        ).colorScheme.tertiaryContainer,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Icon(
                                    Icons.pin_drop_outlined,
                                    size: 20,
                                    color:
                                        Theme.of(context).colorScheme.tertiary,
                                  ),
                                ),
                                title: Text(
                                  'Meeting Point',
                                  style: Theme.of(
                                    context,
                                  ).textTheme.bodyMedium?.copyWith(
                                    fontWeight: FontWeight.w500,
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.onSurface.withOpacity(0.8),
                                  ),
                                ),
                                subtitle: Text(
                                  resbite.meetingPoint!,
                                  style: Theme.of(context).textTheme.bodyLarge
                                      ?.copyWith(fontWeight: FontWeight.w500),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),

                    // Divider
                    const Divider(height: 32),

                    // Description header with Material Design 3 typography
                    Row(
                      children: [
                        Icon(
                          Icons.description_outlined,
                          size: 20,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Description',
                          style: Theme.of(
                            context,
                          ).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Description Card with Material Design 3 styling
                    Card(
                      elevation: 0,
                      color: Theme.of(context).colorScheme.surface,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                        side: BorderSide(
                          color: Theme.of(context).colorScheme.outlineVariant,
                          width: 1,
                        ),
                      ),
                      margin: EdgeInsets.zero,
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Text(
                          resbite.description ?? 'No description provided',
                          style: Theme.of(
                            context,
                          ).textTheme.bodyLarge?.copyWith(
                            color: Theme.of(context).colorScheme.onSurface,
                            height: 1.5,
                          ),
                        ),
                      ),
                    ),

                    // Additional notes with Material Design 3 Alert styling
                    if (resbite.note != null && resbite.note!.isNotEmpty) ...[
                      const SizedBox(height: 24),
                      Card(
                        elevation: 0,
                        color: Theme.of(context).colorScheme.errorContainer,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                          side: BorderSide(
                            color: Theme.of(context).colorScheme.error,
                            width: 1,
                          ),
                        ),
                        margin: EdgeInsets.zero,
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    Icons.info_outline,
                                    color: Theme.of(context).colorScheme.error,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 12),
                                  Text(
                                    'Important Note from Organizer',
                                    style: Theme.of(context).textTheme.titleSmall
                                        ?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: Theme.of(context).colorScheme.error,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Text(
                                resbite.note!,
                                style: Theme.of(context).textTheme.bodyLarge
                                    ?.copyWith(
                                  color: Theme.of(context).colorScheme.onError,
                                  height: 1.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],

                    // Divider
                    const Divider(height: 32),

                    // Organizer with Material Design 3 typography and card
                    Row(
                      children: [
                        Icon(
                          Icons.person_outlined,
                          size: 20,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Organizer',
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    if (resbite.owner != null)
                      Card(
                        elevation: 0,
                        color: Theme.of(context).colorScheme.secondaryContainer,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                          side: BorderSide(
                            color: Theme.of(context).colorScheme.outlineVariant,
                            width: 1,
                          ),
                        ),
                        margin: EdgeInsets.zero,
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Row(
                            children: [
                              // Organizer avatar with Material Design 3 styling
                              Container(
                                width: 56,
                                height: 56,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Theme.of(context)
                                      .colorScheme
                                      .secondaryContainer,
                                  border: Border.all(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .secondary
                                        .withOpacity(0.5),
                                    width: 2,
                                  ),
                                ),
                                clipBehavior: Clip.antiAlias,
                                child: resbite.owner!.profileImageUrl != null
                                    ? Image.network(
                                        resbite.owner!.profileImageUrl!,
                                        fit: BoxFit.cover,
                                        errorBuilder: (context, error,
                                            stackTrace) {
                                          return Icon(
                                            Icons.person,
                                            size: 32,
                                            color: Theme.of(context)
                                                .colorScheme
                                                .secondary,
                                          );
                                        },
                                      )
                                    : Icon(
                                        Icons.person,
                                        size: 32,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .secondary,
                                      ),
                              ),
                              const SizedBox(width: 16),

                              // Organizer details with Material Design 3 typography
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      resbite.owner!.displayName ?? 'Organizer',
                                      style: Theme.of(context).textTheme.titleMedium
                                          ?.copyWith(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    if (resbite.owner!.shortDescription != null)
                                      Text(
                                        resbite.owner!.shortDescription!,
                                        style: Theme.of(context).textTheme.bodyMedium
                                            ?.copyWith(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .onSurfaceVariant,
                                        ),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),

                                    // Add email or contact button for contacting organizer
                                    const SizedBox(height: 8),
                                    ActionChip(
                                      avatar: Icon(
                                        Icons.email_outlined,
                                        size: 16,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .secondary,
                                      ),
                                      label: Text(
                                        resbite.owner!.email,
                                        style: Theme.of(context).textTheme.bodySmall
                                            ?.copyWith(
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      backgroundColor: Theme.of(context)
                                          .colorScheme
                                          .surfaceVariant,
                                      visualDensity: VisualDensity.compact,
                                      materialTapTargetSize:
                                          MaterialTapTargetSize.shrinkWrap,
                                      padding: EdgeInsets.zero,
                                      onPressed: () {
                                        // contact organizer
                                        // Implement contacting organizer, e.g., launch email app
                                        // Example: launchUrl(Uri.parse('mailto:${resbite.owner!.email}'));
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(
                                            content: Text(
                                              'Contacting organizer... (not implemented)',
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    else
                      Card(
                        elevation: 0,
                        color: Theme.of(context).colorScheme.surfaceContainerLow,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                          side: BorderSide(
                            color: Theme.of(context).colorScheme.outlineVariant,
                            width: 1,
                          ),
                        ),
                        margin: EdgeInsets.zero,
                        child: const Padding(
                          padding: EdgeInsets.all(16.0),
                          child: Text('Organizer information not available'),
                        ),
                      ),

                    // Divider
                    const Divider(height: 32),

                    // Participants with Material Design 3 typography
                    Row(
                      children: [
                        Icon(
                          Icons.people_outlined,
                          size: 20,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Participants',
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                        const SizedBox(width: 8),
                        // Participant count chip
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.primaryContainer,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Text(
                            '${resbite.participants.length}', // only confirmed participants now
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context)
                                  .colorScheme
                                  .onPrimaryContainer,
                            ),
                          ),
                        ),
                        const Spacer(),
                        if (resbite.participants.length > 5)
                          TextButton.icon(
                            onPressed: () {
                              // TODO: Show all participants
                            },
                            icon: const Icon(Icons.people, size: 16),
                            label: const Text('See All'),
                            style: TextButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Participants list with Material Design 3 styling
                    if (resbite.participants.isEmpty)
                      Card(
                        elevation: 0,
                        color: Theme.of(context).colorScheme.surfaceContainerLow,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                          side: BorderSide(
                            color: Theme.of(context).colorScheme.outlineVariant,
                            width: 1,
                          ),
                        ),
                        margin: EdgeInsets.zero,
                        child: SizedBox(
                          width: double.infinity,
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              children: [
                                Icon(
                                  Icons.people_outline,
                                  size: 48,
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onSurfaceVariant
                                      .withOpacity(0.5),
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'No participants yet',
                                  style: Theme.of(context).textTheme.titleMedium
                                      ?.copyWith(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurfaceVariant,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Be the first to join this resbite!',
                                  style: Theme.of(context).textTheme.bodyMedium
                                      ?.copyWith(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurfaceVariant
                                        .withOpacity(0.7),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      )
                    else
                      Card(
                        elevation: 0,
                        color: Theme.of(context).colorScheme.surfaceContainerLow,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                          side: BorderSide(
                            color: Theme.of(context).colorScheme.outlineVariant,
                            width: 1,
                          ),
                        ),
                        margin: EdgeInsets.zero,
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Wrap(
                            spacing: 16,
                            runSpacing: 16,
                            alignment: WrapAlignment.start,
                            children: resbite.participants
                                .take(10)
                                .map(
                                  (participant) => Column(
                                    children: [
                                      // Avatar with Material Design 3 styling
                                      Container(
                                        width: 56,
                                        height: 56,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: Theme.of(context)
                                              .colorScheme
                                              .secondaryContainer,
                                          border: Border.all(
                                            color: Theme.of(context)
                                                .colorScheme
                                                .outlineVariant,
                                            width: 1,
                                          ),
                                        ),
                                        clipBehavior: Clip.antiAlias,
                                        child: participant.profileImageUrl !=
                                                null
                                            ? Image.network(
                                                participant.profileImageUrl!,
                                                fit: BoxFit.cover,
                                                errorBuilder: (context, error,
                                                    stackTrace) {
                                                  return Icon(
                                                    Icons.person,
                                                    size: 32,
                                                    color: Theme.of(context)
                                                        .colorScheme
                                                        .secondary,
                                                  );
                                                },
                                              )
                                            : Icon(
                                                Icons.person,
                                                size: 32,
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .secondary,
                                              ),
                                      ),
                                      const SizedBox(height: 8),
                                      SizedBox(
                                        width: 64,
                                        child: Text(
                                          participant.displayName ?? 'User',
                                          textAlign: TextAlign.center,
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodySmall
                                              ?.copyWith(
                                            fontWeight: FontWeight.w500,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                                .toList(),
                          ),
                        ),
                      ),

                    // Action button
                    const SizedBox(height: 40),
                    _buildActionButton(
                      context,
                      ref,
                      resbite,
                      isOwner,
                      isParticipant,
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton(
    BuildContext context,
    WidgetRef ref,
    Resbite resbite,
    bool isOwner,
    bool isParticipant,
  ) {
    // Check if user is authenticated
    final user = ref.watch(currentUserProvider).valueOrNull;
    if (user == null) {
      return FilledButton.tonalIcon(
        onPressed: () {
          Navigator.of(context).pushNamed('/login');
        },
        icon: const Icon(Icons.login),
        label: const Text('Sign in to Join'),
        style: FilledButton.styleFrom(
          minimumSize: const Size(double.infinity, 56),
          backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
          foregroundColor: Theme.of(context).colorScheme.onSecondaryContainer,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: Theme.of(
            context,
          ).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.bold),
          padding: const EdgeInsets.symmetric(vertical: 16),
        ),
      );
    }

    // Check if resbite is in the past
    final isPast = resbite.startDate.isBefore(DateTime.now());

    // Check if resbite is full
    final isFull =
        resbite.attendanceLimit != null &&
        resbite.attendanceLimit! > 0 &&
        resbite.currentAttendance >= resbite.attendanceLimit!;

    // Check if resbite is cancelled
    final isCancelled = resbite.status == ResbiteStatus.cancelled;

    if (isPast) {
      // Past resbite - Material Design 3 disabled button
      return FilledButton.icon(
        onPressed: null,
        icon: const Icon(Icons.check_circle),
        label: const Text('This resbite has already happened'),
        style: FilledButton.styleFrom(
          minimumSize: const Size(double.infinity, 56),
          disabledBackgroundColor: Theme.of(context).colorScheme.surfaceVariant,
          disabledForegroundColor:
              Theme.of(context).colorScheme.onSurfaceVariant,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: Theme.of(context).textTheme.labelLarge,
          padding: const EdgeInsets.symmetric(vertical: 16),
        ),
      );
    } else if (isCancelled) {
      // Cancelled resbite - Material Design 3 error-styled button
      return FilledButton.icon(
        onPressed: null,
        icon: const Icon(Icons.cancel),
        label: const Text('This resbite has been cancelled'),
        style: FilledButton.styleFrom(
          minimumSize: const Size(double.infinity, 56),
          disabledBackgroundColor: Theme.of(context).colorScheme.errorContainer,
          disabledForegroundColor:
              Theme.of(context).colorScheme.onErrorContainer,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: Theme.of(context).textTheme.labelLarge,
          padding: const EdgeInsets.symmetric(vertical: 16),
        ),
      );
    } else if (isOwner) {
      // User is owner - Material Design 3 primary-colored button
      return FilledButton.icon(
        onPressed: () {
          // TODO: Navigate to manage resbite screen
        },
        icon: const Icon(Icons.edit),
        label: const Text('Manage Resbite'),
        style: FilledButton.styleFrom(
          minimumSize: const Size(double.infinity, 56),
          backgroundColor: Theme.of(context).colorScheme.primary,
          foregroundColor: Theme.of(context).colorScheme.onPrimary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: Theme.of(
            context,
          ).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.bold),
          padding: const EdgeInsets.symmetric(vertical: 16),
        ),
      );
    } else if (isParticipant) {
      // User is participant - Material Design 3 outlined button with error colors
      return OutlinedButton.icon(
        onPressed: () async {
          // Show leave confirmation dialog
          final confirm = await _showLeaveConfirmationDialog(context);
          if (confirm != true || !context.mounted) return;

          // Leave resbite
          try {
            final resbiteService = ref.read(resbiteServiceProvider);
            await resbiteService.leaveResbite(resbite.id, user.id);
            final _ = ref.refresh(resbiteDetailProvider(resbite.id));

            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('You have left this resbite'),
                  behavior: SnackBarBehavior.floating,
                  backgroundColor: Theme.of(context).colorScheme.secondary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              );
            }
          } catch (e) {
            AppLogger.error('Failed to leave resbite', e);
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Error: $e'),
                  behavior: SnackBarBehavior.floating,
                  backgroundColor: Theme.of(context).colorScheme.error,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              );
            }
          }
        },
        icon: const Icon(Icons.exit_to_app),
        label: const Text('Leave Resbite'),
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(double.infinity, 56),
          foregroundColor: Theme.of(context).colorScheme.error,
          side: BorderSide(
            color: Theme.of(context).colorScheme.error,
            width: 2,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: Theme.of(
            context,
          ).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.bold),
          padding: const EdgeInsets.symmetric(vertical: 16),
        ),
      );
    } else if (isFull) {
      // Resbite is full - Material Design 3 disabled button
      return FilledButton.icon(
        onPressed: null,
        icon: const Icon(Icons.people_alt),
        label: const Text('This resbite is full'),
        style: FilledButton.styleFrom(
          minimumSize: const Size(double.infinity, 56),
          disabledBackgroundColor: Theme.of(context).colorScheme.errorContainer,
          disabledForegroundColor:
              Theme.of(context).colorScheme.onErrorContainer,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: Theme.of(context).textTheme.labelLarge,
          padding: const EdgeInsets.symmetric(vertical: 16),
        ),
      );
    } else {
      // User can join - Material Design 3 tertiary-colored button
      return FilledButton.icon(
        onPressed: () async {
          // Join resbite
          try {
            final resbiteService = ref.read(resbiteServiceProvider);
            await resbiteService.joinResbite(resbite.id, user.id);
            final _ = ref.refresh(resbiteDetailProvider(resbite.id));

            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('You have joined this resbite!'),
                  behavior: SnackBarBehavior.floating,
                  backgroundColor: Theme.of(context).colorScheme.tertiary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              );
            }
          } catch (e) {
            AppLogger.error('Failed to join resbite', e);
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Error: $e'),
                  behavior: SnackBarBehavior.floating,
                  backgroundColor: Theme.of(context).colorScheme.error,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              );
            }
          }
        },
        icon: const Icon(Icons.person_add),
        label: const Text('Join Resbite'),
        style: FilledButton.styleFrom(
          minimumSize: const Size(double.infinity, 56),
          backgroundColor: Theme.of(context).colorScheme.tertiary,
          foregroundColor: Theme.of(context).colorScheme.onTertiary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: Theme.of(
            context,
          ).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.bold),
          padding: const EdgeInsets.symmetric(vertical: 16),
        ),
      );
    }
  }

  // Material Design 3 confirmation dialog for leaving a resbite
  Future<bool?> _showLeaveConfirmationDialog(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Leave Resbite?'),
        titleTextStyle: Theme.of(context).textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.bold,
          color: Theme.of(context).colorScheme.onSurface,
        ),
        content: const Text(
          'Are you sure you want to leave this resbite? The organizer and other participants will be notified.',
        ),
        contentTextStyle: Theme.of(context).textTheme.bodyLarge?.copyWith(
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(28),
        ),
        surfaceTintColor: Colors.transparent,
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(
              'Cancel',
              style: TextStyle(
                color: Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
              foregroundColor: Theme.of(context).colorScheme.onError,
            ),
            child: const Text('Yes, Leave'),
          ),
        ],
        actionsPadding: const EdgeInsets.symmetric(
          horizontal: 24,
          vertical: 16,
        ),
      ),
    );
  }

  void _showCancelDialog(BuildContext context, WidgetRef ref, Resbite resbite) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        icon: Icon(
          Icons.warning_amber_rounded,
          color: Theme.of(context).colorScheme.error,
          size: 32,
        ),
        title: const Text('Cancel Resbite?'),
        titleTextStyle: Theme.of(context).textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.bold,
          color: Theme.of(context).colorScheme.onSurface,
        ),
        content: const Text(
          'Are you sure you want to cancel this resbite? This action cannot be undone and all participants will be notified.',
        ),
        contentTextStyle: Theme.of(context).textTheme.bodyLarge?.copyWith(
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(28),
        ),
        surfaceTintColor: Colors.transparent,
        elevation: 3,
        actionsPadding: const EdgeInsets.all(24),
        actions: [
          // "Keep" button (secondary action)
          OutlinedButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            style: OutlinedButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.primary,
              side: BorderSide(
                color: Theme.of(context).colorScheme.primary,
                width: 1,
              ),
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('No, Keep It'),
          ),
          const SizedBox(width: 8),

          // "Cancel Resbite" button (destructive action)
          FilledButton(
            onPressed: () async {
              Navigator.of(context).pop();
              final service = ref.read(resbiteServiceProvider);
              final success = await service.cancelResbite(resbite.id);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(success
                        ? 'Resbite cancelled'
                        : 'Failed to cancel resbite'),
                    behavior: SnackBarBehavior.floating,
                    backgroundColor: success
                        ? Theme.of(context).colorScheme.errorContainer
                        : Theme.of(context).colorScheme.error,
                  ),
                );
              }
            },
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
              foregroundColor: Theme.of(context).colorScheme.onError,
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('Yes, Cancel It'),
          ),
        ],
      ),
    );
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

  // Get status icon
  IconData _getStatusIcon(ResbiteStatus status) {
    switch (status) {
      case ResbiteStatus.planned:
        return Icons.check_circle_outline;
      case ResbiteStatus.active:
        return Icons.people;
      case ResbiteStatus.cancelled:
        return Icons.cancel_outlined;
      case ResbiteStatus.completed:
        return Icons.event_available;
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
