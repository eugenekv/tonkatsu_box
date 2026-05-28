import 'package:flutter/material.dart';

import '../../../shared/models/mood_grid.dart';
import '../../../shared/models/mood_grid_cell.dart';
import '../../../shared/theme/app_assets.dart';
import '../../../shared/theme/app_colors.dart';
import '../../../shared/theme/app_spacing.dart';
import '../../../shared/theme/app_typography.dart';
import 'mood_grid_cell_media.dart';
import 'mood_grid_cell_widget.dart';
import 'mood_grid_row_captions.dart';

/// Off-screen render of a mood grid for `RepaintBoundary.toImage` export.
class MoodGridExportView extends StatelessWidget {
  const MoodGridExportView({
    required this.repaintKey,
    required this.grid,
    required this.cells,
    required this.mediaByPosition,
    super.key,
  });

  final GlobalKey repaintKey;
  final MoodGrid grid;
  final List<MoodGridCell> cells;
  final Map<int, MoodGridCellMedia> mediaByPosition;

  static const double _cellWidth = 140;
  static const double _captionWidth = 240;

  @override
  Widget build(BuildContext context) {
    final String template = grid.captionTemplate ?? '';
    final bool showCaptions = template.trim().isNotEmpty;
    final double cellsWidth =
        _cellWidth * grid.cols + AppSpacing.md * (grid.cols + 1);
    final double width =
        cellsWidth + (showCaptions ? _captionWidth + AppSpacing.md : 0);

    return RepaintBoundary(
      key: repaintKey,
      child: Container(
        width: width,
        color: AppColors.background,
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text(
              grid.name,
              textAlign: TextAlign.center,
              style: AppTypography.h2,
            ),
            const SizedBox(height: AppSpacing.lg),
            for (int row = 0; row < grid.rows; row++)
              Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.md),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    for (int col = 0; col < grid.cols; col++)
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.xs,
                        ),
                        child: MoodGridCellWidget(
                          cell: _cellAt(row, col),
                          media: mediaByPosition[row * grid.cols + col] ??
                              MoodGridCellMedia.empty,
                          width: _cellWidth,
                        ),
                      ),
                    if (showCaptions)
                      MoodGridRowCaptions(
                        template: template,
                        rowMedia: _rowMedia(row),
                        width: _captionWidth,
                      ),
                  ],
                ),
              ),
            const SizedBox(height: AppSpacing.md),
            const Divider(height: 1, color: AppColors.surfaceBorder),
            const SizedBox(height: AppSpacing.sm),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                Image.asset(AppAssets.logo, width: 16, height: 16),
                const SizedBox(width: 4),
                Text(
                  'made by Tonkatsu Box',
                  style: AppTypography.caption.copyWith(
                    color: AppColors.textTertiary,
                    fontSize: 10,
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
          ],
        ),
      ),
    );
  }

  MoodGridCell _cellAt(int row, int col) {
    final int pos = row * grid.cols + col;
    return cells.firstWhere(
      (MoodGridCell c) => c.position == pos,
      orElse: () => MoodGridCell(id: -1, gridId: grid.id, position: pos),
    );
  }

  List<MoodGridCellMedia> _rowMedia(int row) {
    return <MoodGridCellMedia>[
      for (int col = 0; col < grid.cols; col++)
        mediaByPosition[row * grid.cols + col] ?? MoodGridCellMedia.empty,
    ];
  }
}
