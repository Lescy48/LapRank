# Rekomendasi Laptop — Metode ARAS

SPK sederhana untuk merekomendasikan laptop terbaik pakai metode **ARAS (Additive Ratio Assessment)**. Dibangun dengan Flutter.

## Tentang

Aplikasi ini membandingkan beberapa laptop berdasarkan kriteria seperti harga, RAM, dan storage, lalu menghasilkan ranking laptop terbaik secara otomatis.

**Fitur:**
- CRUD kriteria (nama, bobot %, tipe Benefit/Cost)
- CRUD laptop beserta nilai tiap kriteria
- Hitung ranking otomatis pakai ARAS
- Validasi total bobot harus 100%
- 5 data laptop dummy sudah tersedia dari awal

## Metode ARAS

ARAS bekerja dengan membandingkan tiap laptop terhadap sebuah **alternatif optimal (A0)** — gabungan nilai terbaik dari semua kriteria. Laptop yang paling mendekati A0 jadi rekomendasi #1.

**1. Bentuk matriks keputusan + Alternatif Optimal (A0)**

```math
X_{0j} = \max_i x_{ij} \quad \text{(benefit)} \qquad X_{0j} = \min_i x_{ij} \quad \text{(cost)}
```

**2. Normalisasi matriks**

Benefit:
```math
x_{ij}^{*} = \frac{x_{ij}}{\sum_{i=0}^{m} x_{ij}}
```

Cost:
```math
x_{ij}^{*} = \frac{1/x_{ij}}{\sum_{i=0}^{m} (1/x_{ij})}
```

**3. Pembobotan matriks ternormalisasi**
```math
\hat{x}_{ij} = w_j \cdot x_{ij}^{*}
```

**4. Nilai fungsi optimalitas (Sᵢ)**
```math
S_i = \sum_{j=1}^{n} \hat{x}_{ij}
```

**5. Derajat utilitas (Kᵢ) — dasar ranking**
```math
K_i = \frac{S_i}{S_0}
```

`S_0` adalah nilai `S_i` dari alternatif optimal (A0). Laptop dengan `K_i` terbesar = rekomendasi #1.

## Cara Menjalankan

```bash
flutter create aras_laptop
cd aras_laptop
# timpa folder lib/ dan pubspec.yaml dengan file dari repo ini
flutter pub get
flutter run
```

Cara build APK:

```bash
flutter build apk --release
```

Hasilnya ada di `build/app/outputs/flutter-apk/app-release.apk`

## Contoh Kriteria (Data Dummy)

| Kriteria | Tipe | Bobot |
|---|---|---|
| Harga (juta) | Cost | 30% |
| RAM (GB) | Benefit | 20% |
| Storage (GB) | Benefit | 15% |
| Skor Processor | Benefit | 25% |
| Baterai (jam) | Benefit | 10% |
| **Total** | | **100%** |

Bobot bebas disesuaikan, yang penting totalnya 100%.

## Referensi

ARAS diperkenalkan oleh Zavadskas & Turskis (2010) sebagai metode MCDM untuk masalah keputusan dengan kriteria kuantitatif dan kualitatif.