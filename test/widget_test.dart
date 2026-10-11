import 'package:flutter_test/flutter_test.dart';
import 'package:my_offline_gps/main.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const OfflineGpsApp());
    expect(find.text('Offline GPS'), findsOneWidget);
  });
}
