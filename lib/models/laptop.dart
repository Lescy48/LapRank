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
}
