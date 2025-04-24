import 'package:flutter/material.dart';

/// Tailwind-like color configuration for the Resbite app.
/// This provides easy access to the color palette to use throughout the app.
class TwColors {
  // Brand Colors
  static const Color primary = Color(0xFF89CAC7);     // Teal (#89CAC7)
  static const Color secondary = Color(0xFF462748);   // Purple (#462748)
  static const Color tertiary = Color(0xFFEFB0B4);    // Pink (#EFB0B4)
  
  // Standard Tailwind-like grayscale
  static const Color slate50 = Color(0xFFF8FAFC);
  static const Color slate100 = Color(0xFFF1F5F9);
  static const Color slate200 = Color(0xFFE2E8F0);
  static const Color slate300 = Color(0xFFCBD5E1);
  static const Color slate400 = Color(0xFF94A3B8);
  static const Color slate500 = Color(0xFF64748B);
  static const Color slate600 = Color(0xFF475569);
  static const Color slate700 = Color(0xFF334155);
  static const Color slate800 = Color(0xFF1E293B);
  static const Color slate900 = Color(0xFF0F172A);
  static const Color slate950 = Color(0xFF020617);
  
  // Semantic Colors
  static const Color success = Color(0xFF10B981); // Emerald 500
  static const Color warning = Color(0xFFF59E0B); // Amber 500
  static const Color error = Color(0xFFEF4444);   // Red 500
  static const Color info = Color(0xFF3B82F6);    // Blue 500
  
  // Text Colors
  static const Color textLight = Color(0xFFFEFEFE); // Light text
  static const Color textDark = Color(0xFF462748);  // Dark text (same as secondary)
}

/// Extension methods to apply Tailwind-like properties to widgets
extension TwExtensions on Widget {
  // Padding shortcuts
  Widget get p0 => Padding(padding: const EdgeInsets.all(0), child: this);
  Widget get p1 => Padding(padding: const EdgeInsets.all(4), child: this);
  Widget get p2 => Padding(padding: const EdgeInsets.all(8), child: this);
  Widget get p3 => Padding(padding: const EdgeInsets.all(12), child: this);
  Widget get p4 => Padding(padding: const EdgeInsets.all(16), child: this);
  Widget get p5 => Padding(padding: const EdgeInsets.all(20), child: this);
  Widget get p6 => Padding(padding: const EdgeInsets.all(24), child: this);
  Widget get p8 => Padding(padding: const EdgeInsets.all(32), child: this);
  
  // Margin shortcuts
  Widget get m0 => Container(margin: const EdgeInsets.all(0), child: this);
  Widget get m1 => Container(margin: const EdgeInsets.all(4), child: this);
  Widget get m2 => Container(margin: const EdgeInsets.all(8), child: this);
  Widget get m3 => Container(margin: const EdgeInsets.all(12), child: this);
  Widget get m4 => Container(margin: const EdgeInsets.all(16), child: this);
  Widget get m5 => Container(margin: const EdgeInsets.all(20), child: this);
  Widget get m6 => Container(margin: const EdgeInsets.all(24), child: this);
  Widget get m8 => Container(margin: const EdgeInsets.all(32), child: this);
  
  // Rounded corners
  Widget get rounded => ClipRRect(borderRadius: BorderRadius.circular(8), child: this);
  Widget get roundedMd => ClipRRect(borderRadius: BorderRadius.circular(12), child: this);
  Widget get roundedLg => ClipRRect(borderRadius: BorderRadius.circular(16), child: this);
  Widget get roundedXl => ClipRRect(borderRadius: BorderRadius.circular(24), child: this);
  Widget get roundedFull => ClipRRect(borderRadius: BorderRadius.circular(9999), child: this);
  
  // Shadow variants
  Widget get shadow => Container(
    decoration: BoxDecoration(
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.1),
          blurRadius: 4,
          offset: const Offset(0, 2),
        ),
      ],
    ),
    child: this,
  );
  
  Widget get shadowMd => Container(
    decoration: BoxDecoration(
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.1),
          blurRadius: 8,
          offset: const Offset(0, 4),
        ),
      ],
    ),
    child: this,
  );
  
  Widget get shadowLg => Container(
    decoration: BoxDecoration(
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.15),
          blurRadius: 16,
          offset: const Offset(0, 8),
        ),
      ],
    ),
    child: this,
  );
}

