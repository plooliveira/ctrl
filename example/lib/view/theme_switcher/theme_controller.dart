import 'package:flutter/material.dart';
import 'package:ctrl/ctrl.dart';
import '../../core/theme/app_themes.dart';
import '../../core/theme/theme_mode.dart';

// Controller for managing theme switching logic. In this example, it allows switching
// between light, dark, and custom themes using hotswappable Observable.
// Of course that is not necessary for themes, but it serves as a good example of how to use
// HotswapObservable in a Controller.

class ThemeController extends Controller {
  late final _lightTheme = mutable(AppThemes.light());
  late final _darkTheme = mutable(AppThemes.dark());
  late final _customTheme = mutable(AppThemes.custom());

  // HotswapObservable allows switching reactive data sources without losing existing subscribers.
  late final HotswapObservable<ThemeData> currentTheme = _lightTheme
      .hotswappable(scope);

  late final _currentMode = mutable(AppThemeMode.light);
  Observable<AppThemeMode> get themeMode => _currentMode;

  void switchToLight() {
    // disposeOld: false keeps theme references for reuse
    currentTheme.hotswap(_lightTheme, disposeOld: false);
    _currentMode.value = AppThemeMode.light;
  }

  void switchToDark() {
    currentTheme.hotswap(_darkTheme, disposeOld: false);
    _currentMode.value = AppThemeMode.dark;
  }

  void switchToCustom() {
    currentTheme.hotswap(_customTheme, disposeOld: false);
    _currentMode.value = AppThemeMode.custom;
  }
}
