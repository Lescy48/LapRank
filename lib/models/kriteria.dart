enum TipeKriteria { benefit, cost }

class Kriteria {
  String id;
  String nama;
  double bobot; // dalam persen, misal 25 artinya 25%
  TipeKriteria tipe;

  Kriteria({
    required this.id,
    required this.nama,
    required this.bobot,
    required this.tipe,
  });

  // bobot dalam desimal (0-1), dipakai di perhitungan ARAS
  double get bobotDesimal => bobot / 100;

  Kriteria copyWith({
    String? nama,
    double? bobot,
    TipeKriteria? tipe,
  }) {
    return Kriteria(
      id: id,
      nama: nama ?? this.nama,
      bobot: bobot ?? this.bobot,
      tipe: tipe ?? this.tipe,
    );
  }
}
