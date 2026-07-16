import '../models/kriteria.dart';
import '../models/laptop.dart';
import '../models/hasil_aras.dart';

/// Kelas untuk menampung detail tiap tahap perhitungan ARAS,
/// berguna kalau mau ditampilkan step-by-step di UI (buat presentasi).
class DetailPerhitunganARAS {
  final Map<String, Map<String, double>> matriksAwal; // termasuk A0
  final Map<String, Map<String, double>> matriksNormalisasi;
  final Map<String, Map<String, double>> matriksTerbobot;
  final Map<String, double> nilaiSi; // termasuk S0
  final List<HasilARAS> hasilAkhir;

  DetailPerhitunganARAS({
    required this.matriksAwal,
    required this.matriksNormalisasi,
    required this.matriksTerbobot,
    required this.nilaiSi,
    required this.hasilAkhir,
  });
}

class ARASCalculator {
  static const String idAlternatifOptimal = 'A0';

  /// Menjalankan seluruh proses ARAS dan mengembalikan detail tiap tahap.
  static DetailPerhitunganARAS hitung({
    required List<Kriteria> daftarKriteria,
    required List<Laptop> daftarLaptop,
  }) {
    if (daftarLaptop.isEmpty || daftarKriteria.isEmpty) {
      return DetailPerhitunganARAS(
        matriksAwal: {},
        matriksNormalisasi: {},
        matriksTerbobot: {},
        nilaiSi: {},
        hasilAkhir: [],
      );
    }

    // ---------- LANGKAH 1: Bentuk matriks awal + Alternatif Optimal (A0) ----------
    // A0 = nilai terbaik tiap kriteria (max untuk benefit, min untuk cost)
    final Map<String, double> nilaiA0 = {};
    for (final k in daftarKriteria) {
      final nilaiSemuaLaptop = daftarLaptop.map((l) => l.nilai[k.id] ?? 0).toList();
      if (k.tipe == TipeKriteria.benefit) {
        nilaiA0[k.id] = nilaiSemuaLaptop.reduce((a, b) => a > b ? a : b);
      } else {
        nilaiA0[k.id] = nilaiSemuaLaptop.reduce((a, b) => a < b ? a : b);
      }
    }

    final Map<String, Map<String, double>> matriksAwal = {
      idAlternatifOptimal: nilaiA0,
      for (final l in daftarLaptop) l.id: Map<String, double>.from(l.nilai),
    };

    // ---------- LANGKAH 2: Normalisasi ----------
    // benefit: x* = x / sum(x kolom itu, termasuk A0)
    // cost   : x* = (1/x) / sum(1/x kolom itu, termasuk A0)
    final Map<String, Map<String, double>> matriksNormalisasi = {
      for (final id in matriksAwal.keys) id: <String, double>{}
    };

    for (final k in daftarKriteria) {
      if (k.tipe == TipeKriteria.benefit) {
        final total = matriksAwal.values.fold<double>(0, (sum, row) => sum + (row[k.id] ?? 0));
        for (final id in matriksAwal.keys) {
          final x = matriksAwal[id]![k.id] ?? 0;
          matriksNormalisasi[id]![k.id] = total == 0 ? 0 : x / total;
        }
      } else {
        // cost -> pakai 1/x
        final totalInvers = matriksAwal.values.fold<double>(0, (sum, row) {
          final x = row[k.id] ?? 0;
          return sum + (x == 0 ? 0 : 1 / x);
        });
        for (final id in matriksAwal.keys) {
          final x = matriksAwal[id]![k.id] ?? 0;
          final invers = x == 0 ? 0 : 1 / x;
          matriksNormalisasi[id]![k.id] = totalInvers == 0 ? 0 : invers / totalInvers;
        }
      }
    }

    // ---------- LANGKAH 3: Pembobotan ----------
    final Map<String, Map<String, double>> matriksTerbobot = {
      for (final id in matriksNormalisasi.keys)
        id: {
          for (final k in daftarKriteria)
            k.id: (matriksNormalisasi[id]![k.id] ?? 0) * k.bobotDesimal
        }
    };

    // ---------- LANGKAH 4: Nilai Si (fungsi optimalitas) = jumlah tiap baris ----------
    final Map<String, double> nilaiSi = {
      for (final id in matriksTerbobot.keys)
        id: matriksTerbobot[id]!.values.fold<double>(0, (a, b) => a + b)
    };

    final double s0 = nilaiSi[idAlternatifOptimal] ?? 0;

    // ---------- LANGKAH 5: Nilai Ki (derajat utilitas) = Si / S0, lalu ranking ----------
    final List<HasilARAS> hasil = daftarLaptop.map((l) {
      final si = nilaiSi[l.id] ?? 0;
      final ki = s0 == 0 ? 0.0 : si / s0;
      return HasilARAS(laptop: l, si: si, ki: ki);
    }).toList();

    // urutkan dari Ki terbesar -> terkecil (rekomendasi terbaik di atas)
    hasil.sort((a, b) => b.ki.compareTo(a.ki));
    for (int i = 0; i < hasil.length; i++) {
      hasil[i].ranking = i + 1;
    }

    return DetailPerhitunganARAS(
      matriksAwal: matriksAwal,
      matriksNormalisasi: matriksNormalisasi,
      matriksTerbobot: matriksTerbobot,
      nilaiSi: nilaiSi,
      hasilAkhir: hasil,
    );
  }

  /// Validasi total bobot kriteria harus 100%. Berguna buat kasih warning di UI.
  static bool bobotValid(List<Kriteria> daftarKriteria) {
    final total = daftarKriteria.fold<double>(0, (sum, k) => sum + k.bobot);
    return (total - 100).abs() < 0.01;
  }

  static double totalBobot(List<Kriteria> daftarKriteria) {
    return daftarKriteria.fold<double>(0, (sum, k) => sum + k.bobot);
  }
}
