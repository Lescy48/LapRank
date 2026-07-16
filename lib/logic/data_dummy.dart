import '../models/kriteria.dart';
import '../models/laptop.dart';

class DataDummy {
  static List<Kriteria> kriteriaAwal() {
    return [
      Kriteria(id: 'harga', nama: 'Harga (juta)', bobot: 30, tipe: TipeKriteria.cost),
      Kriteria(id: 'ram', nama: 'RAM (GB)', bobot: 20, tipe: TipeKriteria.benefit),
      Kriteria(id: 'storage', nama: 'Storage (GB)', bobot: 15, tipe: TipeKriteria.benefit),
      Kriteria(id: 'processor', nama: 'Skor Processor', bobot: 25, tipe: TipeKriteria.benefit),
      Kriteria(id: 'baterai', nama: 'Baterai (jam)', bobot: 10, tipe: TipeKriteria.benefit),
    ];
  }

  static List<Laptop> laptopAwal() {
    return [
      Laptop(id: 'l1', nama: 'Asus Vivobook 14', merek: 'Asus', nilai: {
        'harga': 8.5, 'ram': 8, 'storage': 512, 'processor': 75, 'baterai': 7,
      }),
      Laptop(id: 'l2', nama: 'Lenovo IdeaPad Slim 3', merek: 'Lenovo', nilai: {
        'harga': 7.2, 'ram': 8, 'storage': 256, 'processor': 68, 'baterai': 6,
      }),
      Laptop(id: 'l3', nama: 'Acer Aspire 5', merek: 'Acer', nilai: {
        'harga': 9.0, 'ram': 16, 'storage': 512, 'processor': 82, 'baterai': 8,
      }),
      Laptop(id: 'l4', nama: 'HP Pavilion 14', merek: 'HP', nilai: {
        'harga': 10.5, 'ram': 16, 'storage': 1024, 'processor': 88, 'baterai': 9,
      }),
      Laptop(id: 'l5', nama: 'MacBook Air M1', merek: 'Apple', nilai: {
        'harga': 13.0, 'ram': 8, 'storage': 256, 'processor': 95, 'baterai': 12,
      }),
    ];
  }
}