/// Text styles with Tailwind-like naming
class TwTypography {
  static TextStyle heading1(BuildContext context) => Theme.of(context).textTheme.displayLarge!;
  static TextStyle heading2(BuildContext context) => Theme.of(context).textTheme.displayMedium!;
  static TextStyle heading3(BuildContext context) => Theme.of(context).textTheme.displaySmall!;
  static TextStyle heading4(BuildContext context) => Theme.of(context).textTheme.headlineMedium!;
  static TextStyle heading5(BuildContext context) => Theme.of(context).textTheme.headlineSmall!;
  static TextStyle heading6(BuildContext context) => Theme.of(context).textTheme.titleLarge!;
  
  static TextStyle body(BuildContext context) => Theme.of(context).textTheme.bodyLarge!;
  static TextStyle bodySm(BuildContext context) => Theme.of(context).textTheme.bodyMedium!;
  static TextStyle bodyXs(BuildContext context) => Theme.of(context).textTheme.bodySmall!;
  
  static TextStyle label(BuildContext context) => Theme.of(context).textTheme.labelLarge!;
  static TextStyle labelSm(BuildContext context) => Theme.of(context).textTheme.labelMedium!;
  static TextStyle labelXs(BuildContext context) => Theme.of(context).textTheme.labelSmall!;
}

/// Create a ThemeData using Tailwind-like values
ThemeData createTailwindTheme({bool isDark = false}) {
  final ColorScheme colorScheme = ColorScheme(
    brightness: isDark ? Brightness.dark : Brightness.light,
    primary: TwColors.primary,
    onPrimary: TwColors.textLight,
    primaryContainer: TwColors.primary.withOpacity(0.2),
    onPrimaryContainer: TwColors.primary,
    secondary: TwColors.secondary,
    onSecondary: TwColors.textLight,
    secondaryContainer: TwColors.secondary.withOpacity(0.2),
    onSecondaryContainer: TwColors.secondary,
    tertiary: TwColors.tertiary,
    onTertiary: TwColors.textDark,
    tertiaryContainer: TwColors.tertiary.withOpacity(0.2),
    onTertiaryContainer: TwColors.tertiary,
    error: TwColors.error,
    onError: TwColors.textLight,
    errorContainer: TwColors.error.withOpacity(0.2),
    onErrorContainer: TwColors.error,
    background: isDark ? TwColors.slate900 : TwColors.slate50,
    onBackground: isDark ? TwColors.textLight : TwColors.textDark,
    surface: isDark ? TwColors.slate800 : Colors.white,
    onSurface: isDark ? TwColors.textLight : TwColors.textDark,
    surfaceTint: TwColors.primary.withOpacity(0.05),
    surfaceVariant: isDark ? TwColors.slate700 : TwColors.slate100,
    onSurfaceVariant: isDark ? TwColors.slate300 : TwColors.slate700,
    outline: isDark ? TwColors.slate600 : TwColors.slate300,
    outlineVariant: isDark ? TwColors.slate700 : TwColors.slate200,
    shadow: Colors.black,
    scrim: Colors.black,
    inverseSurface: isDark ? Colors.white : TwColors.slate900,
    onInverseSurface: isDark ? TwColors.textDark : TwColors.textLight,
    inversePrimary: TwColors.primary.withOpacity(0.8),
  );
  
  return ThemeData(
    useMaterial3: true,
    colorScheme: colorScheme,
    fontFamily: 'Montserrat',
    scaffoldBackgroundColor: colorScheme.background,
    appBarTheme: AppBarTheme(
      backgroundColor: colorScheme.surface,
      foregroundColor: colorScheme.onSurface,
      elevation: 0,
      centerTitle: false,
      scrolledUnderElevation: 2,
      shadowColor: colorScheme.shadow.withOpacity(0.15),
    ),
  );
}