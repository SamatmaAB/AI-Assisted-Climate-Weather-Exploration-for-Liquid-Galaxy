import 'package:flutter/material.dart';

const ColorScheme appDarkColorScheme = ColorScheme(
  brightness: Brightness.dark,

  primary: Color(0xFF9ECEFF),
  onPrimary: Color(0xFF00325B),
  primaryContainer: Color(0xFF00497D),
  onPrimaryContainer: Color(0xFFD1E4FF),

  secondary: Color(0xFF76D69B),
  onSecondary: Color(0xFF00391C),
  secondaryContainer: Color(0xFF00522B),
  onSecondaryContainer: Color(0xFF92F3B5),

  tertiary: Color(0xFFFFB86B),
  onTertiary: Color(0xFF492800),
  tertiaryContainer: Color(0xFF693C00),
  onTertiaryContainer: Color(0xFFFFDCC2),

  error: Color(0xFFFFB4AB),
  onError: Color(0xFF690005),
  errorContainer: Color(0xFF93000A),
  onErrorContainer: Color(0xFFFFDAD6),

  surface: Color(0xFF0F141C),
  onSurface: Color(0xFFE1E2E9),
  onSurfaceVariant: Color(0xFFC2C7D3),

  outline: Color(0xFF8C919D),
  outlineVariant: Color(0xFF424750),

  inverseSurface: Color(0xFFE1E2E9),
  onInverseSurface: Color(0xFF2E3038),
  inversePrimary: Color(0xFF00639B),

  shadow: Color(0xFF000000),
  scrim: Color(0xFF000000),
);

const ColorScheme appLightColorScheme = ColorScheme(
  brightness: Brightness.light,

  primary: Color(0xFF00639B),
  onPrimary: Color(0xFFFFFFFF),
  primaryContainer: Color(0xFFD1E4FF),
  onPrimaryContainer: Color(0xFF00325B),

  secondary: Color(0xFF006D3D),
  onSecondary: Color(0xFFFFFFFF),
  secondaryContainer: Color(0xFF92F3B5),
  onSecondaryContainer: Color(0xFF00391C),

  tertiary: Color(0xFF8B5000),
  onTertiary: Color(0xFFFFFFFF),
  tertiaryContainer: Color(0xFFFFDCC2),
  onTertiaryContainer: Color(0xFF492800),

  error: Color(0xFFBA1A1A),
  onError: Color(0xFFFFFFFF),
  errorContainer: Color(0xFFFFDAD6),
  onErrorContainer: Color(0xFF410002),

  surface: Color(0xFFF8F9FF),
  onSurface: Color(0xFF191C20),
  onSurfaceVariant: Color(0xFF43474E),

  outline: Color(0xFF73777F),
  outlineVariant: Color(0xFFC3C7CF),

  inverseSurface: Color(0xFF2E3038),
  onInverseSurface: Color(0xFFEFF0F7),
  inversePrimary: Color(0xFF9ECEFF),

  shadow: Color(0xFF000000),
  scrim: Color(0xFF000000),
);

const ColorScheme appColorblindDarkColorScheme = ColorScheme(
  brightness: Brightness.dark,

  primary: Color(0xFF9ECEFF),
  onPrimary: Color(0xFF00325B),
  primaryContainer: Color(0xFF00497D),
  onPrimaryContainer: Color(0xFFD1E4FF),

  secondary: Color(0xFFFFB86B),
  onSecondary: Color(0xFF492800),
  secondaryContainer: Color(0xFF693C00),
  onSecondaryContainer: Color(0xFFFFDCC2),

  tertiary: Color(0xFFFFE57A),
  onTertiary: Color(0xFF3D2E00),
  tertiaryContainer: Color(0xFF584400),
  onTertiaryContainer: Color(0xFFFFEFA0),

  error: Color(0xFFFFB4AB),
  onError: Color(0xFF690005),
  errorContainer: Color(0xFF93000A),
  onErrorContainer: Color(0xFFFFDAD6),

  surface: Color(0xFF0F141C),
  onSurface: Color(0xFFE1E2E9),
  onSurfaceVariant: Color(0xFFC2C7D3),

  outline: Color(0xFF8C919D),
  outlineVariant: Color(0xFF424750),

  inverseSurface: Color(0xFFE1E2E9),
  onInverseSurface: Color(0xFF2E3038),
  inversePrimary: Color(0xFF00639B),

  shadow: Color(0xFF000000),
  scrim: Color(0xFF000000),
);

const ColorScheme appColorblindLightColorScheme = ColorScheme(
  brightness: Brightness.light,

  primary: Color(0xFF00639B),
  onPrimary: Color(0xFFFFFFFF),
  primaryContainer: Color(0xFFD1E4FF),
  onPrimaryContainer: Color(0xFF00325B),

  secondary: Color(0xFF8B5000),
  onSecondary: Color(0xFFFFFFFF),
  secondaryContainer: Color(0xFFFFDCC2),
  onSecondaryContainer: Color(0xFF492800),

  tertiary: Color(0xFF6B5C00),
  onTertiary: Color(0xFFFFFFFF),
  tertiaryContainer: Color(0xFFFFEFA0),
  onTertiaryContainer: Color(0xFF3D2E00),

  error: Color(0xFFBA1A1A),
  onError: Color(0xFFFFFFFF),
  errorContainer: Color(0xFFFFDAD6),
  onErrorContainer: Color(0xFF410002),

  surface: Color(0xFFF8F9FF),
  onSurface: Color(0xFF191C20),
  onSurfaceVariant: Color(0xFF43474E),

  outline: Color(0xFF73777F),
  outlineVariant: Color(0xFFC3C7CF),

  inverseSurface: Color(0xFF2E3038),
  onInverseSurface: Color(0xFFEFF0F7),
  inversePrimary: Color(0xFF9ECEFF),

  shadow: Color(0xFF000000),
  scrim: Color(0xFF000000),
);

extension AppColorSchemeExtension on ColorScheme {
  /// Lighter green used for success banners / snackbars.
  Color get bannerSuccess =>
      brightness == Brightness.dark ? const Color(0xFF1B5E3A) : const Color(0xFFB7F0CC);

  /// Lighter red used for error banners / snackbars.
  Color get bannerError =>
      brightness == Brightness.dark ? const Color(0xFF5E1418) : const Color(0xFFFFC9C4);
}

