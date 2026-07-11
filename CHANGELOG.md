# 0.0.1

Initial release.

- `Mo2FACodeField` — configurable-length code input with auto-advance,
  backspace navigation, paste / one-time-code autofill distribution and
  type-over on focused cells.
- `Form` integration via `FormField<String>` (`validator`, `autovalidateMode`).
- `Mo2FAInputType` (numeric / alphanumeric / any) and `Mo2FACaseTransform`
  (upper / lower / none) input filtering.
- `Mo2FACodeStyle` for cell size, spacing, text style, per-cell decorations
  (focus and error aware) and error text style.
- `Mo2FACodeController` to read, set or clear the code programmatically.
