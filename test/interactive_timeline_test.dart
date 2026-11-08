import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:bil_cut/presentation/screens/editor_screen.dart';
import 'package:bil_cut/presentation/widgets/timeline/custom_time_ruler.dart';
import 'package:bil_cut/presentation/widgets/timeline/timeline_track_widget.dart';

void main() {
  testWidgets('EditorScreen mounts with InteractiveTimeline, Ruler, and Tracks',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: EditorScreen(),
        ),
      ),
    );

    await tester.pumpAndSettle();

    // Verify presence of interactive timeline components
    expect(find.byType(CustomTimeRuler), findsOneWidget);
    expect(find.byType(TimelineTrackWidget), findsWidgets);
    expect(find.text('Bagi'), findsWidgets);
    expect(find.text('Ekspor'), findsOneWidget);
  });
}

