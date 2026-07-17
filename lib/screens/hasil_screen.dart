import 'package:flutter/material.dart';
import '../models/kriteria.dart';
import '../models/laptop.dart';
import '../models/hasil_aras.dart';
import '../logic/aras_calculator.dart';
import '../services/export_service.dart';
import '../theme/app_theme.dart';
import '../widgets/gradient_header.dart';
import '../widgets/topography_background.dart';
import 'detail_perhitungan_screen.dart';

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
  bool _mengekspor = false;

  void _hitung() {
    if (widget.daftarKriteria.isEmpty || widget.daftarLaptop.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lengkapi kriteria dan data laptop dulu!'),
        duration: Duration(seconds: 3),
        ),
      );
      return;
    }
    if (!ARASCalculator.bobotValid(widget.daftarKriteria)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Total bobot kriteria harus 100% dulu!'),
          duration: const Duration(seconds: 3),
        ),
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

  void _bukaDetailPerhitungan() {
    if (_detail == null) return;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => DetailPerhitunganScreen(
          detail: _detail!,
          daftarKriteria: widget.daftarKriteria,
        ),
      ),
    );
  }

  Future<void> _export(String tipe) async {
    if (_detail == null || _detail!.hasilAkhir.isEmpty) return;
    setState(() => _mengekspor = true);
    try {
      if (tipe == 'pdf') {
        await ExportService.exportPdf(
          hasil: _detail!.hasilAkhir,
          daftarKriteria: widget.daftarKriteria,
        );
      } else {
        await ExportService.exportCsv(hasil: _detail!.hasilAkhir);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal export: $e'),
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _mengekspor = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final hasil = _detail?.hasilAkhir ?? [];

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          const TopographyBackground(),
          SafeArea(
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
            if (hasil.isNotEmpty)
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _bukaDetailPerhitungan,
                        icon: Icon(Icons.list_alt_rounded, color: context.colors.primary, size: 18),
                        label: Text('Detail Perhitungan', style: TextStyle(color: context.colors.primary)),
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: context.colors.primary),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    _tombolExport(),
                  ],
                ),
              ),
            Expanded(
              child: hasil.isEmpty
                  ? Center(
                      child: Text(
                        'Tekan tombol di atas\nuntuk melihat hasil ranking.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: context.colors.textSecondary),
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
        ],
      ),
    );
  }

  Widget _tombolExport() {
    if (_mengekspor) {
      return Container(
        width: 46,
        height: 46,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: context.colors.surfaceLight,
          borderRadius: BorderRadius.circular(14),
        ),
        child: SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(strokeWidth: 2, color: context.colors.primary),
        ),
      );
    }

    return PopupMenuButton<String>(
      onSelected: _export,
      color: context.colors.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      itemBuilder: (ctx) => [
        PopupMenuItem(
          value: 'pdf',
          child: Row(
            children: [
              Icon(Icons.picture_as_pdf_rounded, color: context.colors.danger, size: 18),
              const SizedBox(width: 10),
              Text('Export PDF', style: TextStyle(color: context.colors.textPrimary)),
            ],
          ),
        ),
        PopupMenuItem(
          value: 'csv',
          child: Row(
            children: [
              Icon(Icons.grid_on_rounded, color: context.colors.success, size: 18),
              const SizedBox(width: 10),
              Text('Export Excel (CSV)', style: TextStyle(color: context.colors.textPrimary)),
            ],
          ),
        ),
      ],
      child: Container(
        width: 46,
        height: 46,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: context.colors.surfaceLight,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Icon(Icons.ios_share_rounded, color: context.colors.textPrimary, size: 20),
      ),
    );
  }

  Widget _kartuHasil(HasilARAS h) {
    final juara = h.ranking == 1;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: juara ? context.colors.goldGradient : null,
        color: juara ? null : context.colors.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: juara
            ? [BoxShadow(color: context.colors.gold.withOpacity(0.3), blurRadius: 16, offset: const Offset(0, 6))]
            : null,
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: juara ? Colors.white.withOpacity(0.25) : context.colors.surfaceLight,
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Text(
              '#${h.ranking}',
              style: TextStyle(
                color: juara ? Colors.white : context.colors.textPrimary,
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
                    color: juara ? Colors.white : context.colors.textPrimary,
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  'Si = ${h.si.toStringAsFixed(4)}  ·  Ki = ${h.ki.toStringAsFixed(4)}',
                  style: TextStyle(
                    color: juara ? Colors.white.withOpacity(0.9) : context.colors.textSecondary,
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