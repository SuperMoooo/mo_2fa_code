import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'mo_2fa_code_style.dart';

/// Controls a [Mo2FACodeField] from outside the widget tree.
///
/// Useful to clear the field after a failed verification or to pre-fill it:
///
/// ```dart
/// final controller = Mo2FACodeController();
/// // later:
/// controller.clear();
/// controller.setCode('12345');
/// print(controller.code);
/// ```
class Mo2FACodeController extends ChangeNotifier {
  String _code = '';

  /// The current code. May be shorter than the field length while typing.
  String get code => _code;

  /// Replaces the current code.
  ///
  /// The attached field sanitizes the value (input type, case transform) and
  /// drops characters beyond its length. Triggers `onChanged`, and
  /// `onCompleted` when the resulting code is full.
  void setCode(String value) {
    if (_code == value) return;
    _code = value;
    notifyListeners();
  }

  /// Clears every cell.
  void clear() => setCode('');
}

/// A one-character-per-cell code input for 2FA / OTP screens.
///
/// Handles the fiddly parts for you:
/// - auto-advance to the next cell while typing, unfocus when done
/// - backspace jumps back and clears the previous cell (soft and hardware
///   keyboards)
/// - pasting or SMS/email autofill distributes the code across the cells
/// - tapping a filled cell selects its character so typing replaces it
///
/// It is a [FormField], so `validator` works inside a [Form] exactly like
/// a [TextFormField].
///
/// ```dart
/// Mo2FACodeField(
///   length: 5,
///   inputType: Mo2FAInputType.alphanumeric,
///   caseTransform: Mo2FACaseTransform.upperCase,
///   validator: (code) => code != null && code.length == 5 ? null : 'Enter the full code',
///   onCompleted: (code) => verify(code),
/// )
/// ```
class Mo2FACodeField extends FormField<String> {
  /// Creates a code input with [length] cells.
  Mo2FACodeField({
    super.key,
    this.length = 6,
    this.controller,
    this.onChanged,
    this.onCompleted,
    this.inputType = Mo2FAInputType.numeric,
    this.caseTransform = Mo2FACaseTransform.none,
    this.obscureText = false,
    this.autoFocus = false,
    this.keyboardType,
    this.autofillHints = const [AutofillHints.oneTimeCode],
    this.style = const Mo2FACodeStyle(),
    super.validator,
    super.autovalidateMode,
    super.enabled,
  })  : assert(length > 0, 'length must be at least 1'),
        super(
          initialValue: controller?.code ?? '',
          builder: (field) => (field as _Mo2FACodeFieldState)._buildCells(),
        );

  /// Number of characters in the code.
  final int length;

  /// Optional controller to read, set or clear the code programmatically.
  final Mo2FACodeController? controller;

  /// Called on every change with the current (possibly partial) code.
  final ValueChanged<String>? onChanged;

  /// Called once every cell is filled, with the complete code.
  final ValueChanged<String>? onCompleted;

  /// Which characters are accepted. Defaults to [Mo2FAInputType.numeric].
  final Mo2FAInputType inputType;

  /// Case transformation applied to typed and pasted characters.
  final Mo2FACaseTransform caseTransform;

  /// Hide the typed characters (uses [Mo2FACodeStyle.obscuringCharacter]).
  final bool obscureText;

  /// Focus the first cell as soon as the field appears.
  final bool autoFocus;

  /// Overrides the keyboard type derived from [inputType].
  final TextInputType? keyboardType;

  /// Autofill hints for the first cell, enabling SMS / email code autofill.
  ///
  /// Defaults to `[AutofillHints.oneTimeCode]`. Pass an empty list to disable.
  final List<String> autofillHints;

  /// Visual configuration. See [Mo2FACodeStyle].
  final Mo2FACodeStyle style;

  @override
  FormFieldState<String> createState() => _Mo2FACodeFieldState();
}

class _Mo2FACodeFieldState extends FormFieldState<String> {
  late List<TextEditingController> _cells;
  late List<FocusNode> _nodes;

  Mo2FACodeField get _widget => widget as Mo2FACodeField;

  String get _code => _cells.map((c) => c.text).join();

