import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../models/quote_model.dart';
import '../utils/app_theme.dart';

class QuoteCard extends StatelessWidget {
  const QuoteCard({super.key, required this.quote});

  final Quote quote;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final brightness = theme.brightness;
    final cardColor = theme.cardTheme.color ?? Colors.white;
    final shadowColor = AppTheme.cardShadowColor(brightness);
    // Keep the card height responsive and avoid pixel overflow with very
    // long quotes by limiting maxHeight and allowing the inner content to
    // scroll when needed.
    final maxCardHeight = MediaQuery.sizeOf(context).height * 0.56;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        color: cardColor,
        boxShadow: [
          BoxShadow(
            color: shadowColor,
            blurRadius: 40,
            spreadRadius: 0,
            offset: const Offset(0, 12),
          ),
          BoxShadow(
            color: shadowColor.withValues(alpha: 0.06),
            blurRadius: 80,
            spreadRadius: 0,
            offset: const Offset(0, 30),
          ),
        ],
      ),
      child: ConstrainedBox(
        constraints: BoxConstraints(maxHeight: maxCardHeight),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 6),
                // ── Quotation mark icon ─────────────────────────────────
                _QuotationMark(brightness: brightness),
                const SizedBox(height: 18),

                // ── Quote text ───────────────────────────────────────────
                Text(
                  quote.text,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    fontSize: 20,
                    fontWeight: FontWeight.w500,
                    color: theme.textTheme.displayMedium?.color,
                    height: 1.55,
                    letterSpacing: 0.2,
                  ),
                ),

                // ── Divider ─────────────────────────────────────────────
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  child: Row(
                    children: [
                      Expanded(
                        child: Container(
                          height: 1,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Colors.transparent,
                                const Color(0xFF6C63FF).withValues(alpha: 0.3),
                              ],
                            ),
                          ),
                        ),
                      ),
                      Container(
                        width: 6,
                        height: 6,
                        margin: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: const BoxDecoration(
                          color: Color(0xFF6C63FF),
                          shape: BoxShape.circle,
                        ),
                      ),
                      Expanded(
                        child: Container(
                          height: 1,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                const Color(0xFF6C63FF).withValues(alpha: 0.3),
                                Colors.transparent,
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // ── Author ──────────────────────────────────────────────
                Text(
                  '— ${quote.author}',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF6C63FF),
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 6),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Quotation mark ornament ──────────────────────────────────────────────────

class _QuotationMark extends StatelessWidget {
  const _QuotationMark({required this.brightness});

  final Brightness brightness;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF6C63FF), Color(0xFF9B8FFF)],
        ),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF6C63FF).withValues(alpha: 0.35),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: const Center(
        child: Text(
          '\u201C',
          style: TextStyle(
            fontSize: 36,
            color: Colors.white,
            height: 1.2,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
