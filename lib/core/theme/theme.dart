import 'package:flutter/material.dart';

class AppTheme {
  AppTheme._();

  static const MaterialColor primarySwatch =
      MaterialColor(_primarySwatchPrimaryValue, <int, Color>{
        50: Color(0xFFE8EEFB),
        100: Color(0xFFCAD7E7),
        200: Color(0xFFADBBCF),
        300: Color(0xFF8FA0B8),
        400: Color(0xFF788CA6),
        500: Color(_primarySwatchPrimaryValue),
        600: Color(0xFF536A84),
        700: Color(0xFF43566D),
        800: Color(0xFF344457),
        900: Color(0xFF222F3F),
      });
  static const int _primarySwatchPrimaryValue = 0xFF617895;

  static final ColorScheme _lightScheme = ColorScheme.light(
    primary: AppColors.lightSidebarSelected,
    onPrimary: AppColors.textOnColoredCards,
    secondary: AppColors.lightConnectNowButton,
    onSecondary: AppColors.textOnColoredCards,
    surface: AppColors.lightCardBackground,
    onSurface: AppColors.lightTextPrimary,
    error: Colors.redAccent.shade200,
    onError: Colors.white,
  );

  static final ColorScheme _darkScheme = ColorScheme.dark(
    primary: AppColors.statCardBlue,
    onPrimary: AppColors.textOnColoredCards,
    secondary: AppColors.darkConnectNowButton,
    onSecondary: Colors.black,
    surface: AppColors.darkCardBackground,
    onSurface: AppColors.darkTextPrimary,

    error: Colors.redAccent.shade100,
    onError: Colors.black,
  );

  static final ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    colorScheme: _lightScheme,
    scaffoldBackgroundColor: AppColors.lightScaffoldBackground,
    fontFamily: 'Poppins',

    appBarTheme: AppBarTheme(
      backgroundColor: AppColors.lightHeaderBackground,
      elevation: 0,
      centerTitle: true,
      iconTheme: IconThemeData(color: AppColors.lightIconColor),
      titleTextStyle: TextStyle(
        color: AppColors.lightTextPrimary,
        fontSize: 20,
        fontWeight: FontWeight.bold,
        fontFamily: 'Poppins',
      ),
      toolbarHeight: 56,
    ),

    iconTheme: IconThemeData(color: AppColors.lightIconColor),

