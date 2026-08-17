import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../models/quote_model.dart';
import '../widgets/quote_card.dart';

/// A widget that animates between quotes using a 3-D left-swipe transition.
///
/// When [quote] changes via [didUpdateWidget], the old quote slides out to the
/// LEFT while the new quote enters from the RIGHT, both with a Matrix4
/// perspective + Y-axis rotation for a physical card-swipe feel.
class QuoteSwitcher extends StatefulWidget {
  const QuoteSwitcher({
    super.key,
    required this.quote,
    required this.onTransitionComplete,
  });

  final Quote quote;

  /// Called when the 3-D transition animation finishes so the controller can
  /// release its animation lock.
  final VoidCallback onTransitionComplete;

  @override
  State<QuoteSwitcher> createState() => _QuoteSwitcherState();
}

class _QuoteSwitcherState extends State<QuoteSwitcher>
    with SingleTickerProviderStateMixin {
  // ─── Animation controller ─────────────────────────────────────────────────

  late final AnimationController _ctrl;

  // Curves used for outgoing / incoming cards
  late final CurvedAnimation _outCurve;
  late final CurvedAnimation _inCurve;
  late final CurvedAnimation _outOpacityCurve;
  late final CurvedAnimation _inOpacityCurve;

  // Outgoing (old) card — goes LEFT
  late final Animation<double> _outSlide;   // 0 → 1  (× -screenWidth)
  late final Animation<double> _outRotate;  // 0 → 1  (× π/12)
  late final Animation<double> _outScale;   // 1 → 0.88
  late final Animation<double> _outOpacity; // 1 → 0

  // Incoming (new) card — comes from RIGHT
  late final Animation<double> _inSlide;    // 1 → 0  (× +screenWidth)
  late final Animation<double> _inRotate;   // 1 → 0  (× -π/12)
  late final Animation<double> _inScale;    // 0.88 → 1
  late final Animation<double> _inOpacity;  // 0 → 1

  // ─── Display state ────────────────────────────────────────────────────────

  late Quote _displayedQuote;
  Quote? _outgoingQuote;

  // ─── Lifecycle ────────────────────────────────────────────────────────────

  @override
  void initState() {
    super.initState();
    _displayedQuote = widget.quote;
    _setupAnimations();
  }

  void _setupAnimations() {
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 620),
    );

    // Curves
    _outCurve = CurvedAnimation(
      parent: _ctrl,
      curve: Curves.easeInCubic,
    );
    _inCurve = CurvedAnimation(
      parent: _ctrl,
      curve: Curves.easeOutBack,
    );
    _outOpacityCurve = CurvedAnimation(
      parent: _ctrl,
      curve: const Interval(0.25, 1.0, curve: Curves.easeIn),
    );
    _inOpacityCurve = CurvedAnimation(
      parent: _ctrl,
      curve: const Interval(0.0, 0.65, curve: Curves.easeOut),
    );

    // Outgoing animations
    _outSlide   = Tween<double>(begin: 0.0, end: 1.0).animate(_outCurve);
    _outRotate  = Tween<double>(begin: 0.0, end: 1.0).animate(_outCurve);
    _outScale   = Tween<double>(begin: 1.0, end: 0.88).animate(_outCurve);
    _outOpacity = Tween<double>(begin: 1.0, end: 0.0).animate(_outOpacityCurve);

    // Incoming animations
    _inSlide   = Tween<double>(begin: 1.0, end: 0.0).animate(_inCurve);
    _inRotate  = Tween<double>(begin: 1.0, end: 0.0).animate(_inCurve);
    _inScale   = Tween<double>(begin: 0.88, end: 1.0).animate(_inCurve);
    _inOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(_inOpacityCurve);

    // When animation completes, remove the outgoing card from the tree and
    // notify the controller so the next tap becomes available again.
    _ctrl.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        setState(() => _outgoingQuote = null);
        widget.onTransitionComplete();
      }
    });
  }

  @override
  void didUpdateWidget(QuoteSwitcher oldWidget) {
    super.didUpdateWidget(oldWidget);
    // A genuine quote change — trigger the 3-D transition.
    if (oldWidget.quote != widget.quote && !_ctrl.isAnimating) {
      _triggerTransition(fromQuote: oldWidget.quote, toQuote: widget.quote);
    }
  }

  void _triggerTransition({
    required Quote fromQuote,
    required Quote toQuote,
  }) {
    setState(() {
      _outgoingQuote   = fromQuote;
      _displayedQuote  = toQuote;
    });
    _ctrl.forward(from: 0.0);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    _outCurve.dispose();
    _inCurve.dispose();
    _outOpacityCurve.dispose();
    _inOpacityCurve.dispose();
    super.dispose();
  }

  // ─── Build ────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.sizeOf(context).width;

    return Stack(
      // Clip.none lets cards travel past the Stack's own bounds so they
      // disappear at the screen edge rather than the card boundary.
      clipBehavior: Clip.none,
      alignment: Alignment.center,
      children: [
        // ── Incoming / current card ──────────────────────────────────────────
        _IncomingCard(
          quote: _displayedQuote,
          isAnimating: _outgoingQuote != null,
          screenWidth: screenWidth,
          slideAnim: _inSlide,
          rotateAnim: _inRotate,
          scaleAnim: _inScale,
          opacityAnim: _inOpacity,
          ctrl: _ctrl,
        ),

        // ── Outgoing card (only during transition) ───────────────────────────
        if (_outgoingQuote != null)
          _OutgoingCard(
            quote: _outgoingQuote!,
            screenWidth: screenWidth,
            slideAnim: _outSlide,
            rotateAnim: _outRotate,
            scaleAnim: _outScale,
            opacityAnim: _outOpacity,
            ctrl: _ctrl,
          ),
      ],
    );
  }
}

