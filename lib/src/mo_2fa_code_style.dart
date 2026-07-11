import 'package:flutter/material.dart';

/// Which characters the code cells accept.
enum Mo2FAInputType {
  /// Digits 0-9 only. Shows the number keyboard.
  numeric,

  /// Letters and digits only.
  alphanumeric,

  /// Any character.
  any,
}

/// How typed characters are transformed before being stored.
enum Mo2FACaseTransform {
  /// Keep characters exactly as typed.
  none,

  /// Convert every character to upper case.
  upperCase,

  /// Convert every character to lower case.
  lowerCase,
}

/// Builds the [InputDecoration] for a single cell.
///
/// [index] is the cell position, [hasFocus] whether that cell currently has
/// focus, and [hasError] whether the field failed validation.
typedef Mo2FACellDecorationBuilder = InputDecoration Function(
  BuildContext context,
  int index, {
  required bool hasFocus,
  required bool hasError,
});

/// Visual configuration for a [Mo2FACodeField].
///
/// Every property has a sensible Material 3 default, so `const
/// Mo2FACodeStyle()` gives a ready-to-use look. Override only what you need:
///
/// ```dart
/// Mo2FACodeStyle(
///   cellWidth: 56,
///   spacing: 8,
///   textStyle: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
/// )
/// ```
///
/// For full control over the look of each cell, provide [decoration] (same
/// decoration for every cell) or [decorationBuilder] (per-cell, focus and
/// error aware).
class Mo2FACodeStyle {
  /// Creates a style. Every parameter has a Material 3 default.
  const Mo2FACodeStyle({
    this.cellWidth = 48,
    this.cellHeight = 56,
    this.spacing = 12,
    this.mainAxisAlignment = MainAxisAlignment.center,
    this.textStyle,
    this.decoration,
    this.decorationBuilder,
    this.cursorColor,
    this.obscuringCharacter = '•',
    this.errorTextStyle,
  });

  /// Width of each cell.
  final double cellWidth;

  /// Height of each cell.
  final double cellHeight;

  /// Horizontal gap between cells.
  final double spacing;

  /// How the row of cells is aligned.
  final MainAxisAlignment mainAxisAlignment;

  /// Text style of the typed character. Defaults to the theme's `titleLarge`.
  final TextStyle? textStyle;

  /// A single decoration applied to every cell.
  ///
  /// Ignored when [decorationBuilder] is provided.
  final InputDecoration? decoration;

  /// Per-cell decoration builder. Takes precedence over [decoration].
  final Mo2FACellDecorationBuilder? decorationBuilder;

  /// Cursor color inside the cells.
  final Color? cursorColor;

  /// Character shown when `obscureText` is enabled on the field.
  final String obscuringCharacter;

  /// Style of the validation error text shown under the cells.
  ///
  /// Defaults to the theme's `bodySmall` in the error color.
  final TextStyle? errorTextStyle;
}
