import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../dialogs/select_people_dialog.dart';

import '../../../config/constants.dart';
import '../../../config/theme.dart';
import '../../../models/activity.dart';
import '../../../models/resbite.dart';
import '../../../models/user.dart' as app_user;
import '../../../services/providers.dart';
import '../../../utils/logger.dart';

// State provider to keep track of the current step in the resbite creation process
final resbiteCreationStepProvider = StateProvider<int>((ref) => 0);

// State provider to store the resbite data being created
final resbiteDataProvider = StateProvider<Map<String, dynamic>>((ref) => {});

class StartResbiteScreen extends ConsumerStatefulWidget {
  final String? activityId;

  const StartResbiteScreen({super.key, this.activityId});

  @override
  ConsumerState<StartResbiteScreen> createState() => _StartResbiteScreenState();
}

class _StartResbiteScreenState extends ConsumerState<StartResbiteScreen> {
  final _pages = <Widget>[];
  late final PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();

    // Initialize resbite data with activity ID if provided
    if (widget.activityId != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final resbiteData = ref.read(resbiteDataProvider.notifier);
        resbiteData.state = {
          ...resbiteData.state,
          'activityId': widget.activityId,
        };

        // Pre-load the activity data
        _loadActivityData(widget.activityId!);
      });
    }

    // Check authentication status after build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkAuthStatus();
    });
  }

  // Helper method to pre-load the activity data
  Future<void> _loadActivityData(String activityId) async {
    try {
      // Load the activity data from the provider
      final activity = await ref.read(activityProvider(activityId).future);

      if (activity != null && mounted) {
        // Update resbite data with the activity
        final resbiteData = ref.read(resbiteDataProvider.notifier);
        resbiteData.state = {
          ...resbiteData.state,
          'activity': activity,
          'title': 'Let\'s do ${activity.title}',
        };
      }
    } catch (e) {
      // Log error but continue
      print('Error pre-loading activity: $e');
    }
  }

  void _checkAuthStatus() {
    final authService = ref.read(authServiceProvider);
    if (authService.status != AuthStatus.authenticated) {
      // Not authenticated, show dialog and navigate to login
      if (mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder:
              (context) => AlertDialog(
                title: const Text('Authentication Required'),
                content: const Text(
                  'You must be logged in to create a resbite.',
                ),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop(); // Close dialog
                      Navigator.of(
                        context,
                      ).pushReplacementNamed('/login'); // Go to login
                    },
                    child: const Text('Log In'),
                  ),
                ],
              ),
        );
      }
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Verify authentication
    final authState = ref.watch(authStatusProvider);
    if (authState.value != AuthStatus.authenticated) {
      // If not authenticated, redirect to login
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.of(context).pushReplacementNamed('/login');
      });

      // Show loading screen while redirecting
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    // Get the current step
    final currentStep = ref.watch(resbiteCreationStepProvider);

    // Create pages if they haven't been created yet
    if (_pages.isEmpty) {
      _pages.addAll([
        const ActivitySelectionPage(),
        const BasicDetailsPage(),
        const DateTimePage(),
        const LocationPage(),
        const InvitationsPage(),
        const ReviewPage(),
      ]);
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Start a Resbite'),
        actions: [
          // Only show close button if not on the first step
          if (currentStep > 0)
            IconButton(
              icon: const Icon(Icons.close),
              onPressed: () {
                // Show confirmation dialog
                showDialog(
                  context: context,
                  builder:
                      (context) => AlertDialog(
                        title: const Text('Discard Resbite?'),
                        content: const Text(
                          'Are you sure you want to discard this resbite?',
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(),
                            child: const Text('Cancel'),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                              Navigator.of(context).pop();
                            },
                            child: const Text('Discard'),
                          ),
                        ],
                      ),
                );
              },
            ),
        ],
      ),
      body: Column(
        children: [
          // Stepper indicator
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(_pages.length, (index) {
                return Container(
                  width: 10,
                  height: 10,
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color:
                        index == currentStep
                            ? Theme.of(context).colorScheme.primary
                            : Theme.of(
                              context,
                            ).colorScheme.primary.withOpacity(0.3),
                  ),
                );
              }),
            ),
          ),

          // Page content
          Expanded(
            child: PageView(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(),
              onPageChanged: (index) {
                ref.read(resbiteCreationStepProvider.notifier).state = index;
              },
              children: _pages,
            ),
          ),

          // Navigation buttons
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Back button
                if (currentStep > 0)
                  OutlinedButton(
                    onPressed: () {
                      _pageController.previousPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppTheme.primaryColor,
                      side: BorderSide(color: AppTheme.primaryColor),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                    ),
                    child: const Text('Back'),
                  )
                else
                  const SizedBox(width: 100), // Placeholder for spacing
                // Next/Finish button
                ElevatedButton(
                  onPressed: () {
                    // If we're on the last page, submit the resbite
                    if (currentStep == _pages.length - 1) {
                      // The ReviewPage handles the submission
                      return;
                    }

                    // Otherwise, go to the next page
                    _pageController.nextPage(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryColor,
                    foregroundColor: AppTheme.lightTextColor,
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                  ),
                  child: Text(
                    currentStep == _pages.length - 1 ? 'Create' : 'Next',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
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

// STEP 1: Activity Selection
class ActivitySelectionPage extends ConsumerStatefulWidget {
  const ActivitySelectionPage({super.key});

  @override
  ConsumerState<ActivitySelectionPage> createState() =>
      _ActivitySelectionPageState();
}

class _ActivitySelectionPageState extends ConsumerState<ActivitySelectionPage> {
  Activity? _selectedActivity;

  @override
  void initState() {
    super.initState();
    _loadActivity();
  }

  Future<void> _loadActivity() async {
    final resbiteData = ref.read(resbiteDataProvider);
    final activityId = resbiteData['activityId'] as String?;

    if (activityId != null) {
      final activity = await ref.read(activityProvider(activityId).future);
      if (activity != null && mounted) {
        setState(() {
          _selectedActivity = activity;
        });

        // Update resbite data
        final resbiteData = ref.read(resbiteDataProvider.notifier);
        resbiteData.state = {
          ...resbiteData.state,
          'activity': activity,
          'title': 'Let\'s do ${activity.title}',
        };
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Select an Activity',
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'Choose the activity for your resbite. This will help others understand what you\'re planning.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 24),

          // Selected activity card
          if (_selectedActivity != null) _buildSelectedActivityCard(),

          // Activity selection grid
          _buildActivityGrid(),
        ],
      ),
    );
  }

  Widget _buildSelectedActivityCard() {
    return Card(
      margin: const EdgeInsets.only(bottom: 24),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            // Activity image
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child:
                  _selectedActivity!.imageUrl != null
                      ? ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          _selectedActivity!.imageUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Icon(
                              Icons.image,
                              size: 40,
                              color: Theme.of(context).colorScheme.primary,
                            );
                          },
                        ),
                      )
                      : Icon(
                        Icons.image,
                        size: 40,
                        color: Theme.of(context).colorScheme.primary,
                      ),
            ),
            const SizedBox(width: 16),

            // Activity details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _selectedActivity!.title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _selectedActivity!.description ?? 'No description',
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActivityGrid() {
    // If an activity is already selected, show a "change" button
    if (_selectedActivity != null) {
      return Align(
        alignment: Alignment.centerLeft,
        child: TextButton.icon(
          icon: const Icon(Icons.refresh),
          label: const Text('Choose a different activity'),
          onPressed: () {
            setState(() {
              _selectedActivity = null;
            });
          },
        ),
      );
    }

    // Otherwise, show the activity grid
    return Consumer(
      builder: (context, ref, child) {
        final activitiesData = ref.watch(activitiesProvider);

        return activitiesData.when(
          data: (activities) {
            if (activities.isEmpty) {
              return const Center(child: Text('No activities found'));
            }

            return GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 0.8,
              ),
              itemCount: activities.length,
              itemBuilder: (context, index) {
                final activity = activities[index];
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedActivity = activity;
                    });

                    // Update resbite data
                    final resbiteData = ref.read(resbiteDataProvider.notifier);
                    resbiteData.state = {
                      ...resbiteData.state,
                      'activityId': activity.id,
                      'activity': activity,
                      'title': 'Let\'s do ${activity.title}',
                    };
                  },
                  child: Card(
                    clipBehavior: Clip.antiAlias,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Activity image
                        Expanded(
                          child: Container(
                            width: double.infinity,
                            color: AppTheme.primaryColor.withOpacity(0.1),
                            child:
                                activity.imageUrl != null
                                    ? Image.network(
                                      activity.imageUrl!,
                                      fit: BoxFit.cover,
                                      errorBuilder: (
                                        context,
                                        error,
                                        stackTrace,
                                      ) {
                                        return Icon(
                                          Icons.image,
                                          size: 40,
                                          color: AppTheme.primaryColor,
                                        );
                                      },
                                    )
                                    : Icon(
                                      Icons.image,
                                      size: 40,
                                      color: AppTheme.primaryColor,
                                    ),
                          ),
                        ),

                        // Activity title
                        Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Text(
                            activity.title,
                            style: Theme.of(
                              context,
                            ).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: AppTheme.darkTextColor,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, _) => Center(child: Text('Error: $error')),
        );
      },
    );
  }
}

