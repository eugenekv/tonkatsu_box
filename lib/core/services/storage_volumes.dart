import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:logging/logging.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

/// A mounted storage volume usable as a folder-picker root.
class StorageVolume {
  /// Creates a [StorageVolume].
  const StorageVolume({required this.path, required this.isPrimary});

  /// Volume root directory.
  final String path;

  /// Whether this is the built-in internal storage.
  final bool isPrimary;
}

/// Detects mounted storage volumes on Android.
class StorageVolumes {
  StorageVolumes._();

  static final Logger _log = Logger('StorageVolumes');

  /// Test seam: the OS query for per-volume app-specific directories.
  /// Each entry looks like `<volume>/Android/data/<pkg>/files`.
  @visibleForTesting
  static Future<List<Directory>?> Function() externalDirsProvider =
      () => getExternalStorageDirectories();

  /// Canonical primary (internal) storage path.
  static String get primaryPath => p.join('/storage', 'emulated', '0');

  /// Internal storage plus mounted removable volumes (SD card).
  ///
  /// Volume roots are derived from [getExternalStorageDirectories]
  /// (`getExternalFilesDirs` under the hood) by trimming the
  /// `/Android/data/<pkg>/files` suffix — never by listing `/storage`,
  /// which Android 11+ refuses with a permission error regardless of
  /// "All files access". The first entry is the primary volume. USB OTG
  /// is not reported: `getExternalFilesDirs` excludes it, and on modern
  /// Android it is reachable only through SAF (no real path).
  static Future<List<StorageVolume>> detect() async {
    List<Directory>? appDirs;
    try {
      appDirs = await externalDirsProvider();
    } on Exception catch (e) {
      _log.warning('Failed to query external storage directories', e);
    }

    final List<StorageVolume> volumes = <StorageVolume>[];
    if (appDirs != null) {
      for (int i = 0; i < appDirs.length; i++) {
        final String? root = _volumeRoot(appDirs[i].path);
        if (root == null) continue;
        if (volumes.any((StorageVolume v) => v.path == root)) continue;
        volumes.add(StorageVolume(path: root, isPrimary: i == 0));
      }
    }

    // Fallback to canonical internal storage when the query yields nothing.
    if (volumes.isEmpty && Directory(primaryPath).existsSync()) {
      volumes.add(StorageVolume(path: primaryPath, isPrimary: true));
    }
    return volumes;
  }

  /// `/storage/XXXX/Android/data/<pkg>/files` → `/storage/XXXX`.
  static String? _volumeRoot(String appSpecificDir) {
    const String marker = '/Android/';
    final int idx = appSpecificDir.indexOf(marker);
    if (idx <= 0) return null;
    return appSpecificDir.substring(0, idx);
  }
}
