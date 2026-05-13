import 'package:flutter/material.dart';

import '../../../../../shared/theme/app_colors.dart';
import '../../../../../shared/theme/app_typography.dart';

class RatingCell extends StatelessWidget {
  const RatingCell({
    required this.rating,
    this.onRatingChanged,
    super.key,
  });

  final int? rating;
  final ValueChanged<int?>? onRatingChanged;

  @override
  Widget build(BuildContext context) {
    final Widget content = rating == null
        ? Text(
            '—',
            textAlign: TextAlign.center,
            style: AppTypography.body.copyWith(
              color: AppColors.textTertiary,
              fontSize: 13,
            ),
          )
        : Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              const Icon(
                Icons.star_rounded,
                size: 14,
                color: AppColors.ratingStar,
              ),
              const SizedBox(width: 2),
              Text(
                rating.toString(),
                style: AppTypography.body.copyWith(
                  color: AppColors.ratingStar,
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
            ],
          );

    if (onRatingChanged == null) return content;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => _showRatingPopup(context),
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: content,
      ),
    );
  }

  void _showRatingPopup(BuildContext context) {
    final RenderBox box = context.findRenderObject()! as RenderBox;
    final Offset offset = box.localToGlobal(Offset.zero);
    final Size size = box.size;

    showMenu<int?>(
      context: context,
      position: RelativeRect.fromLTRB(
        offset.dx,
        offset.dy + size.height,
        offset.dx + size.width,
        offset.dy + size.height,
      ),
      constraints: const BoxConstraints(maxWidth: 240),
      items: <PopupMenuEntry<int?>>[
        _RatingPopupItem(currentRating: rating),
      ],
    ).then((int? value) {
      // value == -1 → clear, null → dismissed
      if (value == null) return;
      onRatingChanged!(value == -1 ? null : value);
    });
  }
}

class _RatingPopupItem extends PopupMenuEntry<int?> {
  const _RatingPopupItem({required this.currentRating});

  final int? currentRating;

  @override
  double get height => 40;

  @override
  bool represents(int? value) => false;

  @override
  State<_RatingPopupItem> createState() => _RatingPopupItemState();
}

class _RatingPopupItemState extends State<_RatingPopupItem> {
  int? _hoveredRating;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          _buildClearButton(),
          const SizedBox(width: 4),
          for (int i = 1; i <= 10; i++) _buildStar(i),
        ],
      ),
    );
  }

  Widget _buildClearButton() {
    return InkWell(
      onTap: () => Navigator.of(context).pop(-1),
      borderRadius: BorderRadius.circular(4),
      child: const Padding(
        padding: EdgeInsets.all(2),
        child: Icon(
          Icons.close_rounded,
          size: 16,
          color: AppColors.textTertiary,
        ),
      ),
    );
  }

  Widget _buildStar(int value) {
    final bool isActive =
        widget.currentRating != null && value <= widget.currentRating!;
    final bool isHovered =
        _hoveredRating != null && value <= _hoveredRating!;

    return MouseRegion(
      onEnter: (_) => setState(() => _hoveredRating = value),
      onExit: (_) => setState(() => _hoveredRating = null),
      child: GestureDetector(
        onTap: () => Navigator.of(context).pop(value),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 1),
          child: Icon(
            isHovered || isActive
                ? Icons.star_rounded
                : Icons.star_border_rounded,
            size: 18,
            color: isHovered
                ? AppColors.ratingStar
                : isActive
                    ? AppColors.ratingStar.withAlpha(180)
                    : AppColors.textTertiary,
          ),
        ),
      ),
    );
  }
}
