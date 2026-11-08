import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:bil_cut/main.dart';

void main() {
  testWidgets('BilCutApp mounts and renders home screen with Proyek Baru button',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: BilCutApp(),
      ),
    );

    // Verify 'Proyek Baru' hero button is displayed
    expect(find.text('Proyek Baru'), findsOneWidget);
    expect(find.text('Proyek Terbaru'), findsOneWidget);
  });
}
