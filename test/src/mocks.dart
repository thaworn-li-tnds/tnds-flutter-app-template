import 'dart:ui';

import 'package:easy_localization/easy_localization.dart';

/// In-memory translations for tests — keep keys in sync with
/// `assets/translations/` when a test asserts on localized text.
class TestAssetLoader extends AssetLoader {
  const TestAssetLoader();

  @override
  Future<Map<String, dynamic>> load(String path, Locale locale) async {
    return {
      'common': {
        'close': 'Close',
        'error': {
          'title': 'Something went wrong',
          'description': 'Please try again.',
        },
      },
    };
  }
}