// STEP 2: Basic details
class BasicDetailsPage extends ConsumerStatefulWidget {
  const BasicDetailsPage({super.key});

  @override
  ConsumerState<BasicDetailsPage> createState() => _BasicDetailsPageState();
}

class _BasicDetailsPageState extends ConsumerState<BasicDetailsPage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _attendanceLimitController;
  late final TextEditingController _noteController;
  bool _isPrivate = false;

  @override
  void initState() {
    super.initState();

    // Get values from resbite data provider
    final resbiteData = ref.read(resbiteDataProvider);

    _titleController = TextEditingController(
      text: resbiteData['title'] as String? ?? '',
    );
    _descriptionController = TextEditingController(
      text: resbiteData['description'] as String? ?? '',
    );
    _attendanceLimitController = TextEditingController(
      text:
          resbiteData['attendanceLimit'] != null
              ? resbiteData['attendanceLimit'].toString()
              : '',
    );
    _noteController = TextEditingController(
      text: resbiteData['note'] as String? ?? '',
    );
    _isPrivate = resbiteData['isPrivate'] as bool? ?? false;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _attendanceLimitController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  void _saveBasicDetails() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // Parse attendance limit
    int? attendanceLimit;
    if (_attendanceLimitController.text.isNotEmpty) {
      attendanceLimit = int.tryParse(_attendanceLimitController.text);
    }

    // Update resbite data
    final resbiteData = ref.read(resbiteDataProvider.notifier);
    resbiteData.state = {
      ...resbiteData.state,
      'title': _titleController.text.trim(),
      'description': _descriptionController.text.trim(),
      'attendanceLimit': attendanceLimit,
      'note': _noteController.text.trim(),
      'isPrivate': _isPrivate,
    };
  }

  @override
  Widget build(BuildContext context) {
    // Automatically save when navigating to the next step
    ref.listen(resbiteCreationStepProvider, (previous, next) {
      if (previous == 1 && next != 1) {
        _saveBasicDetails();
      }
    });

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Basic Information',
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Provide some basic information about your resbite.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 24),

            // Title field
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Title',
                hintText: 'Give your resbite a catchy title',
              ),
              maxLength: AppConstants.maxTitleLength,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a title';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Description field
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Description',
                hintText: 'Provide a description of your resbite',
                alignLabelWithHint: true,
              ),
              maxLines: 3,
              maxLength: AppConstants.maxDescriptionLength,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a description';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Attendance limit field
            TextFormField(
              controller: _attendanceLimitController,
              decoration: const InputDecoration(
                labelText: 'Attendance Limit',
                hintText:
                    'Maximum number of participants (leave empty for no limit)',
              ),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value != null && value.isNotEmpty) {
                  final limit = int.tryParse(value);
                  if (limit == null) {
                    return 'Please enter a valid number';
                  }
                  if (limit < 1) {
                    return 'Attendance limit must be at least 1';
                  }
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Notes field
            TextFormField(
              controller: _noteController,
              decoration: const InputDecoration(
                labelText: 'Additional Notes',
                hintText: 'Any additional information for participants',
                alignLabelWithHint: true,
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 16),

            // Privacy toggle
            SwitchListTile(
              title: const Text('Private Resbite'),
              subtitle: const Text('Only visible to invited participants'),
              value: _isPrivate,
              onChanged: (value) {
                setState(() {
                  _isPrivate = value;
                });
              },
            ),
          ],
        ),
      ),
    );
  }
}

