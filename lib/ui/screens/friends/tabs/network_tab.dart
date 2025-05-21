import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:resbite_app/components/ui/button.dart';
import 'package:resbite_app/models/friend.dart'; // Import for NetworkConnection model
import 'package:resbite_app/services/providers.dart'
    show contactServiceProvider, resbiteContactsProvider;
import 'package:resbite_app/ui/screens/friends/services/services.dart'
    as friends_services;
import 'package:resbite_app/styles/tailwind_theme.dart';
import 'package:resbite_app/ui/shared/empty_state.dart';
import 'package:resbite_app/ui/shared/loading_state.dart';

/// Tab that displays the user's extended network and contacts
class NetworkTab extends ConsumerWidget {
  final String searchQuery;
  final Function(BuildContext) showSyncContactsDialog;
  final Function(dynamic, {required bool isResbiteUser}) buildContactItem;
  final Function(dynamic) buildNetworkConnectionItem;

  const NetworkTab({
    super.key,
    required this.searchQuery,
    required this.showSyncContactsDialog,
    required this.buildContactItem,
    required this.buildNetworkConnectionItem,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Add access to contacts provider to get contact info
    final networkAsync = ref.watch(friends_services.networkConnectionsProvider);
    final contactsAsync = ref.watch(resbiteContactsProvider);
    final contactService = ref.read(contactServiceProvider);
    // Use the contact service to check permissions directly
    final contactPermissionAsync = Future.value(
      contactService.hasContactsPermission(),
    );

    return RefreshIndicator(
      onRefresh: () async {
        ref.refresh(friends_services.extendedNetworkProvider).value;
        ref.refresh(resbiteContactsProvider).value;
      },
      child: FutureBuilder<bool>(
        future: contactPermissionAsync,
        builder: (context, permissionSnapshot) {
          // If permission status is loading, show loading
          if (!permissionSnapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          // If we don't have permission, show the contact sync button
          final hasPermission = permissionSnapshot.data ?? false;
          if (!hasPermission) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SvgPicture.asset(
                    'assets/illustrations/contacts.svg',
                    height: 150,
                    colorFilter: ColorFilter.mode(
                      Theme.of(context).colorScheme.primary.withOpacity(0.8),
                      BlendMode.srcIn,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Sync Your Contacts',
                    style: TwTypography.heading5(context),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32.0),
                    child: Text(
                      'Find friends who are already using Resbite and invite others to join.',
                      style: TwTypography.body(context),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 24),
                  ShadButton.primary(
                    text: 'Sync Contacts',
                    onPressed: () => showSyncContactsDialog(context),
                    icon: Icons.sync,
                  ),
                ],
              ),
            );
          }

          // If we have permission but contacts are loading, show loading
          return contactsAsync.when(
            data: (contacts) {
              // Filter contacts based on search query
              final filteredContacts =
                  searchQuery.isEmpty
                      ? contacts
                      : contacts.where((contact) {
                        // Access PhoneContact properties using dot notation
                        final displayName = contact.displayName;
                        final emails = contact.emails;
                        final phones = contact.phoneNumbers;

                        final emailStr = emails.join(' ');
                        final phoneStr = phones.join(' ');

                        return displayName.toLowerCase().contains(
                              searchQuery,
                            ) ||
                            emailStr.toLowerCase().contains(searchQuery) ||
                            phoneStr.toLowerCase().contains(searchQuery);
                      }).toList();

              // Get the extended network connections
              return networkAsync.when(
                data: (network) {
                  // Get contacts that are Resbite users vs non-users
                  final resbiteUsers =
                      filteredContacts
                          .where((contact) => contact.isResbiteUser == true)
                          .toList();

                  final nonResbiteUsers =
                      filteredContacts
                          .where((contact) => contact.isResbiteUser == false)
                          .toList();

                  // Group connections - all are second degree in the NetworkConnection model
                  // Since we're now using strongly typed NetworkConnection objects
                  final secondDegree =
                      network; // All connections are second degree by default
                  final thirdDegree =
                      <
                        NetworkConnection
                      >[]; // No longer supporting third degree in the model

                  // If everything is empty, show prompt
                  if (resbiteUsers.isEmpty &&
                      nonResbiteUsers.isEmpty &&
                      secondDegree.isEmpty &&
                      thirdDegree.isEmpty) {
                    return EmptyState(
                      type: EmptyStateType.empty,
                      title:
                          searchQuery.isEmpty
                              ? 'No Contacts or Network Yet'
                              : 'No Results Found',
                      message:
                          searchQuery.isEmpty
                              ? 'Sync your contacts to find friends or invite others to join Resbite.'
                              : 'Try a different search term.',
                      customIcon: Icons.diversity_3,
                      actionLabel: 'Refresh Contacts',
                      onActionPressed: () async {
                        ref.refresh(resbiteContactsProvider).value;
                        ref
                            .refresh(
                              friends_services.networkConnectionsProvider,
                            )
                            .value;
                      },
                    );
                  }

                  return ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      // Resbite users from contacts
                      if (resbiteUsers.isNotEmpty) ...[
                        Padding(
                          padding: const EdgeInsets.only(
                            bottom: 8.0,
                            left: 4.0,
                          ),
                          child: Text(
                            'Contacts on Resbite',
                            style: TwTypography.heading6(context),
                          ),
                        ),
                        ...resbiteUsers.map(
                          (contact) =>
                              buildContactItem(contact, isResbiteUser: true),
                        ),
                        const SizedBox(height: 24),
                      ],

                      // Friends of friends from network
                      if (secondDegree.isNotEmpty) ...[
                        Padding(
                          padding: const EdgeInsets.only(
                            bottom: 8.0,
                            left: 4.0,
                          ),
                          child: Text(
                            'Friends of Friends',
                            style: TwTypography.heading6(context),
                          ),
                        ),
                        ...secondDegree.map(
                          (conn) => buildNetworkConnectionItem(conn as dynamic),
                        ),
                        const SizedBox(height: 24),
                      ],

                      // Extended network from network tab
                      if (thirdDegree.isNotEmpty) ...[
                        Padding(
                          padding: const EdgeInsets.only(
                            bottom: 8.0,
                            left: 4.0,
                          ),
                          child: Text(
                            'Extended Network',
                            style: TwTypography.heading6(context),
                          ),
                        ),
                        ...thirdDegree.map(
                          (conn) => buildNetworkConnectionItem(conn as dynamic),
                        ),
                        const SizedBox(height: 24),
                      ],

                      // Non-Resbite users from contacts
                      if (nonResbiteUsers.isNotEmpty) ...[
                        Padding(
                          padding: const EdgeInsets.only(
                            bottom: 8.0,
                            left: 4.0,
                          ),
                          child: Text(
                            'Invite Contacts to Resbite',
                            style: TwTypography.heading6(context),
                          ),
                        ),
                        ...nonResbiteUsers.map(
                          (contact) =>
                              buildContactItem(contact, isResbiteUser: false),
                        ),
                      ],
                    ],
                  );
                },
                loading:
                    () => LoadingState(
                      type: LoadingStateType.shimmer,
                      child: ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: 5,
                        itemBuilder: (context, index) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 16),
                            child: LoadingState.listItemSkeleton(height: 70),
                          );
                        },
                      ),
                    ),
                error:
                    (error, _) => EmptyState(
                      type: EmptyStateType.error,
                      title: 'Error Loading Network',
                      message:
                          'We couldn\'t load your network. Please try again.',
                      onActionPressed: () async {
                        ref
                            .refresh(
                              friends_services.networkConnectionsProvider,
                            )
                            .value;
                        ref.refresh(resbiteContactsProvider).value;
                      },
                      actionLabel: 'Try Again',
                    ),
              );
            },
            loading:
                () => LoadingState(
                  type: LoadingStateType.shimmer,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: 5,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: LoadingState.listItemSkeleton(height: 70),
                      );
                    },
                  ),
                ),
            error:
                (error, _) => EmptyState(
                  type: EmptyStateType.error,
                  title: 'Error Loading Contacts',
                  message: 'We couldn\'t load your contacts. Please try again.',
                  onActionPressed: () async {
                    ref.refresh(resbiteContactsProvider).value;
                  },
                  actionLabel: 'Try Again',
                ),
          );
        },
      ),
    );
  }
}
