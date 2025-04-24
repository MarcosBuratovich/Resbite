import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../config/constants.dart';
import '../../config/theme.dart';
import '../../services/providers.dart';
import '../../models/resbite.dart';
import '../../ui/components/resbite_button.dart';
import '../../ui/components/resbite_card.dart';
import '../../ui/shared/empty_state.dart';
import '../../ui/shared/loading_state.dart';
import '../../ui/shared/toast.dart';
import 'activities/activities_screen.dart';
import 'friends_screen.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> with SingleTickerProviderStateMixin {
  int _selectedTab = 1; // Default to Activities tab (middle)
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _fadeAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );
    _animationController.forward();
  }
  
  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }
  
  void _changeTab(int index) {
    if (_selectedTab == index) return;
    
    setState(() {
      _animationController.reset();
      _selectedTab = index;
      _animationController.forward();
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(currentUserProvider).valueOrNull;
    
    // Continue rendering the home screen
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Resbite',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            color: AppTheme.darkTextColor,
            fontWeight: FontWeight.bold,
            fontFamily: 'Quicksand', // Use Quicksand for logo text
            letterSpacing: 1,
          ),
        ),
        backgroundColor: Colors.white,
        foregroundColor: AppTheme.darkTextColor,
        elevation: 1,
        shadowColor: Colors.black.withOpacity(0.1),
        centerTitle: true,
        automaticallyImplyLeading: false, // Remove back button and search icon
        actions: [
          // Shadcn Demo icon
          IconButton(
            icon: const Icon(Icons.design_services),
            tooltip: 'Shadcn Demo',
            onPressed: () {
              Navigator.of(context).pushNamed('/shadcn-demo');
            },
          ),
          
          // Settings icon
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            tooltip: 'Settings',
            onPressed: () {
              Toast.showInfo(
                context, 
                'Settings feature coming soon!',
                actionLabel: 'OK',
              );
            },
          ),
          
          // Profile icon in top-right
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppTheme.lightTextColor,
                  width: 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.15),
                    blurRadius: 8,
                    spreadRadius: 1,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: GestureDetector(
                onTap: () {
                  Navigator.of(context).pushNamed('/profile');
                },
                child: Hero(
                  tag: 'profile-avatar',
                  child: CircleAvatar(
                    radius: 18,
                    backgroundColor: AppTheme.lightTextColor.withOpacity(0.2),
                    backgroundImage: user?.profileImageUrl != null 
                        ? NetworkImage(user!.profileImageUrl!) as ImageProvider
                        : null,
                    child: user?.profileImageUrl == null
                        ? Icon(
                            Icons.person,
                            color: AppTheme.lightTextColor,
                            size: 20,
                          )
                        : null,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: IndexedStack(
          index: _selectedTab,
          children: const [
            MyResbitesTab(),
            ActivitiesScreen(),
            FriendsScreen(),
          ],
        ),
      ),
      // Floating action button for quick resbite creation
      floatingActionButton: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0.0, end: 1.0),
        duration: const Duration(milliseconds: 500),
        curve: Curves.elasticOut,
        builder: (context, value, child) {
          return Transform.scale(
            scale: value,
            child: child,
          );
        },
        child: FloatingActionButton(
          onPressed: () {
            // Add ripple animation effect before navigation
            ScaffoldMessenger.of(context).clearSnackBars();
            Navigator.of(context).pushNamed('/start-resbite');
          },
          backgroundColor: AppTheme.accentColor,
          foregroundColor: AppTheme.darkTextColor,
          elevation: 4,
          tooltip: 'Create new Resbite',
          child: const Icon(Icons.add),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      
      // Material Design 3 Navigation Bar
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedTab,
        onDestinationSelected: _changeTab,
        destinations: [
          // My Resbites tab
          NavigationDestination(
            icon: Badge(
              isLabelVisible: false,
              child: Icon(Icons.event_outlined),
            ),
            selectedIcon: Badge(
              isLabelVisible: false,
              child: Icon(Icons.event),
            ),
            label: 'My Resbites',
          ),
          
          // Activities tab
          NavigationDestination(
            icon: Icon(Icons.explore_outlined),
            selectedIcon: Icon(Icons.explore),
            label: 'Activities',
          ),
          
          // Friends tab (with badge for pending requests)
          NavigationDestination(
            icon: Badge(
              isLabelVisible: true,  // Show the badge with a count
              label: const Text("2"),
              backgroundColor: AppTheme.accentColor,
              child: const Icon(Icons.people_outlined),
            ),
            selectedIcon: Badge(
              isLabelVisible: false,
              child: const Icon(Icons.people),
            ),
            label: 'Friends',
          ),
        ],
      ),
    );
  }
  
  // Build a navigation item for the custom bottom bar
  Widget _buildNavItem({
    required IconData icon,
    required String label,
    required int index,
    bool hasBadge = false,
  }) {
    final bool isSelected = _selectedTab == index;
    
    return InkWell(
      onTap: () {
        _changeTab(index);
      },
      borderRadius: BorderRadius.circular(8),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 6.0),
        decoration: isSelected 
            ? BoxDecoration(
                color: AppTheme.primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              )
            : null,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Badge indicator if needed
            Stack(
              clipBehavior: Clip.none,
              children: [
                Icon(
                  icon,
                  size: 22,
                  color: isSelected ? AppTheme.primaryColor : Colors.grey,
                ),
                if (hasBadge && !isSelected)
                  Positioned(
                    top: -2,
                    right: -2,
                    child: Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: AppTheme.accentColor,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? AppTheme.primaryColor : Colors.grey,
                fontSize: 10,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// My Resbites Tab
class MyResbitesTab extends ConsumerStatefulWidget {
  const MyResbitesTab({super.key});

  @override
  ConsumerState<MyResbitesTab> createState() => _MyResbitesTabState();
}

class _MyResbitesTabState extends ConsumerState<MyResbitesTab> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  
  @override
  void initState() {
    super.initState();
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
        title: Text(
          'My Resbites',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            color: Theme.of(context).colorScheme.primary,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: false,
        elevation: 0,
        backgroundColor: Colors.transparent,
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 8.0),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: const Icon(Icons.add),
              onPressed: () {
                Navigator.of(context).pushNamed('/start-resbite');
              },
              color: Theme.of(context).colorScheme.primary,
              tooltip: 'Create new Resbite',
            ),
          ),
        ],
      ),
      body: Column(
        children: [
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
                Tab(text: 'Upcoming'),
                Tab(text: 'Past'),
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
          // Tab bar view 
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                // Upcoming resbites tab
                _buildResbitesListView(upcoming: true),
                
                // Past resbites tab
                _buildResbitesListView(upcoming: false),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildResbitesListView({required bool upcoming}) {
    final resbitesAsync = ref.watch(resbitesProvider(upcoming));
    
    return RefreshIndicator(
      onRefresh: () async {
        ref.refresh(resbitesProvider(upcoming));
      },
      child: resbitesAsync.when(
        data: (resbites) {
          if (resbites.isEmpty) {
            return upcoming
                ? EmptyState(
                    type: EmptyStateType.empty,
                    title: 'No Upcoming Resbites',
                    message: 'Create your first resbite to get started on your activities planning.',
                    customIcon: Icons.event_available,
                    onActionPressed: () {
                      Navigator.of(context).pushNamed('/start-resbite');
                    },
                    actionLabel: 'Create a Resbite',
                  )
                : EmptyState(
                    type: EmptyStateType.noData,
                    title: 'No Past Resbites',
                    message: 'Your completed resbites will appear here once you join or create activities.',
                    customIcon: Icons.history,
                  );
          }
          
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: resbites.length,
            itemBuilder: (context, index) {
              return _buildResbiteItem(resbites[index]);
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
                  height: 120,
                ),
              );
            },
          ),
        ),
        error: (error, _) => EmptyState(
          type: EmptyStateType.error,
          title: 'Error Loading Resbites',
          message: 'We couldn\'t load your resbites. ${error.toString().length > 50 ? error.toString().substring(0, 50) + '...' : error.toString()}',
          onActionPressed: () {
            ref.refresh(resbitesProvider(upcoming));
          },
          actionLabel: 'Try Again',
        ),
      ),
    );
  }
  
  Widget _buildResbiteItem(Resbite resbite) {
    // Create leading widget (image)
    final leading = Container(
      width: 65,
      height: 65,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: resbite.images.isNotEmpty
            ? Image.network(
                resbite.images.first,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Icon(
                    Icons.event,
                    size: 32,
                    color: AppTheme.primaryColor,
                  );
                },
              )
            : Icon(
                Icons.event,
                size: 32,
                color: AppTheme.primaryColor,
              ),
      ),
    );
    
    // Create status badge
    final statusBadge = Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            spreadRadius: 0,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Add icon for public/private indicator
          if (!resbite.isPrivate) ...[
            Icon(
              Icons.public,
              size: 12,
              color: _getStatusColor(resbite.status),
            ),
            const SizedBox(width: 4),
          ],
          Text(
            _getStatusText(resbite.status),
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: _getStatusColor(resbite.status),
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
    
    // Determine card colors based on status
    Color cardColor = Colors.white;
    Color headerColor;
    Color contentTextColor = AppTheme.darkTextColor;
    Color separatorColor;
    
    switch (resbite.status) {
      case ResbiteStatus.planned:
        headerColor = AppTheme.primaryColor;
        separatorColor = AppTheme.primaryColor.withOpacity(0.2);
        break;
      case ResbiteStatus.active:
        headerColor = AppTheme.secondaryColor;
        separatorColor = AppTheme.secondaryColor.withOpacity(0.2);
        break;
      case ResbiteStatus.cancelled:
        headerColor = Colors.grey.shade700;
        separatorColor = Colors.grey.shade300;
        break;
      case ResbiteStatus.completed:
        headerColor = Colors.grey.shade500;
        separatorColor = Colors.grey.shade300;
        break;
    }
    
    // Build detailed card
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 8,
              spreadRadius: 0,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(14),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: () {
              Navigator.of(context).pushNamed(
                '/resbites/details',
                arguments: {'id': resbite.id},
              );
            },
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header section with color
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: headerColor,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(14),
                      topRight: Radius.circular(14),
                    ),
                  ),
                  child: Row(
                    children: [
                      leading,
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    resbite.title,
                                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                statusBadge,
                              ],
                            ),
                            if (resbite.activity?.title != null) ...[
                              const SizedBox(height: 6),
                              Text(
                                resbite.activity!.title!,
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: Colors.white.withOpacity(0.9),
                                  fontWeight: FontWeight.w500,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Content section with details
                Container(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Date and time
                      _buildDetailRow(
                        icon: Icons.calendar_today,
                        text: _formatDate(resbite.startDate),
                        iconColor: headerColor,
                        textColor: contentTextColor,
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Divider(height: 1, color: separatorColor),
                      ),
                      
                      // Location
                      _buildDetailRow(
                        icon: Icons.location_on_outlined,
                        text: resbite.place?.name ?? resbite.meetingPoint ?? 'Location not specified',
                        iconColor: headerColor,
                        textColor: contentTextColor,
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Divider(height: 1, color: separatorColor),
                      ),
                      
                      // Participants
                      _buildDetailRow(
                        icon: Icons.people_outline,
                        text: 'Participants: ${resbite.currentAttendance}/${resbite.attendanceLimit != null && resbite.attendanceLimit! > 0 ? resbite.attendanceLimit : '∞'}',
                        iconColor: headerColor,
                        textColor: contentTextColor,
                      ),
                    ],
                  ),
                ),
                
                // Footer with actions
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      // Details button
                      TextButton.icon(
                        onPressed: () {
                          Navigator.of(context).pushNamed(
                            '/resbites/details',
                            arguments: {'id': resbite.id},
                          );
                        },
                        icon: Icon(
                          Icons.info_outline,
                          size: 18,
                          color: headerColor,
                        ),
                        label: Text(
                          'Details',
                          style: TextStyle(
                            color: headerColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                      
                      // Invite button for active or planned resbites
                      if (resbite.status == ResbiteStatus.active || resbite.status == ResbiteStatus.planned) ...[
                        const SizedBox(width: 8),
                        TextButton.icon(
                          onPressed: () {
                            Toast.showInfo(
                              context,
                              'Invite feature coming soon!',
                              actionLabel: 'OK',
                            );
                          },
                          icon: Icon(
                            Icons.person_add_outlined,
                            size: 18,
                            color: headerColor,
                          ),
                          label: Text(
                            'Invite',
                            style: TextStyle(
                              color: headerColor,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
  
  Widget _buildDetailRow({
    required IconData icon, 
    required String text,
    Color? iconColor,
    Color? textColor,
  }) {
    return Row(
      children: [
        Icon(
          icon,
          size: 18,
          color: iconColor ?? AppTheme.primaryColor,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: textColor ?? AppTheme.darkTextColor,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
  
  // Get status color
  Color _getStatusColor(ResbiteStatus status) {
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
  
  // Format date
  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));
    final dateToCheck = DateTime(date.year, date.month, date.day);
    
    if (dateToCheck == today) {
      return 'Today, ${DateFormat('h:mm a').format(date)}';
    } else if (dateToCheck == tomorrow) {
      return 'Tomorrow, ${DateFormat('h:mm a').format(date)}';
    } else {
      return DateFormat('EEE, MMM d, yyyy • h:mm a').format(date);
    }
  }
}

// Notifications Tab removed - Replaced with FriendsScreen