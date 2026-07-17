import 'package:flutter/material.dart';
import '../models/kriteria.dart';
import '../logic/aras_calculator.dart';
import '../theme/app_theme.dart';
import '../widgets/gradient_header.dart';
import '../widgets/topography_background.dart';

/// Menampilkan tiap tahap perhitungan ARAS dalam bentuk tabel,
/// berguna sebagai bukti perhitungan sesuai teori saat presentasi ke dosen.
class DetailPerhitunganScreen extends StatelessWidget {
  final DetailPerhitunganARAS detail;
  final List<Kriteria> daftarKriteria;

  const DetailPerhitunganScreen({
    super.key,
    required this.detail,
    required this.daftarKriteria,
  });

  String _namaBaris(String id) {
    if (id == ARASCalculator.idAlternatifOptimal) return 'A0 (Optimal)';
    final hasilSesuai = detail.hasilAkhir.where((h) => h.laptop.id == id);
    if (hasilSesuai.isEmpty) return id;
    return hasilSesuai.first.laptop.nama;
  }

  @override
  Widget build(BuildContext context) {
    // urutan baris: A0 dulu, baru laptop sesuai urutan input awal
    final urutanId = detail.matriksAwal.keys.toList();

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          const TopographyBackground(),
          SafeArea(
        child: Column(
          children: [
            GradientHeader(
              title: 'Detail Perhitungan',
              subtitle: 'Tahapan lengkap metode ARAS',
              icon: Icons.functions_rounded,
              trailing: _tombolKembali(context),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  _judulBagian(context, '1. Matriks Awal + Alternatif Optimal (A0)'),
                  _tabelMatriks(context, detail.matriksAwal, urutanId),
                  const SizedBox(height: 24),
                  _judulBagian(context, '2. Matriks Normalisasi'),
                  _tabelMatriks(context, detail.matriksNormalisasi, urutanId, desimal: true),
                  const SizedBox(height: 24),
                  _judulBagian(context, '3. Matriks Terbobot'),
                  _tabelMatriks(context, detail.matriksTerbobot, urutanId, desimal: true),
                  const SizedBox(height: 24),
                  _judulBagian(context, '4 & 5. Nilai Si dan Ki (Ranking)'),
                  _tabelSiKi(context, urutanId),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ],
        ),
      ),
        ],
      ),
    );
  }

  Widget _tombolKembali(BuildContext context) {
    return Material(
      color: Colors.white.withOpacity(0.2),
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: () => Navigator.pop(context),
        child: const Padding(
          padding: EdgeInsets.all(9),
          child: Icon(Icons.close_rounded, color: Colors.white, size: 20),
        ),
      ),
    );
  }

  Widget _judulBagian(BuildContext context, String judul) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(
        judul,
        style: TextStyle(color: context.colors.textPrimary, fontWeight: FontWeight.w700, fontSize: 15),
      ),
    );
  }

  Widget _tabelMatriks(
    BuildContext context,
    Map<String, Map<String, double>> matriks,
    List<String> urutanId, {
    bool desimal = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      clipBehavior: Clip.antiAlias,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          headingRowColor: MaterialStateProperty.all(context.colors.surfaceLight),
          columns: [
            DataColumn(label: Text('Alternatif', style: TextStyle(color: context.colors.textPrimary, fontWeight: FontWeight.w700))),
            ...daftarKriteria.map(
              (k) => DataColumn(label: Text(k.nama, style: TextStyle(color: context.colors.textPrimary, fontWeight: FontWeight.w700))),
            ),
          ],
          rows: urutanId.map((id) {
            final isA0 = id == ARASCalculator.idAlternatifOptimal;
            return DataRow(
              color: isA0 ? MaterialStateProperty.all(context.colors.primary.withOpacity(0.08)) : null,
              cells: [
                DataCell(Text(
                  _namaBaris(id),
                  style: TextStyle(
                    color: context.colors.textPrimary,
                    fontWeight: isA0 ? FontWeight.w700 : FontWeight.w400,
                  ),
                )),
                ...daftarKriteria.map((k) {
                  final nilai = matriks[id]?[k.id] ?? 0;
                  return DataCell(Text(
                    desimal ? nilai.toStringAsFixed(4) : nilai.toStringAsFixed(2),
                    style: TextStyle(color: context.colors.textSecondary),
                  ));
                }),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _tabelSiKi(BuildContext context, List<String> urutanId) {
    return Container(
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      clipBehavior: Clip.antiAlias,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          headingRowColor: MaterialStateProperty.all(context.colors.surfaceLight),
          columns: [
            DataColumn(label: Text('Alternatif', style: TextStyle(color: context.colors.textPrimary, fontWeight: FontWeight.w700))),
            DataColumn(label: Text('Si', style: TextStyle(color: context.colors.textPrimary, fontWeight: FontWeight.w700))),
            DataColumn(label: Text('Ki', style: TextStyle(color: context.colors.textPrimary, fontWeight: FontWeight.w700))),
            DataColumn(label: Text('Ranking', style: TextStyle(color: context.colors.textPrimary, fontWeight: FontWeight.w700))),
          ],
          rows: urutanId.map((id) {
            final isA0 = id == ARASCalculator.idAlternatifOptimal;
            final si = detail.nilaiSi[id] ?? 0;
            final hasilSesuai = detail.hasilAkhir.where((h) => h.laptop.id == id);
            final ki = isA0 ? 1.0 : (hasilSesuai.isEmpty ? 0.0 : hasilSesuai.first.ki);
            final ranking = isA0 ? '-' : (hasilSesuai.isEmpty ? '-' : '#${hasilSesuai.first.ranking}');

            return DataRow(
              color: isA0 ? MaterialStateProperty.all(context.colors.primary.withOpacity(0.08)) : null,
              cells: [
                DataCell(Text(
                  _namaBaris(id),
                  style: TextStyle(
                    color: context.colors.textPrimary,
                    fontWeight: isA0 ? FontWeight.w700 : FontWeight.w400,
                  ),
                )),
                DataCell(Text(si.toStringAsFixed(4), style: TextStyle(color: context.colors.textSecondary))),
                DataCell(Text(ki.toStringAsFixed(4), style: TextStyle(color: context.colors.textSecondary))),
                DataCell(Text(ranking, style: TextStyle(color: context.colors.primary, fontWeight: FontWeight.w700))),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }
}