    cardTheme: CardThemeData(
      color: AppColors.lightCardBackground,
      elevation: 3,
      shadowColor: AppColors.cardShadow,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    ),

    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.lightCardBackground,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: _lightScheme.primary, width: 1.5),
      ),
      hintStyle: TextStyle(color: Colors.grey.shade500, fontFamily: 'Poppins'),
    ),

    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.lightConnectNowButton,
        foregroundColor: AppColors.textOnColoredCards,
        minimumSize: Size(120, 50),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        elevation: 1,
        textStyle: const TextStyle(
          fontFamily: 'Poppins',
          fontWeight: FontWeight.bold,
          fontSize: 15,
        ),
      ),
    ),

    navigationRailTheme: NavigationRailThemeData(
      backgroundColor: AppColors.lightSidebarBackground,
      selectedIconTheme: IconThemeData(color: AppColors.lightSidebarSelected),
      unselectedIconTheme: IconThemeData(
        color: AppColors.lightIconColor.withValues(alpha: 0.7),
      ),
      selectedLabelTextStyle: TextStyle(
        color: AppColors.lightSidebarSelected,
        fontWeight: FontWeight.bold,
        fontFamily: 'Poppins',
        fontSize: 12,
      ),
      unselectedLabelTextStyle: TextStyle(
        color: AppColors.lightIconColor.withValues(alpha: 0.7),
        fontFamily: 'Poppins',
        fontSize: 12,
      ),
      indicatorColor: AppColors.lightSidebarSelected.withValues(alpha: 0.1),
      elevation: 1,
    ),

    listTileTheme: ListTileThemeData(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      tileColor: AppColors.lightCardBackground,
      selectedTileColor: AppColors.lightSidebarSelected.withValues(alpha: 0.1),
      iconColor: AppColors.lightIconColor,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      horizontalTitleGap: 12,
    ),

    shadowColor: AppColors.cardShadow,

    textTheme: TextTheme(
      headlineMedium: TextStyle(
        fontFamily: 'Poppins',
        fontSize: 22,
        fontWeight: FontWeight.w700,
        color: _lightScheme.onSurface,
      ),

      titleMedium: TextStyle(
        fontFamily: 'Poppins',
        fontSize: 20,
        fontWeight: FontWeight.w500,
        color: AppColors.lightTextSecondary,
      ),

      titleSmall: TextStyle(
        fontFamily: 'Poppins',
        fontSize: 15,
        fontWeight: FontWeight.w600,
        color: AppColors.textOnColoredCards,
      ),

      displaySmall: TextStyle(
        fontFamily: 'Poppins',
        fontSize: 28,
        fontWeight: FontWeight.bold,
        color: AppColors.textOnColoredCards,
      ),

      bodyLarge: TextStyle(
        fontFamily: 'Poppins',
        fontSize: 15,
        color: AppColors.lightTextPrimary,
      ),
      bodyMedium: TextStyle(
        fontFamily: 'Poppins',
        fontSize: 13,
        color: AppColors.lightTextSecondary,
      ),

      labelLarge: TextStyle(
        fontFamily: 'Poppins',
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: AppColors.lightTextPrimary,
      ),

      headlineLarge: TextStyle(
        fontFamily: 'Poppins',
        fontSize: 32,
        fontWeight: FontWeight.w700,
        color: AppColors.lightTextPrimary,
      ),
      titleLarge: TextStyle(
        fontFamily: 'Poppins',
        fontSize: 26,
        fontWeight: FontWeight.w700,
        color: AppColors.lightTextPrimary,
      ),
    ),
  );

  static final ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: _darkScheme,
    scaffoldBackgroundColor: AppColors.darkScaffoldBackground,
    fontFamily: 'Poppins',

    appBarTheme: AppBarTheme(
      backgroundColor: AppColors.darkHeaderBackground,
      elevation: 0,
      centerTitle: true,
      iconTheme: IconThemeData(color: AppColors.darkIconColor),
      titleTextStyle: TextStyle(
        color: AppColors.darkTextPrimary,
        fontSize: 20,
        fontWeight: FontWeight.bold,
        fontFamily: 'Poppins',
      ),
      toolbarHeight: 56,
    ),

    iconTheme: IconThemeData(color: AppColors.darkIconColor),

    cardTheme: CardThemeData(
      color: AppColors.darkCardBackground,
      elevation: 1,
      shadowColor: Colors.black.withValues(alpha: 0.3),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    ),

    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.darkInputFill,
      // contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: Colors.white24.withValues(alpha: 0.2)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: Colors.white24.withValues(alpha: 0.2)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: _darkScheme.primary, width: 1.5),
      ),
      hintStyle: TextStyle(color: Colors.white60, fontFamily: 'Poppins'),
    ),

    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.darkConnectNowButton,
        foregroundColor: Colors.black,
        minimumSize: Size(120, 50),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        elevation: 1,
        textStyle: const TextStyle(
          fontFamily: 'Poppins',
          fontWeight: FontWeight.bold,
          fontSize: 15,
        ),
      ),
    ),

    navigationRailTheme: NavigationRailThemeData(
      backgroundColor: AppColors.darkSidebarBackground,
      selectedIconTheme: IconThemeData(color: AppColors.darkSidebarSelected),
      unselectedIconTheme: IconThemeData(
        color: AppColors.darkIconColor.withValues(alpha: 0.7),
      ),
      selectedLabelTextStyle: TextStyle(
        color: AppColors.darkSidebarSelected,
        fontWeight: FontWeight.bold,
        fontFamily: 'Poppins',
        fontSize: 12,
      ),
      unselectedLabelTextStyle: TextStyle(
        color: AppColors.darkIconColor.withValues(alpha: 0.7),
        fontFamily: 'Poppins',
        fontSize: 12,
      ),
      indicatorColor: AppColors.darkSidebarSelected.withValues(alpha: 0.15),
      elevation: 1,
    ),

    listTileTheme: ListTileThemeData(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      tileColor: AppColors.darkCardBackground,
      selectedTileColor: AppColors.darkSidebarSelected.withValues(alpha: 0.15),
      iconColor: AppColors.darkIconColor,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      horizontalTitleGap: 12,
    ),

    shadowColor: Colors.black.withValues(alpha: 0.4),

    textTheme: TextTheme(
      headlineMedium: TextStyle(
        fontFamily: 'Poppins',
        fontSize: 22,
        fontWeight: FontWeight.bold,
        color: _darkScheme.onSurface,
      ),
      titleMedium: TextStyle(
        fontFamily: 'Poppins',
        fontSize: 20,
        fontWeight: FontWeight.normal,
        color: AppColors.darkTextSecondary,
      ),
      titleSmall: TextStyle(
        fontFamily: 'Poppins',
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: AppColors.textOnColoredCards,
      ),
      displaySmall: TextStyle(
        fontFamily: 'Poppins',
        fontSize: 28,
        fontWeight: FontWeight.bold,
        color: AppColors.textOnColoredCards,
      ),
      bodyLarge: TextStyle(
        fontFamily: 'Poppins',
        fontSize: 15,
        color: AppColors.darkTextPrimary,
      ),
      bodyMedium: TextStyle(
        fontFamily: 'Poppins',
        fontSize: 13,
        color: AppColors.darkTextSecondary,
      ),
      labelLarge: TextStyle(
        fontFamily: 'Poppins',
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: AppColors.darkTextPrimary,
      ),
      headlineLarge: TextStyle(
        fontFamily: 'Poppins',
        fontSize: 32,
        fontWeight: FontWeight.w700,
        color: AppColors.darkTextPrimary,
      ),
      titleLarge: TextStyle(
        fontFamily: 'Poppins',
        fontSize: 26,
        fontWeight: FontWeight.w700,
        color: AppColors.darkTextPrimary,
      ),
    ),
  );
}

