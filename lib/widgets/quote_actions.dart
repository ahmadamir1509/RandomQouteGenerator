import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:share_plus/share_plus.dart';

import '../models/quote_model.dart';
import '../providers/quote_controller.dart';

class QuoteActions extends StatelessWidget {
  const QuoteActions({
    super.key,
    required this.quote,
    required this.controller,
  });

  final Quote quote;
  final QuoteController controller;

  String get _shareText => '"${quote.text}"\n\u2014 ${quote.author}';

  // ─── Action handlers ───────────────────────────────────────────────────────

  Future<void> _copyToClipboard(BuildContext context) async {
    await Clipboard.setData(ClipboardData(text: _shareText));
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle_rounded,
                color: Color(0xFF6C63FF), size: 20),
            const SizedBox(width: 10),
            Text(
              'Quote copied!',
              style: GoogleFonts.poppins(fontWeight: FontWeight.w500),
            ),
          ],
        ),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Future<void> _shareQuote() async {
    await Share.share(_shareText);
  }

  Future<void> _showDeleteDialog(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Text(
          'Delete Quote?',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w700),
        ),
        content: Text(
          'Are you sure you want to delete this quote?',
          style: GoogleFonts.poppins(fontSize: 14, height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(
              'Cancel',
              style: GoogleFonts.poppins(fontWeight: FontWeight.w500),
            ),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: FilledButton.styleFrom(
              backgroundColor: Colors.red.shade600,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              'Delete',
              style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    await controller.deleteCurrentQuote();

    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.delete_rounded, color: Colors.white, size: 20),
            const SizedBox(width: 10),
            Text(
              'Quote deleted successfully!',
              style: GoogleFonts.poppins(fontWeight: FontWeight.w500),
            ),
          ],
        ),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  // ─── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final colorScheme   = Theme.of(context).colorScheme;
    final isFavorite    = controller.isCurrentFavorite;
    final isUserCreated = controller.isCurrentQuoteUserCreated;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Copy
        _ActionButton(
          icon: Icons.copy_rounded,
          tooltip: 'Copy quote',
          onTap: () => _copyToClipboard(context),
          colorScheme: colorScheme,
        ),
        const SizedBox(width: 14),

        // Favorite
        _ActionButton(
          icon: isFavorite
              ? Icons.favorite_rounded
              : Icons.favorite_border_rounded,
          tooltip:
              isFavorite ? 'Remove from favorites' : 'Add to favorites',
          onTap: controller.toggleFavorite,
          colorScheme: colorScheme,
          isActive: isFavorite,
          activeColor: const Color(0xFFFF6B6B),
        ),
        const SizedBox(width: 14),

        // Share
        _ActionButton(
          icon: Icons.share_rounded,
          tooltip: 'Share quote',
          onTap: _shareQuote,
          colorScheme: colorScheme,
        ),

        // Delete — only for user-created quotes
        if (isUserCreated) ...[
          const SizedBox(width: 14),
          _ActionButton(
            icon: Icons.delete_outline_rounded,
            tooltip: 'Delete quote',
            onTap: () => _showDeleteDialog(context),
            colorScheme: colorScheme,
            activeColor: Colors.red.shade400,
          ),
        ],
      ],
    );
  }
}

// ─── Reusable animated action button ─────────────────────────────────────────

class _ActionButton extends StatefulWidget {
  const _ActionButton({
    required this.icon,
    required this.tooltip,
    required this.onTap,
    required this.colorScheme,
    this.isActive = false,
    this.activeColor,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;
  final ColorScheme colorScheme;
  final bool isActive;
  final Color? activeColor;

  @override
  State<_ActionButton> createState() => _ActionButtonState();
}

class _ActionButtonState extends State<_ActionButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _scaleCtrl;
  late final Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _scaleCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 110),
      reverseDuration: const Duration(milliseconds: 200),
      lowerBound: 0.85,
      upperBound: 1.0,
      value: 1.0,
    );
    _scaleAnim =
        CurvedAnimation(parent: _scaleCtrl, curve: Curves.easeOut);
  }

  @override
  void dispose() {
    _scaleCtrl.dispose();
    super.dispose();
  }

  Future<void> _onTap() async {
    await _scaleCtrl.reverse();
    widget.onTap();
    await _scaleCtrl.forward();
  }

  @override
  Widget build(BuildContext context) {
    final color = widget.isActive
        ? (widget.activeColor ?? widget.colorScheme.primary)
        : widget.colorScheme.onSurfaceVariant;

    return Tooltip(
      message: widget.tooltip,
      child: ScaleTransition(
        scale: _scaleAnim,
        child: Material(
          color: widget.colorScheme.surfaceContainerHighest
              .withValues(alpha: 0.6),
          borderRadius: BorderRadius.circular(16),
          child: InkWell(
            onTap: _onTap,
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 220),
                transitionBuilder: (child, animation) => ScaleTransition(
                  scale: animation,
                  child: child,
                ),
                child: Icon(
                  widget.icon,
                  key: ValueKey('${widget.icon}_${widget.isActive}'),
                  color: color,
                  size: 22,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
