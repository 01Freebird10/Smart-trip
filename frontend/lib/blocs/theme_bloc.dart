import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/hive_flutter.dart';

class ThemeState {
  final ThemeMode themeMode;
  final Color primaryColor;

  ThemeState({required this.themeMode, required this.primaryColor});
}

class ThemeRepository {
  final Box settingsBox;
  static const String _themeKey = 'theme_mode';
  static const String _colorKey = 'primary_color';

  ThemeRepository(this.settingsBox);

  ThemeState getThemeState() {
    final mode = settingsBox.get(_themeKey, defaultValue: 'dark');
    final colorVal = settingsBox.get(_colorKey, defaultValue: 0xFF0091EA);
    return ThemeState(
      themeMode: mode == 'light' ? ThemeMode.light : ThemeMode.dark,
      primaryColor: Color(colorVal as int),
    );
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    await settingsBox.put(_themeKey, mode == ThemeMode.light ? 'light' : 'dark');
  }

  Future<void> setPrimaryColor(Color color) async {
    await settingsBox.put(_colorKey, color.value);
  }
}

class ThemeBloc extends Bloc<ThemeEvent, ThemeState> {
  final ThemeRepository repository;

  ThemeBloc(this.repository) : super(repository.getThemeState()) {
    on<ToggleTheme>((event, emit) async {
      final newMode = state.themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
      await repository.setThemeMode(newMode);
      emit(ThemeState(themeMode: newMode, primaryColor: state.primaryColor));
    });

    on<ChangePrimaryColor>((event, emit) async {
      await repository.setPrimaryColor(event.color);
      emit(ThemeState(themeMode: state.themeMode, primaryColor: event.color));
    });
  }
}

abstract class ThemeEvent {}
class ToggleTheme extends ThemeEvent {}
class ChangePrimaryColor extends ThemeEvent {
  final Color color;
  ChangePrimaryColor(this.color);
}
