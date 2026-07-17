import 'package:flutter/material.dart';
import '../models/kriteria.dart';
import '../models/laptop.dart';
import '../theme/app_theme.dart';
import '../widgets/gradient_header.dart';
import '../widgets/topography_background.dart';

class LaptopScreen extends StatefulWidget {
  final List<Laptop> daftarLaptop;
  final List<Kriteria> daftarKriteria;
  final VoidCallback onChanged;

  const LaptopScreen({
    super.key,
    required this.daftarLaptop,
    required this.daftarKriteria,
    required this.onChanged,
  });

  @override
  State<LaptopScreen> createState() => _LaptopScreenState();
}

class _LaptopScreenState extends State<LaptopScreen> {
  void _bukaFormLaptop({Laptop? laptop}) {
    if (widget.daftarKriteria.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tambahkan kriteria dulu sebelum input laptop!'),
        duration: Duration(seconds: 3),
        ),
      );
      return;
    }

    final namaCtrl = TextEditingController(text: laptop?.nama ?? '');
    final merekCtrl = TextEditingController(text: laptop?.merek ?? '');
    final Map<String, TextEditingController> nilaiCtrl = {
      for (final k in widget.daftarKriteria)
        k.id: TextEditingController(text: laptop?.nilai[k.id]?.toString() ?? '')
    };

    showModalBottomSheet(
      context: context,
      backgroundColor: context.colors.surface,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return DraggableScrollableSheet(
          initialChildSize: 0.85,
          maxChildSize: 0.95,
          minChildSize: 0.5,
          expand: false,
          builder: (ctx, scrollCtrl) {
            return Padding(
              padding: EdgeInsets.only(
                left: 20, right: 20, top: 24,
                bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
              ),
              child: ListView(
                controller: scrollCtrl,
                children: [
                  Text(
                    laptop == null ? 'Tambah Laptop' : 'Edit Laptop',
                    style: TextStyle(color: context.colors.textPrimary, fontSize: 18, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: namaCtrl,
                    style: TextStyle(color: context.colors.textPrimary),
                    decoration: const InputDecoration(labelText: 'Nama Laptop'),
                  ),
                  const SizedBox(height: 14),
                  TextField(
                    controller: merekCtrl,
                    style: TextStyle(color: context.colors.textPrimary),
                    decoration: const InputDecoration(labelText: 'Merek (opsional)'),
                  ),
                  const SizedBox(height: 20),
                  Text('Nilai per Kriteria', style: TextStyle(color: context.colors.textSecondary, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 10),
                  ...widget.daftarKriteria.map((k) => Padding(
                        padding: const EdgeInsets.only(bottom: 14),
                        child: TextField(
                          controller: nilaiCtrl[k.id],
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          style: TextStyle(color: context.colors.textPrimary),
                          decoration: InputDecoration(
                            labelText: k.nama,
                            suffixText: k.tipe == TipeKriteria.benefit ? 'Benefit' : 'Cost',
                            suffixStyle: TextStyle(
                              color: k.tipe == TipeKriteria.benefit ? context.colors.success : context.colors.danger,
                              fontSize: 11,
                            ),
                          ),
                        ),
                      )),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        final nama = namaCtrl.text.trim();
                        if (nama.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Nama laptop wajib diisi!'),
                            duration: Duration(seconds: 3),
                            ),
                          );
                          return;
                        }
                        final Map<String, double> nilai = {
                          for (final k in widget.daftarKriteria)
                            k.id: double.tryParse(nilaiCtrl[k.id]!.text.trim()) ?? 0
                        };
                        setState(() {
                          if (laptop == null) {
                            widget.daftarLaptop.add(Laptop(
                              id: DateTime.now().millisecondsSinceEpoch.toString(),
                              nama: nama,
                              merek: merekCtrl.text.trim(),
                              nilai: nilai,
                            ));
                          } else {
                            laptop.nama = nama;
                            laptop.merek = merekCtrl.text.trim();
                            laptop.nilai = nilai;
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

  void _hapusLaptop(Laptop l) {
    final index = widget.daftarLaptop.indexWhere((e) => e.id == l.id);
    setState(() => widget.daftarLaptop.removeWhere((e) => e.id == l.id));
    widget.onChanged();

    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('"${l.nama}" dihapus'),
        duration: const Duration(seconds: 3),
        action: SnackBarAction(
          label: 'Undo',
          onPressed: () {
            setState(() => widget.daftarLaptop.insert(
                  index.clamp(0, widget.daftarLaptop.length),
                  l,
                ));
            widget.onChanged();
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          const TopographyBackground(),
          SafeArea(
        child: Column(
          children: [
            const GradientHeader(
              title: 'Data Laptop',
              subtitle: 'Alternatif yang akan dibandingkan',
              icon: Icons.laptop_mac_rounded,
            ),
            Expanded(
              child: widget.daftarLaptop.isEmpty
                  ? Center(
                      child: Text('Belum ada data laptop.\nTekan + untuk menambah.',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: context.colors.textSecondary)),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
                      itemCount: widget.daftarLaptop.length,
                      itemBuilder: (ctx, i) {
                        final l = widget.daftarLaptop[i];
                        return Dismissible(
                          key: ValueKey(l.id),
                          direction: DismissDirection.endToStart,
                          onDismissed: (_) => _hapusLaptop(l),
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
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      gradient: context.colors.primaryGradient,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: const Icon(Icons.laptop_rounded, color: Colors.white, size: 20),
                                  ),
                                  const SizedBox(width: 14),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(l.nama, style: TextStyle(color: context.colors.textPrimary, fontWeight: FontWeight.w600)),
                                        if (l.merek != null && l.merek!.isNotEmpty)
                                          Text(l.merek!, style: TextStyle(color: context.colors.textSecondary, fontSize: 12)),
                                      ],
                                    ),
                                  ),
                                  IconButton(
                                    icon: Icon(Icons.edit_rounded, color: context.colors.textSecondary, size: 20),
                                    onPressed: () => _bukaFormLaptop(laptop: l),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),
                              Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: widget.daftarKriteria.map((k) {
                                  return Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: context.colors.surfaceLight,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      '${k.nama}: ${l.nilai[k.id]?.toStringAsFixed(1) ?? "-"}',
                                      style: TextStyle(color: context.colors.textSecondary, fontSize: 11),
                                    ),
                                  );
                                }).toList(),
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
        onPressed: () => _bukaFormLaptop(),
        icon: const Icon(Icons.add_rounded),
        label: const Text('Laptop'),
      ),
    );
  }
}