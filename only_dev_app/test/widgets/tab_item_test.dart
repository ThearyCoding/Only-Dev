import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:only_dev_app/widgets/tabs-widget/tab_item.dart';

void main() {
  Widget host() => MaterialApp(
        home: DefaultTabController(
          length: 2,
          child: Scaffold(
            appBar: AppBar(
              bottom: const TabBar(
                isScrollable: true,
                labelColor: Colors.green,
                unselectedLabelColor: Colors.grey,
                tabs: [
                  TabItem(title: 'Lessons', count: 5),
                  TabItem(title: 'Recent', count: 0),
                ],
              ),
            ),
          ),
        ),
      );

  testWidgets('shows count capsule only when count > 0', (tester) async {
    await tester.pumpWidget(host());
    expect(find.text('Lessons'), findsOneWidget);
    expect(find.text('5'), findsOneWidget);
    expect(find.text('0'), findsNothing);
  });

  testWidgets('count capsule follows the selected label color',
      (tester) async {
    await tester.pumpWidget(host());
    final count = tester.widget<Text>(find.text('5'));
    expect(count.style?.color?.toARGB32(), Colors.green.toARGB32());
  });
}
