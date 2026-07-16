# Rekomendasi Laptop — Metode ARAS

Aplikasi Sistem Pendukung Keputusan (SPK) untuk merekomendasikan laptop terbaik menggunakan metode **Additive Ratio Assessment (ARAS)**, dibangun dengan Flutter.

---

## 📱 Tentang Aplikasi

Aplikasi ini membantu pengguna menentukan laptop terbaik dari beberapa alternatif berdasarkan beberapa kriteria penilaian (harga, RAM, storage, dll), dengan menghitung ranking menggunakan metode ARAS.

### Fitur
- **CRUD Kriteria** — tambah/edit/hapus kriteria penilaian beserta bobot (%) dan tipe (Benefit/Cost)
- **CRUD Laptop** — tambah/edit/hapus data laptop (alternatif) beserta nilai per kriteria
- **Hitung Rekomendasi** — proses perhitungan ARAS otomatis, menghasilkan ranking laptop terbaik
- **Validasi bobot** — sistem memastikan total bobot kriteria = 100% sebelum bisa dihitung
- **Data dummy** — 5 laptop contoh sudah tersedia sejak awal buka aplikasi

---

## 🧮 Tentang Metode ARAS

**ARAS (Additive Ratio Assessment)** adalah metode MCDM (Multi-Criteria Decision Making) yang membandingkan setiap alternatif dengan sebuah **alternatif optimal (A0)** — alternatif "ideal" yang dibentuk dari nilai terbaik tiap kriteria. Alternatif dengan rasio kedekatan tertinggi terhadap A0 dianggap sebagai rekomendasi terbaik.

### Langkah-Langkah Perhitungan

**1. Bentuk matriks keputusan + Alternatif Optimal (A0)**

$$X_{0j} = \max_i x_{ij} \quad \text{(untuk kriteria benefit)}$$
$$X_{0j} = \min_i x_{ij} \quad \text{(untuk kriteria cost)}$$

**2. Normalisasi matriks**

Untuk kriteria **benefit**:
$$x_{ij}^{*} = \frac{x_{ij}}{\sum_{i=0}^{m} x_{ij}}$$

Untuk kriteria **cost**:
$$x_{ij}^{*} = \frac{1/x_{ij}}{\sum_{i=0}^{m} (1/x_{ij})}$$

**3. Pembobotan matriks ternormalisasi**
$$\hat{x}_{ij} = w_j \cdot x_{ij}^{*}$$

**4. Hitung nilai fungsi optimalitas (Si)**
$$S_i = \sum_{j=1}^{n} \hat{x}_{ij}$$

**5. Hitung derajat utilitas (Ki) — dasar ranking**
$$K_i = \frac{S_i}{S_0}$$

di mana $S_0$ adalah nilai $S_i$ dari Alternatif Optimal (A0). Laptop dengan $K_i$ terbesar menempati ranking #1 (rekomendasi terbaik).

---

## ⚙️ Cara Menjalankan

1. Pastikan Flutter SDK sudah terinstall (`flutter doctor` untuk cek).

2. Buat project baru (jika belum ada):
   ```bash
   flutter create aras_laptop
   cd aras_laptop
   ```

3. Timpa folder `lib/` dan file `pubspec.yaml` dengan file-file dari repo ini.

4. Install dependencies:
   ```bash
   flutter pub get
   ```

5. Jalankan aplikasi:
   ```bash
   flutter run
   ```

6. Build APK untuk keperluan submit tugas:
   ```bash
   flutter build apk --release
   ```
   APK hasil build ada di `build/app/outputs/flutter-apk/app-release.apk`

---

## 📊 Contoh Kriteria (Data Dummy)

| Kriteria | Tipe | Bobot |
|---|---|---|
| Harga (juta) | Cost | 30% |
| RAM (GB) | Benefit | 20% |
| Storage (GB) | Benefit | 15% |
| Skor Processor | Benefit | 25% |
| Baterai (jam) | Benefit | 10% |
| **Total** | | **100%** |

> Bobot bisa disesuaikan sendiri, yang penting totalnya harus 100%.

---

## 🔧 Pengembangan Lanjutan (Opsional)

- **Penyimpanan permanen**: saat ini data hanya tersimpan di memory selama aplikasi berjalan. Bisa ditambahkan `sqflite` atau `shared_preferences` agar data tidak hilang saat aplikasi ditutup.
- **Detail perhitungan step-by-step**: kelas `DetailPerhitunganARAS` di `aras_calculator.dart` sudah menyimpan matriks awal, normalisasi, dan pembobotan — tinggal dibuatkan tampilan UI-nya untuk keperluan presentasi ke dosen.
- **Export hasil**: tambahkan fitur export hasil ranking ke PDF/Excel.

---

## 📚 Referensi Metode

ARAS pertama kali diperkenalkan oleh **Zavadskas & Turskis (2010)** sebagai metode MCDM baru untuk menyelesaikan masalah keputusan kompleks dengan kriteria kuantitatif dan kualitatif.