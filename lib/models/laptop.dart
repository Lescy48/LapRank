class Laptop {
  String id;
  String nama;
  String? merek;
  // key: id kriteria, value: nilai laptop untuk kriteria itu
  Map<String, double> nilai;

  Laptop({
    required this.id,
    required this.nama,
    this.merek,
    required this.nilai,
  });

  Laptop copyWith({
    String? nama,
    String? merek,
    Map<String, double>? nilai,
  }) {
    return Laptop(
      id: id,
      nama: nama ?? this.nama,
      merek: merek ?? this.merek,
      nilai: nilai ?? Map<String, double>.from(this.nilai),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'nama': nama,
        'merek': merek,
        'nilai': nilai,
      };

  factory Laptop.fromJson(Map<String, dynamic> json) => Laptop(
        id: json['id'] as String,
        nama: json['nama'] as String,
        merek: json['merek'] as String?,
        nilai: Map<String, double>.from(
          (json['nilai'] as Map).map(
            (key, value) => MapEntry(key as String, (value as num).toDouble()),
          ),
        ),
      );
}
