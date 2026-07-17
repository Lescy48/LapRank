import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'home_screen.dart';

/// Splash screen animasi:
/// 1. Logo zoom-in dengan efek glow berdenyut di belakangnya
/// 2. Teks "LapRank" drop-down (jatuh dari atas + fade in)
/// 3. "Lap" dan "Rank" geser saling menjauh secara smooth, membuka celah
///    yang perlahan terisi "top", spasi, dan "ing" -> jadi "Laptop Ranking"
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with TickerProviderStateMixin {
  late final AnimationController _logoController;
  late final AnimationController _glowController;
  late final AnimationController _textDropController;
  late final AnimationController _extendController;

  late final Animation<double> _logoScale;
  late final Animation<double> _logoOpacity;
  late final Animation<double> _textDropOffset;
  late final Animation<double> _textOpacity;

  // Tiap segmen sisipan ("top", " ", "ing") punya animasi lebar (0 -> 1)
  // sendiri, di-stagger dengan curve halus supaya kesannya "Lap" dan "Rank"
  // geser membuka celah secara alami, bukan wiper yang kaku.
  late final Animation<double> _topWidth;
  late final Animation<double> _spaceWidth;
  late final Animation<double> _ingWidth;

  // Fade tipis di atas width-reveal supaya kemunculan huruf lebih lembut.
  late final Animation<double> _topOpacity;
  late final Animation<double> _ingOpacity;

  @override
  void initState() {
    super.initState();

    _logoController = AnimationController(vsync: this, duration: const Duration(milliseconds: 800));
    _logoScale = CurvedAnimation(parent: _logoController, curve: Curves.elasticOut);
    _logoOpacity = CurvedAnimation(parent: _logoController, curve: const Interval(0.0, 0.4));

    _glowController = AnimationController(vsync: this, duration: const Duration(milliseconds: 1400))
      ..repeat(reverse: true);

    _textDropController = AnimationController(vsync: this, duration: const Duration(milliseconds: 500));
    _textDropOffset = Tween<double>(begin: -30, end: 0)
        .animate(CurvedAnimation(parent: _textDropController, curve: Curves.easeOutBack));
    _textOpacity = CurvedAnimation(parent: _textDropController, curve: const Interval(0.0, 0.6));

    // Durasi lebih panjang (1100ms) + curve easeInOutCubic supaya gerakan
    // membuka celah terasa mengalir, bukan instan/patah.
    _extendController = AnimationController(vsync: this, duration: const Duration(milliseconds: 1100));

    // "top" dan "ing" melebar BERSAMAAN (interval sama persis), jadi "Lap"
    // dan "Rank" kelihatan geser menjauh serentak, bukan gantian.
    _topWidth = CurvedAnimation(
      parent: _extendController,
      curve: const Interval(0.0, 0.8, curve: Curves.easeInOutCubic),
    );
    _topOpacity = CurvedAnimation(
      parent: _extendController,
      curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
    );

    // Spasi ikut melebar bareng juga.
    _spaceWidth = CurvedAnimation(
      parent: _extendController,
      curve: const Interval(0.0, 0.8, curve: Curves.easeInOutCubic),
    );

    _ingWidth = CurvedAnimation(
      parent: _extendController,
      curve: const Interval(0.0, 0.8, curve: Curves.easeInOutCubic),
    );
    _ingOpacity = CurvedAnimation(
      parent: _extendController,
      curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
    );

    _jalankanUrutanAnimasi();
  }

  Future<void> _jalankanUrutanAnimasi() async {
    await _logoController.forward();
    await Future.delayed(const Duration(milliseconds: 150));
    await _textDropController.forward();
    await Future.delayed(const Duration(milliseconds: 550));
    await _extendController.forward();
    await Future.delayed(const Duration(milliseconds: 700));
    _kePindahHalamanUtama();
  }

  void _kePindahHalamanUtama() {
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 500),
        pageBuilder: (_, animasi, __) => const HomeScreen(),
        transitionsBuilder: (_, animasi, __, child) => FadeTransition(opacity: animasi, child: child),
      ),
    );
  }

  @override
  void dispose() {
    _logoController.dispose();
    _glowController.dispose();
    _textDropController.dispose();
    _extendController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(gradient: context.colors.primaryGradient),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildLogoDenganGlow(),
              const SizedBox(height: 22),
              _buildTeksLapRank(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLogoDenganGlow() {
    return AnimatedBuilder(
      animation: Listenable.merge([_logoController, _glowController]),
      builder: (context, child) {
        final glowValue = _glowController.value;
        return SizedBox(
          width: 200,
          height: 200,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Opacity(
                opacity: _logoOpacity.value * (0.35 + 0.25 * glowValue),
                child: Container(
                  width: 140 + 30 * glowValue,
                  height: 140 + 30 * glowValue,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.white.withOpacity(0.6),
                        blurRadius: 50 + 20 * glowValue,
                        spreadRadius: 10 + 10 * glowValue,
                      ),
                    ],
                  ),
                ),
              ),
              Opacity(
                opacity: _logoOpacity.value.clamp(0.0, 1.0),
                child: Transform.scale(
                  scale: _logoScale.value,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(32),
                    child: Image.asset(
                      'assets/icon/icon.png',
                      width: 140,
                      height: 140,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTeksLapRank() {
    return AnimatedBuilder(
      animation: Listenable.merge([_textDropController, _extendController]),
      builder: (context, child) {
        return Opacity(
          opacity: _textOpacity.value.clamp(0.0, 1.0),
          child: Transform.translate(
            offset: Offset(0, _textDropOffset.value),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _teksStatis('Lap'),
                _teksMelebar('top', _topWidth.value, opacity: _topOpacity.value),
                _teksMelebar(' ', _spaceWidth.value, opacity: 1),
                _teksStatis('Rank'),
                _teksMelebar('ing', _ingWidth.value, opacity: _ingOpacity.value),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _teksStatis(String teks) {
    return Text(teks, style: _gayaTeksJudul());
  }

  /// Segmen yang melebar dari lebar 0 -> lebar penuh (widthFactor),
  /// dipadukan fade tipis supaya kemunculan terasa halus, bukan wiper kaku.
  Widget _teksMelebar(String teks, double widthFactor, {required double opacity}) {
    return ClipRect(
      child: Align(
        alignment: Alignment.centerLeft,
        widthFactor: widthFactor.clamp(0.0, 1.0),
        child: Opacity(
          opacity: opacity.clamp(0.0, 1.0),
          child: Text(teks, style: _gayaTeksJudul()),
        ),
      ),
    );
  }

  TextStyle _gayaTeksJudul() {
    return const TextStyle(
      color: Colors.white,
      fontSize: 28,
      fontWeight: FontWeight.w700,
      letterSpacing: 0.5,
    );
  }
}