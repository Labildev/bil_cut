import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bil_cut/presentation/screens/home_screen.dart';

void main() {
  group('HomeScreen & Quick Tools Tests', () {
    testWidgets('HomeScreen renders header, new project hero, quick tools and draft list', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: HomeScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Check header branding via RichText
      expect(
        find.byWidgetPredicate(
          (w) => w is RichText && w.text.toPlainText().contains('BIL_CUT'),
        ),
        findsOneWidget,
      );

      // Check Hero
      expect(find.text('Proyek Baru'), findsOneWidget);

      // Check Quick Tools
      expect(find.text('Kamera'), findsOneWidget);
      expect(find.text('AutoCut'), findsOneWidget);
      expect(find.text('Teks ke Video'), findsOneWidget);
      expect(find.text('Voiceover'), findsOneWidget);

      // Check Draft Items
      expect(find.text('Proyek Terbaru'), findsOneWidget);
      expect(find.text('Vlog Senja Bali #1'), findsOneWidget);
      expect(find.text('Cinematic Reel Beat Sync'), findsOneWidget);
    });

    testWidgets('Tapping Settings opens App Architecture and Cache bottom sheet', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: HomeScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Tap settings button
      final settingsButton = find.byTooltip('Pengaturan');
      expect(settingsButton, findsOneWidget);
      await tester.tap(settingsButton);
      await tester.pumpAndSettle();

      // Verify settings bottom sheet details
      expect(find.text('Versi 1.0.0 • Pro Video Editor Engine'), findsOneWidget);
      expect(find.text('Custom Timeline Engine'), findsOneWidget);
      expect(find.text('GPU Shader Color Matrix'), findsOneWidget);
      expect(find.text('Video Export Pipeline'), findsOneWidget);
      expect(find.text('Bersihkan Cache Video'), findsOneWidget);

      // Tap Bersihkan
      await tester.tap(find.text('Bersihkan'));
      await tester.pumpAndSettle();

      expect(find.text('Cache aplikasi berhasil dibersihkan'), findsOneWidget);
    });
  });
}
