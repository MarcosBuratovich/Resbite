import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:resbite_app/styles/tailwind_theme.dart';
import 'package:resbite_app/components/ui.dart';
import 'package:resbite_app/models/friend_circle.dart';
import 'package:resbite_app/components/ui/button.dart';
import 'package:resbite_app/components/ui/badge.dart';
import 'package:resbite_app/ui/shared/empty_state.dart';
import 'package:resbite_app/ui/shared/loading_state.dart';
import 'package:resbite_app/ui/shared/toast.dart';
import 'package:resbite_app/services/providers.dart';

/// Screen for managing friends
class FriendsScreen extends ConsumerStatefulWidget {
  const FriendsScreen({super.key});

  @override
  ConsumerState<FriendsScreen> createState() => _FriendsScreenState();
}

class _FriendsScreenState extends ConsumerState<FriendsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _searchController.addListener(_onSearchChanged);
  }
  
  @override
  void dispose() {
    _tabController.dispose();
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }
  
  void _onSearchChanged() {
    setState(() {
      _searchQuery = _searchController.text.toLowerCase();
    });
  }
  
  @override
  Widget build(BuildContext context) {
    final pendingInvitationsAsync = ref.watch(pendingInvitationsProvider);
    final invitationCount = pendingInvitationsAsync.maybeWhen(
      data: (invitations) => invitations.length,
      orElse: () => 0,
    );
    
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Friends & Circles',
          style: TwTypography.heading6(context).copyWith(
            color: Theme.of(context).colorScheme.primary,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: false,
        elevation: 0,
        backgroundColor: Colors.transparent,
        actions: [
          // Invitations button with badge for pending invitations
          if (invitationCount > 0)
            Container(
              margin: const EdgeInsets.only(right: 8.0),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Badge(
                label: Text('$invitationCount'),
                isLabelVisible: invitationCount > 0,
                backgroundColor: TwColors.primary,
                child: IconButton(
                  icon: const Icon(Icons.mail),
                  onPressed: () {
                    _showPendingInvitationsDialog(context);
                  },
                  color: Theme.of(context).colorScheme.primary,
                  tooltip: 'Pending Invitations',
                ),
              ),
            ),
          
          // Add friend icon
          Container(
            margin: const EdgeInsets.only(right: 8.0),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: const Icon(Icons.person_add),
              onPressed: () {
                _showSyncContactsDialog(context);
              },
              color: Theme.of(context).colorScheme.primary,
              tooltip: 'Add Friends',
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showCreateCircleDialog(context);
        },
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
        tooltip: 'Create Friend Circle',
        child: const Icon(Icons.group_add),
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: ShadInput.text(
              hintText: 'Search friends, circles, or contacts...',
              controller: _searchController,
              prefixIcon: const Icon(Icons.search),
              suffixIcon: _searchQuery.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _searchController.clear();
                      },
                    )
                  : null,
            ),
          ),
          
          // Tab bar
          Container(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: TabBar(
              controller: _tabController,
              tabs: const [
                Tab(text: 'My Friends'),
                Tab(text: 'Circles'),
                Tab(text: 'Network'),
              ],
              labelColor: Theme.of(context).colorScheme.primary,
              unselectedLabelColor: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
              labelStyle: Theme.of(context).textTheme.labelLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
              unselectedLabelStyle: Theme.of(context).textTheme.labelLarge,
              indicatorColor: Theme.of(context).colorScheme.primary,
              indicatorWeight: 3,
              indicatorSize: TabBarIndicatorSize.label,
              padding: const EdgeInsets.symmetric(horizontal: 16),
            ),
          ),
          
          // Tab content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                // Direct Friends Tab
                _buildDirectFriendsTab(),
                
                // Circles Tab
                _buildCirclesTab(),
                
                // Extended Network Tab
                _buildNetworkTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildDirectFriendsTab() {
    final friendsAsync = ref.watch(directFriendsProvider);
    
    return RefreshIndicator(
      onRefresh: () async {
        await ref.refresh(directFriendsProvider).value;
      },
      child: friendsAsync.when(
        data: (friends) {
          // Filter friends based on search query
          final filteredFriends = _searchQuery.isEmpty
              ? friends
              : friends
                  .where((friend) {
                      if (friend is Map && friend.containsKey('user')) {
                        final user = friend['user'];
                        if (user is Map) {
                          final displayName = user['displayName'];
                          final email = user['email'];
                          if ((displayName != null && displayName.toString().toLowerCase().contains(_searchQuery)) ||
                              (email != null && email.toString().toLowerCase().contains(_searchQuery))) {
                            return true;
                          }
                        }
                      }
                      return false;
                    })
                  .toList();
          
          if (filteredFriends.isEmpty) {
            return EmptyState(
              type: EmptyStateType.empty,
              title: _searchQuery.isEmpty ? 'No Friends Yet' : 'No Results Found',
              message: _searchQuery.isEmpty
                  ? 'Sync your contacts to find friends using Resbite.'
                  : 'Try a different search term or sync more contacts.',
              customIcon: Icons.people_outline,
              onActionPressed: () {
                _showSyncContactsDialog(context);
              },
              actionLabel: 'Add Friends',
            );
          }
          
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: filteredFriends.length,
            separatorBuilder: (context, index) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final friend = filteredFriends[index];
              return _buildFriendItem(friend);
            },
          );
        },
        loading: () => LoadingState(
          type: LoadingStateType.shimmer,
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: 5,
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: LoadingState.listItemSkeleton(
                  height: 70,
                ),
              );
            },
          ),
        ),
        error: (error, _) => EmptyState(
          type: EmptyStateType.error,
          title: 'Error Loading Friends',
          message: 'We couldn\'t load your friends. Please try again.',
          onActionPressed: () {
            ref.refresh(directFriendsProvider);
          },
          actionLabel: 'Try Again',
        ),
      ),
    );
  }
  
  Widget _buildCirclesTab() {
    final circlesAsync = ref.watch(friendCirclesProvider);
    
    return RefreshIndicator(
      onRefresh: () async {
        await ref.refresh(extendedNetworkProvider).value;
      },
      child: circlesAsync.when(
        data: (circles) {
          // Filter circles based on search query
          final filteredCircles = _searchQuery.isEmpty
              ? circles
              : circles
                  .where((circle) {
                      if (circle is Map) {
                        final name = circle['name'];
                        final description = circle['description'];
                        if ((name != null && name.toString().toLowerCase().contains(_searchQuery)) ||
                            (description != null && description.toString().toLowerCase().contains(_searchQuery))) {
                          return true;
                        }
                      }
                      return false;
                    })
                  .toList();
          
          if (filteredCircles.isEmpty) {
            return EmptyState(
              type: EmptyStateType.empty,
              title: _searchQuery.isEmpty ? 'No Friend Circles Yet' : 'No Results Found',
              message: _searchQuery.isEmpty
                  ? 'Create your first friend circle to organize your friends.'
                  : 'Try a different search term.',
              customIcon: Icons.group,
              onActionPressed: () {
                _showCreateCircleDialog(context);
              },
              actionLabel: 'Create Circle',
            );
          }
          
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: filteredCircles.length,
            itemBuilder: (context, index) {
              final circle = filteredCircles[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: _buildCircleItem(circle),
              );
            },
          );
        },
        loading: () => LoadingState(
          type: LoadingStateType.shimmer,
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: 3,
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: LoadingState.listItemSkeleton(
                  height: 100,
                ),
              );
            },
          ),
        ),
        error: (error, _) => EmptyState(
          type: EmptyStateType.error,
          title: 'Error Loading Circles',
          message: 'We couldn\'t load your friend circles. Please try again.',
          onActionPressed: () {
            ref.refresh(friendCirclesProvider);
          },
          actionLabel: 'Try Again',
        ),
      ),
    );
  }
  
  Widget _buildNetworkTab() {
    // Add access to contacts provider to get contact info
    final networkAsync = ref.watch(extendedNetworkProvider);
    final contactsAsync = ref.watch(resbiteContactsProvider);
    final contactService = ref.read(contactServiceProvider);
    // Use the contact service to check permissions directly
    final contactPermissionAsync = Future.value(contactService.hasContactsPermission());
    
    return RefreshIndicator(
      onRefresh: () async {
        await ref.refresh(extendedNetworkProvider).value;
        await ref.refresh(resbiteContactsProvider).value;
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
                    onPressed: () => _showSyncContactsDialog(context),
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
              final filteredContacts = _searchQuery.isEmpty
                ? contacts
                : contacts.where((contact) {
                    // Access PhoneContact properties using dot notation
                    final displayName = contact.displayName;
                    final emails = contact.emails;
                    final phones = contact.phoneNumbers;
                    final profileImageUrl = contact.profileImageUrl;
                      
                    final emailStr = emails.join(' ');
                    final phoneStr = phones.join(' ');
                      
                    return displayName.toLowerCase().contains(_searchQuery) ||
                           emailStr.toLowerCase().contains(_searchQuery) ||
                           phoneStr.toLowerCase().contains(_searchQuery);
                  }).toList();
              
              // Get the extended network connections
              return networkAsync.when(
                data: (network) {
                  // Get contacts that are Resbite users vs non-users
                  final resbiteUsers = filteredContacts.where((contact) => 
                    contact.isResbiteUser == true).toList();
                  
                  final nonResbiteUsers = filteredContacts.where((contact) => 
                    contact.isResbiteUser == false).toList();
                  
                  // Group connections by level (from original network tab)
                  final secondDegree = network
                    .where((conn) => conn is Map && conn['level'] == 'secondDegree')
                    .toList();
                  
                  final thirdDegree = network
                    .where((conn) => conn is Map && conn['level'] == 'thirdDegree')
                    .toList();
                  
                  // If everything is empty, show prompt
                  if (resbiteUsers.isEmpty && nonResbiteUsers.isEmpty && 
                      secondDegree.isEmpty && thirdDegree.isEmpty) {
                    return EmptyState(
                      type: EmptyStateType.empty,
                      title: _searchQuery.isEmpty ? 'No Contacts or Network Yet' : 'No Results Found',
                      message: _searchQuery.isEmpty
                          ? 'Sync your contacts to find friends or invite others to join Resbite.'
                          : 'Try a different search term.',
                      customIcon: Icons.diversity_3,
                      actionLabel: 'Refresh Contacts',
                      onActionPressed: () async {
                        await ref.refresh(resbiteContactsProvider).value;
                        await ref.refresh(extendedNetworkProvider).value;
                      },
                    );
                  }
                  
                  return ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      // Resbite users from contacts
                      if (resbiteUsers.isNotEmpty) ...[                        Padding(
                          padding: const EdgeInsets.only(bottom: 8.0, left: 4.0),
                          child: Text(
                            'Contacts on Resbite',
                            style: TwTypography.heading6(context),
                          ),
                        ),
                        ...resbiteUsers.map((contact) => _buildContactItem(contact, isResbiteUser: true)),
                        const SizedBox(height: 24),
                      ],
                      
                      // Friends of friends from network
                      if (secondDegree.isNotEmpty) ...[                        Padding(
                          padding: const EdgeInsets.only(bottom: 8.0, left: 4.0),
                          child: Text(
                            'Friends of Friends',
                            style: TwTypography.heading6(context),
                          ),
                        ),
                        ...secondDegree.map((conn) => _buildNetworkConnectionItem(conn as dynamic)),
                        const SizedBox(height: 24),
                      ],
                      
                      // Extended network from network tab
                      if (thirdDegree.isNotEmpty) ...[                        Padding(
                          padding: const EdgeInsets.only(bottom: 8.0, left: 4.0),
                          child: Text(
                            'Extended Network',
                            style: TwTypography.heading6(context),
                          ),
                        ),
                        ...thirdDegree.map((conn) => _buildNetworkConnectionItem(conn as dynamic)),
                        const SizedBox(height: 24),
                      ],
                      
                      // Non-Resbite users from contacts
                      if (nonResbiteUsers.isNotEmpty) ...[                        Padding(
                          padding: const EdgeInsets.only(bottom: 8.0, left: 4.0),
                          child: Text(
                            'Invite Contacts to Resbite',
                            style: TwTypography.heading6(context),
                          ),
                        ),
                        ...nonResbiteUsers.map((contact) => _buildContactItem(contact, isResbiteUser: false)),
                      ],
                    ],
                  );
                },
                loading: () => LoadingState(
                  type: LoadingStateType.shimmer,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: 5,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: LoadingState.listItemSkeleton(
                          height: 70,
                        ),
                      );
                    },
                  ),
                ),
                error: (error, _) => EmptyState(
                  type: EmptyStateType.error,
                  title: 'Error Loading Network',
                  message: 'We couldn\'t load your network. Please try again.',
                  onActionPressed: () async {
                    await ref.refresh(extendedNetworkProvider).value;
                    await ref.refresh(resbiteContactsProvider).value;
                  },
                  actionLabel: 'Try Again',
                ),
              );
            },
            loading: () => LoadingState(
              type: LoadingStateType.shimmer,
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: 5,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: LoadingState.listItemSkeleton(
                      height: 70,
                    ),
                  );
                },
              ),
            ),
            error: (error, _) => EmptyState(
              type: EmptyStateType.error,
              title: 'Error Loading Contacts',
              message: 'We couldn\'t load your contacts. Please try again.',
              onActionPressed: () async {
                await ref.refresh(resbiteContactsProvider).value;
              },
              actionLabel: 'Try Again',
            ),
          );
        },
      ),
    );
  }
  
  Widget _buildFriendItem(dynamic friend) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: InkWell(
        onTap: () {
          _showFriendDetailsDialog(context, friend);
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              // Profile picture
              ShadAvatar(
                size: AvatarSize.md,
                imageUrl: friend.user.profileImageUrl,
                initials: friend.user.displayName?.split(' ').map((e) => e.isNotEmpty ? e[0] : '').join('') ?? '',
                backgroundColor: TwColors.primary.withOpacity(0.2),
                textColor: TwColors.primary,
                statusColor: friend.isFavorite ? TwColors.warning : null,
              ),
              const SizedBox(width: 16),
              
              // Friend details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          friend.user.displayName ?? 'Friend',
                          style: TwTypography.body(context).copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (friend.isFavorite) ...[
                          const SizedBox(width: 8),
                          Icon(
                            Icons.star,
                            size: 16,
                            color: TwColors.warning,
                          ),
                        ],
                      ],
                    ),
                    if (friend.user.email != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        friend.user.email!,
                        style: TwTypography.bodyXs(context).copyWith(
                          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                        ),
                      ),
                    ],
                    
                    // Show circles the friend is in
                    if (friend.groupIds.isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Icon(
                            Icons.people,
                            size: 14,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'In ${friend.groupIds.length} circles',
                            style: TwTypography.bodyXs(context).copyWith(
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              
              // Action buttons
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Message button
                  IconButton(
                    icon: const Icon(Icons.message_outlined),
                    color: Theme.of(context).colorScheme.primary,
                    tooltip: 'Message',
                    onPressed: () {
                      Toast.showInfo(
                        context, 
                        'Messaging will be available soon',
                      );
                    },
                  ),
                  
                  // Resbite invite button
                  IconButton(
                    icon: const Icon(Icons.calendar_today_outlined),
                    color: Theme.of(context).colorScheme.primary,
                    tooltip: 'Invite to Resbite',
                    onPressed: () {
                      _showInviteToResbiteDialog(context, friend);
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildCircleItem(dynamic circle) {
    final isAdmin = circle is Map && circle.containsKey('adminIds') && 
                     (circle['adminIds'] as List).contains('current-user-id'); // Use actual current user ID in real app
    
    return ShadCard.default_(
      onTap: () {
        _showCircleDetailsDialog(context, circle);
      },
      title: circle.name,
      subtitle: circle.description.isNotEmpty ? circle.description : null,
      leading: CircleAvatar(
        backgroundColor: isAdmin ? TwColors.primary : TwColors.slate300,
        foregroundColor: isAdmin ? TwColors.textLight : TwColors.textDark,
        child: Icon(
          isAdmin ? Icons.edit : Icons.group,
        ),
      ),
      trailing: BadgeIcon(
        memberCount: circle.memberCount,
        isPrivate: circle.isPrivate,
      ),
      footer: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            // View members button
            ShadButton.ghost(
              text: 'Members',
              size: ButtonSize.sm,
              icon: Icons.people,
              onPressed: () {
                _showCircleMembersDialog(context, circle);
              },
            ),
            
            // Add member button (if admin)
            if (isAdmin)
              ShadButton.primary(
                text: 'Invite',
                size: ButtonSize.sm,
                icon: Icons.person_add,
                onPressed: () {
                  _showInviteToCircleDialog(context, circle);
                },
              ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildContactItem(dynamic contact, {required bool isResbiteUser}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: InkWell(
        onTap: () {
          if (isResbiteUser) {
            // If contact is a Resbite user, we can add them as friend
            _addContactAsFriend(contact.resbiteUserId);
          } else {
            // If not a Resbite user, we can invite them to the app
            _inviteContactToApp(context, contact);
          }
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              // Profile picture/avatar
              ShadAvatar(
                size: AvatarSize.md,
                imageUrl: isResbiteUser ? contact.profileImageUrl : null,
                initials: contact.displayName?.split(' ').map((e) => e.isNotEmpty ? e[0] : '').join('') ?? '',
                backgroundColor: isResbiteUser 
                  ? TwColors.primary.withOpacity(0.2) 
                  : TwColors.slate200,
                textColor: isResbiteUser ? TwColors.primary : TwColors.slate700,
              ),
              const SizedBox(width: 16),
              
              // Contact information
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      contact.displayName ?? '',
                      style: TwTypography.body(context),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (contact.phoneNumbers.isNotEmpty)
                      Text(
                        contact.phoneNumbers.first,
                        style: TwTypography.bodySm(context).copyWith(
                          color: TwColors.slate600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                  ],
                ),
              ),
              
              // Action button
              isResbiteUser
                ? ShadButton.primary(
                    text: 'Add',
                    onPressed: () => _addContactAsFriend(contact.resbiteUserId),
                    size: ButtonSize.sm,
                    icon: Icons.person_add_alt,
                  )
                : ShadButton.secondary(
                    text: 'Invite',
                    onPressed: () => _inviteContactToApp(context, contact),
                    size: ButtonSize.sm,
                    icon: Icons.share,
                  ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNetworkConnectionItem(dynamic connection) {
    final isSecondDegree = connection is Map && connection['level'] == 'secondDegree';
    
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: InkWell(
        onTap: () {
          // Show limited profile
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              // Profile picture
              ShadAvatar(
                size: AvatarSize.md,
                imageUrl: connection.user.profileImageUrl,
                initials: connection.user.displayName?.split(' ').map((e) => e.isNotEmpty ? e[0] : '').join('') ?? '',
                backgroundColor: isSecondDegree ? TwColors.slate200 : TwColors.slate100,
                textColor: isSecondDegree ? TwColors.slate700 : TwColors.slate500,
              ),
              const SizedBox(width: 16),
              
              // Connection details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      connection.user.displayName ?? 'Friend',
                      style: TwTypography.body(context),
                    ),
                    const SizedBox(height: 4),
                    
                    // Connection path
                    if (connection.connectedThrough != null) ...[
                      Row(
                        children: [
                          Icon(
                            Icons.people_outline,
                            size: 14,
                            color: Theme.of(context).colorScheme.primary.withOpacity(0.7),
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              isSecondDegree
                                  ? 'Connected via ${connection['connectedThrough']['displayName']}' // Replace with actual friend name
                                  : 'Friend of a friend',
                              style: TwTypography.bodyXs(context).copyWith(
                                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              
              // Action button - only for 2nd degree connections
              if (isSecondDegree)
                ShadButton.secondary(
                  text: 'Add Friend',
                  size: ButtonSize.sm,
                  icon: Icons.person_add,
                  onPressed: () {
                    final userId = connection is Map && connection['user'] is Map 
                        ? connection['user']['id'] 
                        : null;
                    if (userId != null) {
                      _addFriend(userId);
                    }
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }
  
  void _showSyncContactsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(
          'Sync Contacts',
          style: TwTypography.heading6(dialogContext),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Syncing your contacts helps you find friends who are already using Resbite and invite others to join.',
              style: TwTypography.body(dialogContext),
            ),
            const SizedBox(height: 12),
            Text(
              'This requires permission to access your contacts. Your contacts won\'t be stored on our servers without your permission.',
              style: TwTypography.bodySm(dialogContext).copyWith(
                color: Theme.of(dialogContext).colorScheme.onSurface.withOpacity(0.7),
              ),
            ),
          ],
        ),
        actions: [
          ShadButton.ghost(
            text: 'Cancel',
            onPressed: () {
              Navigator.of(dialogContext).pop();
            },
          ),
          ShadButton.primary(
            text: 'Sync Contacts',
            onPressed: () async {
              // Store the BuildContext in a local variable
              final navContext = dialogContext;
              Navigator.of(navContext).pop();
              
              // Store the build context before async operations
              final scaffoldContext = context;
              
              // The 'mounted' property will help us track if the widget is still active
              // We'll check it before accessing context in the async operation
              
              // Show loading indicator
              if (mounted) {
                showDialog(
                  context: scaffoldContext,
                  barrierDismissible: false,
                  builder: (loadingContext) => const Center(
                    child: CircularProgressIndicator(),
                  ),
                );
              }
              
              try {
                final friendService = ref.read(friendServiceProvider);
                final contacts = await friendService.syncDeviceContacts();
                
                // Close loading dialog and proceed only if still mounted
                if (mounted) {
                  // Close loading dialog
                  Navigator.of(scaffoldContext).pop();
                  
                  // Show results dialog
                  _showContactSyncResultsDialog(scaffoldContext, contacts);
                  
                  // Refresh the data
                  ref.refresh(directFriendsProvider);
                  ref.refresh(extendedNetworkProvider);
                  ref.refresh(resbiteContactsProvider);
                }
              } catch (e) {
                // Only proceed if still mounted
                if (mounted) {
                  // Close loading dialog
                  Navigator.of(scaffoldContext).pop();
                  
                  // Show error
                  ScaffoldMessenger.of(scaffoldContext).showSnackBar(
                    SnackBar(
                      content: Text('Error syncing contacts: ${e.toString()}'),
                      backgroundColor: TwColors.error,
                    ),
                  );
                }
              }
            },
          ),
        ],
      ),
    );
  }
  
  void _showContactSyncResultsDialog(BuildContext context, List<dynamic> contacts) {
    // Count Resbite users
    final resbiteUsers = contacts.where((contact) => contact is Map ? contact['isResbiteUser'] ?? false : false).toList();
    
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Container(
          width: double.maxFinite,
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.7,
            maxWidth: MediaQuery.of(context).size.width * 0.9,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  'Contacts Synced',
                  style: TwTypography.heading6(context),
                ),
              ),
              
              // Content
              Flexible(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Found ${contacts.length} contacts on your device.',
                          style: TwTypography.body(context),
                        ),
                        const SizedBox(height: 8),
                        RichText(
                          text: TextSpan(
                            style: TwTypography.body(context),
                            children: [
                              TextSpan(
                                text: '${resbiteUsers.length} ',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                              ),
                              TextSpan(
                                text: 'of your contacts are already using Resbite.',
                                style: TextStyle(
                                  color: Theme.of(context).colorScheme.onSurface,
                                ),
                              ),
                            ],
                          ),
                        ),
                        
                        if (resbiteUsers.isNotEmpty) ...[              
                          const SizedBox(height: 16),
                          Text(
                            'Resbite users in your contacts:',
                            style: TwTypography.bodySm(context).copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          
                          // Instead of ListView, use Column with individual items
                          ...resbiteUsers.take(5).map((contact) => Padding(
                            padding: const EdgeInsets.only(bottom: 8.0),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    contact is Map ? (contact['displayName'] ?? 'Unknown') : 'Unknown',
                                    style: TwTypography.bodySm(context),
                                  ),
                                ),
                                ShadButton.primary(
                                  text: 'Add Friend',
                                  size: ButtonSize.sm,
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                    final userId = contact['resbiteUserId'];
                                    if (userId != null) {
                                      _addContactAsFriend(userId);
                                    }
                                  },
                                ),
                              ],
                            ),
                          )).toList(),
                          
                          if (resbiteUsers.length > 5) ...[                
                            const SizedBox(height: 8),
                            Center(
                              child: Text(
                                '...and ${resbiteUsers.length - 5} more',
                                style: TwTypography.bodyXs(context).copyWith(
                                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                                ),
                              ),
                            ),
                          ],
                        ],
                      ],
                    ),
                  ),
                ),
              ),
              
              // Actions
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    ShadButton.ghost(
                      text: 'Close',
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    ),
                    const SizedBox(width: 8),
                    ShadButton.primary(
                      text: 'Invite Contacts',
                      onPressed: () {
                        Navigator.of(context).pop();
                        _showInviteContactsDialog(context, contacts.where(
                          (c) => c is Map ? !(c['isResbiteUser'] ?? false) : true
                        ).toList());
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  void _showInviteContactsDialog(BuildContext context, List<dynamic> nonResbiteContacts) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Invite Contacts',
          style: TwTypography.heading6(context),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Select contacts to invite to Resbite:',
              style: TwTypography.body(context),
            ),
            const SizedBox(height: 16),
            Container(
              constraints: const BoxConstraints(maxHeight: 300),
              width: double.maxFinite,
              child: nonResbiteContacts.isEmpty
                  ? Center(
                      child: Text(
                        'No contacts to invite',
                        style: TwTypography.bodySm(context).copyWith(
                          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                        ),
                      ),
                    )
                  : ListView.builder(
                      shrinkWrap: true,
                      itemCount: nonResbiteContacts.length > 10 ? 10 : nonResbiteContacts.length,
                      itemBuilder: (context, index) {
                        final contact = nonResbiteContacts[index];
                        return ListTile(
                          title: Text(
                            contact is Map ? (contact['displayName'] ?? 'Unknown') : 'Unknown',
                            style: TwTypography.bodySm(context),
                          ),
                          subtitle: Text(
                            contact is Map 
                              ? (contact['phoneNumbers'] is List && (contact['phoneNumbers'] as List).isNotEmpty 
                                ? contact['phoneNumbers'][0] 
                                : (contact['emails'] is List && (contact['emails'] as List).isNotEmpty 
                                  ? contact['emails'][0] 
                                  : ''))
                              : '',
                            style: TwTypography.bodyXs(context),
                          ),
                          trailing: ShadButton.secondary(
                            text: 'Invite',
                            size: ButtonSize.sm,
                            onPressed: () {
                              _inviteContactToApp(context, contact);
                            },
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
        actions: [
          ShadButton.ghost(
            text: 'Close',
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          if (nonResbiteContacts.isNotEmpty)
            ShadButton.primary(
              text: 'Invite All',
              onPressed: () {
                Navigator.of(context).pop();
                _inviteAllContacts(context, nonResbiteContacts);
              },
            ),
        ],
      ),
    );
  }
  
  void _addContactAsFriend(String resbiteUserId) async {
    try {
      final friendService = ref.read(friendServiceProvider);
      final success = await friendService.addContactAsFriend(resbiteUserId);
      
      if (success) {
        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Friend added successfully!'),
            backgroundColor: TwColors.success,
          ),
        );
        
        // Refresh data
        ref.refresh(directFriendsProvider);
      } else {
        // Show error
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Failed to add friend'),
            backgroundColor: TwColors.error,
          ),
        );
      }
    } catch (e) {
      // Show error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: TwColors.error,
        ),
      );
    }
  }
  
  void _inviteContactToApp(BuildContext context, dynamic contact) async {
    try {
      final friendService = ref.read(friendServiceProvider);
      final success = await friendService.inviteContactToApp(contact);
      
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Invitation sent to ${contact is Map ? contact['displayName'] ?? 'contact' : 'contact'}'),
            backgroundColor: TwColors.success,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to send invitation to ${contact is Map ? contact['displayName'] ?? 'contact' : 'contact'}'),
            backgroundColor: TwColors.error,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: TwColors.error,
        ),
      );
    }
  }
  
  void _inviteAllContacts(BuildContext context, List<dynamic> contacts) async {
    try {
      // Show loading indicator
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(),
        ),
      );
      
      final friendService = ref.read(friendServiceProvider);
      int successCount = 0;
      
      for (final contact in contacts) {
        try {
          final success = await friendService.inviteContactToApp(contact);
          if (success) successCount++;
        } catch (e) {
          // Continue with next contact
        }
      }
      
      // Close loading dialog
      Navigator.of(context).pop();
      
      // Show results
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Sent $successCount invitations out of ${contacts.length} contacts'),
          backgroundColor: successCount > 0 ? TwColors.success : TwColors.warning,
        ),
      );
    } catch (e) {
      // Close loading dialog
      Navigator.of(context).pop();
      
      // Show error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: TwColors.error,
        ),
      );
    }
  }
  
  void _showFriendDetailsDialog(BuildContext context, dynamic friend) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        contentPadding: const EdgeInsets.all(16),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Profile picture
            ShadAvatar(
              size: AvatarSize.xl,
              imageUrl: friend.user.profileImageUrl,
              initials: friend.user.displayName?.split(' ').map((e) => e.isNotEmpty ? e[0] : '').join('') ?? '',
              backgroundColor: TwColors.primary.withOpacity(0.2),
              textColor: TwColors.primary,
              hasBorder: true,
              borderColor: TwColors.primary,
            ),
            const SizedBox(height: 16),
            
            // Name
            Text(
              friend.user.displayName ?? 'Friend',
              style: TwTypography.heading5(context).copyWith(
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            
            // Friend since
            Text(
              'Friend since ${_formatDate(friend.connectedAt)}',
              style: TwTypography.bodySm(context).copyWith(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
              ),
            ),
            const SizedBox(height: 16),
            
            // Contact details
            if (friend.user.email != null) ...[
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.email, size: 18),
                  const SizedBox(width: 8),
                  Text(
                    friend.user.email!,
                    style: TwTypography.body(context),
                  ),
                ],
              ),
              const SizedBox(height: 16),
            ],
            
            // Action buttons for large screens
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ShadButton.ghost(
                  text: 'Message',
                  icon: Icons.message,
                  onPressed: () {
                    Navigator.of(context).pop();
                    // Messaging functionality
                    Toast.showInfo(
                      context, 
                      'Messaging will be available soon',
                    );
                  },
                ),
                ShadButton.primary(
                  text: 'Invite to Resbite',
                  icon: Icons.calendar_today,
                  onPressed: () {
                    Navigator.of(context).pop();
                    _showInviteToResbiteDialog(context, friend);
                  },
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Friend circles
            if (friend.groupIds.isNotEmpty) ...[
              const Divider(),
              const SizedBox(height: 8),
              Text(
                'Shared Friend Circles',
                style: TwTypography.heading6(context),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                alignment: WrapAlignment.center,
                children: friend.groupIds.map((circleId) => 
                  ShadBadge.secondary(
                    text: 'Close Friends', // Would fetch actual circle name
                    size: BadgeSize.md,
                    icon: Icons.group,
                  ),
                ).toList(),
              ),
            ],
          ],
        ),
        actions: [
          ShadButton.destructive(
            text: 'Remove Friend',
            onPressed: () {
              Navigator.of(context).pop();
              _showRemoveFriendConfirmation(context, friend);
            },
          ),
          ShadButton.ghost(
            text: 'Close',
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
    );
  }
  
  void _showInviteToResbiteDialog(BuildContext context, dynamic friend) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Invite to Resbite',
          style: TwTypography.heading6(context),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Select a resbite to invite ${friend.user.displayName ?? 'Friend'} to:',
              style: TwTypography.body(context),
            ),
            const SizedBox(height: 16),
            
            // List of upcoming resbites (mock data)
            ShadCard.default_(
              child: Column(
                children: [
                  ListTile(
                    title: const Text('Beach Day'),
                    subtitle: const Text('Saturday, Apr. 13 • 2:00 PM'),
                    trailing: ShadButton.primary(
                      text: 'Invite',
                      size: ButtonSize.sm,
                      onPressed: () {
                        Navigator.of(context).pop();
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Invitation sent to ${friend.user.displayName ?? 'Friend'}!'),
                            backgroundColor: TwColors.success,
                          ),
                        );
                      },
                    ),
                  ),
                  const Divider(),
                  ListTile(
                    title: const Text('Board Game Night'),
                    subtitle: const Text('Friday, Apr. 19 • 7:00 PM'),
                    trailing: ShadButton.primary(
                      text: 'Invite',
                      size: ButtonSize.sm,
                      onPressed: () {
                        Navigator.of(context).pop();
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Invitation sent to ${friend.user.displayName ?? 'Friend'}!'),
                            backgroundColor: TwColors.success,
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          ShadButton.ghost(
            text: 'Cancel',
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          ShadButton.secondary(
            text: 'Create New Resbite',
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pushNamed('/start-resbite');
            },
          ),
        ],
      ),
    );
  }
  
  void _showCreateCircleDialog(BuildContext context) {
    final nameController = TextEditingController();
    final descriptionController = TextEditingController();
    bool isPrivate = true;
    
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text(
            'Create Friend Circle',
            style: TwTypography.heading6(context),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Create a circle to group your friends by interests, activities, or relationships.',
                style: TwTypography.bodySm(context),
              ),
              const SizedBox(height: 16),
              
              // Name field
              ShadInput.text(
                labelText: 'Circle Name',
                hintText: 'E.g., Close Friends, Family, Sports Team',
                controller: nameController,
              ),
              const SizedBox(height: 16),
              
              // Description field
              ShadInput.text(
                labelText: 'Description (Optional)',
                hintText: 'What brings this group together?',
                controller: descriptionController,
              ),
              const SizedBox(height: 16),
              
              // Privacy toggle
              Row(
                children: [
                  Icon(
                    isPrivate ? Icons.lock_outline : Icons.lock_open_outlined,
                    size: 18,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Private Circle',
                      style: TwTypography.body(context),
                    ),
                  ),
                  Switch(
                    value: isPrivate,
                    onChanged: (value) {
                      setState(() {
                        isPrivate = value;
                      });
                    },
                    activeColor: Theme.of(context).colorScheme.primary,
                  ),
                ],
              ),
              
              // Privacy explanation
              Text(
                isPrivate
                    ? 'Only you can add members to this circle.'
                    : 'Members can add their friends to this circle.',
                style: TwTypography.bodyXs(context).copyWith(
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                ),
              ),
            ],
          ),
          actions: [
            ShadButton.ghost(
              text: 'Cancel',
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            ShadButton.primary(
              text: 'Create Circle',
              onPressed: () {
                if (nameController.text.trim().isEmpty) {
                  Toast.showError(context, 'Please enter a circle name');
                  return;
                }
                
                // Create circle
                _createFriendCircle(
                  name: nameController.text.trim(),
                  description: descriptionController.text.trim(),
                  isPrivate: isPrivate,
                );
                
                Navigator.of(context).pop();
              },
            ),
          ],
        ),
      ),
    );
  }
  
  void _showCircleDetailsDialog(BuildContext context, dynamic circle) {
    final isAdmin = circle is Map && circle.containsKey('adminIds') && 
                     (circle['adminIds'] as List?)?.contains('current-user-id') == true; // Use actual current user ID in real app
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Expanded(
              child: Text(
                circle.name,
                style: TwTypography.heading6(context),
              ),
            ),
            if (circle.isPrivate)
              Icon(
                Icons.lock_outline,
                size: 18,
                color: Theme.of(context).colorScheme.primary,
              ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Description
            if (circle.description.isNotEmpty) ...[
              Text(
                circle.description,
                style: TwTypography.body(context),
              ),
              const SizedBox(height: 16),
            ],
            
            // Circle stats
            Row(
              children: [
                Icon(
                  Icons.people,
                  size: 16,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  '${circle.memberCount} members',
                  style: TwTypography.bodySm(context),
                ),
                const Spacer(),
                Text(
                  'Created ${_formatDate(circle.createdAt)}',
                  style: TwTypography.bodyXs(context).copyWith(
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 16),
            
            // Admin section
            if (isAdmin) ...[
              Text(
                'Admin Tools',
                style: TwTypography.heading6(context),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: ShadButton.secondary(
                      text: 'Edit Circle',
                      icon: Icons.edit,
                      onPressed: () {
                        Navigator.of(context).pop();
                        // Show edit dialog
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ShadButton.destructive(
                      text: 'Delete',
                      icon: Icons.delete,
                      onPressed: () {
                        Navigator.of(context).pop();
                        // Show delete confirmation
                      },
                    ),
                  ),
                ],
              ),
            ] else ...[
              // Member section
              ShadButton.destructive(
                text: 'Leave Circle',
                isFullWidth: true,
                onPressed: () {
                  Navigator.of(context).pop();
                  _showLeaveCircleConfirmation(context, circle);
                },
              ),
            ],
          ],
        ),
        actions: [
          ShadButton.ghost(
            text: 'Close',
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          ShadButton.primary(
            text: 'View Members',
            onPressed: () {
              Navigator.of(context).pop();
              _showCircleMembersDialog(context, circle);
            },
          ),
        ],
      ),
    );
  }
  
  void _showCircleMembersDialog(BuildContext context, dynamic circle) {
    // In a real app, you would fetch the actual user data for each member ID
    // Here we'll mock it with the limited mock data we have
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          '${circle.name} Members',
          style: TwTypography.heading6(context),
        ),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView(
            shrinkWrap: true,
            children: [
              // Creator
              ListTile(
                leading: ShadAvatar(
                  size: AvatarSize.sm,
                  initials: 'CU', // Current User initials
                  backgroundColor: TwColors.secondary,
                  textColor: TwColors.textLight,
                ),
                title: const Text('You'),
                subtitle: const Text('Creator'),
                trailing: ShadBadge.primary(
                  text: 'Creator',
                  size: BadgeSize.sm,
                ),
              ),
              
              // Admins
              ...circle.adminIds.map((adminId) => 
                ListTile(
                  leading: ShadAvatar(
                    size: AvatarSize.sm,
                    initials: 'AD', // Admin initials
                    backgroundColor: TwColors.primary,
                    textColor: TwColors.textLight,
                  ),
                  title: const Text('Admin User'),
                  subtitle: const Text('Admin'),
                  trailing: ShadBadge.secondary(
                    text: 'Admin',
                    size: BadgeSize.sm,
                  ),
                ),
              ),
              
              // Regular members
              ...circle.memberIds.map((memberId) => 
                ListTile(
                  leading: ShadAvatar(
                    size: AvatarSize.sm,
                    initials: 'MU', // Member initials
                    backgroundColor: TwColors.slate200,
                    textColor: TwColors.slate700,
                  ),
                  title: const Text('Member User'),
                  trailing: Icon(
                    Icons.more_vert,
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                  ),
                ),
              ),
              
              // Pending invites
              if (circle.pendingInviteIds.isNotEmpty) ...[
                const Divider(),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                  child: Text(
                    'Pending Invites',
                    style: TwTypography.bodySm(context).copyWith(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                    ),
                  ),
                ),
                ...circle.pendingInviteIds.map((inviteId) => 
                  ListTile(
                    leading: ShadAvatar(
                      size: AvatarSize.sm,
                      initials: 'PU', // Pending User initials
                      backgroundColor: TwColors.slate100,
                      textColor: TwColors.slate500,
                    ),
                    title: const Text('Invited User'),
                    subtitle: const Text('Pending'),
                    trailing: ShadButton.ghost(
                      text: 'Cancel',
                      size: ButtonSize.sm,
                      onPressed: () {
                        // Cancel invitation
                      },
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
        actions: [
          // Only show add members button if admin or if circle is not private
          if (circle.isAdmin('current-user-id') || !circle.isPrivate)
            ShadButton.primary(
              text: 'Add Members',
              onPressed: () {
                Navigator.of(context).pop();
                _showInviteToCircleDialog(context, circle);
              },
            ),
          ShadButton.ghost(
            text: 'Close',
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
    );
  }
  
  void _showInviteToCircleDialog(BuildContext context, dynamic circle) {
    // In a real app, you would fetch the user's friends who aren't already in the circle
    // Here we'll mock it with direct friends
    
    showDialog(
      context: context,
      builder: (context) => FutureBuilder<List<FriendConnection>>(
        future: ref.read(friendServiceProvider).getDirectFriends(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const AlertDialog(
              content: Center(
                child: CircularProgressIndicator(),
              ),
            );
          }
          
          if (snapshot.hasError || !snapshot.hasData) {
            return AlertDialog(
              title: const Text('Error'),
              content: const Text('Could not load friends.'),
              actions: [
                ShadButton.ghost(
                  text: 'Close',
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          }
          
          final friends = snapshot.data!;
          
          // Filter out friends already in the circle
          final eligibleFriends = friends.where((friend) => 
            !circle.memberIds.contains(friend.user.id) &&
            !circle.adminIds.contains(friend.user.id) &&
            circle.createdBy != friend.user.id &&
            !circle.pendingInviteIds.contains(friend.user.id)
          ).toList();
          
          if (eligibleFriends.isEmpty) {
            return AlertDialog(
              title: Text(
                'Invite to ${circle.name}',
                style: TwTypography.heading6(context),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('All your friends are already in this circle.'),
                  const SizedBox(height: 16),
                  ShadButton.secondary(
                    text: 'Add New Friends',
                    isFullWidth: true,
                    onPressed: () {
                      Navigator.of(context).pop();
                      _showSyncContactsDialog(context);
                    },
                  ),
                ],
              ),
              actions: [
                ShadButton.ghost(
                  text: 'Close',
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          }
          
          return AlertDialog(
            title: Text(
              'Invite to ${circle.name}',
              style: TwTypography.heading6(context),
            ),
            content: SizedBox(
              width: double.maxFinite,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Select friends to invite:',
                    style: TwTypography.body(context),
                  ),
                  const SizedBox(height: 16),
                  
                  // Friend list
                  Flexible(
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: eligibleFriends.length,
                      itemBuilder: (context, index) {
                        final friend = eligibleFriends[index];
                        return ListTile(
                          leading: ShadAvatar(
                            size: AvatarSize.sm,
                            imageUrl: friend.user.profileImageUrl,
                            initials: friend.user.displayName?.split(' ').map((e) => e.isNotEmpty ? e[0] : '').join('') ?? '',
                          ),
                          title: Text(friend.user.displayName ?? 'Friend'),
                          trailing: ShadButton.primary(
                            text: 'Invite',
                            size: ButtonSize.sm,
                            onPressed: () {
                              Navigator.of(context).pop();
                              _inviteToCircle(circle.id, friend.user.id);
                            },
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              ShadButton.ghost(
                text: 'Cancel',
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      ),
    );
  }
  
  void _showPendingInvitationsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => FutureBuilder<List<CircleInvitation>>(
        future: ref.read(friendServiceProvider).getPendingInvitations(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const AlertDialog(
              content: Center(
                child: CircularProgressIndicator(),
              ),
            );
          }
          
          if (snapshot.hasError) {
            return AlertDialog(
              title: const Text('Error'),
              content: const Text('Could not load invitations.'),
              actions: [
                ShadButton.ghost(
                  text: 'Close',
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          }
          
          final invitations = snapshot.data ?? [];
          
          if (invitations.isEmpty) {
            return AlertDialog(
              title: Text(
                'Pending Invitations',
                style: TwTypography.heading6(context),
              ),
              content: const Text('You have no pending invitations.'),
              actions: [
                ShadButton.ghost(
                  text: 'Close',
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          }
          
          return AlertDialog(
            title: Text(
              'Pending Invitations',
              style: TwTypography.heading6(context),
            ),
            content: SizedBox(
              width: double.maxFinite,
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: invitations.length,
                itemBuilder: (context, index) {
                  final invitation = invitations[index];
                  return ListTile(
                    title: const Text('Book Club'), // Would fetch circle name
                    subtitle: Text(
                      'Invited by Alex Kim', // Would fetch inviter name
                      style: TwTypography.bodyXs(context),
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ShadButton.ghost(
                          text: 'Decline',
                          size: ButtonSize.sm,
                          onPressed: () {
                            Navigator.of(context).pop();
                            _declineInvitation(invitation.id);
                          },
                        ),
                        const SizedBox(width: 8),
                        ShadButton.primary(
                          text: 'Accept',
                          size: ButtonSize.sm,
                          onPressed: () {
                            Navigator.of(context).pop();
                            _acceptInvitation(invitation.id);
                          },
                        ),
                      ],
                    ),
                    isThreeLine: true,
                  );
                },
              ),
            ),
            actions: [
              ShadButton.ghost(
                text: 'Close',
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      ),
    );
  }
  
  void _showRemoveFriendConfirmation(BuildContext context, dynamic friend) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Remove Friend',
          style: TwTypography.heading6(context),
        ),
        content: Text(
          'Are you sure you want to remove ${friend.user.displayName ?? 'Friend'} from your friends? '
          'They will also be removed from any circle you\'ve created.',
          style: TwTypography.body(context),
        ),
        actions: [
          ShadButton.ghost(
            text: 'Cancel',
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          ShadButton.destructive(
            text: 'Remove',
            onPressed: () {
              Navigator.of(context).pop();
              _removeFriend(friend.user.id);
            },
          ),
        ],
      ),
    );
  }
  
  void _showLeaveCircleConfirmation(BuildContext context, dynamic circle) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Leave Circle',
          style: TwTypography.heading6(context),
        ),
        content: Text(
          'Are you sure you want to leave the ${circle.name} circle? '
          'You\'ll need an invitation to rejoin.',
          style: TwTypography.body(context),
        ),
        actions: [
          ShadButton.ghost(
            text: 'Cancel',
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          ShadButton.destructive(
            text: 'Leave Circle',
            onPressed: () {
              Navigator.of(context).pop();
              _leaveCircle(circle.id);
            },
          ),
        ],
      ),
    );
  }
  
  void _showAppInviteDialog(BuildContext context, String contactName, String contactPhone) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Invite to Resbite App',
          style: TwTypography.heading6(context),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Send $contactName an invitation to join Resbite:',
              style: TwTypography.body(context),
            ),
            const SizedBox(height: 16),
            
            ShadInput.multiline(
              maxLines: 5,
              minLines: 3,
              controller: TextEditingController(
                text: 'Hey ${contactName.split(' ').first}! I\'m using this great app called Resbite for organizing activities with friends. You should check it out: https://resbite.app/download',
              ),
            ),
          ],
        ),
        actions: [
          ShadButton.ghost(
            text: 'Cancel',
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          ShadButton.primary(
            text: 'Send Invitation',
            onPressed: () {
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('App invitation sent to $contactName!'),
                  backgroundColor: TwColors.success,
                ),
              );
            },
          ),
        ],
      ),
    );
  }
  
  // Helper methods to call the friend service
  
  void _addFriend(String userId) async {
    final friendService = ref.read(friendServiceProvider);
    final result = await friendService.addFriend(userId);
    
    if (result != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${result.user.displayName ?? 'Friend'} added to your friends!'),
          backgroundColor: TwColors.success,
        ),
      );
      // Refresh friends list
      ref.refresh(directFriendsProvider);
      ref.refresh(extendedNetworkProvider);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Failed to add friend'),
          backgroundColor: TwColors.error,
        ),
      );
    }
  }
  
  void _removeFriend(String userId) async {
    final friendService = ref.read(friendServiceProvider);
    final result = await friendService.removeFriend(userId);
    
    if (result) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Friend removed'),
          backgroundColor: TwColors.success,
        ),
      );
      // Refresh friends list
      ref.refresh(directFriendsProvider);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Failed to remove friend'),
          backgroundColor: TwColors.error,
        ),
      );
    }
  }
  
  void _createFriendCircle({
    required String name,
    String description = '',
    bool isPrivate = true,
  }) async {
    final friendService = ref.read(friendServiceProvider);
    final result = await friendService.createFriendCircle(
      name: name,
      description: description,
      isPrivate: isPrivate,
    );
    
    if (result != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Circle "$name" created!'),
          backgroundColor: TwColors.success,
        ),
      );
      // Refresh circles list
      ref.refresh(friendCirclesProvider);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Failed to create circle'),
          backgroundColor: TwColors.error,
        ),
      );
    }
  }
  
  void _inviteToCircle(String circleId, String userId) async {
    final friendService = ref.read(friendServiceProvider);
    final result = await friendService.inviteToCircle(
      circleId: circleId,
      userId: userId,
    );
    
    if (result != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Invitation sent!'),
          backgroundColor: TwColors.success,
        ),
      );
      // Refresh circles list
      ref.refresh(friendCirclesProvider);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Failed to send invitation'),
          backgroundColor: TwColors.error,
        ),
      );
    }
  }
  
  void _acceptInvitation(String invitationId) async {
    final friendService = ref.read(friendServiceProvider);
    final result = await friendService.acceptInvitation(invitationId);
    
    if (result) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Invitation accepted!'),
          backgroundColor: TwColors.success,
        ),
      );
      // Refresh data
      ref.refresh(pendingInvitationsProvider);
      ref.refresh(friendCirclesProvider);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Failed to accept invitation'),
          backgroundColor: TwColors.error,
        ),
      );
    }
  }
  
  void _declineInvitation(String invitationId) async {
    final friendService = ref.read(friendServiceProvider);
    final result = await friendService.declineInvitation(invitationId);
    
    if (result) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Invitation declined'),
          backgroundColor: TwColors.success,
        ),
      );
      // Refresh data
      ref.refresh(pendingInvitationsProvider);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Failed to decline invitation'),
          backgroundColor: TwColors.error,
        ),
      );
    }
  }
  
  void _leaveCircle(String circleId) async {
    final friendService = ref.read(friendServiceProvider);
    final result = await friendService.leaveCircle(circleId);
    
    if (result) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('You left the circle'),
          backgroundColor: TwColors.success,
        ),
      );
      // Refresh data
      ref.refresh(friendCirclesProvider);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Failed to leave circle'),
          backgroundColor: TwColors.error,
        ),
      );
    }
  }
  
  // Helper method to format dates
  String _formatDate(DateTime date) {
    // Simple date formatting - could be enhanced with a proper formatter
    return '${date.month}/${date.day}/${date.year}';
  }
}

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