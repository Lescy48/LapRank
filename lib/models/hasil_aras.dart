import 'laptop.dart';

class HasilARAS {
  final Laptop laptop;
  final double si; // nilai fungsi optimalitas
  final double ki; // derajat utilitas (dipakai buat ranking)
  int ranking;

  HasilARAS({
    required this.laptop,
    required this.si,
    required this.ki,
    this.ranking = 0,
  });
}
