import 'package:flutter/material.dart';
import '../models/kriteria.dart';
import '../models/laptop.dart';
import '../models/hasil_aras.dart';
import '../logic/aras_calculator.dart';
import '../theme/app_theme.dart';
import '../widgets/gradient_header.dart';

class HasilScreen extends StatefulWidget {
  final List<Kriteria> daftarKriteria;
  final List<Laptop> daftarLaptop;

  const HasilScreen({
    super.key,
    required this.daftarKriteria,
    required this.daftarLaptop,
  });

  @override
  State<HasilScreen> createState() => _HasilScreenState();
}

class _HasilScreenState extends State<HasilScreen> {
  DetailPerhitunganARAS? _detail;

  void _hitung() {
    if (widget.daftarKriteria.isEmpty || widget.daftarLaptop.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lengkapi kriteria dan data laptop dulu!')),
      );
      return;
    }
    if (!ARASCalculator.bobotValid(widget.daftarKriteria)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Total bobot kriteria harus 100% dulu!')),
      );
      return;
    }
    setState(() {
      _detail = ARASCalculator.hitung(
        daftarKriteria: widget.daftarKriteria,
        daftarLaptop: widget.daftarLaptop,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final hasil = _detail?.hasilAkhir ?? [];

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const GradientHeader(
              title: 'Hasil Rekomendasi',
              subtitle: 'Ranking laptop berdasarkan metode ARAS',
              icon: Icons.leaderboard_rounded,
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _hitung,
                  icon: const Icon(Icons.calculate_rounded),
                  label: const Text('Hitung Rekomendasi'),
                ),
              ),
            ),
            Expanded(
              child: hasil.isEmpty
                  ? const Center(
                      child: Text(
                        'Tekan tombol di atas\nuntuk melihat hasil ranking.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: AppColors.textSecondary),
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
                      itemCount: hasil.length,
                      itemBuilder: (ctx, i) => _kartuHasil(hasil[i]),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _kartuHasil(HasilARAS h) {
    final juara = h.ranking == 1;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: juara ? AppColors.goldGradient : null,
        color: juara ? null : AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: juara
            ? [BoxShadow(color: AppColors.gold.withOpacity(0.3), blurRadius: 16, offset: const Offset(0, 6))]
            : null,
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: juara ? Colors.white.withOpacity(0.25) : AppColors.surfaceLight,
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Text(
              '#${h.ranking}',
              style: TextStyle(
                color: juara ? Colors.white : AppColors.textPrimary,
                fontWeight: FontWeight.w700,
                fontSize: 15,
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  h.laptop.nama,
                  style: TextStyle(
                    color: juara ? Colors.white : AppColors.textPrimary,
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  'Si = ${h.si.toStringAsFixed(4)}  ·  Ki = ${h.ki.toStringAsFixed(4)}',
                  style: TextStyle(
                    color: juara ? Colors.white.withOpacity(0.9) : AppColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          if (juara) const Icon(Icons.emoji_events_rounded, color: Colors.white, size: 26),
        ],
      ),
    );
  }
}