class AppColors {
  AppColors._();

  static const background = Color(0xFFF5F7FA);
  static const cardShadow = Colors.black12;

  static const white = Colors.white;

  static const lightScaffoldBackground = Color(0xFFF4F6F8);
  static const lightCardBackground = Colors.white;
  static const lightHeaderBackground = Color(0xFFF4F6F8);
  static const lightSidebarBackground = Colors.white;
  static const lightSidebarSelected = Color(0xFF5C6BC0);
  static const lightConnectNowButton = Color(0xFF26A69A);
  static const lightTextPrimary = Color(0xFF333333);
  static const lightTextSecondary = Color(0xFF555555);
  static const lightIconColor = Color(0xFF555555);

  static const darkScaffoldBackground = Color(0xFF030C1B);
  static const darkCardBackground = Color(0xFF171A3B);
  static const darkHeaderBackground = Color(0xFF1E1E2F);
  static const darkSidebarBackground = Color(0xFF171A3B);
  static const darkSidebarSelected = Color(0xFFFFD54F);
  static const darkConnectNowButton = Color(0xFF4DB6AC);
  static const darkTextPrimary = Color(0xFFE0E0E0);
  static const darkTextSecondary = Color(0xFFFFFFFF);
  static const darkIconColor = Color(0xFFE0E0E0);
  static const darkInputFill = Color(0xFF3A3A5A);

  static const statCardBlue = Color(0xFF5C6BC0);
  static const statCardPinkRed = Color(0xFFEF5350);
  static const statCardPurple = Color(0xFFAB47BC);

  static const textOnColoredCards = Colors.white;
}
