import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:resbite_app/components/ui.dart';
import 'package:resbite_app/models/circle.dart';
import 'package:resbite_app/services/providers.dart'; // Corrected import path
import 'package:resbite_app/styles/tailwind_theme.dart';
import 'package:resbite_app/ui/screens/friends/components/components.dart';
import 'package:resbite_app/ui/screens/friends/services/services.dart'
    as friends_services;
import 'package:resbite_app/ui/screens/friends/tabs/tabs.dart'; // Re-added import
// Added import for CircleService
import 'package:resbite_app/ui/screens/friends/mixins/friends_dialog_mixin.dart';

/// Screen for managing friends
class FriendsScreen extends ConsumerStatefulWidget {
  const FriendsScreen({super.key});

  @override
  ConsumerState<FriendsScreen> createState() => _FriendsScreenState();
}

class _FriendsScreenState extends ConsumerState<FriendsScreen>
    with SingleTickerProviderStateMixin, FriendsDialogMixin<FriendsScreen> {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String? get _currentUserId =>
      ref.watch(supabaseClientProvider).auth.currentUser?.id;

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
    final pendingInvitationsAsync = ref.watch(
      friends_services.pendingInvitationsProvider,
    );
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
                    showPendingInvitationsDialog(context);
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
                showSyncContactsDialog(context);
              },
              color: Theme.of(context).colorScheme.primary,
              tooltip: 'Add Friends',
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showCreateCircleDialog(context);
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
              suffixIcon:
                  _searchQuery.isNotEmpty
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
              unselectedLabelColor: Theme.of(
                context,
              ).colorScheme.onSurface.withOpacity(0.7),
              labelStyle: Theme.of(
                context,
              ).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.bold),
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
                // Direct Friends Tab - using refactored widget
                DirectFriendsTab(
                  searchQuery: _searchQuery,
                  showSyncContactsDialog: showSyncContactsDialog,
                  buildFriendItem: _buildFriendItem,
                ),

                // Circles Tab - using refactored widget
                CirclesTab(
                  searchQuery: _searchQuery,
                  showCreateCircleDialog: showCreateCircleDialog,
                  buildCircleItem: _buildCircleItem,
                ),

                // Extended Network Tab - using refactored widget
                NetworkTab(
                  searchQuery: _searchQuery,
                  showSyncContactsDialog: showSyncContactsDialog,
                  buildContactItem: _buildContactItem,
                  buildNetworkConnectionItem: _buildNetworkConnectionItem,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Builder methods that use the extracted components
  Widget _buildFriendItem(dynamic friend) {
    return FriendItem(
      friend: friend,
      showFriendDetailsDialog: showFriendDetailsDialog,
      showInviteToResbiteDialog: showInviteToResbiteDialog,
    );
  }

  Widget _buildCircleItem(Circle circle) {
    return CircleItem(
      circle: circle,
      showCircleDetailsDialog: showCircleDetailsDialog,
      showCircleMembersDialog: showCircleMembersDialog,
      showInviteToCircleDialog: showInviteToCircleDialog,
      currentUserId: _currentUserId ?? '',
    );
  }

  Widget _buildContactItem(dynamic contact, {required bool isResbiteUser}) {
    return ContactItem(
      contact: contact,
      isResbiteUser: isResbiteUser,
      addContactAsFriend: addContactAsFriend,
      inviteContactToApp: inviteContactToApp,
    );
  }

  Widget _buildNetworkConnectionItem(dynamic connection) {
    return NetworkConnectionItem(connection: connection, addFriend: addFriend);
  }
}
