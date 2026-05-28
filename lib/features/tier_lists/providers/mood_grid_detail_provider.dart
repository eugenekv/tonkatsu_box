import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/dao/mood_grid_dao.dart';
import '../../../core/database/database_service.dart';
import '../../../shared/models/media_type.dart';
import '../../../shared/models/mood_grid.dart';
import '../../../shared/models/mood_grid_cell.dart';
import '../widgets/mood_grid_cell_media.dart';
import 'mood_grids_provider.dart';

class MoodGridDetailState {
  const MoodGridDetailState({
    required this.grid,
    required this.cells,
    required this.mediaByPosition,
  });

  final MoodGrid grid;
  final List<MoodGridCell> cells;

  /// Resolved cell media keyed by cell position. Cells with no item map to
  /// [MoodGridCellMedia.empty] so callers can index without null checks.
  final Map<int, MoodGridCellMedia> mediaByPosition;

  MoodGridDetailState copyWith({
    MoodGrid? grid,
    List<MoodGridCell>? cells,
    Map<int, MoodGridCellMedia>? mediaByPosition,
  }) {
    return MoodGridDetailState(
      grid: grid ?? this.grid,
      cells: cells ?? this.cells,
      mediaByPosition: mediaByPosition ?? this.mediaByPosition,
    );
  }
}

final AsyncNotifierProviderFamily<MoodGridDetailNotifier, MoodGridDetailState,
        int> moodGridDetailProvider =
    AsyncNotifierProvider.family<MoodGridDetailNotifier, MoodGridDetailState,
        int>(
  MoodGridDetailNotifier.new,
);

class MoodGridDetailNotifier
    extends FamilyAsyncNotifier<MoodGridDetailState, int> {
  late MoodGridDao _dao;
  late DatabaseService _db;

  @override
  Future<MoodGridDetailState> build(int arg) async {
    _dao = ref.watch(moodGridDaoProvider);
    _db = ref.watch(databaseServiceProvider);
    final MoodGrid? grid = await _dao.getMoodGridById(arg);
    if (grid == null) {
      throw StateError('Mood grid $arg not found');
    }
    final List<MoodGridCell> cells = await _dao.getCells(arg);
    final Map<int, MoodGridCellMedia> media = await _resolveAll(cells);
    return MoodGridDetailState(
      grid: grid,
      cells: cells,
      mediaByPosition: media,
    );
  }

  Future<Map<int, MoodGridCellMedia>> _resolveAll(
    List<MoodGridCell> cells,
  ) async {
    final List<MoodGridCellMedia> resolved = await Future.wait(
      cells.map(_resolveOne),
    );
    return <int, MoodGridCellMedia>{
      for (int i = 0; i < cells.length; i++) cells[i].position: resolved[i],
    };
  }

  Future<MoodGridCellMedia> _resolveOne(MoodGridCell cell) {
    if (cell.isEmpty) {
      return Future<MoodGridCellMedia>.value(MoodGridCellMedia.empty);
    }
    return resolveMoodGridCellMedia(
      _db,
      cell.mediaType!,
      cell.externalId!,
      cell.platformId,
    );
  }

  Future<void> rename(String name) async {
    await _dao.renameMoodGrid(arg, name);
    final MoodGridDetailState? current = state.valueOrNull;
    if (current == null) return;
    state = AsyncData<MoodGridDetailState>(
      current.copyWith(
        grid: current.grid.copyWith(name: name, updatedAt: DateTime.now()),
      ),
    );
    ref.invalidate(moodGridsProvider);
  }

  Future<void> setCaptionTemplate(String? template) async {
    final String? normalised =
        (template == null || template.isEmpty) ? null : template;
    await _dao.setCaptionTemplate(arg, normalised);
    final MoodGridDetailState? current = state.valueOrNull;
    if (current == null) return;
    state = AsyncData<MoodGridDetailState>(
      current.copyWith(
        grid: current.grid.copyWith(
          captionTemplate: normalised,
          clearCaptionTemplate: normalised == null,
          updatedAt: DateTime.now(),
        ),
      ),
    );
    ref.invalidate(moodGridsProvider);
  }

  Future<void> setCellLabel(int cellId, String? label) async {
    await _dao.setCellLabel(cellId, label);
    _replaceCell(cellId, (MoodGridCell c) =>
        c.copyWith(label: label, clearLabel: label == null));
    ref.invalidate(moodGridsProvider);
  }

  Future<void> setCellItem({
    required int cellId,
    required MediaType mediaType,
    required int externalId,
    int? platformId,
  }) async {
    await _dao.setCellItem(
      cellId: cellId,
      mediaType: mediaType,
      externalId: externalId,
      platformId: platformId,
    );
    await _replaceCellAndMedia(
      cellId,
      (MoodGridCell c) => c.copyWith(
        mediaType: mediaType,
        externalId: externalId,
        platformId: platformId,
      ),
    );
    ref.invalidate(moodGridsProvider);
  }

  Future<void> clearCellItem(int cellId) async {
    await _dao.clearCellItem(cellId);
    await _replaceCellAndMedia(
      cellId,
      (MoodGridCell c) => c.copyWith(clearItem: true),
    );
    ref.invalidate(moodGridsProvider);
  }

  Future<void> resize({required int newRows, required int newCols}) async {
    await _dao.resizeMoodGrid(arg, newRows: newRows, newCols: newCols);
    final MoodGrid? grid = await _dao.getMoodGridById(arg);
    if (grid == null) return;
    final List<MoodGridCell> cells = await _dao.getCells(arg);
    final Map<int, MoodGridCellMedia> media = await _resolveAll(cells);
    state = AsyncData<MoodGridDetailState>(
      MoodGridDetailState(
        grid: grid,
        cells: cells,
        mediaByPosition: media,
      ),
    );
    ref.invalidate(moodGridsProvider);
  }

  void _replaceCell(int cellId, MoodGridCell Function(MoodGridCell) update) {
    final MoodGridDetailState? current = state.valueOrNull;
    if (current == null) return;
    final List<MoodGridCell> next = current.cells.map((MoodGridCell c) {
      if (c.id != cellId) return c;
      return update(c);
    }).toList();
    state = AsyncData<MoodGridDetailState>(current.copyWith(cells: next));
  }

  Future<void> _replaceCellAndMedia(
    int cellId,
    MoodGridCell Function(MoodGridCell) update,
  ) async {
    final MoodGridDetailState? current = state.valueOrNull;
    if (current == null) return;
    MoodGridCell? updated;
    final List<MoodGridCell> next = current.cells.map((MoodGridCell c) {
      if (c.id != cellId) return c;
      updated = update(c);
      return updated!;
    }).toList();
    if (updated == null) return;
    final MoodGridCellMedia media = await _resolveOne(updated!);
    final Map<int, MoodGridCellMedia> nextMedia =
        Map<int, MoodGridCellMedia>.of(current.mediaByPosition);
    nextMedia[updated!.position] = media;
    state = AsyncData<MoodGridDetailState>(
      current.copyWith(cells: next, mediaByPosition: nextMedia),
    );
  }
}
