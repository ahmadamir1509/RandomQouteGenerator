import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../models/quote_model.dart';
import '../providers/quote_controller.dart';
import '../utils/app_theme.dart';

class AddQuoteScreen extends StatefulWidget {
  const AddQuoteScreen({super.key, this.initialQuote});

  final Quote? initialQuote;

  @override
  State<AddQuoteScreen> createState() => _AddQuoteScreenState();
}

class _AddQuoteScreenState extends State<AddQuoteScreen> {
  final _formKey = GlobalKey<FormState>();
  final _quoteCtrl = TextEditingController();
  final _authorCtrl = TextEditingController();
  bool _isSaving = false;

  bool get _isEditMode => widget.initialQuote != null;

  @override
  void dispose() {
    _quoteCtrl.dispose();
    _authorCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    final controller = context.read<QuoteController>();
    if (_isEditMode) {
      await controller.editCurrentQuote(_quoteCtrl.text, _authorCtrl.text);
    } else {
      await controller.addUserQuote(_quoteCtrl.text, _authorCtrl.text);
    }

    if (!mounted) return;
    Navigator.of(context).pop();
  }

  @override
  void initState() {
    super.initState();
    if (widget.initialQuote != null) {
      _quoteCtrl.text = widget.initialQuote!.text;
      _authorCtrl.text = widget.initialQuote!.author;
    }
  }

  // ─── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final isDark = brightness == Brightness.dark;
    final scheme = Theme.of(context).colorScheme;

    return Container(
      decoration: BoxDecoration(
        gradient: AppTheme.backgroundGradient(brightness),
      ),
      child: Scaffold(
        appBar: AppBar(
          title: Text(_isEditMode ? 'Edit Quote' : 'Add Quote'),
          leading: IconButton(
            icon: const Icon(Icons.close_rounded),
            onPressed: () => Navigator.of(context).pop(),
            tooltip: 'Cancel',
          ),
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 8),

                  // ── Header ──────────────────────────────────────────────
                  _SectionHeader(
                    isDark: isDark,
                    icon: Icons.format_quote_rounded,
                    title: 'Your Quote',
                    subtitle: 'Write something meaningful.',
                  ),

                  const SizedBox(height: 20),

                  // ── Quote text ───────────────────────────────────────────
                  _StyledField(
                    controller: _quoteCtrl,
                    hint: 'Enter your quote here\u2026',
                    maxLines: 5,
                    scheme: scheme,
                    isDark: isDark,
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) {
                        return 'Please enter a quote.';
                      }
                      if (v.trim().length < 10) {
                        return 'Quote must be at least 10 characters.';
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 24),

                  // ── Author ───────────────────────────────────────────────
                  _SectionHeader(
                    isDark: isDark,
                    icon: Icons.person_rounded,
                    title: 'Author',
                    subtitle: 'Who said it?',
                  ),

                  const SizedBox(height: 20),

                  _StyledField(
                    controller: _authorCtrl,
                    hint: 'e.g. Albert Einstein, Anonymous\u2026',
                    maxLines: 1,
                    scheme: scheme,
                    isDark: isDark,
                    textInputAction: TextInputAction.done,
                    onFieldSubmitted: (_) => _save(),
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) {
                        return 'Please enter the author\'s name.';
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 40),

                  // ── Save button ──────────────────────────────────────────
                  SizedBox(
                    height: 56,
                    child: ElevatedButton.icon(
                      onPressed: _isSaving ? null : _save,
                      icon: _isSaving
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Icon(Icons.check_rounded, size: 20),
                      label: Text(
                        _isSaving ? 'Saving\u2026' : 'Save Quote',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  Text(
                    'Your quote will be saved locally on this device.',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: Theme.of(
                        context,
                      ).textTheme.bodyMedium?.color?.withValues(alpha: 0.5),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Section header ────────────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.isDark,
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final bool isDark;
  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: const Color(0xFF6C63FF).withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: const Color(0xFF6C63FF), size: 20),
        ),
        const SizedBox(width: 14),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: isDark
                    ? const Color(0xFFF0EFFF)
                    : const Color(0xFF1A1A2E),
              ),
            ),
            Text(
              subtitle,
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: const Color(0xFF6B7280),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

// ─── Styled text field ─────────────────────────────────────────────────────────

class _StyledField extends StatelessWidget {
  const _StyledField({
    required this.controller,
    required this.hint,
    required this.maxLines,
    required this.scheme,
    required this.isDark,
    required this.validator,
    this.textInputAction = TextInputAction.next,
    this.onFieldSubmitted,
  });

  final TextEditingController controller;
  final String hint;
  final int maxLines;
  final ColorScheme scheme;
  final bool isDark;
  final String? Function(String?) validator;
  final TextInputAction textInputAction;
  final ValueChanged<String>? onFieldSubmitted;

  @override
  Widget build(BuildContext context) {
    final fillColor = isDark ? const Color(0xFF1E1E35) : Colors.white;
    final borderColor = const Color(0xFF6C63FF).withValues(alpha: 0.25);

    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      textInputAction: textInputAction,
      onFieldSubmitted: onFieldSubmitted,
      validator: validator,
      style: GoogleFonts.poppins(
        fontSize: 15,
        color: isDark ? const Color(0xFFF0EFFF) : const Color(0xFF1A1A2E),
        height: 1.55,
      ),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: GoogleFonts.poppins(
          fontSize: 15,
          color: const Color(0xFF6B7280).withValues(alpha: 0.7),
        ),
        filled: true,
        fillColor: fillColor,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 18,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: borderColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: borderColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFF6C63FF), width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Colors.red),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Colors.red, width: 1.5),
        ),
      ),
    );
  }
}