// STEP 3: Date and Time
class DateTimePage extends ConsumerStatefulWidget {
  const DateTimePage({super.key});

  @override
  ConsumerState<DateTimePage> createState() => _DateTimePageState();
}

class _DateTimePageState extends ConsumerState<DateTimePage> {
  late DateTime _startDate;
  late DateTime _endDate;
  bool _isMultiDay = false;

  @override
  void initState() {
    super.initState();

    // Get values from resbite data provider
    final resbiteData = ref.read(resbiteDataProvider);

    _startDate =
        resbiteData['startDate'] as DateTime? ??
        DateTime.now().add(const Duration(days: 1));
    _endDate =
        resbiteData['endDate'] as DateTime? ??
        _startDate.add(const Duration(hours: 2));
    _isMultiDay = resbiteData['isMultiDay'] as bool? ?? false;
  }

  Future<void> _selectStartDate() async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _startDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (pickedDate != null) {
      final pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(_startDate),
      );

      if (pickedTime != null) {
        setState(() {
          _startDate = DateTime(
            pickedDate.year,
            pickedDate.month,
            pickedDate.day,
            pickedTime.hour,
            pickedTime.minute,
          );

          // If end date is before start date, update it
          if (_endDate.isBefore(_startDate)) {
            _endDate = _startDate.add(const Duration(hours: 2));
          }
        });
      }
    }
  }

  Future<void> _selectEndDate() async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _endDate.isBefore(_startDate) ? _startDate : _endDate,
      firstDate: _startDate,
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (pickedDate != null) {
      final pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(_endDate),
      );

      if (pickedTime != null) {
        setState(() {
          _endDate = DateTime(
            pickedDate.year,
            pickedDate.month,
            pickedDate.day,
            pickedTime.hour,
            pickedTime.minute,
          );
        });
      }
    }
  }

  void _saveDateTimeInfo() {
    // Update resbite data
    final resbiteData = ref.read(resbiteDataProvider.notifier);
    resbiteData.state = {
      ...resbiteData.state,
      'startDate': _startDate,
      'endDate': _endDate,
      'isMultiDay': _isMultiDay,
    };
  }

  @override
  Widget build(BuildContext context) {
    // Automatically save when navigating to the next step
    ref.listen(resbiteCreationStepProvider, (previous, next) {
      if (previous == 2 && next != 2) {
        _saveDateTimeInfo();
      }
    });

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Date and Time',
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'Choose when your resbite will take place.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 24),

          // Start date and time
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Start Date and Time',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.calendar_today),
                    title: Text(
                      DateFormat('EEEE, MMMM d, yyyy').format(_startDate),
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                    subtitle: Text(DateFormat('h:mm a').format(_startDate)),
                    trailing: OutlinedButton(
                      onPressed: _selectStartDate,
                      child: const Text('Change'),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Multi-day toggle
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Duration',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Multi-day toggle
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Multiple Days'),
                    subtitle: const Text(
                      'Does this resbite span multiple days?',
                    ),
                    value: _isMultiDay,
                    onChanged: (value) {
                      setState(() {
                        _isMultiDay = value;
                      });
                    },
                  ),

                  // End date (shown if multi-day or if on the same day but with specific end time)
                  if (_isMultiDay || _endDate.day == _startDate.day)
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(Icons.event_outlined),
                      title: Text(
                        _isMultiDay ? 'End Date and Time' : 'End Time',
                        style: Theme.of(context).textTheme.titleSmall,
                      ),
                      subtitle: Text(
                        _isMultiDay
                            ? DateFormat(
                              'EEEE, MMMM d, yyyy \'at\' h:mm a',
                            ).format(_endDate)
                            : DateFormat('h:mm a').format(_endDate),
                      ),
                      trailing: OutlinedButton(
                        onPressed: _selectEndDate,
                        child: const Text('Change'),
                      ),
                    ),
                ],
              ),
            ),
          ),

          // Duration summary
          const SizedBox(height: 24),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Summary',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      const Icon(Icons.access_time),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Text(
                          _getDurationText(),
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getDurationText() {
    final duration = _endDate.difference(_startDate);

    if (duration.inDays > 0) {
      return 'This resbite will last for ${duration.inDays} days and ${duration.inHours % 24} hours';
    } else if (duration.inHours > 0) {
      return 'This resbite will last for ${duration.inHours} hours and ${duration.inMinutes % 60} minutes';
    } else {
      return 'This resbite will last for ${duration.inMinutes} minutes';
    }
  }
}

