import 'package:flutter/material.dart';

import '../../../../../l10n/app_localizations.dart';
import '../../../../../shared/models/collection_tag.dart';
import '../../../../../shared/theme/app_colors.dart';
import '../../../../../shared/theme/app_spacing.dart';
import '../../../../../shared/theme/app_typography.dart';

class TagCell extends StatelessWidget {
  const TagCell({
    this.tag,
    this.tags = const <CollectionTag>[],
    this.onTagChanged,
    super.key,
  });

  final CollectionTag? tag;
  final List<CollectionTag> tags;
  final ValueChanged<int?>? onTagChanged;

  @override
  Widget build(BuildContext context) {
    final Widget content = tag != null
        ? Align(
            alignment: Alignment.centerLeft,
            child: _buildTagChip(tag!),
          )
        : const SizedBox.shrink();

    if (onTagChanged == null || tags.isEmpty) return content;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => _showTagPopup(context),
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: content,
      ),
    );
  }

  Widget _buildTagChip(CollectionTag t) {
    final Color chipColor =
        t.color != null ? Color(t.color!) : AppColors.textSecondary;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: chipColor.withAlpha(40),
        borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
        border: Border.all(color: chipColor.withAlpha(110)),
      ),
      child: Text(
        t.name,
        style: AppTypography.caption.copyWith(
          color: chipColor,
          fontSize: 10,
          fontWeight: FontWeight.w600,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  void _showTagPopup(BuildContext context) {
    final RenderBox box = context.findRenderObject()! as RenderBox;
    final Offset offset = box.localToGlobal(Offset.zero);
    final Size size = box.size;

    final S l = S.of(context);

    final List<PopupMenuEntry<int?>> items = <PopupMenuEntry<int?>>[
      PopupMenuItem<int?>(
        value: -1,
        height: 36,
        child: Row(
          children: <Widget>[
            const Icon(
              Icons.label_off_outlined,
              size: 16,
              color: AppColors.textTertiary,
            ),
            const SizedBox(width: 8),
            Text(
              l.tagNone,
              style: AppTypography.body.copyWith(
                fontSize: 13,
                color: AppColors.textSecondary,
              ),
            ),
            const Spacer(),
            if (tag == null)
              const Icon(
                Icons.check_rounded,
                size: 16,
                color: AppColors.brand,
              ),
          ],
        ),
      ),
      const PopupMenuDivider(height: 1),
      ...tags.map((CollectionTag t) {
        final Color chipColor =
            t.color != null ? Color(t.color!) : AppColors.textSecondary;
        return PopupMenuItem<int?>(
          value: t.id,
          height: 36,
          child: Row(
            children: <Widget>[
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: chipColor,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  t.name,
                  style: AppTypography.body.copyWith(fontSize: 13),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (tag?.id == t.id)
                const Icon(
                  Icons.check_rounded,
                  size: 16,
                  color: AppColors.brand,
                ),
            ],
          ),
        );
      }),
    ];

    showMenu<int?>(
      context: context,
      position: RelativeRect.fromLTRB(
        offset.dx,
        offset.dy + size.height,
        offset.dx + size.width,
        offset.dy + size.height,
      ),
      items: items,
    ).then((int? value) {
      if (value == null) return;
      if (value == -1) {
        if (tag != null) onTagChanged!(null);
      } else if (value != tag?.id) {
        onTagChanged!(value);
      }
    });
  }
}
