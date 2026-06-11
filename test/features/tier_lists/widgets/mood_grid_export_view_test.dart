import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tonkatsu_box/features/tier_lists/widgets/mood_grid_cell_media.dart';
import 'package:tonkatsu_box/features/tier_lists/widgets/mood_grid_export_view.dart';
import 'package:tonkatsu_box/shared/models/mood_grid.dart';
import 'package:tonkatsu_box/shared/models/mood_grid_cell.dart';

import '../../../helpers/test_helpers.dart';

void main() {
  setUpAll(registerAllFallbacks);

  group('MoodGridExportView', () {
    late GlobalKey repaintKey;

    setUp(() {
      repaintKey = GlobalKey();
    });

    MoodGrid createGrid({int rows = 2, int cols = 2, String? template}) {
      return MoodGrid(
        id: 1,
        name: 'My Mood Grid',
        rows: rows,
        cols: cols,
        captionTemplate: template,
        createdAt: testDate,
        updatedAt: testDate,
      );
    }

    Future<void> pumpView(WidgetTester tester, MoodGrid grid) async {
      await tester.pumpApp(
        Material(
          child: SingleChildScrollView(
            child: MoodGridExportView(
              repaintKey: repaintKey,
              grid: grid,
              cells: const <MoodGridCell>[],
              mediaByPosition: const <int, MoodGridCellMedia>{},
            ),
          ),
        ),
        settle: false,
      );
      await tester.pump();
    }

    testWidgets('should render without layout overflow', (
      WidgetTester tester,
    ) async {
      await pumpView(tester, createGrid());

      expect(tester.takeException(), isNull);
      expect(find.byType(MoodGridExportView), findsOneWidget);
      expect(find.text('My Mood Grid'), findsOneWidget);
    });

    testWidgets('should render without overflow when captions are shown', (
      WidgetTester tester,
    ) async {
      await pumpView(tester, createGrid(template: '{title}'));

      expect(tester.takeException(), isNull);
      expect(find.byType(MoodGridExportView), findsOneWidget);
    });

    testWidgets('should render without overflow for a single column', (
      WidgetTester tester,
    ) async {
      await pumpView(tester, createGrid(rows: 1, cols: 1));

      expect(tester.takeException(), isNull);
    });
  });
}
