import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:resbite_app/models/user.dart' as app_user;
import 'package:resbite_app/ui/screens/friends/services/services.dart' as friends_services;

/// Utility dialog that lets the user select individual friends or entire circles.
/// Returns the list of unique `User`s selected, or `null` if the dialog was
/// dismissed.
class SelectPeopleDialog {
  static Future<List<app_user.User>?> show(
    BuildContext context,
    WidgetRef ref,
  ) async {
    return showDialog<List<app_user.User>>(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return _SelectPeopleDialogContent(ref: ref);
      },
    );
  }
}

class _SelectPeopleDialogContent extends ConsumerStatefulWidget {
  const _SelectPeopleDialogContent({required this.ref});

  final WidgetRef ref;

  @override
  ConsumerState<_SelectPeopleDialogContent> createState() => _SelectPeopleDialogContentState();
}

class _SelectPeopleDialogContentState extends ConsumerState<_SelectPeopleDialogContent> {
  // Keep track of selections
  final Set<String> _selectedUserIds = {};
  final List<app_user.User> _selectedUsers = [];

  bool _loadingCircles = true;
  bool _loadingFriends = true;
  List<dynamic> _circles = [];
  List<app_user.User> _friends = [];

  @override
  void initState() {
    super.initState();

    _loadCircles();
    _loadFriends();
  }

  Future<void> _loadCircles() async {
    try {
      final circles = await widget.ref
          .read(friends_services.circleServiceProvider)
          .getUserCircles();
      setState(() {
        _circles = circles;
        _loadingCircles = false;
      });
    } catch (_) {
      setState(() => _loadingCircles = false);
    }
  }

  Future<void> _loadFriends() async {
    try {
      final friends = await widget.ref
          .read(friends_services.directFriendsListProvider.future);
      setState(() {
        _friends = friends.map((fc) => fc.user).toList();
        _loadingFriends = false;
      });
    } catch (_) {
      setState(() => _loadingFriends = false);
    }
  }

  void _toggleUser(app_user.User user, bool selected) {
    setState(() {
      if (selected) {
        if (_selectedUserIds.add(user.id)) {
          _selectedUsers.add(user);
        }
      } else {
        _selectedUserIds.remove(user.id);
        _selectedUsers.removeWhere((u) => u.id == user.id);
      }
    });
  }

  Future<void> _addEntireCircle(dynamic circle) async {
    setState(() => _loadingCircles = true);
    try {
      final members = await widget.ref
          .read(friends_services.circleServiceProvider)
          .getCircleMembers(circle.id as String);
      for (final member in members) {
        _toggleUser(member, true);
      }
    } catch (_) {
      // ignore errors for now
    } finally {
      setState(() => _loadingCircles = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Select people to invite'),
      content: SizedBox(
        width: double.maxFinite,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Circles Section
              Text(
                'Your Circles',
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              _loadingCircles
                  ? const Center(child: CircularProgressIndicator())
                  : _circles.isEmpty
                      ? const Text('You have no circles')
                      : ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: _circles.length,
                          itemBuilder: (context, index) {
                            final circle = _circles[index];
                            return ListTile(
                              title: Text(circle.name),
                              subtitle: Text(circle.description ?? ''),
                              trailing: TextButton(
                                onPressed: () => _addEntireCircle(circle),
                                child: const Text('Invite All'),
                              ),
                            );
                          },
                        ),
              const SizedBox(height: 16),

              // Friends Section
              Text(
                'Direct Friends',
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              _loadingFriends
                  ? const Center(child: CircularProgressIndicator())
                  : _friends.isEmpty
                      ? const Text('No friends found')
                      : ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: _friends.length,
                          itemBuilder: (context, index) {
                            final user = _friends[index];
                            final selected = _selectedUserIds.contains(user.id);
                            return CheckboxListTile(
                              value: selected,
                              onChanged: (value) =>
                                  _toggleUser(user, value ?? false),
                              title: Text(user.displayName ?? user.email),
                              secondary: CircleAvatar(
                                backgroundImage: user.profileImageUrl != null
                                    ? NetworkImage(user.profileImageUrl!)
                                    : null,
                                child: user.profileImageUrl == null
                                    ? Text(
                                        (user.displayName ?? user.email)
                                            .substring(0, 1)
                                            .toUpperCase(),
                                      )
                                    : null,
                              ),
                            );
                          },
                        ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _selectedUsers.isEmpty
              ? null
              : () => Navigator.of(context).pop<List<app_user.User>>(_selectedUsers),
          child: const Text('Add'),
        ),
      ],
    );
  }
}