// STEP 4: Location
class LocationPage extends ConsumerStatefulWidget {
  const LocationPage({super.key});

  @override
  ConsumerState<LocationPage> createState() => _LocationPageState();
}

class _LocationPageState extends ConsumerState<LocationPage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _meetingPointController;
  double? _latitude;
  double? _longitude;

  @override
  void initState() {
    super.initState();

    // Get values from resbite data provider
    final resbiteData = ref.read(resbiteDataProvider);

    _meetingPointController = TextEditingController(
      text: resbiteData['meetingPoint'] as String? ?? '',
    );
    _latitude = resbiteData['meetingLatitude'] as double?;
    _longitude = resbiteData['meetingLongitude'] as double?;
  }

  @override
  void dispose() {
    _meetingPointController.dispose();
    super.dispose();
  }

  void _saveLocationInfo() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // Update resbite data
    final resbiteData = ref.read(resbiteDataProvider.notifier);
    resbiteData.state = {
      ...resbiteData.state,
      'meetingPoint': _meetingPointController.text.trim(),
      'meetingLatitude': _latitude,
      'meetingLongitude': _longitude,
    };
  }

  @override
  Widget build(BuildContext context) {
    // Automatically save when navigating to the next step
    ref.listen(resbiteCreationStepProvider, (previous, next) {
      if (previous == 3 && next != 3) {
        _saveLocationInfo();
      }
    });

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Location',
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Specify where participants should meet for the resbite.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 24),

            // Meeting point field
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Meeting Point',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _meetingPointController,
                      decoration: const InputDecoration(
                        hintText: 'Enter a specific meeting location',
                        prefixIcon: Icon(Icons.location_on_outlined),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a meeting point';
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Location map - will be replaced with a real map in future
            Card(
              child: Container(
                height: 200,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.map,
                        size: 64,
                        color: Theme.of(
                          context,
                        ).colorScheme.primary.withOpacity(0.5),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Map view coming soon',
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Location tips
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Tips',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildTip(
                      context,
                      icon: Icons.info_outline,
                      text:
                          'Be specific about the meeting place to avoid confusion',
                    ),
                    const SizedBox(height: 8),
                    _buildTip(
                      context,
                      icon: Icons.lightbulb_outline,
                      text:
                          'Include nearby landmarks to help people find the location',
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTip(
    BuildContext context, {
    required IconData icon,
    required String text,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20),
        const SizedBox(width: 12),
        Expanded(child: Text(text)),
      ],
    );
  }
}

