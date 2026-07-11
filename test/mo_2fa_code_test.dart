import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mo_2fa_code/mo_2fa_code.dart';

Widget _wrap(Widget child) {
  return MaterialApp(
    home: Scaffold(body: Center(child: child)),
  );
}

void main() {
  testWidgets('renders the configured number of cells', (tester) async {
    await tester.pumpWidget(_wrap(Mo2FACodeField(length: 5)));
    expect(find.byType(TextField), findsNWidgets(5));
  });

  testWidgets('typing advances focus and fires onChanged / onCompleted',
      (tester) async {
    String? completed;
    final changes = <String>[];

    await tester.pumpWidget(_wrap(Mo2FACodeField(
      length: 4,
      onChanged: changes.add,
      onCompleted: (code) => completed = code,
    )));

    for (var i = 0; i < 4; i++) {
      await tester.enterText(find.byType(TextField).at(i), '${i + 1}');
      await tester.pump();
    }

    expect(changes.last, '1234');
    expect(completed, '1234');
  });

  testWidgets('pasting a full code distributes it across the cells',
      (tester) async {
    String? completed;

    await tester.pumpWidget(_wrap(Mo2FACodeField(
      length: 5,
      onCompleted: (code) => completed = code,
    )));

    await tester.enterText(find.byType(TextField).first, '12345');
    await tester.pump();

    expect(completed, '12345');
    for (var i = 0; i < 5; i++) {
      expect(
        tester.widget<TextField>(find.byType(TextField).at(i)).controller!.text,
        '${i + 1}',
      );
    }
  });

  testWidgets('backspace on an empty cell clears and refocuses the previous',
      (tester) async {
    await tester.pumpWidget(_wrap(Mo2FACodeField(length: 4)));

    await tester.enterText(find.byType(TextField).at(0), '1');
    await tester.pump();

    // Focus moved to cell 1, which is empty.
    await tester.sendKeyEvent(LogicalKeyboardKey.backspace);
    await tester.pump();

    final firstCell = tester.widget<TextField>(find.byType(TextField).at(0));
    expect(firstCell.controller!.text, isEmpty);
    expect(firstCell.focusNode!.hasFocus, isTrue);
  });

  testWidgets('numeric input type rejects letters', (tester) async {
    await tester.pumpWidget(_wrap(Mo2FACodeField(length: 4)));

    await tester.enterText(find.byType(TextField).first, 'a');
    await tester.pump();

    expect(
      tester.widget<TextField>(find.byType(TextField).first).controller!.text,
      isEmpty,
    );
  });

  testWidgets('caseTransform upperCase uppercases typed characters',
      (tester) async {
    await tester.pumpWidget(_wrap(Mo2FACodeField(
      length: 4,
      inputType: Mo2FAInputType.alphanumeric,
      caseTransform: Mo2FACaseTransform.upperCase,
    )));

    await tester.enterText(find.byType(TextField).first, 'ab1c');
    await tester.pump();

    for (var i = 0; i < 4; i++) {
      expect(
        tester.widget<TextField>(find.byType(TextField).at(i)).controller!.text,
        'AB1C'[i],
      );
    }
  });

  testWidgets('validator integrates with Form', (tester) async {
    final formKey = GlobalKey<FormState>();

    await tester.pumpWidget(_wrap(Form(
      key: formKey,
      child: Mo2FACodeField(
        length: 5,
        validator: (code) =>
            code != null && code.length == 5 ? null : 'Enter the full code',
      ),
    )));

    expect(formKey.currentState!.validate(), isFalse);
    await tester.pump();
    expect(find.text('Enter the full code'), findsOneWidget);

    await tester.enterText(find.byType(TextField).first, '12345');
    await tester.pump();
    expect(formKey.currentState!.validate(), isTrue);
  });

  testWidgets('controller reads, sets and clears the code', (tester) async {
    final controller = Mo2FACodeController();
    addTearDown(controller.dispose);

    await tester.pumpWidget(_wrap(Mo2FACodeField(
      length: 5,
      controller: controller,
    )));

    await tester.enterText(find.byType(TextField).first, '12345');
    await tester.pump();
    expect(controller.code, '12345');

    controller.clear();
    await tester.pump();
    for (var i = 0; i < 5; i++) {
      expect(
        tester.widget<TextField>(find.byType(TextField).at(i)).controller!.text,
        isEmpty,
      );
    }

    controller.setCode('54321');
    await tester.pump();
    expect(
      tester.widget<TextField>(find.byType(TextField).at(0)).controller!.text,
      '5',
    );
    expect(
      tester.widget<TextField>(find.byType(TextField).at(4)).controller!.text,
      '1',
    );
  });
}
