import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Main brand colors based on requirements
  static const Color primaryColor = Color(0xFF89CAC7);     // Teal (#89CAC7)
  static const Color secondaryColor = Color(0xFF462748);   // Purple (#462748)
  static const Color tertiaryColor = Color(0xFFEFB0B4);    // Pink (#EFB0B4)
  static const Color accentColor = tertiaryColor;          // For backward compatibility
  static const Color lightTextColor = Color(0xFFFEFEFE);   // Almost white (#FEFEFE)
  static const Color darkTextColor = Color(0xFF462748);    // Same as secondary (#462748)
  
  // Material Design 3 semantic colors
  static const Color successColor = Color(0xFF43A047);     // Green
  static const Color errorColor = Color(0xFFE53935);       // Red
  static const Color warningColor = Color(0xFFFFA000);     // Amber
  static const Color infoColor = Color(0xFF0288D1);        // Light blue
  
  // Background and surface colors
  static const Color backgroundLightColor = Colors.white;  
  static const Color backgroundDarkColor = Color(0xFF121212); // MD3 recommended dark bg
  static const Color surfaceLightColor = Colors.white;
  static const Color surfaceDarkColor = Color(0xFF1F1F1F); // MD3 recommended dark surface
  
  // MD3 elevation colors
  static Color getSurfaceContainerColor({bool isDark = false}) => 
      isDark ? const Color(0xFF2D2D2D) : const Color(0xFFF5F5F5);
  static Color getSurfaceContainerLowColor({bool isDark = false}) => 
      isDark ? const Color(0xFF252525) : const Color(0xFFF8F8F8);
  static Color getSurfaceContainerHighColor({bool isDark = false}) => 
      isDark ? const Color(0xFF323232) : const Color(0xFFEEEEEE);
      
  // Utility colors
  static const Color disabledColor = Color(0xFFBDBDBD);
  
  // Gradient colors for decorative elements
  static const List<Color> primaryGradient = [
    Color(0xFF89CAC7),                                    // Primary teal
    Color(0xFF7EBAB7),                                    // Slightly darker teal
  ];
  
  static const List<Color> accentGradient = [
    Color(0xFFEFB0B4),                                    // Pink
    Color(0xFFE8A0A4),                                    // Slightly darker pink
  ];

  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    primaryColor: primaryColor,
    colorScheme: ColorScheme.light(
      // Core colors
      primary: primaryColor,
      onPrimary: lightTextColor,
      primaryContainer: primaryColor.withOpacity(0.15),
      onPrimaryContainer: primaryColor.withOpacity(0.8),
      
      // Secondary colors
      secondary: secondaryColor,
      onSecondary: lightTextColor,
      secondaryContainer: secondaryColor.withOpacity(0.15),
      onSecondaryContainer: secondaryColor.withOpacity(0.8),
      
      // Tertiary colors
      tertiary: tertiaryColor,
      onTertiary: darkTextColor,
      tertiaryContainer: tertiaryColor.withOpacity(0.15),
      onTertiaryContainer: tertiaryColor.withOpacity(0.8),
      
      // Error colors
      error: errorColor,
      onError: lightTextColor,
      errorContainer: errorColor.withOpacity(0.15),
      onErrorContainer: errorColor.withOpacity(0.8),
      
      // Background colors
      background: backgroundLightColor,
      onBackground: darkTextColor,
      
      // Surface colors
      surface: surfaceLightColor,
      onSurface: darkTextColor,
      surfaceVariant: getSurfaceContainerColor(),
      onSurfaceVariant: darkTextColor.withOpacity(0.7),
      surfaceTint: primaryColor.withOpacity(0.05),
      
      // Outline and shadow colors
      outline: darkTextColor.withOpacity(0.2),
      outlineVariant: darkTextColor.withOpacity(0.1),
      shadow: Colors.black.withOpacity(0.15),
      scrim: Colors.black.withOpacity(0.3),
      
      // Inverse colors
      inverseSurface: darkTextColor,
      onInverseSurface: lightTextColor,
      inversePrimary: primaryColor.withOpacity(0.8),
    ),
    scaffoldBackgroundColor: backgroundLightColor,
    fontFamily: 'Montserrat',
    textTheme: GoogleFonts.montserratTextTheme(ThemeData.light().textTheme).copyWith(
      // Display styles
      displayLarge: GoogleFonts.montserrat(
        fontWeight: FontWeight.bold,
        fontSize: 57,
        letterSpacing: -0.25,
        color: darkTextColor,
        height: 1.12,
      ),
      displayMedium: GoogleFonts.montserrat(
        fontWeight: FontWeight.bold,
        fontSize: 45,
        letterSpacing: 0,
        color: darkTextColor,
        height: 1.16,
      ),
      displaySmall: GoogleFonts.montserrat(
        fontWeight: FontWeight.bold,
        fontSize: 36,
        letterSpacing: 0,
        color: darkTextColor,
        height: 1.22,
      ),
      
      // Headline styles
      headlineLarge: GoogleFonts.montserrat(
        fontWeight: FontWeight.bold,
        fontSize: 32,
        letterSpacing: 0,
        color: darkTextColor,
        height: 1.25,
      ),
      headlineMedium: GoogleFonts.montserrat(
        fontWeight: FontWeight.bold,
        fontSize: 28,
        letterSpacing: 0,
        color: darkTextColor,
        height: 1.29,
      ),
      headlineSmall: GoogleFonts.montserrat(
        fontWeight: FontWeight.bold,
        fontSize: 24,
        letterSpacing: 0,
        color: darkTextColor,
        height: 1.33,
      ),
      
      // Title styles
      titleLarge: GoogleFonts.montserrat(
        fontWeight: FontWeight.w600,
        fontSize: 22,
        letterSpacing: 0,
        color: darkTextColor,
        height: 1.27,
      ),
      titleMedium: GoogleFonts.montserrat(
        fontWeight: FontWeight.w600,
        fontSize: 16,
        letterSpacing: 0.15,
        color: darkTextColor,
        height: 1.5,
      ),
      titleSmall: GoogleFonts.montserrat(
        fontWeight: FontWeight.w600,
        fontSize: 14,
        letterSpacing: 0.1,
        color: darkTextColor,
        height: 1.43,
      ),
      
      // Body styles
      bodyLarge: GoogleFonts.montserrat(
        fontWeight: FontWeight.normal,
        fontSize: 16,
        letterSpacing: 0.5,
        color: darkTextColor,
        height: 1.5,
      ),
      bodyMedium: GoogleFonts.montserrat(
        fontWeight: FontWeight.normal,
        fontSize: 14,
        letterSpacing: 0.25,
        color: darkTextColor,
        height: 1.43,
      ),
      bodySmall: GoogleFonts.montserrat(
        fontWeight: FontWeight.normal,
        fontSize: 12,
        letterSpacing: 0.4,
        color: darkTextColor.withOpacity(0.8),
        height: 1.33,
      ),
      
      // Label styles
      labelLarge: GoogleFonts.montserrat(
        fontWeight: FontWeight.w600,
        fontSize: 14,
        letterSpacing: 0.1,
        color: darkTextColor,
        height: 1.43,
      ),
      labelMedium: GoogleFonts.montserrat(
        fontWeight: FontWeight.w600,
        fontSize: 12,
        letterSpacing: 0.5,
        color: darkTextColor,
        height: 1.33,
      ),
      labelSmall: GoogleFonts.montserrat(
        fontWeight: FontWeight.w600,
        fontSize: 11,
        letterSpacing: 0.5,
        color: darkTextColor,
        height: 1.45,
      ),
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: surfaceLightColor,
      foregroundColor: darkTextColor,
      elevation: 0,
      centerTitle: true,
      scrolledUnderElevation: 2,
      shadowColor: Colors.black.withOpacity(0.15),
    ),
    // Material 3 Card Theme
    cardTheme: CardTheme(
      color: surfaceLightColor,
      elevation: 0,
      shadowColor: Colors.transparent,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
        side: BorderSide(
          color: darkTextColor.withOpacity(0.08),
          width: 1,
        ),
      ),
    ),
    
    // Material 3 Button Themes
    // Filled Button (primary action)
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryColor,
        foregroundColor: lightTextColor,
        padding: const EdgeInsets.symmetric(vertical: 14.0, horizontal: 24.0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0),
        ),
        elevation: 0,
        shadowColor: Colors.transparent,
        minimumSize: const Size(64, 40),
        textStyle: GoogleFonts.montserrat(
          fontWeight: FontWeight.w600,
          fontSize: 14,
          letterSpacing: 0.1,
        ),
      ),
    ),
    
    // Outlined Button (secondary action)
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: primaryColor,
        side: BorderSide(color: primaryColor, width: 1),
        padding: const EdgeInsets.symmetric(vertical: 14.0, horizontal: 24.0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0),
        ),
        minimumSize: const Size(64, 40),
        textStyle: GoogleFonts.montserrat(
          fontWeight: FontWeight.w600,
          fontSize: 14,
          letterSpacing: 0.1,
        ),
      ),
    ),
    
    // Text Button (tertiary action)
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: primaryColor,
        padding: const EdgeInsets.symmetric(vertical: 14.0, horizontal: 16.0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0),
        ),
        minimumSize: const Size(48, 40),
        textStyle: GoogleFonts.montserrat(
          fontWeight: FontWeight.w600,
          fontSize: 14,
          letterSpacing: 0.1,
        ),
      ),
    ),
    
    // FilledButton (accent/alternate primary action)
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: tertiaryColor,
        foregroundColor: darkTextColor,
        padding: const EdgeInsets.symmetric(vertical: 14.0, horizontal: 24.0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0),
        ),
        elevation: 0,
        minimumSize: const Size(64, 40),
        textStyle: GoogleFonts.montserrat(
          fontWeight: FontWeight.w600,
          fontSize: 14,
          letterSpacing: 0.1,
        ),
      ),
    ),
    // Material 3 Input Decoration Theme
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: getSurfaceContainerLowColor(),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.0),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.0),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.0),
        borderSide: BorderSide(color: primaryColor, width: 1.0),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.0),
        borderSide: BorderSide(color: errorColor, width: 1.0),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
      floatingLabelBehavior: FloatingLabelBehavior.auto,
      prefixIconColor: darkTextColor.withOpacity(0.6),
      suffixIconColor: darkTextColor.withOpacity(0.6),
      hintStyle: GoogleFonts.montserrat(
        color: darkTextColor.withOpacity(0.5),
        fontSize: 14,
      ),
      labelStyle: GoogleFonts.montserrat(
        color: darkTextColor.withOpacity(0.7),
        fontSize: 14,
        fontWeight: FontWeight.w500,
      ),
      floatingLabelStyle: GoogleFonts.montserrat(
        color: primaryColor,
        fontSize: 14,
        fontWeight: FontWeight.w600,
      ),
      helperStyle: GoogleFonts.montserrat(
        color: darkTextColor.withOpacity(0.6),
        fontSize: 12,
      ),
      errorStyle: GoogleFonts.montserrat(
        color: errorColor,
        fontSize: 12,
      ),
    ),
    
    // Material 3 Switch Theme
    switchTheme: SwitchThemeData(
      thumbColor: MaterialStateProperty.resolveWith<Color>((Set<MaterialState> states) {
        if (states.contains(MaterialState.disabled)) {
          return disabledColor;
        }
        if (states.contains(MaterialState.selected)) {
          return primaryColor;
        }
        return Colors.white;
      }),
      trackColor: MaterialStateProperty.resolveWith<Color>((Set<MaterialState> states) {
        if (states.contains(MaterialState.disabled)) {
          return disabledColor.withOpacity(0.12);
        }
        if (states.contains(MaterialState.selected)) {
          return primaryColor.withOpacity(0.3);
        }
        return darkTextColor.withOpacity(0.08);
      }),
      trackOutlineColor: MaterialStateProperty.resolveWith<Color>((Set<MaterialState> states) {
        if (states.contains(MaterialState.disabled)) {
          return disabledColor.withOpacity(0.12);
        }
        if (states.contains(MaterialState.selected)) {
          return Colors.transparent;
        }
        return darkTextColor.withOpacity(0.12);
      }),
      thumbIcon: MaterialStateProperty.resolveWith<Icon?>((Set<MaterialState> states) {
        if (states.contains(MaterialState.selected)) {
          return const Icon(Icons.check, size: 12, color: Colors.white);
        }
        return null;
      }),
    ),
    
    // Material 3 Checkbox Theme
    checkboxTheme: CheckboxThemeData(
      fillColor: MaterialStateProperty.resolveWith<Color>((Set<MaterialState> states) {
        if (states.contains(MaterialState.disabled)) {
          return disabledColor;
        }
        if (states.contains(MaterialState.selected)) {
          return primaryColor;
        }
        return Colors.transparent;
      }),
      checkColor: MaterialStateProperty.all(Colors.white),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(2.0),
      ),
      side: BorderSide(
        width: 1.5, 
        color: darkTextColor.withOpacity(0.5),
      ),
    ),
    // Material 3 Tab Bar Theme
    tabBarTheme: TabBarTheme(
      labelColor: primaryColor,
      unselectedLabelColor: darkTextColor.withOpacity(0.6),
      indicatorColor: primaryColor,
      indicatorSize: TabBarIndicatorSize.tab,
      dividerColor: Colors.transparent,
      labelStyle: GoogleFonts.montserrat(
        fontWeight: FontWeight.w600,
        fontSize: 14,
      ),
      unselectedLabelStyle: GoogleFonts.montserrat(
        fontWeight: FontWeight.w500,
        fontSize: 14,
      ),
      overlayColor: MaterialStateProperty.resolveWith<Color>((Set<MaterialState> states) {
        if (states.contains(MaterialState.pressed)) {
          return primaryColor.withOpacity(0.1);
        }
        return Colors.transparent;
      }),
    ),
    
    // Material 3 Bottom Navigation Bar Theme
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: surfaceLightColor,
      selectedItemColor: primaryColor,
      unselectedItemColor: darkTextColor.withOpacity(0.6),
      type: BottomNavigationBarType.fixed,
      elevation: 3,
      selectedLabelStyle: GoogleFonts.montserrat(
        fontSize: 12,
        fontWeight: FontWeight.w600,
      ),
      unselectedLabelStyle: GoogleFonts.montserrat(
        fontSize: 12,
        fontWeight: FontWeight.w500,
      ),
      landscapeLayout: BottomNavigationBarLandscapeLayout.centered,
    ),
    
    // Navigation Bar (Material 3's preferred bottom nav)
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: surfaceLightColor,
      surfaceTintColor: Colors.transparent,
      indicatorColor: primaryColor.withOpacity(0.1),
      iconTheme: MaterialStateProperty.resolveWith<IconThemeData>((Set<MaterialState> states) {
        if (states.contains(MaterialState.selected)) {
          return IconThemeData(color: primaryColor);
        }
        return IconThemeData(color: darkTextColor.withOpacity(0.6));
      }),
      labelTextStyle: MaterialStateProperty.resolveWith<TextStyle>((Set<MaterialState> states) {
        if (states.contains(MaterialState.selected)) {
          return GoogleFonts.montserrat(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: primaryColor,
          );
        }
        return GoogleFonts.montserrat(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: darkTextColor.withOpacity(0.6),
        );
      }),
      elevation: 3,
      height: 60,
      labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
    ),
    
    // Material 3 Divider Theme
    dividerTheme: DividerThemeData(
      color: darkTextColor.withOpacity(0.12),
      thickness: 1,
      space: 24,
      indent: 0,
      endIndent: 0,
    ),
    // Material 3 Chip Theme
    chipTheme: ChipThemeData(
      backgroundColor: primaryColor.withOpacity(0.1),
      disabledColor: disabledColor.withOpacity(0.1),
      selectedColor: primaryColor,
      secondarySelectedColor: secondaryColor,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      labelStyle: GoogleFonts.montserrat(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: darkTextColor,
        height: 1.3,
      ),
      secondaryLabelStyle: GoogleFonts.montserrat(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: lightTextColor,
        height: 1.3,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      side: BorderSide.none,
      shadowColor: Colors.transparent,
      surfaceTintColor: Colors.transparent,
      iconTheme: IconThemeData(
        color: darkTextColor,
        size: 18,
      ),
      checkmarkColor: lightTextColor,
      deleteIconColor: darkTextColor.withOpacity(0.7),
    ),
    
    // Material 3 Dialog Theme
    dialogTheme: DialogTheme(
      backgroundColor: surfaceLightColor,
      elevation: 3,
      shadowColor: Colors.black.withOpacity(0.2),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(28),
      ),
      alignment: Alignment.center,
      titleTextStyle: GoogleFonts.montserrat(
        fontSize: 24,
        fontWeight: FontWeight.w600,
        color: darkTextColor,
        height: 1.2,
      ),
      contentTextStyle: GoogleFonts.montserrat(
        fontSize: 16,
        color: darkTextColor.withOpacity(0.8),
        height: 1.5,
      ),
      surfaceTintColor: Colors.transparent,
    ),
    
    // Material 3 Floating Action Button Theme
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: tertiaryColor,
      foregroundColor: darkTextColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(16)),
      ),
      elevation: 3,
      focusElevation: 2,
      hoverElevation: 4,
      disabledElevation: 0,
      highlightElevation: 2,
      enableFeedback: true,
      sizeConstraints: const BoxConstraints.tightFor(
        width: 56,
        height: 56,
      ),
      iconSize: 24,
      extendedIconLabelSpacing: 12,
      extendedPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      extendedSizeConstraints: const BoxConstraints.tightForFinite(
        width: double.infinity,
        height: 56,
      ),
      extendedTextStyle: GoogleFonts.montserrat(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: darkTextColor,
        letterSpacing: 0.1,
      ),
    ),
    
    // Material 3 Segmented Button Theme
    segmentedButtonTheme: SegmentedButtonThemeData(
      style: ButtonStyle(
        backgroundColor: MaterialStateProperty.resolveWith<Color>((Set<MaterialState> states) {
          if (states.contains(MaterialState.selected)) {
            return primaryColor;
          }
          return surfaceLightColor;
        }),
        foregroundColor: MaterialStateProperty.resolveWith<Color>((Set<MaterialState> states) {
          if (states.contains(MaterialState.selected)) {
            return lightTextColor;
          }
          return darkTextColor;
        }),
        side: MaterialStateProperty.all(BorderSide(
          color: primaryColor,
          width: 1,
        )),
        shape: MaterialStateProperty.all(RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        )),
        padding: MaterialStateProperty.all(
          const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        ),
        textStyle: MaterialStateProperty.all(GoogleFonts.montserrat(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.1,
        )),
      ),
    ),
  );
  
  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    primaryColor: primaryColor,
    colorScheme: ColorScheme.dark(
      primary: primaryColor,
      secondary: accentColor,
      tertiary: secondaryColor,
      error: errorColor,
      background: backgroundDarkColor,
      surface: surfaceDarkColor,
      onPrimary: lightTextColor,
      onSecondary: darkTextColor,
      onTertiary: lightTextColor,
      onBackground: lightTextColor,
      onSurface: lightTextColor,
      onError: lightTextColor,
    ),
    scaffoldBackgroundColor: backgroundDarkColor,
    fontFamily: 'Montserrat',
    textTheme: GoogleFonts.montserratTextTheme(ThemeData.dark().textTheme).copyWith(
      displayLarge: GoogleFonts.montserrat(
        fontWeight: FontWeight.bold,
        fontSize: 32,
        letterSpacing: -0.5,
        color: lightTextColor,
      ),
      displayMedium: GoogleFonts.montserrat(
        fontWeight: FontWeight.bold,
        fontSize: 28,
        letterSpacing: -0.5,
        color: lightTextColor,
      ),
      displaySmall: GoogleFonts.montserrat(
        fontWeight: FontWeight.bold,
        fontSize: 24,
        letterSpacing: 0,
        color: lightTextColor,
      ),
      headlineLarge: GoogleFonts.montserrat(
        fontWeight: FontWeight.bold,
        fontSize: 22,
        letterSpacing: 0,
        color: lightTextColor,
      ),
      headlineMedium: GoogleFonts.montserrat(
        fontWeight: FontWeight.bold,
        fontSize: 20,
        letterSpacing: 0,
        color: lightTextColor,
      ),
      headlineSmall: GoogleFonts.montserrat(
        fontWeight: FontWeight.bold,
        fontSize: 18,
        letterSpacing: 0,
        color: lightTextColor,
      ),
      titleLarge: GoogleFonts.montserrat(
        fontWeight: FontWeight.bold,
        fontSize: 18,
        letterSpacing: 0,
        color: lightTextColor,
      ),
      titleMedium: GoogleFonts.montserrat(
        fontWeight: FontWeight.w600,
        fontSize: 16,
        letterSpacing: 0.15,
        color: lightTextColor,
      ),
      titleSmall: GoogleFonts.montserrat(
        fontWeight: FontWeight.w600,
        fontSize: 14,
        letterSpacing: 0.1,
        color: lightTextColor,
      ),
      bodyLarge: GoogleFonts.montserrat(
        fontWeight: FontWeight.normal,
        fontSize: 16,
        letterSpacing: 0.5,
        color: lightTextColor,
      ),
      bodyMedium: GoogleFonts.montserrat(
        fontWeight: FontWeight.normal,
        fontSize: 14,
        letterSpacing: 0.25,
        color: lightTextColor,
      ),
      bodySmall: GoogleFonts.montserrat(
        fontWeight: FontWeight.normal,
        fontSize: 12,
        letterSpacing: 0.4,
        color: lightTextColor.withOpacity(0.8),
      ),
      labelLarge: GoogleFonts.montserrat(
        fontWeight: FontWeight.w600,
        fontSize: 14,
        letterSpacing: 1.25,
        color: lightTextColor,
      ),
      labelMedium: GoogleFonts.montserrat(
        fontWeight: FontWeight.w600,
        fontSize: 12,
        letterSpacing: 1.0,
        color: lightTextColor,
      ),
      labelSmall: GoogleFonts.montserrat(
        fontWeight: FontWeight.w600,
        fontSize: 10,
        letterSpacing: 1.5,
        color: lightTextColor,
      ),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: primaryColor,
      foregroundColor: lightTextColor,
      elevation: 0,
      centerTitle: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          bottom: Radius.circular(16),
        ),
      ),
    ),
    cardTheme: CardTheme(
      color: surfaceDarkColor,
      elevation: 1.5,
      shadowColor: Colors.black.withOpacity(0.3),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.0),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryColor,
        foregroundColor: lightTextColor,
        padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 24.0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0),
        ),
        elevation: 2,
        shadowColor: primaryColor.withOpacity(0.4),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: primaryColor,
        side: const BorderSide(color: primaryColor, width: 1.5),
        padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 24.0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0),
        ),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: primaryColor,
        padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 24.0),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: surfaceDarkColor.withOpacity(0.7),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.0),
        borderSide: BorderSide(color: Colors.grey.shade700, width: 1.0),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.0),
        borderSide: BorderSide(color: Colors.grey.shade700, width: 1.0),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.0),
        borderSide: const BorderSide(color: primaryColor, width: 2.0),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.0),
        borderSide: const BorderSide(color: errorColor, width: 1.5),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
      floatingLabelBehavior: FloatingLabelBehavior.auto,
      prefixIconColor: Colors.grey.shade400,
      suffixIconColor: Colors.grey.shade400,
      hintStyle: GoogleFonts.montserrat(
        color: Colors.grey.shade500,
        fontSize: 14,
      ),
      labelStyle: GoogleFonts.montserrat(
        color: Colors.grey.shade400,
        fontSize: 14,
        fontWeight: FontWeight.w500,
      ),
      floatingLabelStyle: GoogleFonts.montserrat(
        color: primaryColor,
        fontSize: 14,
        fontWeight: FontWeight.w600,
      ),
    ),
    switchTheme: SwitchThemeData(
      thumbColor: MaterialStateProperty.resolveWith<Color>((Set<MaterialState> states) {
        if (states.contains(MaterialState.disabled)) {
          return disabledColor;
        }
        if (states.contains(MaterialState.selected)) {
          return primaryColor;
        }
        return Colors.white;
      }),
      trackColor: MaterialStateProperty.resolveWith<Color>((Set<MaterialState> states) {
        if (states.contains(MaterialState.disabled)) {
          return disabledColor.withOpacity(0.48);
        }
        if (states.contains(MaterialState.selected)) {
          return primaryColor.withOpacity(0.48);
        }
        return Colors.grey.withOpacity(0.48);
      }),
      trackOutlineColor: MaterialStateProperty.all(Colors.transparent),
    ),
    checkboxTheme: CheckboxThemeData(
      fillColor: MaterialStateProperty.resolveWith<Color>((Set<MaterialState> states) {
        if (states.contains(MaterialState.disabled)) {
          return disabledColor;
        }
        if (states.contains(MaterialState.selected)) {
          return primaryColor;
        }
        return Colors.transparent;
      }),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(4.0),
      ),
    ),
    tabBarTheme: TabBarTheme(
      labelColor: primaryColor,
      unselectedLabelColor: Colors.grey.shade400,
      indicatorColor: primaryColor,
      indicatorSize: TabBarIndicatorSize.label,
      labelStyle: GoogleFonts.montserrat(
        fontWeight: FontWeight.w600,
        fontSize: 14,
      ),
      unselectedLabelStyle: GoogleFonts.montserrat(
        fontWeight: FontWeight.w500,
        fontSize: 14,
      ),
    ),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: surfaceDarkColor,
      selectedItemColor: primaryColor,
      unselectedItemColor: Colors.grey.shade400,
      type: BottomNavigationBarType.fixed,
      elevation: 8,
      selectedLabelStyle: GoogleFonts.montserrat(
        fontSize: 12,
        fontWeight: FontWeight.w600,
      ),
      unselectedLabelStyle: GoogleFonts.montserrat(
        fontSize: 12,
        fontWeight: FontWeight.w500,
      ),
    ),
    dividerTheme: DividerThemeData(
      color: Colors.grey.shade800,
      thickness: 1,
      space: 32,
    ),
    chipTheme: ChipThemeData(
      backgroundColor: Colors.grey.shade800,
      disabledColor: Colors.grey.shade700,
      selectedColor: primaryColor.withOpacity(0.3),
      secondarySelectedColor: primaryColor,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      labelStyle: GoogleFonts.montserrat(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: lightTextColor,
      ),
      secondaryLabelStyle: GoogleFonts.montserrat(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: primaryColor,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
    ),
    dialogTheme: DialogTheme(
      backgroundColor: surfaceDarkColor,
      elevation: 8,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      titleTextStyle: GoogleFonts.montserrat(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: lightTextColor,
      ),
      contentTextStyle: GoogleFonts.montserrat(
        fontSize: 16,
        color: lightTextColor,
      ),
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: accentColor,
      foregroundColor: darkTextColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
    ),
  );
  
  // Helper methods for gradients and shadows
  static BoxDecoration gradientBoxDecoration({
    bool primary = true,
    double borderRadius = 16.0,
  }) {
    return BoxDecoration(
      gradient: LinearGradient(
        colors: primary ? primaryGradient : accentGradient,
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      borderRadius: BorderRadius.circular(borderRadius),
      boxShadow: [
        BoxShadow(
          color: primary ? primaryColor.withOpacity(0.3) : accentColor.withOpacity(0.3),
          spreadRadius: 1,
          blurRadius: 10,
          offset: const Offset(0, 4),
        ),
      ],
    );
  }
  
  static BoxDecoration cardBoxDecoration({
    required BuildContext context,
    double borderRadius = 16.0,
    double elevation = 1.5,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return BoxDecoration(
      color: isDark ? surfaceDarkColor : surfaceLightColor,
      borderRadius: BorderRadius.circular(borderRadius),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(isDark ? 0.3 : 0.1),
          spreadRadius: 0,
          blurRadius: elevation * 3,
          offset: const Offset(0, 2),
        ),
      ],
    );
  }
  
  // Specific helper for primary background with white text
  static BoxDecoration primaryWithLightTextDecoration({
    double borderRadius = 16.0,
  }) {
    return BoxDecoration(
      color: primaryColor,
      borderRadius: BorderRadius.circular(borderRadius),
      boxShadow: [
        BoxShadow(
          color: primaryColor.withOpacity(0.3),
          spreadRadius: 1,
          blurRadius: 10,
          offset: const Offset(0, 4),
        ),
      ],
    );
  }
  
  // Specific helper for white background with purple text
  static BoxDecoration whiteWithDarkTextDecoration({
    double borderRadius = 16.0,
  }) {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(borderRadius),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.1),
          spreadRadius: 0,
          blurRadius: 6,
          offset: const Offset(0, 2),
        ),
      ],
    );
  }
  
  // Accent (pink) decoration
  static BoxDecoration accentDecoration({
    double borderRadius = 16.0,
  }) {
    return BoxDecoration(
      color: accentColor,
      borderRadius: BorderRadius.circular(borderRadius),
      boxShadow: [
        BoxShadow(
          color: accentColor.withOpacity(0.3),
          spreadRadius: 1,
          blurRadius: 10,
          offset: const Offset(0, 4),
        ),
      ],
    );
  }
}