// ─── Outgoing card ────────────────────────────────────────────────────────────

class _OutgoingCard extends StatelessWidget {
  const _OutgoingCard({
    required this.quote,
    required this.screenWidth,
    required this.slideAnim,
    required this.rotateAnim,
    required this.scaleAnim,
    required this.opacityAnim,
    required this.ctrl,
  });

  final Quote quote;
  final double screenWidth;
  final Animation<double> slideAnim;
  final Animation<double> rotateAnim;
  final Animation<double> scaleAnim;
  final Animation<double> opacityAnim;
  final AnimationController ctrl;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: ctrl,
      child: QuoteCard(quote: quote),
      builder: (context, child) {
        // Translate LEFT  →  slight right-side-forward Y rotation  →  shrink
        final matrix = Matrix4.identity()
          ..setEntry(3, 2, 0.001)                           // perspective
          ..translateByDouble(-screenWidth * 1.3 * slideAnim.value, 0.0, 0.0, 0.0)
          ..rotateY(math.pi / 12 * rotateAnim.value)        // right edge toward viewer
          ..scaleByDouble(scaleAnim.value, scaleAnim.value, scaleAnim.value, 1.0);

        return Opacity(
          opacity: opacityAnim.value.clamp(0.0, 1.0),
          child: Transform(
            transform: matrix,
            alignment: Alignment.center,
            child: child,
          ),
        );
      },
    );
  }
}

// ─── Incoming card ────────────────────────────────────────────────────────────

class _IncomingCard extends StatelessWidget {
  const _IncomingCard({
    required this.quote,
    required this.isAnimating,
    required this.screenWidth,
    required this.slideAnim,
    required this.rotateAnim,
    required this.scaleAnim,
    required this.opacityAnim,
    required this.ctrl,
  });

  final Quote quote;
  final bool isAnimating;
  final double screenWidth;
  final Animation<double> slideAnim;
  final Animation<double> rotateAnim;
  final Animation<double> scaleAnim;
  final Animation<double> opacityAnim;
  final AnimationController ctrl;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: ctrl,
      child: QuoteCard(quote: quote),
      builder: (context, child) {
        // When NOT animating just show the card at its natural position.
        if (!isAnimating) return child!;

        // Translate from RIGHT → centre  +  slight left-side-forward Y rotation
        final matrix = Matrix4.identity()
          ..setEntry(3, 2, 0.001)
          ..translateByDouble(screenWidth * 1.3 * slideAnim.value, 0.0, 0.0, 0.0)
          ..rotateY(-math.pi / 12 * rotateAnim.value)  // left edge toward viewer
          ..scaleByDouble(scaleAnim.value, scaleAnim.value, scaleAnim.value, 1.0);

        return Opacity(
          opacity: opacityAnim.value.clamp(0.0, 1.0),
          child: Transform(
            transform: matrix,
            alignment: Alignment.center,
            child: child,
          ),
        );
      },
    );
  }
}
