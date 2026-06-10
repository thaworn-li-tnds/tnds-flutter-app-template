import 'dart:convert';
import 'dart:ui';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/services.dart';

/// Loads and merges every JSON file under `assets/translations/<locale>/`
/// (the per-feature file layout that `tool/gen_locale_keys.dart` reads),
/// namespaced by file name: `common.json` → keys under `common.*`.
class FolderAssetLoader extends AssetLoader {
  const FolderAssetLoader();

  @override
  Future<Map<String, dynamic>> load(String path, Locale locale) async {
    final manifest = await AssetManifest.loadFromAssetBundle(rootBundle);
    final prefix = '$path/${locale.languageCode}/';
    final files = manifest
        .listAssets()
        .where((a) => a.startsWith(prefix) && a.endsWith('.json'));

    final merged = <String, dynamic>{};
    for (final file in files) {
      final namespace = file.split('/').last.replaceAll('.json', '');
      final content = await rootBundle.loadString(file);
      merged[namespace] = json.decode(content);
    }
    return merged;
  }
}
