import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class NewQuoteButton extends StatefulWidget {
  const NewQuoteButton({
    super.key,
    required this.onPressed,
    this.isLoading = false,
  });

  final VoidCallback onPressed;
  final bool isLoading;

  @override
  State<NewQuoteButton> createState() => _NewQuoteButtonState();
}

class _NewQuoteButtonState extends State<NewQuoteButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _iconRotation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0, 0.5, curve: Curves.easeIn),
        reverseCurve: const Interval(0.5, 1, curve: Curves.elasticOut),
      ),
    );

    _iconRotation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _onPressed() async {
    if (widget.isLoading) return;
    await _controller.forward(from: 0);
    widget.onPressed();
    _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scaleAnimation,
      child: ElevatedButton(
        onPressed: widget.isLoading ? null : _onPressed,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            RotationTransition(
              turns: _iconRotation,
              child: const Icon(Icons.refresh_rounded, size: 20),
            ),
            const SizedBox(width: 10),
            Text(
              'New Quote',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
