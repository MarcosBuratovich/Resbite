import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'dart:io'; - No longer needed

import '../../config/theme.dart';
import '../../models/user.dart';
import '../../services/providers.dart';
// import '../../utils/logger.dart'; - No longer needed
import '../../ui/components/resbite_button.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authStatusProvider);
    final authService = ref.read(authServiceProvider);
    // Try to get user data from multiple sources
    User? user = authService.currentUser;
    final providerUser = ref.watch(currentUserProvider).valueOrNull;
    
    // Use provider user as fallback
    if (user == null && providerUser != null) {
      user = providerUser;
    }
    
    // Try Supabase user as another fallback
    if (user == null) {
      final supabaseUser = ref.read(supabaseClientProvider).auth.currentUser;
      if (supabaseUser != null) {
        user = User.fromSupabaseUser(supabaseUser);
      }
    }
    
    // Create a fallback user with default values if we still don't have user data
    if (user == null && authState.value == AuthStatus.authenticated) {
      user = const User(
        id: 'fallback-id',
        email: 'user@example.com',
        displayName: 'Default User',
        emailVerified: false,
      );
    }
    
    // Debug output to diagnose profile data issues
    print('AUTH STATUS: ${authState.value}');
    print('USER DATA: ${user?.displayName ?? 'No name'}, ${user?.email ?? 'No email'}');
    
    // Check if user is authenticated
    if (authState.value != AuthStatus.authenticated) {
      // Redirect to login if not authenticated
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.of(context).pushReplacementNamed('/login');
      });
      
      // Show loading indicator while redirecting
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }
    
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Profile',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            color: AppTheme.darkTextColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: false,
        elevation: 1,
        backgroundColor: Colors.white,
        foregroundColor: AppTheme.darkTextColor, // Make back button and icons visible
        iconTheme: IconThemeData(color: AppTheme.darkTextColor), // Explicitly set icon color
        actions: [
          // Add sign out button
          Container(
            margin: const EdgeInsets.only(right: 8.0),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.error.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: const Icon(Icons.logout),
              tooltip: 'Sign Out',
              color: Theme.of(context).colorScheme.error,
              onPressed: () async {
                try {
                  await authService.signOut();
                  if (!mounted) return;
                  
                  // Navigate back to login screen
                  Navigator.of(context).pushNamedAndRemoveUntil(
                    '/login', 
                    (route) => false
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Error signing out: $e',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.white,
                        ),
                      ),
                      backgroundColor: Theme.of(context).colorScheme.error,
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                }
              },
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: user == null
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).colorScheme.primary),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Loading profile...',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ],
                ),
              )
            : SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Profile image
                    Center(
                      child: Stack(
                        children: [
                          // Profile picture with decoration
                          Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Theme.of(context).colorScheme.primary.withOpacity(0.2),
                                  blurRadius: 15,
                                  spreadRadius: 5,
                                ),
                              ],
                            ),
                            child: CircleAvatar(
                              radius: 70,
                              backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                              backgroundImage: user.profileImageUrl != null 
                                  ? NetworkImage(user.profileImageUrl!) as ImageProvider
                                  : null,
                              child: user.profileImageUrl == null
                                  ? Icon(
                                      Icons.person,
                                      size: 70,
                                      color: Theme.of(context).colorScheme.primary.withOpacity(0.7),
                                    )
                                  : null,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    
                    // User's name
                    Text(
                      user.displayName ?? 'User',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    
                    // Email address with icon
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.email_outlined,
                          size: 16,
                          color: Theme.of(context).colorScheme.onBackground.withOpacity(0.7),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          user.email,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Theme.of(context).colorScheme.onBackground.withOpacity(0.7),
                          ),
                        ),
                        if (user.emailVerified)
                          Padding(
                            padding: const EdgeInsets.only(left: 8.0),
                            child: Icon(
                              Icons.verified,
                              size: 16,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 32),
                    
                    // User info card
                    Container(
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surface,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Theme.of(context).shadowColor.withOpacity(0.1),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          // Phone section
                          _buildInfoItem(
                            context: context,
                            icon: Icons.phone_outlined,
                            title: 'Phone',
                            value: user.phoneNumber ?? 'Not provided',
                          ),
                          
                          // Divider
                          Divider(
                            height: 1,
                            thickness: 1,
                            indent: 16,
                            endIndent: 16,
                            color: Theme.of(context).dividerColor.withOpacity(0.1),
                          ),
                          
                          // Bio section
                          _buildInfoItem(
                            context: context,
                            icon: Icons.description_outlined,
                            title: 'Bio',
                            value: user.shortDescription ?? 'No bio provided',
                          ),
                          
                          // Show joined date if available
                          if (user.createdAt != null) ...[
                            Divider(
                              height: 1,
                              thickness: 1,
                              indent: 16,
                              endIndent: 16,
                              color: Theme.of(context).dividerColor.withOpacity(0.1),
                            ),
                            
                            _buildInfoItem(
                              context: context,
                              icon: Icons.calendar_today_outlined,
                              title: 'Joined',
                              value: _formatDate(user.createdAt!),
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),
                    
                    // Edit profile button
                    ResbiteButton(
                      text: 'Edit Profile',
                      icon: Icons.edit,
                      type: ResbiteBtnType.primary,
                      size: ResbiteBtnSize.medium,
                      onPressed: () {
                        // Navigate to edit profile screen
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Edit profile feature coming soon!'),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
      ),
    );
  }
  
  // Helper method to format date
  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
  
  // Helper method to build info items
  Widget _buildInfoItem({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Icon
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: Theme.of(context).colorScheme.primary,
              size: 20,
            ),
          ),
          const SizedBox(width: 16),
          
          // Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}