import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../models/event_draft.dart';
import '../../../models/event.dart';
import '../../../services/providers.dart';
import '../friends/services/services.dart' as friends_services;
import '../events/services/event_service.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

/// Quick placeholder multi-step wizard.
class CreateEventWizardScreen extends ConsumerStatefulWidget {
  final Event? event;
  const CreateEventWizardScreen({Key? key, this.event}) : super(key: key);

  @override
  ConsumerState<CreateEventWizardScreen> createState() => _CreateEventWizardScreenState();
}

class _CreateEventWizardScreenState extends ConsumerState<CreateEventWizardScreen> {
  _CreateEventWizardScreenState();
  final PageController _pageController = PageController();
  int _step = 0;
  late EventDraft _draft;
  bool get _isEditing => widget.event != null;

  @override
  void initState() {
    super.initState();
    _draft = EventDraft();
    if (widget.event != null) {
      final e = widget.event!;
      _draft
        ..title = e.title
        ..description = e.description
        ..startAt = e.startAt
        ..endAt = e.endAt
        ..isPrivate = e.isPrivate;
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _next() async {
    if (_step == 0) {
      // Validate details
      if (!_draft.isValidStep1) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please fill title and times')));
        return;
      }
    }

    if (_step < 2) {
      setState(() {
        _step++;
      });
      _pageController.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
      return;
    }

    // Final step – create event & invitations
    final scaffold = ScaffoldMessenger.of(context);
    try {
      scaffold.showSnackBar(SnackBar(content: Text(_isEditing ? 'Updating event...' : 'Creating event...')));
      final service = ref.read(eventServiceProvider);
      final userId = ref.read(currentUserIdProvider);
      if (userId == null) throw Exception('You must be signed in');
      final now = DateTime.now();
      final String eventId = _isEditing ? widget.event!.id : const Uuid().v4();
      final event = Event(
        id: eventId,
        title: _draft.title!.trim(),
        description: _draft.description?.trim(),
        startAt: _draft.startAt ?? now,
        endAt: _draft.endAt ?? now.add(const Duration(hours: 2)),
        isPrivate: _draft.isPrivate,
        createdBy: _isEditing ? widget.event!.createdBy : userId,
        createdAt: _isEditing ? widget.event!.createdAt : now,
        updatedAt: now,
      );
      if (_isEditing) {
        await service.updateEvent(event);
      } else {
        await service.createEvent(event);
      }
      if (!_isEditing) {
        // Create invitations
        for (final inviteeId in _draft.inviteeIds) {
          await service.inviteUser(event.id, inviteeId);
        }
      }
      scaffold.hideCurrentSnackBar();
      scaffold.showSnackBar(SnackBar(content: Text(_isEditing ? 'Event updated!' : 'Event created!')));
      Navigator.of(context).pop();
    } catch (e) {
      scaffold.hideCurrentSnackBar();
      scaffold.showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Create Event (Step ${_step + 1}/3)')),
      body: PageView(
        controller: _pageController,
        physics: const NeverScrollableScrollPhysics(),
        children: [
          _DetailsStep(draft: _draft),
          _LocationStep(draft: _draft),
          _InviteStep(draft: _draft),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _next,
        child: Icon(_step == 2 ? Icons.check : Icons.arrow_forward),
      ),
    );
  }
}

class _DetailsStep extends StatefulWidget {
  final EventDraft draft;
  const _DetailsStep({required this.draft});

  @override
  State<_DetailsStep> createState() => _DetailsStepState();
}

class _DetailsStepState extends State<_DetailsStep> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _titleController.text = widget.draft.title ?? '';
    _descController.text = widget.draft.description ?? '';
  }

  void _pickDateTime({required bool isStart}) async {
    final now = DateTime.now();
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: now,
      lastDate: now.add(const Duration(days: 365)),
    );
    if (picked != null) {
      final TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(now),
      );
      if (pickedTime != null) {
        final DateTime pickedDateTime = DateTime(picked.year, picked.month, picked.day, pickedTime.hour, pickedTime.minute);
        setState(() {
          if (isStart) {
            widget.draft.startAt = pickedDateTime;
          } else {
            widget.draft.endAt = pickedDateTime;
          }
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final dateFmt = DateFormat.yMMMEd().add_Hm();
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: _titleController,
            decoration: const InputDecoration(labelText: 'Title'),
            onChanged: (v) => widget.draft.title = v,
          ),
          TextField(
            controller: _descController,
            decoration: const InputDecoration(labelText: 'Description'),
            onChanged: (v) => widget.draft.description = v,
          ),
          const SizedBox(height: 16),
          ListTile(
            leading: const Icon(Icons.play_arrow),
            title: const Text('Start'),
            subtitle: Text(widget.draft.startAt != null ? dateFmt.format(widget.draft.startAt!) : 'Select start date & time'),
            onTap: () => _pickDateTime(isStart: true),
          ),
          ListTile(
            leading: const Icon(Icons.stop),
            title: const Text('End'),
            subtitle: Text(widget.draft.endAt != null ? dateFmt.format(widget.draft.endAt!) : 'Select end date & time'),
            onTap: () => _pickDateTime(isStart: false),
          ),
          SwitchListTile(
            title: const Text('Private event'),
            value: widget.draft.isPrivate,
            onChanged: (v) => setState(() => widget.draft.isPrivate = v),
          ),
        ],
      ),
    );
  }
}

// -------------------- Location Step --------------------
class _LocationStep extends StatefulWidget {
  final EventDraft draft;
  const _LocationStep({required this.draft});

  @override
  State<_LocationStep> createState() => _LocationStepState();
}

class _LocationStepState extends State<_LocationStep> {
  late final TextEditingController _locationController;

  @override
  void initState() {
    super.initState();
    _locationController = TextEditingController(text: widget.draft.locationName);
  }

  @override
  void dispose() {
    _locationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: _locationController,
            decoration: const InputDecoration(labelText: 'Location (optional)'),
            onChanged: (v) => widget.draft.locationName = v,
          ),
          const SizedBox(height: 8),
          Text('More precise location selection will be available soon.', style: Theme.of(context).textTheme.bodySmall),
        ],
      ),
    );
  }
}

// -------------------- Invite Step --------------------
class _InviteStep extends ConsumerStatefulWidget {
  final EventDraft draft;
  const _InviteStep({required this.draft});

  @override
  ConsumerState<_InviteStep> createState() => _InviteStepState();
}

class _InviteStepState extends ConsumerState<_InviteStep> {
  @override
  Widget build(BuildContext context) {
    final friendsAsync = ref.watch(friends_services.directFriendsProvider);
    return friendsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Error: $e')),
      data: (friends) {
        if (friends.isEmpty) {
          return const Center(child: Text('No friends yet – add friends first.'));
        }
        return ListView.builder(
          itemCount: friends.length,
          itemBuilder: (context, index) {
            final fc = friends[index];
            final id = fc.user.id;
            final selected = widget.draft.inviteeIds.contains(id);
            return CheckboxListTile(
              value: selected,
              title: Text(fc.user.displayName ?? fc.user.email),
              subtitle: Text(fc.user.email),
              onChanged: (val) {
                setState(() {
                  if (val == true) {
                    widget.draft.inviteeIds.add(id);
                  } else {
                    widget.draft.inviteeIds.remove(id);
                  }
                });
              },
            );
          },
        );
      },
    );
  }
}