  @override
  void initState() {
    super.initState();
    _createCells();
    _widget.controller?.addListener(_onControllerChanged);
    final initial = _widget.controller?.code ?? '';
    if (initial.isNotEmpty) {
      _applyCode(initial, moveFocus: false, notify: false);
    }
  }

  @override
  void didUpdateWidget(covariant FormField<String> oldWidget) {
    super.didUpdateWidget(oldWidget);
    final old = oldWidget as Mo2FACodeField;
    if (_widget.controller != old.controller) {
      old.controller?.removeListener(_onControllerChanged);
      _widget.controller?.addListener(_onControllerChanged);
    }
    if (_widget.length != old.length) {
      final code = _code;
      _disposeCells();
      _createCells();
      _applyCode(code, moveFocus: false, notify: false);
    }
  }

  @override
  void dispose() {
    _widget.controller?.removeListener(_onControllerChanged);
    _disposeCells();
    super.dispose();
  }

  @override
  void reset() {
    for (final cell in _cells) {
      cell.clear();
    }
    _widget.controller?._code = '';
    super.reset();
  }

  void _createCells() {
    _cells = List.generate(_widget.length, (_) => TextEditingController());
    _nodes = List.generate(
      _widget.length,
      (index) => FocusNode(
        onKeyEvent: (node, event) => _onKeyEvent(event, index),
      ),
    );
    for (var index = 0; index < _widget.length; index++) {
      _nodes[index].addListener(() => _onFocusChanged(index));
    }
  }

  void _disposeCells() {
    for (final cell in _cells) {
      cell.dispose();
    }
    for (final node in _nodes) {
      node.dispose();
    }
  }

  /// Select the existing character when a cell gains focus, so typing
  /// replaces it instead of appending. Also rebuilds so a focus-aware
  /// decoration can update.
  void _onFocusChanged(int index) {
    if (_nodes[index].hasFocus && _cells[index].text.isNotEmpty) {
      _cells[index].selection = TextSelection(
        baseOffset: 0,
        extentOffset: _cells[index].text.length,
      );
    }
    if (mounted) setState(() {});
  }