// STEP 5: Invitations
class InvitationsPage extends ConsumerStatefulWidget {
  const InvitationsPage({super.key});

  @override
  ConsumerState<InvitationsPage> createState() => _InvitationsPageState();
}

class _InvitationsPageState extends ConsumerState<InvitationsPage> {
  List<app_user.User> _selectedUsers = [];
  bool _isInvitationEnabled = false;

  @override
  void initState() {
    super.initState();

    // Get values from resbite data provider
    final resbiteData = ref.read(resbiteDataProvider);

    if (resbiteData['invitedUsers'] != null) {
      _selectedUsers = List<app_user.User>.from(
        resbiteData['invitedUsers'] as List,
      );
    }
  }

  void _saveInvitationInfo() {
    // Update resbite data
    final resbiteData = ref.read(resbiteDataProvider.notifier);
    resbiteData.state = {...resbiteData.state, 'invitedUsers': _selectedUsers};
  }

  @override
  Widget build(BuildContext context) {
    // Automatically save when navigating to the next step
    ref.listen(resbiteCreationStepProvider, (previous, next) {
      if (previous == 4 && next != 4) {
        _saveInvitationInfo();
      }
    });

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Invitations',
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'Invite people to join your resbite. You can also do this later.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 24),

          // Enable invitations switch
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(
                      'Send Invitations',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    subtitle: const Text(
                      'Enable to invite specific people to your resbite',
                    ),
                    value: _isInvitationEnabled,
                    onChanged: (value) {
                      setState(() {
                        _isInvitationEnabled = value;
                      });
                    },
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Invitation list - only shown if invitations are enabled
          if (_isInvitationEnabled)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'People to Invite',
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        OutlinedButton.icon(
                          icon: const Icon(Icons.add),
                          label: const Text('Add'),
                          onPressed: () async {
                            final users = await SelectPeopleDialog.show(context, ref);
                            if (users != null && context.mounted) {
                              setState(() {
                                for (final u in users) {
                                  if (!_selectedUsers.any((s) => s.id == u.id)) {
                                    _selectedUsers.add(u);
                                  }
                                }
                              });
                              _saveInvitationInfo();
                            }
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Selected users list
                    _selectedUsers.isEmpty
                        ? const Center(
                          child: Padding(
                            padding: EdgeInsets.symmetric(vertical: 32.0),
                            child: Text('No people selected yet'),
                          ),
                        )
                        : ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: _selectedUsers.length,
                          itemBuilder: (context, index) {
                            final user = _selectedUsers[index];
                            return ListTile(
                              leading: CircleAvatar(
                                backgroundImage:
                                    user.profileImageUrl != null
                                        ? NetworkImage(user.profileImageUrl!)
                                        : null,
                                child:
                                    user.profileImageUrl == null
                                        ? Text(user.displayName?[0] ?? '')
                                        : null,
                              ),
                              title: Text(user.displayName ?? 'Unknown User'),
                              subtitle: Text(user.email),
                              trailing: IconButton(
                                icon: const Icon(Icons.remove_circle_outline),
                                onPressed: () {
                                  setState(() {
                                    _selectedUsers.removeAt(index);
                                  });
                                },
                              ),
                            );
                          },
                        ),
                  ],
                ),
              ),
            ),

          // Invitation notes
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Notes',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildNote(
                    context,
                    icon: Icons.info_outline,
                    text:
                        'Invitations will be sent when you create the resbite',
                  ),
                  const SizedBox(height: 8),
                  _buildNote(
                    context,
                    icon: Icons.lightbulb_outline,
                    text:
                        'You can always invite more people after creating the resbite',
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNote(
    BuildContext context, {
    required IconData icon,
    required String text,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20),
        const SizedBox(width: 12),
        Expanded(child: Text(text)),
      ],
    );
  }
}

