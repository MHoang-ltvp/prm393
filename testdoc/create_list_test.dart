import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tet_shop/main.dart';

void main() {
  testWidgets('tao danh sach moi khong crash va duoc chon', (WidgetTester tester) async {
    await tester.pumpWidget(const TetShopApp());
    await tester.pumpAndSettle();

    expect(find.text('Tết 2026'), findsOneWidget);

    await tester.tap(find.text('+ Danh sách'));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField).first, 'Trung thu 2026');
    await tester.tap(find.text('Tạo'));
    await tester.pumpAndSettle();

    expect(find.text('Trung thu 2026'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
