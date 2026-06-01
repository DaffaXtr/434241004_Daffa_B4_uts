import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// 1. Ganti StateNotifierProvider menjadi NotifierProvider
final NotifierProvider<ThemeNotifier, ThemeMode> themeProvider = NotifierProvider<ThemeNotifier, ThemeMode>(
  () => ThemeNotifier(),
);

// 2. Ganti StateNotifier menjadi Notifier murni
class ThemeNotifier extends Notifier<ThemeMode> {
  
  // 3. Definisikan nilai default awal (ThemeMode.system) di dalam method build()
  @override
  ThemeMode build() {
    return ThemeMode.system;
  }

  // Metode pengubah state tetap bekerja dengan cara yang sama
  void setLight() => state = ThemeMode.light;
  void setDark() => state = ThemeMode.dark;
  void setSystem() => state = ThemeMode.system;
  void toggle() => state = state == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
}