import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../utils/logger.dart';
import '../login_screen.dart';
import 'pages/additional_info_page.dart';
import 'pages/credentials_page.dart';
import 'pages/date_of_birth_page.dart';
import 'pages/name_page.dart';
import 'pages/profile_image_page.dart';
import 'pages/review_page.dart';
import 'providers/register_providers.dart';
import 'services/register_service.dart';

/// Pantalla principal para el registro de usuarios
class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  /// Gestiona el paso actual del registro
  late final PageController _pageController;

  /// Lista de páginas del flujo de registro
  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();

    // Inicializar el controlador de página
    _pageController = ref.read(pageControllerProvider);

    // Inicializar las páginas con los componentes modulares
    _pages = [
      DateOfBirthPage(onNext: _goToNextStep, onBack: _navigateToLogin),
      NamePage(onNext: _goToNextStep, onBack: _goToPreviousStep),
      CredentialsPage(onNext: _goToNextStep, onBack: _goToPreviousStep),
      ProfileImagePage(onNext: _goToNextStep, onBack: _goToPreviousStep),
      AdditionalInfoPage(onNext: _goToNextStep, onBack: _goToPreviousStep),
      ReviewPage(onSubmit: _submitRegistration, onBack: _goToPreviousStep),
    ];

    // Asegurarse que el estado inicial sea consistente
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(registrationStepProvider.notifier).state = 0;
      ref.read(isSubmittingProvider.notifier).state = false;
      // Ensure we have a fresh registration data instance
      ref.read(registrationDataProvider);
      ref.read(registrationErrorProvider.notifier).state = null;
    });
  }

  @override
  void dispose() {
    // No es necesario disponer el _pageController ya que lo maneja el provider
    super.dispose();
  }

  /// Avanza al siguiente paso del registro
  void _goToNextStep() {
    final currentStep = ref.read(registrationStepProvider);
    if (currentStep < _pages.length - 1) {
      // Actualizar el estado
      ref.read(registrationStepProvider.notifier).state = currentStep + 1;

      // Animar a la siguiente página
      _pageController.animateToPage(
        currentStep + 1,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  /// Regresa al paso anterior del registro
  void _goToPreviousStep() {
    final currentStep = ref.read(registrationStepProvider);
    if (currentStep > 0) {
      // Actualizar el estado
      ref.read(registrationStepProvider.notifier).state = currentStep - 1;

      // Animar a la página anterior
      _pageController.animateToPage(
        currentStep - 1,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      // Si estamos en el primer paso, navegar a la pantalla de login
      _navigateToLogin();
    }
  }

  /// Navega a la pantalla de login
  void _navigateToLogin() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => const LoginScreen()),
    );
  }

  /// Procesa el envío del formulario de registro
  Future<void> _submitRegistration(BuildContext buildContext) async {
    // Indicar que estamos procesando (opcional, puede ser manejado completamente por el servicio)
    // ref.read(isSubmittingProvider.notifier).state = true; // Service already handles this
    // ref.read(registrationErrorProvider.notifier).state = null; // Service already handles this

    final registerService = ref.read(registerServiceProvider);

    try {
      final success = await registerService.registerWithStoredData();

      if (success) {
        // Mostrar mensaje de éxito
        if (mounted) {
          ScaffoldMessenger.of(buildContext).showSnackBar(
            const SnackBar(
              content: Text('Registro completado correctamente'),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 3),
            ),
          );
          _navigateToHome(buildContext); // Navegar a la pantalla principal
        }
      } else {
        // El error ya debería estar en registrationErrorProvider por el servicio
        // Mostrar mensaje de error (opcionalmente, si el provider no dispara un listener)
        if (mounted) {
          final errorMessage = ref.read(registrationErrorProvider);
          ScaffoldMessenger.of(buildContext).showSnackBar(
            SnackBar(
              content: Text(errorMessage ?? 'Error en el registro. Intente de nuevo.'),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 3),
            ),
          );
        }
      }
    } catch (e) {
      // Esto es un fallback, el servicio debería manejar la mayoría de los errores
      AppLogger.error('Unhandled registration error in UI', e);
      if (mounted) {
        ref.read(isSubmittingProvider.notifier).state = false;
        ref.read(registrationErrorProvider.notifier).state = e.toString();
        ScaffoldMessenger.of(buildContext).showSnackBar(
          SnackBar(
            content: Text('Error inesperado: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
    // El servicio ya gestiona isSubmittingProvider a false en éxito o error
  }

  /// Navega a la pantalla de inicio después de un registro exitoso
  void _navigateToHome(BuildContext buildContext) {
    // TODO: Implementar la navegación a la pantalla de inicio adecuada
    // Por ejemplo, si tienes una ruta '/home':
    // Navigator.of(buildContext).pushNamedAndRemoveUntil('/home', (route) => false);

    // Por ahora, volvemos a login como placeholder
    AppLogger.info('Registro exitoso, navegando a la pantalla de login (placeholder para home)');
    Navigator.of(buildContext).pushReplacement(
      MaterialPageRoute(builder: (context) => const LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentStep = ref.watch(registrationStepProvider);
    final isLoading = ref.watch(isSubmittingProvider);

    // Escuchar cambios en el proveedor de errores para mostrar SnackBar
    // Esto es útil si el error se establece en el servicio y queremos reaccionar en la UI
    ref.listen<String?>(registrationErrorProvider, (previous, next) {
      if (next != null && next.isNotEmpty && previous != next) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next),
            backgroundColor: Colors.red,
          ),
        );
        // Opcional: resetear el error después de mostrarlo para no mostrarlo de nuevo
        // ref.read(registrationErrorProvider.notifier).state = null;
      }
    });

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(currentStep == 0 ? Icons.close : Icons.arrow_back),
          onPressed: currentStep == 0 ? _navigateToLogin : _goToPreviousStep,
        ),
        title: const Text('Crear Cuenta'),
        actions: [
          if (isLoading) // Muestra un indicador de carga en el AppBar
            const Padding(
              padding: EdgeInsets.only(right: 16.0),
              child: Center(child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))),
            )
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Indicador de progreso
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
              child: LinearProgressIndicator(
                value: (currentStep + 1) / _pages.length,
                backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
                valueColor: AlwaysStoppedAnimation<Color>(
                  Theme.of(context).colorScheme.primary,
                ),
              ),
            ),
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(), // Deshabilitar swipe
                itemCount: _pages.length,
                itemBuilder: (context, index) {
                  return _pages[index];
                },
                onPageChanged: (index) {
                  // Esto puede no ser necesario si la navegación es solo por botones
                  // ref.read(registrationStepProvider.notifier).state = index;
                },
              ),
            ),
            // Mostrar mensaje de error global si existe
            // if (errorMessage != null && errorMessage.isNotEmpty && !isLoading) // Se maneja con SnackBar
            //   Padding(
            //     padding: const EdgeInsets.all(16.0),
            //     child: Text(
            //       errorMessage,
            //       style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
            //       textAlign: TextAlign.center,
            //     ),
            //   ),
          ],
        ),
      ),
    );
  }
}