// STEP 6: Review
class ReviewPage extends ConsumerStatefulWidget {
  const ReviewPage({super.key});

  @override
  ConsumerState<ReviewPage> createState() => _ReviewPageState();
}

class _ReviewPageState extends ConsumerState<ReviewPage> {
  bool _isLoading = false;
  String? _errorMessage;

  Future<void> _createResbite() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Verify authentication
      final authService = ref.read(authServiceProvider);
      if (authService.status != AuthStatus.authenticated ||
          authService.currentUser == null) {
        throw Exception('You must be logged in to create a resbite');
      }

      // Get resbite data
      final resbiteData = ref.read(resbiteDataProvider);

      // Get user directly from auth service (more reliable)
      final user = authService.currentUser!;

      // Create resbite object
      final resbite = Resbite(
        id: '', // Will be generated by the database
        title: resbiteData['title'] as String,
        description: resbiteData['description'] as String? ?? '',
        startDate: resbiteData['startDate'] as DateTime,
        endDate: resbiteData['endDate'] as DateTime,
        isMultiDay: resbiteData['isMultiDay'] as bool? ?? false,
        meetingPoint: resbiteData['meetingPoint'] as String? ?? '',
        meetingLatitude: resbiteData['meetingLatitude'] as double?,
        meetingLongitude: resbiteData['meetingLongitude'] as double?,
        attendanceLimit: resbiteData['attendanceLimit'] as int?,
        currentAttendance: 1, // Owner is automatically a participant
        note: resbiteData['note'] as String? ?? '',
        status: ResbiteStatus.planned,
        isPrivate: resbiteData['isPrivate'] as bool? ?? false,
        images: [],
        activityId: resbiteData['activityId'] as String?,
        ownerId: user.id,
        placeId: resbiteData['placeId'] as String?,
        activity: resbiteData['activity'] as Activity?,
        owner: user,
        participants: [user],
        createdAt: DateTime.now(),
      );

