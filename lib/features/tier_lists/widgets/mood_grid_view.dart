import 'package:flutter/material.dart';

import '../../../shared/models/mood_grid.dart';
import '../../../shared/models/mood_grid_cell.dart';
import '../../../shared/theme/app_spacing.dart';
import 'mood_grid_cell_media.dart';
import 'mood_grid_cell_widget.dart';
import 'mood_grid_row_captions.dart';

/// Lays out the cells of a [MoodGrid] in a `rows × cols` matrix, with an
/// optional caption column to the right of each row.
class MoodGridView extends StatelessWidget {
  const MoodGridView({
    required this.grid,
    required this.cells,
    required this.mediaByPosition,
    this.onCellTap,
    this.onCellContextMenu,
    this.cellWidth = 140,
    this.captionWidth = 220,
    super.key,
  });

  final MoodGrid grid;
  final List<MoodGridCell> cells;

  /// Preloaded media for each cell keyed by position; cells without an item
  /// map to [MoodGridCellMedia.empty].
  final Map<int, MoodGridCellMedia> mediaByPosition;

  final void Function(MoodGridCell)? onCellTap;
  final void Function(MoodGridCell, Offset)? onCellContextMenu;

  final double cellWidth;
  final double captionWidth;

  @override
  Widget build(BuildContext context) {
    final String template = grid.captionTemplate ?? '';
    final bool showCaptions = template.trim().isNotEmpty;
    return SingleChildScrollView(
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            for (int row = 0; row < grid.rows; row++)
              Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.md),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    for (int col = 0; col < grid.cols; col++)
                      _buildCell(_cellAt(row, col)),
                    if (showCaptions)
                      MoodGridRowCaptions(
                        template: template,
                        rowMedia: _rowMedia(row),
                        width: captionWidth,
                      ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildCell(MoodGridCell cell) {
    return Padding(
      key: ValueKey<int>(cell.position),
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
      child: MoodGridCellWidget(
        cell: cell,
        media: mediaByPosition[cell.position] ?? MoodGridCellMedia.empty,
        width: cellWidth,
        onTap: onCellTap == null ? null : () => onCellTap!(cell),
        onContextMenu: onCellContextMenu == null
            ? null
            : (Offset pos) => onCellContextMenu!(cell, pos),
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
