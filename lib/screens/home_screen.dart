import 'package:flutter/material.dart';
import '../models/kriteria.dart';
import '../models/laptop.dart';
import '../logic/data_dummy.dart';
import '../services/storage_service.dart';
import '../theme/app_theme.dart';
import '../theme/theme_controller.dart';
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
  bool _loading = true;

  List<Kriteria> _daftarKriteria = [];
  List<Laptop> _daftarLaptop = [];

  @override
  void initState() {
    super.initState();
    _muatData();
  }

  Future<void> _muatData() async {
    final sudahAda = await StorageService.sudahPernahSimpan();
    List<Kriteria> kriteria;
    List<Laptop> laptop;

    if (sudahAda) {
      kriteria = await StorageService.loadKriteria();
      laptop = await StorageService.loadLaptop();
    } else {
      // Belum pernah nyimpen -> isi data dummy dulu biar gak kosong pas demo.
      kriteria = DataDummy.kriteriaAwal();
      laptop = DataDummy.laptopAwal();
    }

    if (!mounted) return;
    setState(() {
      _daftarKriteria = kriteria;
      _daftarLaptop = laptop;
      _loading = false;
    });
  }

  /// Dipanggil tiap ada perubahan kriteria/laptop, langsung disimpan permanen.
  void _onDataChanged() {
    setState(() {});
    StorageService.simpanSemua(daftarKriteria: _daftarKriteria, daftarLaptop: _daftarLaptop);
  }

  Future<void> _toggleTema() async {
    toggleThemeMode();
    await StorageService.simpanThemeMode(themeModeNotifier.value);
    setState(() {});
  }

  Future<void> _konfirmasiReset() async {
    final konfirmasi = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: context.colors.surface,
        title: Text('Reset Semua Data?', style: TextStyle(color: context.colors.textPrimary)),
        content: Text(
          'Semua kriteria dan data laptop yang tersimpan akan dihapus dan dikembalikan ke data contoh.',
          style: TextStyle(color: context.colors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text('Batal', style: TextStyle(color: context.colors.textSecondary)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text('Reset', style: TextStyle(color: context.colors.danger)),
          ),
        ],
      ),
    );

    if (konfirmasi == true) {
      await StorageService.hapusSemua();
      setState(() {
        _daftarKriteria = DataDummy.kriteriaAwal();
        _daftarLaptop = DataDummy.laptopAwal();
      });
      StorageService.simpanSemua(daftarKriteria: _daftarKriteria, daftarLaptop: _daftarLaptop);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return Scaffold(
        backgroundColor: context.colors.background,
        body: Center(child: CircularProgressIndicator(color: context.colors.primary)),
      );
    }

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
      body: Stack(
        children: [
          IndexedStack(index: _tabIndex, children: screens),
          Positioned(
            top: MediaQuery.of(context).padding.top + 14,
            right: 16,
            child: Row(
              children: [
                _tombolBulat(
                  icon: Icons.restart_alt_rounded,
                  onTap: _konfirmasiReset,
                ),
                const SizedBox(width: 10),
                _tombolBulat(
                  icon: themeModeNotifier.value == ThemeMode.dark
                      ? Icons.light_mode_rounded
                      : Icons.dark_mode_rounded,
                  onTap: _toggleTema,
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: context.colors.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
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

  Widget _tombolBulat({required IconData icon, required VoidCallback onTap}) {
    return Material(
      color: Colors.white.withOpacity(0.2),
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(9),
          child: Icon(icon, color: Colors.white, size: 20),
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
            Icon(icon, color: aktif ? context.colors.primary : context.colors.textSecondary, size: 24),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: aktif ? context.colors.primary : context.colors.textSecondary,
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
