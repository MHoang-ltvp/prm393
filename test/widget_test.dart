// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';

import 'package:tet_shop/main.dart';

void main() {
  testWidgets('renders Tet shopping app', (WidgetTester tester) async {
    await tester.pumpWidget(const TetShopApp());
    await tester.pumpAndSettle();

    expect(find.text('🧧 Chợ Tết Thông Minh'), findsOneWidget);
    expect(find.text('🧾 Danh sách'), findsOneWidget);
  });
}