  /// Removes disallowed characters and applies the case transform.
  String _sanitize(String raw) {
    var text = raw.trim();
    switch (_widget.inputType) {
      case Mo2FAInputType.numeric:
        text = text.replaceAll(RegExp(r'[^0-9]'), '');
      case Mo2FAInputType.alphanumeric:
        text = text.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '');
      case Mo2FAInputType.any:
        break;
    }
    return switch (_widget.caseTransform) {
      Mo2FACaseTransform.none => text,
      Mo2FACaseTransform.upperCase => text.toUpperCase(),
      Mo2FACaseTransform.lowerCase => text.toLowerCase(),
    };
  }

  void _onCellChanged(String value, int index) {
    // Backspace deleted the character (soft keyboard).
    if (value.isEmpty) {
      _notifyChanged();
      if (index > 0) _nodes[index - 1].requestFocus();
      return;
    }

    final text = _sanitize(value);

    // Only disallowed characters were typed.
    if (text.isEmpty) {
      _cells[index].clear();
      return;
    }

    // Paste or autofill.
    if (text.length > 1) {
      _applyCode(text, from: index);
      return;
    }

    _cells[index].value = TextEditingValue(
      text: text,
      selection: const TextSelection.collapsed(offset: 1),
    );
    _notifyChanged();

    if (index < _widget.length - 1) {
      _nodes[index + 1].requestFocus();
    } else {
      _nodes[index].unfocus();
    }
  }

  /// Backspace on an empty cell: clear the previous cell and focus it.
  KeyEventResult _onKeyEvent(KeyEvent event, int index) {
    if (event is KeyDownEvent &&
        event.logicalKey == LogicalKeyboardKey.backspace &&
        _cells[index].text.isEmpty &&
        index > 0) {
      _cells[index - 1].clear();
      _nodes[index - 1].requestFocus();
      _notifyChanged();
      return KeyEventResult.handled;
    }
    return KeyEventResult.ignored;
  }

  /// Distributes [raw] across the cells.
  ///
  /// A code long enough to fill the field overwrites every cell from the
  /// start; a shorter fragment is inserted from [from], leaving the cells
  /// before it untouched.
  void _applyCode(
    String raw, {
    int from = 0,
    bool moveFocus = true,
    bool notify = true,
  }) {
    final code = _sanitize(raw);
    final overwrite = code.length >= _widget.length || from == 0;
    final start = overwrite ? 0 : from;

    for (var i = 0; i < _widget.length; i++) {
      if (i >= start && i - start < code.length) {
        _cells[i].text = code[i - start];
      } else if (overwrite) {
        _cells[i].clear();
      }
    }

    if (moveFocus) {
      final firstEmpty = _cells.indexWhere((c) => c.text.isEmpty);
      if (firstEmpty == -1) {
        FocusManager.instance.primaryFocus?.unfocus();
      } else {
        _nodes[firstEmpty].requestFocus();
      }
    }

    if (notify) _notifyChanged();
  }

  void _notifyChanged() {
    final code = _code;
    _widget.controller?._code = code;
    didChange(code);
    _widget.onChanged?.call(code);
    if (code.length == _widget.length) {
      _widget.onCompleted?.call(code);
    }
  }

  void _onControllerChanged() {
    final code = _widget.controller!.code;
    if (code == _code) return;
    // Only steal focus if the field already had it (e.g. clear-and-retry).
    final hadFocus = _nodes.any((n) => n.hasFocus);
    _applyCode(code, moveFocus: hadFocus);
  }

  TextInputType get _keyboardType {
    if (_widget.keyboardType != null) return _widget.keyboardType!;
    return _widget.inputType == Mo2FAInputType.numeric
        ? TextInputType.number
        : TextInputType.text;
  }

  InputDecoration _defaultDecoration(ThemeData theme, bool hasError) {
    final radius = BorderRadius.circular(12);
    final colors = theme.colorScheme;
    return InputDecoration(
      counterText: '',
      contentPadding: EdgeInsets.zero,
      border: OutlineInputBorder(borderRadius: radius),
      enabledBorder: OutlineInputBorder(
        borderRadius: radius,
        borderSide: BorderSide(
          color: hasError ? colors.error : colors.outline,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: radius,
        borderSide: BorderSide(
          color: hasError ? colors.error : colors.primary,
          width: 2,
        ),
      ),
      disabledBorder: OutlineInputBorder(
        borderRadius: radius,
        borderSide: BorderSide(color: colors.outlineVariant),
      ),
    );
  }

  Widget _buildCells() {
    final style = _widget.style;
    final theme = Theme.of(context);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisAlignment: style.mainAxisAlignment,
          spacing: style.spacing,
          children: List.generate(_widget.length, (index) {
            final decoration = style.decorationBuilder?.call(
                  context,
                  index,
                  hasFocus: _nodes[index].hasFocus,
                  hasError: hasError,
                ) ??
                style.decoration ??
                _defaultDecoration(theme, hasError);

            return SizedBox(
              width: style.cellWidth,
              height: style.cellHeight,
              child: TextField(
                controller: _cells[index],
                focusNode: _nodes[index],
                enabled: _widget.enabled,
                autofocus: _widget.autoFocus && index == 0,
                textAlign: TextAlign.center,
                style: style.textStyle ?? theme.textTheme.titleLarge,
                keyboardType: _keyboardType,
                textCapitalization:
                    _widget.caseTransform == Mo2FACaseTransform.upperCase
                        ? TextCapitalization.characters
                        : TextCapitalization.none,
                obscureText: _widget.obscureText,
                obscuringCharacter: style.obscuringCharacter,
                cursorColor: style.cursorColor,
                autocorrect: false,
                enableSuggestions: false,
                autofillHints: index == 0 && _widget.autofillHints.isNotEmpty
                    ? _widget.autofillHints
                    : null,
                decoration: decoration,
                onChanged: (value) => _onCellChanged(value, index),
              ),
            );
          }),
        ),
        if (hasError)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              errorText!,
              textAlign: TextAlign.center,
              style: style.errorTextStyle ??
                  theme.textTheme.bodySmall
                      ?.copyWith(color: theme.colorScheme.error),
            ),
          ),
      ],
    );
  }
}
