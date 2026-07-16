import 'package:flutter/material.dart';
import '../models/kriteria.dart';
import '../models/laptop.dart';
import '../logic/data_dummy.dart';
import '../theme/app_theme.dart';
import 'kriteria_screen.dart';
import 'laptop_screen.dart';
import 'hasil_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _tabIndex = 0;

  // Data disimpan di memory selama app jalan.
  // Diisi data dummy dulu biar gak kosong pas demo ke dosen.
  final List<Kriteria> _daftarKriteria = DataDummy.kriteriaAwal();
  final List<Laptop> _daftarLaptop = DataDummy.laptopAwal();

  void _onDataChanged() {
    // Dipanggil tiap ada perubahan kriteria/laptop.
    // Kalau nanti mau nyambung ke local storage (sqflite/shared_preferences),
    // panggil fungsi simpan di sini.
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final screens = [
      KriteriaScreen(daftarKriteria: _daftarKriteria, onChanged: _onDataChanged),
      LaptopScreen(
        daftarLaptop: _daftarLaptop,
        daftarKriteria: _daftarKriteria,
        onChanged: _onDataChanged,
      ),
      HasilScreen(daftarKriteria: _daftarKriteria, daftarLaptop: _daftarLaptop),
    ];

    return Scaffold(
      body: IndexedStack(index: _tabIndex, children: screens),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: SafeArea(
          top: false,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _navItem(0, Icons.tune_rounded, 'Kriteria'),
              _navItem(1, Icons.laptop_mac_rounded, 'Laptop'),
              _navItem(2, Icons.leaderboard_rounded, 'Hasil'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _navItem(int index, IconData icon, String label) {
    final aktif = _tabIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _tabIndex = index),
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 6),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: aktif ? AppColors.primary : AppColors.textSecondary, size: 24),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: aktif ? AppColors.primary : AppColors.textSecondary,
                fontSize: 11,
                fontWeight: aktif ? FontWeight.w700 : FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
