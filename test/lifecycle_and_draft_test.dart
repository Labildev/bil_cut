import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bil_cut/data/models/project_draft.dart';
import 'package:bil_cut/data/models/timeline_project.dart';
import 'package:bil_cut/logic/timeline/timeline_notifier.dart';
import 'package:bil_cut/presentation/screens/editor_screen.dart';

void main() {
  group('App Lifecycle and Draft Management Tests', () {
    testWidgets('EditorScreen pauses playback on app background/inactive state', (tester) async {
      final container = ProviderContainer();

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(
            home: EditorScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Start playing
      container.read(timelineNotifierProvider.notifier).play();
      expect(container.read(timelineNotifierProvider).isPlaying, isTrue);

      // Simulate AppLifecycleState.paused
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
      await tester.pump();

      // Playback must be paused immediately to preserve resources
      expect(container.read(timelineNotifierProvider).isPlaying, isFalse);
    });

    testWidgets('Back button shows confirmation dialog and Keluar & Simpan pops draft', (tester) async {
      final container = ProviderContainer();
      ProjectDraft? returnedDraft;

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp(
            home: Builder(
              builder: (context) => Scaffold(
                body: ElevatedButton(
                  onPressed: () async {
                    final res = await Navigator.of(context).push<ProjectDraft>(
                      MaterialPageRoute(
                        builder: (_) => const EditorScreen(),
                      ),
                    );
                    returnedDraft = res;
                  },
                  child: const Text('Open Editor'),
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Tap to open EditorScreen
      await tester.tap(find.text('Open Editor'));
      await tester.pumpAndSettle();

      // Tap close/back button in EditorHeader
      final backButton = find.byTooltip('Tutup');
      expect(backButton, findsOneWidget);
      await tester.tap(backButton);
      await tester.pumpAndSettle();

      // Verify confirmation dialog appears
      expect(find.text('Simpan Proyek?'), findsOneWidget);
      expect(find.text('Keluar & Simpan'), findsOneWidget);

      // Tap 'Keluar & Simpan'
      await tester.tap(find.text('Keluar & Simpan'));
      await tester.pumpAndSettle();

      // Check that editor popped and returnedDraft was generated
      expect(find.text('Open Editor'), findsOneWidget);
      expect(returnedDraft, isNotNull);
      expect(returnedDraft!.aspectRatio, '9:16');
    });
  });
}
