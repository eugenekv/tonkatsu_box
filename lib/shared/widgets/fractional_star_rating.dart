import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// Tap/drag bar for a fractional personal rating (1.0–10.0, step 0.1).
///
/// Row of 11 cells: a leading dash cell clears the rating to `null`, followed
/// by 10 stars. Tapping/dragging the stars sets the value by horizontal
/// position; stars fill partially for fractional values. Inline — no popup.
///
/// The fill follows the pointer instantly via internal state; [onChanged] is
/// emitted on tap and at the end of a drag (not on every drag event), so a
/// slow persistence layer can't lag the visual.
class FractionalStarRating extends StatefulWidget {
  const FractionalStarRating({
    required this.onChanged,
    this.value,
    this.starSize = 24.0,
    super.key,
  });

  final double? value;
  final double starSize;

  /// Emits `null` when the leading clear cell is hit.
  final ValueChanged<double?> onChanged;

  static const int starCount = 10;
  static const double minRating = 1.0;
  static const double maxRating = 10.0;
  static const double _gap = 3.0;

  /// Natural (unconstrained) width for a given [starSize]. Useful when the
  /// widget sits inside an `IntrinsicWidth` (e.g. a popup menu), which cannot
  /// measure the internal `LayoutBuilder`.
  static double naturalWidth(double starSize) =>
      (starSize + _gap) * (starCount + 1);

  @override
  State<FractionalStarRating> createState() => _FractionalStarRatingState();
}

class _FractionalStarRatingState extends State<FractionalStarRating> {
  late double? _value = widget.value;

  @override
  void didUpdateWidget(FractionalStarRating oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.value != oldWidget.value) {
      _value = widget.value;
    }
  }

  double get _cellWidth => widget.starSize + FractionalStarRating._gap;

  static double _roundToTenth(double v) => (v * 10).roundToDouble() / 10;

  double? _valueFor(double localX, double cellWidth) {
    if (localX < cellWidth) return null;
    final double raw = (localX - cellWidth) / cellWidth;
    return _roundToTenth(
      raw.clamp(FractionalStarRating.minRating, FractionalStarRating.maxRating),
    );
  }

  void _preview(double localX, double cellWidth) {
    if (cellWidth <= 0) return;
    setState(() => _value = _valueFor(localX, cellWidth));
  }

  void _commit(double localX, double cellWidth) {
    if (cellWidth <= 0) return;
    final double? v = _valueFor(localX, cellWidth);
    setState(() => _value = v);
    widget.onChanged(v);
  }

  @override
  Widget build(BuildContext context) {
    const int starCount = FractionalStarRating.starCount;
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final double intrinsic = _cellWidth * (starCount + 1);
        // Shrink to the parent when it is narrower than the natural width,
        // so the row never overflows; otherwise keep the natural size.
        final double totalWidth =
            constraints.maxWidth.isFinite && constraints.maxWidth < intrinsic
                ? constraints.maxWidth
                : intrinsic;
        final double cellWidth = totalWidth / (starCount + 1);

        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTapDown: (TapDownDetails d) =>
              _preview(d.localPosition.dx, cellWidth),
          onTapUp: (TapUpDetails d) => _commit(d.localPosition.dx, cellWidth),
          onHorizontalDragUpdate: (DragUpdateDetails d) =>
              _preview(d.localPosition.dx, cellWidth),
          onHorizontalDragEnd: (_) => widget.onChanged(_value),
          child: SizedBox(
            width: totalWidth,
            height: widget.starSize,
            child: Row(
              children: <Widget>[
                _Cell(
                  width: cellWidth,
                  child: _ClearCell(
                    size: widget.starSize,
                    active: _value == null,
                  ),
                ),
                for (int i = 1; i <= starCount; i++)
                  _Cell(
                    width: cellWidth,
                    child: _PartialStar(
                      fill: ((_value ?? 0) - (i - 1)).clamp(0.0, 1.0),
                      size: widget.starSize,
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}

/// Fixed-width cell that scales its icon down if the column gets narrow.
class _Cell extends StatelessWidget {
  const _Cell({required this.width, required this.child});

  final double width;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: FittedBox(fit: BoxFit.scaleDown, child: child),
    );
  }
}

class _ClearCell extends StatelessWidget {
  const _ClearCell({required this.size, required this.active});

  final double size;
  final bool active;

  @override
  Widget build(BuildContext context) {
    return Icon(
      Icons.do_not_disturb_alt,
      size: size,
      color: active ? AppColors.ratingStar : AppColors.textTertiary,
    );
  }
}

class _PartialStar extends StatelessWidget {
  const _PartialStar({required this.fill, required this.size});

  /// Fill fraction, 0.0–1.0.
  final double fill;
  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        children: <Widget>[
          Icon(Icons.star_rounded, size: size, color: AppColors.textTertiary),
          if (fill > 0)
            ClipRect(
              child: Align(
                alignment: Alignment.centerLeft,
                widthFactor: fill,
                child: Icon(
                  Icons.star_rounded,
                  size: size,
                  color: AppColors.ratingStar,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
