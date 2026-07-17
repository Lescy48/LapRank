import 'dart:io';
import 'package:csv/csv.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:share_plus/share_plus.dart';
import '../models/hasil_aras.dart';
import '../models/kriteria.dart';

/// Menghasilkan file PDF & CSV (bisa dibuka di Excel) dari hasil ranking ARAS.
class ExportService {
  /// Export hasil ranking ke PDF, lalu buka dialog share/print.
  static Future<void> exportPdf({
    required List<HasilARAS> hasil,
    required List<Kriteria> daftarKriteria,
  }) async {
    final doc = pw.Document();

    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        build: (context) => [
          pw.Header(
            level: 0,
            child: pw.Text(
              'Hasil Rekomendasi Laptop - Metode ARAS',
              style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold),
            ),
          ),
          pw.SizedBox(height: 8),
          pw.Text('Kriteria yang digunakan:', style: const pw.TextStyle(fontSize: 12)),
          pw.SizedBox(height: 4),
          pw.Text(
            daftarKriteria
                .map((k) => '- ${k.nama} (${k.tipe == TipeKriteria.benefit ? "Benefit" : "Cost"}, ${k.bobot.toStringAsFixed(0)}%)')
                .join('\n'),
            style: const pw.TextStyle(fontSize: 11),
          ),
          pw.SizedBox(height: 16),
          pw.Table.fromTextArray(
            headers: ['Ranking', 'Nama Laptop', 'Nilai Si', 'Nilai Ki'],
            data: hasil
                .map((h) => [
                      '#${h.ranking}',
                      h.laptop.nama,
                      h.si.toStringAsFixed(4),
                      h.ki.toStringAsFixed(4),
                    ])
                .toList(),
            headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColors.white),
            headerDecoration: const pw.BoxDecoration(color: PdfColors.deepPurple),
            cellAlignment: pw.Alignment.centerLeft,
            cellPadding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          ),
          pw.SizedBox(height: 16),
          pw.Text(
            'Rekomendasi terbaik: ${hasil.isNotEmpty ? hasil.first.laptop.nama : "-"}',
            style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold),
          ),
        ],
      ),
    );

    final bytes = await doc.save();
    await Printing.sharePdf(bytes: bytes, filename: 'hasil_rekomendasi_aras.pdf');
  }

  /// Export hasil ranking ke CSV (bisa langsung dibuka di Excel).
  static Future<void> exportCsv({
    required List<HasilARAS> hasil,
  }) async {
    final rows = <List<String>>[
      ['Ranking', 'Nama Laptop', 'Merek', 'Nilai Si', 'Nilai Ki'],
      ...hasil.map((h) => [
            h.ranking.toString(),
            h.laptop.nama,
            h.laptop.merek ?? '-',
            h.si.toStringAsFixed(4),
            h.ki.toStringAsFixed(4),
          ]),
    ];

    final csvString = const ListToCsvConverter().convert(rows);

    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/hasil_rekomendasi_aras.csv');
    await file.writeAsString(csvString);

    await Share.shareXFiles(
      [XFile(file.path)],
      subject: 'Hasil Rekomendasi Laptop - ARAS',
      text: 'Hasil perhitungan rekomendasi laptop menggunakan metode ARAS.',
    );
  }
}
