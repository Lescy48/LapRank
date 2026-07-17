import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/kriteria.dart';
import '../models/laptop.dart';

/// Membungkus shared_preferences supaya data kriteria, laptop, dan
/// preferensi tema tetap tersimpan walau aplikasi ditutup.
class StorageService {
  static const _keyKriteria = 'data_kriteria';
  static const _keyLaptop = 'data_laptop';
  static const _keyThemeMode = 'theme_mode';
  static const _keySudahAdaData = 'sudah_ada_data';

  /// Menandakan apakah data pernah disimpan sebelumnya.
  /// Dipakai untuk memutuskan apakah perlu load data dummy di awal.
  static Future<bool> sudahPernahSimpan() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keySudahAdaData) ?? false;
  }

  static Future<void> simpanSemua({
    required List<Kriteria> daftarKriteria,
    required List<Laptop> daftarLaptop,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonKriteria = jsonEncode(daftarKriteria.map((k) => k.toJson()).toList());
    final jsonLaptop = jsonEncode(daftarLaptop.map((l) => l.toJson()).toList());
    await prefs.setString(_keyKriteria, jsonKriteria);
    await prefs.setString(_keyLaptop, jsonLaptop);
    await prefs.setBool(_keySudahAdaData, true);
  }

  static Future<List<Kriteria>> loadKriteria() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_keyKriteria);
    if (raw == null || raw.isEmpty) return [];
    try {
      final List decoded = jsonDecode(raw) as List;
      return decoded.map((e) => Kriteria.fromJson(e as Map<String, dynamic>)).toList();
    } catch (_) {
      return [];
    }
  }

  static Future<List<Laptop>> loadLaptop() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_keyLaptop);
    if (raw == null || raw.isEmpty) return [];
    try {
      final List decoded = jsonDecode(raw) as List;
      return decoded.map((e) => Laptop.fromJson(e as Map<String, dynamic>)).toList();
    } catch (_) {
      return [];
    }
  }

  static Future<void> simpanThemeMode(ThemeMode mode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyThemeMode, mode.name);
  }

  static Future<ThemeMode> loadThemeMode() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_keyThemeMode);
    if (raw == 'light') return ThemeMode.light;
    return ThemeMode.dark;
  }

  /// Hapus semua data tersimpan (opsional, buat tombol "Reset Data").
  static Future<void> hapusSemua() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyKriteria);
    await prefs.remove(_keyLaptop);
    await prefs.setBool(_keySudahAdaData, false);
  }
}
