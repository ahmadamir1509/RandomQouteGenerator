import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../utils/app_theme.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  // ── Quotation-mark icon
  late final Animation<double> _quoteMarkScale;
  late final Animation<double> _quoteMarkOpacity;

  // ── Floating sample card
  late final Animation<double> _cardSlide;
  late final Animation<double> _cardOpacity;

  // ── App title
  late final Animation<double> _titleOpacity;
  late final Animation<double> _titleSlide;

  // ── Tagline
  late final Animation<double> _taglineOpacity;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    );

    final qm = CurvedAnimation(
      parent: _ctrl,
      curve: const Interval(0.0, 0.36, curve: Curves.elasticOut),
    );
    _quoteMarkScale = Tween(begin: 0.0, end: 1.0).animate(qm);
    _quoteMarkOpacity = Tween(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _ctrl, curve: const Interval(0.0, 0.18)));

    final cardCurve = CurvedAnimation(
      parent: _ctrl,
      curve: const Interval(0.18, 0.56, curve: Curves.easeOutCubic),
    );
    _cardSlide = Tween(begin: 28.0, end: 0.0).animate(cardCurve);
    _cardOpacity = Tween(begin: 0.0, end: 1.0).animate(cardCurve);

    final titleCurve = CurvedAnimation(
      parent: _ctrl,
      curve: const Interval(0.48, 0.78, curve: Curves.easeOut),
    );
    _titleOpacity = Tween(begin: 0.0, end: 1.0).animate(titleCurve);
    _titleSlide = Tween(begin: 12.0, end: 0.0).animate(titleCurve);

    _taglineOpacity = Tween(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _ctrl, curve: const Interval(0.66, 0.94)),
    );

    _runSequence();
  }

  Future<void> _runSequence() async {
    await Future<void>.delayed(const Duration(milliseconds: 120));
    if (!mounted) return;
    await _ctrl.forward();
    await Future<void>.delayed(const Duration(milliseconds: 700));
    if (!mounted) return;
    Navigator.of(context).pushReplacementNamed('/home');
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: AppTheme.backgroundGradient(brightness),
        ),
        child: SafeArea(
          child: AnimatedBuilder(
            animation: _ctrl,
            builder: (context, _) => _buildContent(context, brightness),
          ),
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, Brightness brightness) {
    final isDark = brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Spacer(flex: 2),

          Opacity(
            opacity: _quoteMarkOpacity.value.clamp(0.0, 1.0),
            child: Transform.scale(
              scale: _quoteMarkScale.value.clamp(0.0, 1.2),
              child: _GlowingQuoteMark(),
            ),
          ),

          const SizedBox(height: 36),

          Opacity(
            opacity: _cardOpacity.value.clamp(0.0, 1.0),
            child: Transform.translate(
              offset: Offset(0, _cardSlide.value),
              child: _SampleCard(isDark: isDark),
            ),
          ),

          const SizedBox(height: 52),

          Opacity(
            opacity: _titleOpacity.value.clamp(0.0, 1.0),
            child: Transform.translate(
              offset: Offset(0, _titleSlide.value),
              child: Text(
                'Random Quote',
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 32,
                  fontWeight: FontWeight.w700,
                  color: isDark
                      ? const Color(0xFFF0EFFF)
                      : const Color(0xFF1A1A2E),
                  letterSpacing: 0.5,
                  height: 1.2,
                ),
              ),
            ),
          ),

          const SizedBox(height: 12),

          Opacity(
            opacity: _taglineOpacity.value.clamp(0.0, 1.0),
            child: Text(
              '"Words that inspire. Thoughts that stay."',
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w400,
                fontStyle: FontStyle.italic,
                color: const Color(0xFF6C63FF).withValues(alpha: 0.85),
                letterSpacing: 0.3,
                height: 1.55,
              ),
            ),
          ),

          const Spacer(flex: 2),

          Opacity(
            opacity: _taglineOpacity.value.clamp(0.0, 1.0),
            child: const _PulsingDots(),
          ),

          const SizedBox(height: 32),
        ],
      ),
    );
  }
}

class _GlowingQuoteMark extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 96,
      height: 96,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF6C63FF), Color(0xFF9B8FFF)],
        ),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF6C63FF).withValues(alpha: 0.45),
            blurRadius: 40,
            offset: const Offset(0, 12),
          ),
          BoxShadow(
            color: const Color(0xFF6C63FF).withValues(alpha: 0.20),
            blurRadius: 70,
            spreadRadius: 8,
            offset: const Offset(0, 20),
          ),
        ],
      ),
      child: const Center(
        child: Text(
          '\u201C',
          style: TextStyle(
            fontSize: 56,
            color: Colors.white,
            height: 1.15,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

class _SampleCard extends StatelessWidget {
  const _SampleCard({required this.isDark});
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final cardColor = isDark ? const Color(0xFF1E1E35) : Colors.white;
    final textColor = isDark
        ? const Color(0xFFF0EFFF)
        : const Color(0xFF1A1A2E);

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(
              0xFF6C63FF,
            ).withValues(alpha: isDark ? 0.20 : 0.10),
            blurRadius: 30,
            offset: const Offset(0, 10),
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.06),
            blurRadius: 60,
            offset: const Offset(0, 20),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '"The secret of getting ahead is getting started."',
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: 15,
              fontWeight: FontWeight.w500,
              color: textColor,
              height: 1.6,
              fontStyle: FontStyle.italic,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            '— Mark Twain',
            style: GoogleFonts.poppins(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF6C63FF),
            ),
          ),
        ],
      ),
    );
  }
}

class _PulsingDots extends StatefulWidget {
  const _PulsingDots();

  @override
  State<_PulsingDots> createState() => _PulsingDotsState();
}

class _PulsingDotsState extends State<_PulsingDots>
    with SingleTickerProviderStateMixin {
  late final AnimationController _dotCtrl;

  @override
  void initState() {
    super.initState();
    _dotCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _dotCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _dotCtrl,
      builder: (context, _) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(3, (i) {
            final delay = i * 0.28;
            final t = ((_dotCtrl.value - delay) % 1.0).clamp(0.0, 1.0);
            final opacity = math.sin(t * math.pi).clamp(0.15, 1.0);
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Opacity(
                opacity: opacity,
                child: Container(
                  width: 6,
                  height: 6,
                  decoration: const BoxDecoration(
                    color: Color(0xFF6C63FF),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            );
          }),
        );
      },
    );
  }
}
