// coverage:ignore-file

import 'package:flutter/material.dart';
import 'package:tnds_flutter_app/src/themes/app_colors_extension.dart';
import 'package:tnds_flutter_app/src/themes/app_text_extension.dart';
import 'package:tnds_flutter_app/src/themes/app_theme.dart';

extension BuildContextExtensions on BuildContext {
  ThemeData get theme => Theme.of(this);

  AppTextExtension get appTexts => theme.appTexts;

  AppColorsExtension get appColors => theme.appColors;

  MediaQueryData get mediaQuery => MediaQuery.of(this);

  FocusScopeNode get focusScope => FocusScope.of(this);

  ScaffoldMessengerState get scaffoldMessenger => ScaffoldMessenger.of(this);
}
