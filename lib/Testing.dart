import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

// Define a simple StatelessWidget
class MyWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        ElevatedButton(
          onPressed: () {
            // Handle the button press event here
          },
          child: Text('Press Me'),
        ),
        Text('Button not pressed yet'),
      ],
    );
  }
}

void main() {
  testWidgets('Widget test', (WidgetTester tester) async {
    // Build our widget
    await tester.pumpWidget(MyWidget());

    // Verify that the initial text is displayed
    expect(find.text('Button not pressed yet'), findsOneWidget);

    // Tap the button
    await tester.tap(find.text('Press Me'));

    // Rebuild the widget
    await tester.pump();

    // Verify that the text has changed after pressing the button
    expect(find.text('Button not pressed yet'), findsNothing);
  });
}
