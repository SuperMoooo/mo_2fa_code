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

/// Color role of a code cell.
///
/// Every color the built-in decoration paints — border, focus ring and fill
/// tint — is derived from the variant, so a [Mo2FACellVariant.secondary] field
/// is secondary all over. Resolved against the theme's `colorScheme`.
///
/// Only used when the style provides no explicit [Mo2FACodeStyle.decoration]
/// or [Mo2FACodeStyle.decorationBuilder].
enum Mo2FACellVariant {
  /// Uses `colorScheme.primary`.
  primary,

  /// Uses `colorScheme.secondary`.
  secondary,

  /// Uses `colorScheme.tertiary`.
  tertiary,

  /// Uses `colorScheme.error`.
  error,
}

/// Border shape of a code cell.
///
/// - [filled]: filled with a faint tint of the variant, borderless until
///   focused.
/// - [outlined]: transparent with a visible border at rest.
/// - [underline]: bottom border only, no fill.
/// - [rounded]: like [filled], with a pill radius.
///
/// Only used when the style provides no explicit [Mo2FACodeStyle.decoration]
/// or [Mo2FACodeStyle.decorationBuilder].
enum Mo2FACellShape {
  /// Filled with a faint tint of the variant, borderless until focused.
  filled,

  /// Transparent with a visible border at rest.
  outlined,

  /// Bottom border only, no fill.
  underline,

  /// Like [filled], with a pill radius.
  rounded,
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

/// Builds an optional widget shown between cell [index] and the next cell.
///
/// Return `null` to render nothing at that position. Useful to group cells,
/// e.g. a dash in the middle of a 6-digit code:
///
/// ```dart
/// separatorBuilder: (context, index) =>
///     index == 2 ? const Text('-') : null,
/// ```
typedef Mo2FASeparatorBuilder = Widget? Function(
  BuildContext context,
  int index,
);

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
    this.variant = Mo2FACellVariant.primary,
    this.shape = Mo2FACellShape.outlined,
    this.mainAxisAlignment = MainAxisAlignment.center,
    this.textStyle,
    this.hintCharacter,
    this.hintStyle,
    this.decoration,
    this.decorationBuilder,
    this.separatorBuilder,
    this.cursorColor,
    this.obscuringCharacter = '•',
    this.errorTextStyle,
  }) : assert(
          hintCharacter == null || hintCharacter.length == 1,
          'hintCharacter must be a single character',
        );

  /// Width of each cell.
  final double cellWidth;

  /// Height of each cell.
  final double cellHeight;

  /// Horizontal gap between cells.
  final double spacing;

  /// Color role of the built-in cell decoration. See [Mo2FACellVariant].
  ///
  /// Ignored when [decoration] or [decorationBuilder] is provided.
  final Mo2FACellVariant variant;

  /// Border shape of the built-in cell decoration. See [Mo2FACellShape].
  ///
  /// Ignored when [decoration] or [decorationBuilder] is provided.
  final Mo2FACellShape shape;

  /// How the row of cells is aligned.
  final MainAxisAlignment mainAxisAlignment;

  /// Text style of the typed character. Defaults to the theme's `titleLarge`.
  final TextStyle? textStyle;

  /// A single placeholder character shown in every empty cell, e.g. `'0'`
  /// or `'-'`. Disappears as soon as the cell is filled.
  ///
  /// `null` (the default) shows no hint.
  final String? hintCharacter;

  /// Text style of [hintCharacter].
  ///
  /// Defaults to [textStyle] (or the theme's `titleLarge`) in the theme's
  /// hint color.
  final TextStyle? hintStyle;

  /// A single decoration applied to every cell.
  ///
  /// Ignored when [decorationBuilder] is provided.
  final InputDecoration? decoration;

  /// Per-cell decoration builder. Takes precedence over [decoration].
  final Mo2FACellDecorationBuilder? decorationBuilder;

  /// Optional widget between cells, e.g. a dash grouping the code.
  ///
  /// Called with the index of the cell to the left; return `null` for no
  /// separator at that position. [spacing] still applies around separators.
  final Mo2FASeparatorBuilder? separatorBuilder;

  /// Cursor color inside the cells.
  final Color? cursorColor;

  /// Character shown when `obscureText` is enabled on the field.
  final String obscuringCharacter;

  /// Style of the validation error text shown under the cells.
  ///
  /// Defaults to the theme's `bodySmall` in the error color.
  final TextStyle? errorTextStyle;
}
