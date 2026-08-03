import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'app_color_scheme.dart';
import 'app_typography.dart';
import 'theme_controller.dart';

/// Central Material Design 3 theme for Earth Systems Explorer.
///
/// All application-level styling flows from this [ThemeData].
/// Individual screens and widgets must NOT override global theme properties
/// with inline styles where the theme default already provides the correct value.
abstract final class AppTheme {
  /// Selects the correct [ThemeData] based on current [ThemeController] state.
  static ThemeData resolve(ThemeController controller) {
    final isDark = controller.isDarkMode;
    final isColorblind = controller.isColorblindMode;
    if (isColorblind && isDark) return colorblindDarkTheme;
    if (isColorblind && !isDark) return colorblindLightTheme;
    if (!isDark) return lightTheme;
    return darkTheme;
  }

  /// The primary application dark theme.
  static ThemeData get darkTheme {
    const colorScheme = appDarkColorScheme;
    final textTheme = buildAppTextTheme();

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: colorScheme,
      textTheme: textTheme,

      // Scaffold
      scaffoldBackgroundColor: colorScheme.surface,

      // AppBar
      appBarTheme: AppBarTheme(
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
        elevation: 0,
        scrolledUnderElevation: 1,
        surfaceTintColor: colorScheme.primary,
        centerTitle: false,
        titleTextStyle: textTheme.titleLarge?.copyWith(
          color: colorScheme.onSurface,
        ),
        iconTheme: IconThemeData(color: colorScheme.onSurface),
        actionsIconTheme: IconThemeData(color: colorScheme.onSurface),
        systemOverlayStyle: SystemUiOverlayStyle.light,
      ),

      // NavigationBar (M3 bottom nav)
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: colorScheme.surface,
        indicatorColor: colorScheme.primaryContainer,
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return IconThemeData(color: colorScheme.onPrimaryContainer, size: 24);
          }
          return IconThemeData(color: colorScheme.onSurface.withValues(alpha: 0.7), size: 24);
        }),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return textTheme.labelMedium?.copyWith(color: colorScheme.onSecondaryContainer);
          }
          return textTheme.labelMedium?.copyWith(
            color: colorScheme.onSurface.withValues(alpha: 0.7),
          );
        }),
        elevation: 3,
        surfaceTintColor: colorScheme.primary,
        shadowColor: Colors.transparent,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
      ),

      // Card
      cardTheme: CardThemeData(
        color: const Color(0xFF1B2029), // surfaceContainer
        elevation: 1,
        surfaceTintColor: colorScheme.primary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        clipBehavior: Clip.antiAlias,
        margin: EdgeInsets.zero,
      ),

      // FilledButton
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          foregroundColor: colorScheme.onPrimary,
          backgroundColor: colorScheme.primary,
          textStyle: textTheme.labelLarge,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          minimumSize: const Size(64, 48),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),

      // OutlinedButton
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: colorScheme.primary,
          side: BorderSide(color: colorScheme.outline),
          textStyle: textTheme.labelLarge,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          minimumSize: const Size(64, 48),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),

      // TextButton
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: colorScheme.primary,
          textStyle: textTheme.labelLarge,
          minimumSize: const Size(64, 48),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),

      // InputDecoration (TextFields)
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFF262A34), // surfaceContainerHigh
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colorScheme.outline),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colorScheme.outline.withValues(alpha: 0.5)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colorScheme.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colorScheme.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colorScheme.error, width: 2),
        ),
        labelStyle: textTheme.bodyMedium?.copyWith(color: colorScheme.onSurface.withValues(alpha: 0.7)),
        hintStyle: textTheme.bodyMedium?.copyWith(color: colorScheme.onSurface.withValues(alpha: 0.38)),
        errorStyle: textTheme.bodySmall?.copyWith(color: colorScheme.error),
        prefixIconColor: colorScheme.onSurface.withValues(alpha: 0.6),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),

      // Switch
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return colorScheme.primary;
          return colorScheme.outline;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return colorScheme.primaryContainer;
          }
          return colorScheme.surface;
        }),
        trackOutlineColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return Colors.transparent;
          return colorScheme.outline;
        }),
      ),

      // Chip
      chipTheme: ChipThemeData(
        backgroundColor: const Color(0xFF1B2029),
        selectedColor: colorScheme.primaryContainer,
        labelStyle: textTheme.labelMedium,
        side: BorderSide(color: colorScheme.outline.withValues(alpha: 0.5)),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      ),

      // Dialog
      dialogTheme: DialogThemeData(
        backgroundColor: const Color(0xFF1B2029),
        surfaceTintColor: colorScheme.primary,
        elevation: 3,
        titleTextStyle: textTheme.headlineSmall?.copyWith(color: colorScheme.onSurface),
        contentTextStyle: textTheme.bodyMedium?.copyWith(color: colorScheme.onSurface),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(28),
        ),
      ),

      // BottomSheet
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: const Color(0xFF1B2029),
        surfaceTintColor: colorScheme.primary,
        elevation: 1,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        showDragHandle: true,
        dragHandleColor: colorScheme.onSurface.withValues(alpha: 0.4),
        dragHandleSize: const Size(32, 4),
        modalBackgroundColor: const Color(0xFF1B2029),
      ),

      // SnackBar
      snackBarTheme: SnackBarThemeData(
        backgroundColor: colorScheme.inverseSurface,
        contentTextStyle: textTheme.bodyMedium?.copyWith(color: colorScheme.onInverseSurface),
        actionTextColor: colorScheme.inversePrimary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        elevation: 6,
      ),

      // ProgressIndicator
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: colorScheme.primary,
        circularTrackColor: colorScheme.primaryContainer.withValues(alpha: 0.3),
        linearTrackColor: colorScheme.primaryContainer.withValues(alpha: 0.3),
        linearMinHeight: 4,
      ),

      // ListTile
      listTileTheme: ListTileThemeData(
        iconColor: colorScheme.onSurface.withValues(alpha: 0.7),
        textColor: colorScheme.onSurface,
        tileColor: Colors.transparent,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        minLeadingWidth: 24,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),

      // Divider
      dividerTheme: DividerThemeData(
        color: colorScheme.outlineVariant,
        thickness: 1,
        space: 1,
      ),

      // IconButton
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(
          foregroundColor: colorScheme.onSurface,
          minimumSize: const Size(48, 48),
        ),
      ),

      // FloatingActionButton
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: colorScheme.primaryContainer,
        foregroundColor: colorScheme.onPrimaryContainer,
        elevation: 3,
        highlightElevation: 6,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    );
  }

  /// Light theme — same component styles, light ColorScheme.
  static ThemeData get lightTheme => _build(
        colorScheme: appLightColorScheme,
        overlayStyle: SystemUiOverlayStyle.dark,
      );

  /// Colorblind-safe dark theme (Deuteranopia-friendly: blue/orange/yellow).
  static ThemeData get colorblindDarkTheme => _build(
        colorScheme: appColorblindDarkColorScheme,
        overlayStyle: SystemUiOverlayStyle.light,
      );

  /// Colorblind-safe light theme.
  static ThemeData get colorblindLightTheme => _build(
        colorScheme: appColorblindLightColorScheme,
        overlayStyle: SystemUiOverlayStyle.dark,
      );

  /// Internal factory shared by all theme variants.
  static ThemeData _build({
    required ColorScheme colorScheme,
    required SystemUiOverlayStyle overlayStyle,
  }) {
    final textTheme = buildAppTextTheme();
    final isDark = colorScheme.brightness == Brightness.dark;
    final cardColor = isDark ? const Color(0xFF1B2029) : const Color(0xFFEEF0F9);
    final inputFillColor = isDark ? const Color(0xFF262A34) : const Color(0xFFE4E6F0);
    final sheetColor = isDark ? const Color(0xFF1B2029) : const Color(0xFFF4F5FF);

    return ThemeData(
      useMaterial3: true,
      brightness: colorScheme.brightness,
      colorScheme: colorScheme,
      textTheme: textTheme,
      scaffoldBackgroundColor: colorScheme.surface,
      appBarTheme: AppBarTheme(
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
        elevation: 0,
        scrolledUnderElevation: 1,
        surfaceTintColor: colorScheme.primary,
        centerTitle: false,
        titleTextStyle: textTheme.titleLarge?.copyWith(color: colorScheme.onSurface),
        iconTheme: IconThemeData(color: colorScheme.onSurface),
        actionsIconTheme: IconThemeData(color: colorScheme.onSurface),
        systemOverlayStyle: overlayStyle,
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: colorScheme.surface,
        indicatorColor: colorScheme.primaryContainer,
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return IconThemeData(color: colorScheme.onPrimaryContainer, size: 24);
          }
          return IconThemeData(color: colorScheme.onSurface.withValues(alpha: 0.7), size: 24);
        }),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return textTheme.labelMedium?.copyWith(color: colorScheme.onSecondaryContainer);
          }
          return textTheme.labelMedium?.copyWith(
            color: colorScheme.onSurface.withValues(alpha: 0.7),
          );
        }),
        elevation: 3,
        surfaceTintColor: colorScheme.primary,
        shadowColor: Colors.transparent,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
      ),
      cardTheme: CardThemeData(
        color: cardColor,
        elevation: 1,
        surfaceTintColor: colorScheme.primary,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        clipBehavior: Clip.antiAlias,
        margin: EdgeInsets.zero,
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          foregroundColor: colorScheme.onPrimary,
          backgroundColor: colorScheme.primary,
          textStyle: textTheme.labelLarge,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          minimumSize: const Size(64, 48),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: colorScheme.primary,
          side: BorderSide(color: colorScheme.outline),
          textStyle: textTheme.labelLarge,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          minimumSize: const Size(64, 48),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: colorScheme.primary,
          textStyle: textTheme.labelLarge,
          minimumSize: const Size(64, 48),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: inputFillColor,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colorScheme.outline),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colorScheme.outline.withValues(alpha: 0.5)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colorScheme.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colorScheme.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colorScheme.error, width: 2),
        ),
        labelStyle: textTheme.bodyMedium?.copyWith(
          color: colorScheme.onSurface.withValues(alpha: 0.7),
        ),
        hintStyle: textTheme.bodyMedium?.copyWith(
          color: colorScheme.onSurface.withValues(alpha: 0.38),
        ),
        errorStyle: textTheme.bodySmall?.copyWith(color: colorScheme.error),
        prefixIconColor: colorScheme.onSurface.withValues(alpha: 0.6),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return colorScheme.primary;
          return colorScheme.outline;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return colorScheme.primaryContainer;
          return colorScheme.surface;
        }),
        trackOutlineColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return Colors.transparent;
          return colorScheme.outline;
        }),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: cardColor,
        selectedColor: colorScheme.primaryContainer,
        labelStyle: textTheme.labelMedium,
        side: BorderSide(color: colorScheme.outline.withValues(alpha: 0.5)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: cardColor,
        surfaceTintColor: colorScheme.primary,
        elevation: 3,
        titleTextStyle: textTheme.headlineSmall?.copyWith(color: colorScheme.onSurface),
        contentTextStyle: textTheme.bodyMedium?.copyWith(color: colorScheme.onSurface),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: sheetColor,
        surfaceTintColor: colorScheme.primary,
        elevation: 1,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        showDragHandle: true,
        dragHandleColor: colorScheme.onSurface.withValues(alpha: 0.4),
        dragHandleSize: const Size(32, 4),
        modalBackgroundColor: sheetColor,
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: colorScheme.inverseSurface,
        contentTextStyle: textTheme.bodyMedium?.copyWith(color: colorScheme.onInverseSurface),
        actionTextColor: colorScheme.inversePrimary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 6,
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: colorScheme.primary,
        circularTrackColor: colorScheme.primaryContainer.withValues(alpha: 0.3),
        linearTrackColor: colorScheme.primaryContainer.withValues(alpha: 0.3),
        linearMinHeight: 4,
      ),
      listTileTheme: ListTileThemeData(
        iconColor: colorScheme.onSurface.withValues(alpha: 0.7),
        textColor: colorScheme.onSurface,
        tileColor: Colors.transparent,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        minLeadingWidth: 24,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      dividerTheme: DividerThemeData(
        color: colorScheme.outlineVariant,
        thickness: 1,
        space: 1,
      ),
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(
          foregroundColor: colorScheme.onSurface,
          minimumSize: const Size(48, 48),
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: colorScheme.primaryContainer,
        foregroundColor: colorScheme.onPrimaryContainer,
        elevation: 3,
        highlightElevation: 6,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }
}
