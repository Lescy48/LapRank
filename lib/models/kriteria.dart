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

  Map<String, dynamic> toJson() => {
        'id': id,
        'nama': nama,
        'bobot': bobot,
        'tipe': tipe.name,
      };

  factory Kriteria.fromJson(Map<String, dynamic> json) => Kriteria(
        id: json['id'] as String,
        nama: json['nama'] as String,
        bobot: (json['bobot'] as num).toDouble(),
        tipe: TipeKriteria.values.firstWhere(
          (e) => e.name == json['tipe'],
          orElse: () => TipeKriteria.benefit,
        ),
      );
}