      // Create resbite
      final resbiteService = ref.read(resbiteServiceProvider);
      final createdResbite = await resbiteService.createResbite(resbite);

      if (createdResbite != null) {
        // Invite selected users if any
        final invitedUsers = resbiteData['invitedUsers'] as List<app_user.User>?;
        if (invitedUsers != null && invitedUsers.isNotEmpty) {
          await resbiteService.inviteUsers(
            createdResbite.id,
            invitedUsers.map((e) => e.id).toList(),
          );
        }

        // Show success message
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Resbite created successfully')),
          );

          // Refresh resbites list
          await resbiteService.refreshResbites();

          // Navigate to resbite details
          Navigator.of(context).pushReplacementNamed(
            '/resbites/details',
            arguments: {'id': createdResbite.id},
          );
        }
      } else {
        setState(() {
          _errorMessage = 'Failed to create resbite';
        });
      }
    } catch (e) {
      AppLogger.error('Failed to create resbite', e);
      setState(() {
        _errorMessage = 'Error: ${e.toString()}';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Get resbite data
    final resbiteData = ref.watch(resbiteDataProvider);

    // Get activity
    final activity = resbiteData['activity'] as Activity?;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Review and Create',
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'Review your resbite details before creating it.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 24),

          // Error message
          if (_errorMessage != null)
            Container(
              padding: const EdgeInsets.all(12),
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.error.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                _errorMessage!,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            ),

          // Activity info
          if (activity != null)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Activity',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            color: Theme.of(
                              context,
                            ).colorScheme.primary.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child:
                              activity.imageUrl != null
                                  ? ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: Image.network(
                                      activity.imageUrl!,
                                      fit: BoxFit.cover,
                                      errorBuilder: (
                                        context,
                                        error,
                                        stackTrace,
                                      ) {
                                        return Icon(
                                          Icons.image,
                                          size: 30,
                                          color:
                                              Theme.of(
                                                context,
                                              ).colorScheme.primary,
                                        );
                                      },
                                    ),
                                  )
                                  : Icon(
                                    Icons.image,
                                    size: 30,
                                    color:
                                        Theme.of(context).colorScheme.primary,
                                  ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                activity.title,
                                style: Theme.of(context).textTheme.titleSmall,
                              ),
                              if (activity.categories.isNotEmpty)
                                Padding(
                                  padding: const EdgeInsets.only(top: 8.0),
                                  child: Wrap(
                                    spacing: 4,
                                    runSpacing: 4,
                                    children:
                                        activity.categories.map((category) {
                                          return Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 8,
                                              vertical: 2,
                                            ),
                                            decoration: BoxDecoration(
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .primary
                                                  .withOpacity(0.1),
                                              borderRadius:
                                                  BorderRadius.circular(4),
                                            ),
                                            child: Text(
                                              category.name,
                                              style: Theme.of(
                                                context,
                                              ).textTheme.bodySmall?.copyWith(
                                                color:
                                                    Theme.of(
                                                      context,
                                                    ).colorScheme.primary,
                                              ),
                                            ),
                                          );
                                        }).toList(),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          const SizedBox(height: 16),

          // Basic details
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Basic Details',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildReviewItem(
                    context,
                    icon: Icons.title,
                    label: 'Title',
                    value: resbiteData['title'] as String? ?? 'N/A',
                  ),
                  const SizedBox(height: 12),
                  _buildReviewItem(
                    context,
                    icon: Icons.description,
                    label: 'Description',
                    value: resbiteData['description'] as String? ?? 'N/A',
                  ),
                  const SizedBox(height: 12),
                  _buildReviewItem(
                    context,
                    icon: Icons.people,
                    label: 'Attendance Limit',
                    value:
                        resbiteData['attendanceLimit'] != null
                            ? resbiteData['attendanceLimit'].toString()
                            : 'No limit',
                  ),
                  const SizedBox(height: 12),
                  _buildReviewItem(
                    context,
                    icon: Icons.visibility,
                    label: 'Visibility',
                    value:
                        (resbiteData['isPrivate'] as bool? ?? false)
                            ? 'Private'
                            : 'Public',
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Date and time
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Date and Time',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildReviewItem(
                    context,
                    icon: Icons.calendar_today,
                    label: 'Start Date',
                    value: DateFormat(
                      'EEEE, MMMM d, yyyy',
                    ).format(resbiteData['startDate'] as DateTime),
                  ),
                  const SizedBox(height: 12),
                  _buildReviewItem(
                    context,
                    icon: Icons.access_time,
                    label: 'Start Time',
                    value: DateFormat(
                      'h:mm a',
                    ).format(resbiteData['startDate'] as DateTime),
                  ),
                  const SizedBox(height: 12),
                  _buildReviewItem(
                    context,
                    icon: Icons.calendar_today,
                    label: 'End Date',
                    value: DateFormat(
                      'EEEE, MMMM d, yyyy',
                    ).format(resbiteData['endDate'] as DateTime),
                  ),
                  const SizedBox(height: 12),
                  _buildReviewItem(
                    context,
                    icon: Icons.access_time,
                    label: 'End Time',
                    value: DateFormat(
                      'h:mm a',
                    ).format(resbiteData['endDate'] as DateTime),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Location
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Location',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildReviewItem(
                    context,
                    icon: Icons.location_on,
                    label: 'Meeting Point',
                    value: resbiteData['meetingPoint'] as String? ?? 'N/A',
                  ),
                ],
              ),
            ),
          ),

          // Create button
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _createResbite,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.accentColor,
                foregroundColor: AppTheme.darkTextColor,
                padding: const EdgeInsets.symmetric(vertical: 16),
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child:
                  _isLoading
                      ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.white,
                          ),
                        ),
                      )
                      : const Text(
                        'Create Resbite',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildReviewItem(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 24),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Text(value, style: Theme.of(context).textTheme.bodyMedium),
            ],
          ),
        ),
      ],
    );
  }
}
