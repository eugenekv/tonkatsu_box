import 'package:flutter/material.dart';

import '../../../shared/theme/app_colors.dart';
import '../../../shared/theme/app_spacing.dart';
import '../../../shared/theme/app_typography.dart';
import '../services/mood_grid_caption.dart';
import 'mood_grid_cell_media.dart';

/// Multi-line caption column shown to the right of a mood-grid row.
/// Lines are tight-packed using natural text height — the column aligns
/// to the top of the row, not stretched to match cell heights.
class MoodGridRowCaptions extends StatelessWidget {
  const MoodGridRowCaptions({
    required this.template,
    required this.rowMedia,
    this.width = 220,
    super.key,
  });

  final String template;
  final List<MoodGridCellMedia> rowMedia;
  final double width;

  @override
  Widget build(BuildContext context) {
    if (template.trim().isEmpty) return const SizedBox.shrink();
    return SizedBox(
      width: width,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            for (final MoodGridCellMedia media in rowMedia)
              Text(
                renderRowCaption(template, media),
                style: AppTypography.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                  height: 1.15,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
          ],
        ),
      ),
    );
  }
}
