import 'package:flutter/material.dart';
import '../models/kriteria.dart';
import '../theme/app_theme.dart';
import '../widgets/gradient_header.dart';
import '../widgets/topography_background.dart';
import '../logic/aras_calculator.dart';

class KriteriaScreen extends StatefulWidget {
  final List<Kriteria> daftarKriteria;
  final VoidCallback onChanged;

  const KriteriaScreen({
    super.key,
    required this.daftarKriteria,
    required this.onChanged,
  });

  @override
  State<KriteriaScreen> createState() => _KriteriaScreenState();
}

class _KriteriaScreenState extends State<KriteriaScreen> {
  void _bukaFormKriteria({Kriteria? kriteria}) {
    final namaCtrl = TextEditingController(text: kriteria?.nama ?? '');
    final bobotCtrl = TextEditingController(text: kriteria?.bobot.toString() ?? '');
    TipeKriteria tipe = kriteria?.tipe ?? TipeKriteria.benefit;

    showModalBottomSheet(
      context: context,
      backgroundColor: context.colors.surface,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 20, right: 20, top: 24,
                bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    kriteria == null ? 'Tambah Kriteria' : 'Edit Kriteria',
                    style: TextStyle(color: context.colors.textPrimary, fontSize: 18, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: namaCtrl,
                    style: TextStyle(color: context.colors.textPrimary),
                    decoration: const InputDecoration(labelText: 'Nama Kriteria'),
                  ),
                  const SizedBox(height: 14),
                  TextField(
                    controller: bobotCtrl,
                    keyboardType: TextInputType.number,
                    style: TextStyle(color: context.colors.textPrimary),
                    decoration: const InputDecoration(labelText: 'Bobot (%)'),
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Expanded(
                        child: _pilihanTipe(
                          label: 'Benefit',
                          aktif: tipe == TipeKriteria.benefit,
                          onTap: () => setModalState(() => tipe = TipeKriteria.benefit),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _pilihanTipe(
                          label: 'Cost',
                          aktif: tipe == TipeKriteria.cost,
                          onTap: () => setModalState(() => tipe = TipeKriteria.cost),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        final nama = namaCtrl.text.trim();
                        final bobot = double.tryParse(bobotCtrl.text.trim()) ?? 0;
                        if (nama.isEmpty || bobot <= 0) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Nama dan bobot wajib diisi!'),
                            duration: Duration(seconds: 3),
                            ),
                          );
                          return;
                        }
                        setState(() {
                          if (kriteria == null) {
                            widget.daftarKriteria.add(Kriteria(
                              id: DateTime.now().millisecondsSinceEpoch.toString(),
                              nama: nama,
                              bobot: bobot,
                              tipe: tipe,
                            ));
                          } else {
                            kriteria.nama = nama;
                            kriteria.bobot = bobot;
                            kriteria.tipe = tipe;
                          }
                        });
                        widget.onChanged();
                        Navigator.pop(ctx);
                      },
                      child: const Text('Simpan'),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _pilihanTipe({required String label, required bool aktif, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: aktif ? context.colors.primary : context.colors.surfaceLight,
          borderRadius: BorderRadius.circular(12),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: TextStyle(
            color: aktif ? Colors.white : context.colors.textSecondary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  void _hapusKriteria(Kriteria k) {
    final index = widget.daftarKriteria.indexWhere((e) => e.id == k.id);
    setState(() => widget.daftarKriteria.removeWhere((e) => e.id == k.id));
    widget.onChanged();

    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('"${k.nama}" dihapus'),
        duration: const Duration(seconds: 3),
        action: SnackBarAction(
          label: 'Undo',
          onPressed: () {
            setState(() => widget.daftarKriteria.insert(
                  index.clamp(0, widget.daftarKriteria.length),
                  k,
                ));
            widget.onChanged();
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final total = ARASCalculator.totalBobot(widget.daftarKriteria);
    final valid = ARASCalculator.bobotValid(widget.daftarKriteria);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          const TopographyBackground(),
          SafeArea(
        child: Column(
          children: [
            const GradientHeader(
              title: 'Kriteria Penilaian',
              subtitle: 'Atur kriteria & bobot untuk metode ARAS',
              icon: Icons.tune_rounded,
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: valid ? context.colors.success.withOpacity(0.12) : context.colors.danger.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  children: [
                    Icon(
                      valid ? Icons.check_circle_rounded : Icons.error_rounded,
                      color: valid ? context.colors.success : context.colors.danger,
                      size: 20,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        valid
                            ? 'Total bobot: ${total.toStringAsFixed(0)}% ✓'
                            : 'Total bobot: ${total.toStringAsFixed(0)}% (harus 100%)',
                        style: TextStyle(
                          color: valid ? context.colors.success : context.colors.danger,
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: widget.daftarKriteria.isEmpty
                  ? Center(
                      child: Text('Belum ada kriteria.\nTekan + untuk menambah.',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: context.colors.textSecondary)),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
                      itemCount: widget.daftarKriteria.length,
                      itemBuilder: (ctx, i) {
                        final k = widget.daftarKriteria[i];
                        return Dismissible(
                          key: ValueKey(k.id),
                          direction: DismissDirection.endToStart,
                          onDismissed: (_) => _hapusKriteria(k),
                          background: Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            alignment: Alignment.centerRight,
                            decoration: BoxDecoration(
                              color: context.colors.danger,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: const Icon(Icons.delete_rounded, color: Colors.white),
                          ),
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: context.colors.surface,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: (k.tipe == TipeKriteria.benefit ? context.colors.success : context.colors.danger)
                                        .withOpacity(0.15),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Icon(
                                    k.tipe == TipeKriteria.benefit ? Icons.trending_up_rounded : Icons.trending_down_rounded,
                                    color: k.tipe == TipeKriteria.benefit ? context.colors.success : context.colors.danger,
                                  ),
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(k.nama, style: TextStyle(color: context.colors.textPrimary, fontWeight: FontWeight.w600)),
                                      const SizedBox(height: 3),
                                      Text(
                                        '${k.tipe == TipeKriteria.benefit ? "Benefit" : "Cost"} · Bobot ${k.bobot.toStringAsFixed(0)}%',
                                        style: TextStyle(color: context.colors.textSecondary, fontSize: 12),
                                      ),
                                    ],
                                  ),
                                ),
                                IconButton(
                                  icon: Icon(Icons.edit_rounded, color: context.colors.textSecondary, size: 20),
                                  onPressed: () => _bukaFormKriteria(kriteria: k),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _bukaFormKriteria(),
        icon: const Icon(Icons.add_rounded),
        label: const Text('Kriteria'),
      ),
    );
  }
}