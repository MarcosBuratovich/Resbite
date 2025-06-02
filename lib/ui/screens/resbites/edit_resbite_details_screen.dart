import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../services/providers.dart';
import '../../../utils/logger.dart';

class EditResbiteDetailsScreen extends ConsumerStatefulWidget {
  final String resbiteId;
  const EditResbiteDetailsScreen({Key? key, required this.resbiteId}) : super(key: key);

  @override
  ConsumerState<EditResbiteDetailsScreen> createState() => _EditResbiteDetailsScreenState();
}

class _EditResbiteDetailsScreenState extends ConsumerState<EditResbiteDetailsScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late TextEditingController _attendanceLimitController;
  late TextEditingController _noteController;
  bool _isPrivate = false;
  bool _initialized = false;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _attendanceLimitController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final resbiteAsync = ref.watch(resbiteDetailProvider(widget.resbiteId));

    return resbiteAsync.when(
      data: (resbite) {
        if (resbite == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('Edit Resbite')),
            body: const Center(child: Text('Resbite not found')),
          );
        }

        if (!_initialized) {
          _initialized = true;
          _titleController = TextEditingController(text: resbite.title);
          _descriptionController = TextEditingController(text: resbite.description ?? '');
          _attendanceLimitController = TextEditingController(text: resbite.attendanceLimit?.toString() ?? '');
          _noteController = TextEditingController(text: resbite.note ?? '');
          _isPrivate = resbite.isPrivate;
        }

        return Scaffold(
          appBar: AppBar(title: const Text('Edit Resbite')),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextFormField(
                    controller: _titleController,
                    decoration: const InputDecoration(labelText: 'Title'),
                    validator: (value) => value == null || value.isEmpty ? 'Title is required' : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _descriptionController,
                    decoration: const InputDecoration(labelText: 'Description'),
                    maxLines: null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _attendanceLimitController,
                    decoration: const InputDecoration(labelText: 'Attendance Limit'),
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _noteController,
                    decoration: const InputDecoration(labelText: 'Note'),
                    maxLines: null,
                  ),
                  const SizedBox(height: 16),
                  SwitchListTile(
                    title: const Text('Private'),
                    value: _isPrivate,
                    onChanged: (value) {
                      setState(() => _isPrivate = value);
                    },
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () async {
                      if (!_formKey.currentState!.validate()) return;
                      try {
                        final service = ref.read(resbiteServiceProvider);
                        // Build updated Resbite and call service
                        final updatedResbite = resbite.copyWith(
                          title: _titleController.text.trim(),
                          description: _descriptionController.text.trim(),
                          attendanceLimit: int.tryParse(_attendanceLimitController.text),
                          note: _noteController.text.trim(),
                          isPrivate: _isPrivate,
                        );
                        final updated = await service.updateResbite(updatedResbite);
                        if (updated != null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Resbite updated successfully')),
                          );
                          Navigator.of(context).pop(updated);
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Failed to update resbite')),
                          );
                        }
                      } catch (e, stack) {
                        AppLogger.error('Error updating resbite', e, stack);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Error: $e')),
                        );
                      }
                    },
                    child: const Text('Save'),
                  ),
                ],
              ),
            ),
          ),
        );
      },
      loading: () => Scaffold(
        appBar: AppBar(title: Text('Edit Resbite')),
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (error, stack) => Scaffold(
        appBar: AppBar(title: const Text('Edit Resbite')),
        body: Center(child: Text('Error: $error')),
      ),
    );
  }
}
