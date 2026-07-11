import 'package:flutter/material.dart';
import 'package:mo_2fa_code/mo_2fa_code.dart';

void main() => runApp(const ExampleApp());

/// Root of the example app.
class ExampleApp extends StatelessWidget {
  /// Creates the example app.
  const ExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'mo_2fa_code example',
      theme: ThemeData(colorSchemeSeed: Colors.indigo),
      home: const TwoFAScreen(),
    );
  }
}

/// A complete 2FA screen built with [Mo2FACodeField].
class TwoFAScreen extends StatefulWidget {
  /// Creates the 2FA screen.
  const TwoFAScreen({super.key});

  @override
  State<TwoFAScreen> createState() => _TwoFAScreenState();
}

class _TwoFAScreenState extends State<TwoFAScreen> {
  final _formKey = GlobalKey<FormState>();
  final _codeController = Mo2FACodeController();

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  Future<void> _verify(String code) async {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Verifying code $code...')));
    // On failure, clear the field so the user can retry:
    // _codeController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Two Factor Authentication')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('A 5 character code has been sent to your email.'),
              const SizedBox(height: 40),
              Form(
                key: _formKey,
                child: Mo2FACodeField(
                  length: 5,
                  controller: _codeController,
                  autoFocus: true,
                  inputType: Mo2FAInputType.alphanumeric,
                  caseTransform: Mo2FACaseTransform.upperCase,
                  hapticFeedback: true,
                  style: const Mo2FACodeStyle(
                    cellWidth: 52,
                    cellHeight: 60,
                    spacing: 10,
                    hintCharacter: '-',
                    textStyle: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  validator: (code) => (code ?? '').length == 5
                      ? null
                      : 'Enter the full 5 character code',
                  onCompleted: _verify,
                ),
              ),
              const SizedBox(height: 32),
              FilledButton.icon(
                icon: const Icon(Icons.check),
                label: const Text('Confirm'),
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    _verify(_codeController.code);
                  }
                },
              ),
              TextButton(
                onPressed: () => _codeController.clear(),
                child: const Text('Resend Code'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
