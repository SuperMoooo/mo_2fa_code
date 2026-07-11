# mo_2fa_code

A customizable one-character-per-cell code input for 2FA / OTP screens.
Set the length you need, style the cells your way, and get the fiddly parts
for free:

- **Auto-advance** to the next cell while typing, keyboard dismissed when done
- **Backspace navigation** — jumps back and clears the previous cell, on both
  soft and hardware keyboards
- **Paste & autofill** — pasting or SMS/email one-time-code autofill
  distributes the code across the cells
- **Type-over** — tapping a filled cell selects its character so typing
  replaces it
- **`Form` integration** — it is a `FormField<String>`, so `validator` works
  exactly like with `TextFormField`
- **Input filtering** — numeric, alphanumeric or any characters, with optional
  upper/lower case transform
- **Hint character** — a placeholder shown in every empty cell
- **Separators** — group cells with any widget, e.g. `123 - 456`
- Optional **haptic feedback** on every accepted character
- Optional **controller** to read, set or clear the code programmatically

## Usage

```dart
import 'package:mo_2fa_code/mo_2fa_code.dart';

Mo2FACodeField(
  length: 6,
  onCompleted: (code) => verify(code),
)
```

That's it — 6 numeric cells with a Material 3 look.

### With a Form, validation and a controller

```dart
final _formKey = GlobalKey<FormState>();
final _codeController = Mo2FACodeController();

Form(
  key: _formKey,
  child: Mo2FACodeField(
    length: 5,
    controller: _codeController,
    autoFocus: true,
    inputType: Mo2FAInputType.alphanumeric,
    caseTransform: Mo2FACaseTransform.upperCase,
    validator: (code) =>
        (code ?? '').length == 5 ? null : 'Enter the full 5 character code',
    onCompleted: (code) => verify(code),
  ),
)

// Confirm button:
if (_formKey.currentState!.validate()) {
  verify(_codeController.code);
}

// After a failed verification:
_codeController.clear();
```

### Styling

Simple tweaks through `Mo2FACodeStyle`:

```dart
Mo2FACodeField(
  length: 4,
  obscureText: true,
  style: const Mo2FACodeStyle(
    cellWidth: 56,
    cellHeight: 64,
    spacing: 8,
    hintCharacter: '0', // placeholder shown in every empty cell
    textStyle: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
    cursorColor: Colors.indigo,
  ),
)
```

Group the cells with a separator widget:

```dart
Mo2FACodeField(
  length: 6,
  style: Mo2FACodeStyle(
    // renders 3 cells, a dash, then 3 cells
    separatorBuilder: (context, index) =>
        index == 2 ? const Text('—') : null,
  ),
)
```

Full control per cell with `decorationBuilder` (focus and error aware):

```dart
Mo2FACodeStyle(
  decorationBuilder: (context, index, {required hasFocus, required hasError}) {
    return InputDecoration(
      filled: true,
      fillColor: hasFocus ? Colors.indigo.shade50 : Colors.grey.shade100,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
    );
  },
)
```

## API overview

| Parameter | Default | Description |
| --- | --- | --- |
| `length` | `6` | Number of characters in the code |
| `inputType` | `numeric` | `numeric`, `alphanumeric` or `any` |
| `caseTransform` | `none` | `upperCase`, `lowerCase` or `none` |
| `onChanged` | — | Fired on every change with the partial code |
| `onCompleted` | — | Fired once every cell is filled |
| `controller` | — | `Mo2FACodeController` to read / set / clear the code |
| `validator` | — | Standard `FormField` validator, receives the full code string |
| `obscureText` | `false` | Hide characters (see `Mo2FACodeStyle.obscuringCharacter`) |
| `autoFocus` | `false` | Focus the first cell on mount |
| `readOnly` | `false` | Show the code without allowing edits |
| `hapticFeedback` | `false` | Light haptic impact on every accepted character |
| `keyboardType` | derived | Override the keyboard derived from `inputType` |
| `autofillHints` | `[oneTimeCode]` | Autofill hints for the first cell; pass `[]` to disable |
| `style` | `Mo2FACodeStyle()` | Cell size, spacing, hint character, text style, decoration, separators, error style |

See the [example](example/lib/main.dart) for a complete 2FA screen.
