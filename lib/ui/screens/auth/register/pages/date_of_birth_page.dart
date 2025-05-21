import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../../../ui/components/resbite_button.dart';
import '../providers/register_providers.dart';
import '../utils/validation_utils.dart';

/// Página para capturar la fecha de nacimiento durante el registro
class DateOfBirthPage extends ConsumerStatefulWidget {
  /// Callback para avanzar al siguiente paso
  final VoidCallback onNext;
  
  /// Callback para regresar al paso anterior (login)
  final VoidCallback onBack;

  const DateOfBirthPage({
    required this.onNext,
    required this.onBack,
    super.key,
  });

  @override
  ConsumerState<DateOfBirthPage> createState() => _DateOfBirthPageState();
}

class _DateOfBirthPageState extends ConsumerState<DateOfBirthPage> {
  final TextEditingController _dobController = TextEditingController();
  DateTime? _selectedDate;
  bool _showAgeError = false;

  @override
  void initState() {
    super.initState();
    // Pre-fill from provider if available
    final registrationData = ref.read(registrationDataProvider);
    if (registrationData.dateOfBirth != null) {
      _selectedDate = registrationData.dateOfBirth;
      _dobController.text = DateFormat('MM/dd/yyyy').format(_selectedDate!);
      _validateAge();
    }
  }

  @override
  void dispose() {
    _dobController.dispose();
    super.dispose();
  }

  /// Muestra el selector de fecha
  Future<void> _selectDate(BuildContext context) async {
    final DateTime now = DateTime.now();
    final DateTime minDate = DateTime(
      now.year - 100,
      now.month,
      now.day,
    ); // 100 years ago
    final DateTime maxDate = DateTime(
      now.year - 16,
      now.month,
      now.day,
    ); // 16 years ago

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? maxDate,
      firstDate: minDate,
      lastDate: now,
      helpText: 'SELECT DATE OF BIRTH',
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Theme.of(context).colorScheme.primary,
              onPrimary: Colors.white,
              surface: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        _dobController.text = DateFormat('MM/dd/yyyy').format(_selectedDate!);

        // Update provider
        final registrationNotifier = ref.read(registrationDataProvider.notifier);
        registrationNotifier.setDateOfBirth(_selectedDate);

        // Check age
        _validateAge();
      });
    }
  }

  /// Valida que el usuario tenga la edad mínima requerida
  void _validateAge() {
    if (_selectedDate != null) {
      final error = RegistrationValidator.validateDateOfBirth(_selectedDate);
      setState(() {
        _showAgeError = error != null;
      });
    }
  }

  /// Avanza al siguiente paso si la fecha es válida
  void _continueToNext() {
    if (_selectedDate != null) {
      final error = RegistrationValidator.validateDateOfBirth(_selectedDate);
      if (error == null) {
        widget.onNext();
      } else {
        setState(() {
          _showAgeError = true;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title
          Text(
            'When were you born?',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          const SizedBox(height: 16),

          // Subtitle
          Text(
            'You must be at least 16 years old to use Resbite.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 32),

          // Date of birth field
          TextFormField(
            controller: _dobController,
            decoration: InputDecoration(
              labelText: 'Date of Birth',
              hintText: 'MM/DD/YYYY',
              prefixIcon: const Icon(Icons.calendar_today),
              suffixIcon: IconButton(
                icon: const Icon(Icons.event),
                onPressed: () => _selectDate(context),
              ),
              errorText: _showAgeError ? 'You must be at least 16 years old' : null,
            ),
            readOnly: true,
            onTap: () => _selectDate(context),
          ),
          const SizedBox(height: 8),

          // Age display
          if (_selectedDate != null && !_showAgeError) _buildAgeDisplay(context),

          const Spacer(),

          // Continue button
          ResbiteButton(
            text: 'Continue',
            icon: Icons.arrow_forward,
            type: ResbiteBtnType.gradient,
            size: ResbiteBtnSize.large,
            fullWidth: true,
            onPressed: _selectedDate != null ? _continueToNext : null,
          ),
        ],
      ),
    );
  }
  
  /// Construye el widget que muestra la edad calculada
  Widget _buildAgeDisplay(BuildContext context) {
    final now = DateTime.now();
    final age = now.year - _selectedDate!.year - 
        (now.month > _selectedDate!.month || 
        (now.month == _selectedDate!.month && now.day >= _selectedDate!.day) ? 0 : 1);
        
    return Padding(
      padding: const EdgeInsets.only(top: 8.0),
      child: Text(
        'You are $age years old',
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }
}
