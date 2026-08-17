import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../models/quote_model.dart';
import '../providers/quote_controller.dart';
import '../screens/add_quote_screen.dart';
import '../utils/app_theme.dart';
import '../widgets/new_quote_button.dart';
import '../widgets/quote_actions.dart';
import '../widgets/quote_switcher.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: AppTheme.backgroundGradient(Theme.of(context).brightness),
      ),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Random Quote'),
          actions: const [
            _FavoritesMenuButton(),
            SizedBox(width: 4),
            _MoreMenuButton(),
            SizedBox(width: 8),
          ],
        ),
        body: Consumer<QuoteController>(
          builder: (context, controller, _) {
            return switch (controller.status) {
              AppStatus.initial || AppStatus.loading => const _LoadingView(),
              AppStatus.error => _ErrorView(message: controller.errorMessage),
              AppStatus.loaded => _QuoteView(controller: controller),
            };
          },
        ),
      ),
    );
  }
}

// ─── Loading ──────────────────────────────────────────────────────────────────

class _LoadingView extends StatelessWidget {
  const _LoadingView();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Theme.of(context).cardTheme.color,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF6C63FF).withValues(alpha: 0.2),
                  blurRadius: 30,
                ),
              ],
            ),
            child: const CircularProgressIndicator(
              color: Color(0xFF6C63FF),
              strokeWidth: 3,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Loading quotes\u2026',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }
}

// ─── Error ────────────────────────────────────────────────────────────────────

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final controller = context.read<QuoteController>();

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.red.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.error_outline_rounded,
                size: 52,
                color: Colors.red,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Oops! Something went wrong',
              style: Theme.of(context).textTheme.displayMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              message,
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: controller.init,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Try Again'),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Main quote view ──────────────────────────────────────────────────────────

class _QuoteView extends StatelessWidget {
  const _QuoteView({required this.controller});

  final QuoteController controller;

  void _openAddQuote(BuildContext context) {
    Navigator.of(
      context,
    ).push(MaterialPageRoute<void>(builder: (_) => const AddQuoteScreen()));
  }

  @override
  Widget build(BuildContext context) {
    final quote = controller.currentQuote!;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Spacer(),

            // ── 3-D card switcher ─────────────────────────────────────────
            QuoteSwitcher(
              quote: quote,
              onTransitionComplete: controller.onTransitionComplete,
            ),

            const SizedBox(height: 28),

            // ── Action buttons (copy / favorite / share / delete) ─────────
            QuoteActions(quote: quote, controller: controller),

            const Spacer(),

            // ── Bottom row: New Quote | + Add ─────────────────────────────
            // Fully responsive: NewQuoteButton expands to fill available
            // space; _AddButton takes its natural content size.
            // No Positioned, no hardcoded pixel offsets.
            Row(
              children: [
                Expanded(
                  child: NewQuoteButton(
                    onPressed: controller.nextQuote,
                    isLoading: controller.isAnimating,
                  ),
                ),
                const SizedBox(width: 12),
                _AddButton(onPressed: () => _openAddQuote(context)),
              ],
            ),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}

// ─── + Add button ─────────────────────────────────────────────────────────────

class _AddButton extends StatefulWidget {
  const _AddButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  State<_AddButton> createState() => _AddButtonState();
}

class _AddButtonState extends State<_AddButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
      reverseDuration: const Duration(milliseconds: 200),
      lowerBound: 0.90,
      upperBound: 1.0,
      value: 1.0,
    );
    _scale = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  Future<void> _onTap() async {
    await _ctrl.reverse();
    widget.onPressed();
    await _ctrl.forward();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return ScaleTransition(
      scale: _scale,
      child: ElevatedButton.icon(
        onPressed: _onTap,
        icon: const Icon(Icons.add_rounded, size: 18),
        label: Text(
          ' Add',
          style: GoogleFonts.poppins(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.3,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: scheme.secondaryContainer,
          foregroundColor: scheme.onSecondaryContainer,
          elevation: 4,
          shadowColor: scheme.secondaryContainer.withValues(alpha: 0.45),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(50),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        ),
      ),
    );
  }
}

// ─── Favorites AppBar button ──────────────────────────────────────────────────

class _FavoritesMenuButton extends StatelessWidget {
  const _FavoritesMenuButton();

  @override
  Widget build(BuildContext context) {
    return Consumer<QuoteController>(
      builder: (context, controller, _) {
        return IconButton(
          tooltip: 'Favorites',
          icon: Badge(
            isLabelVisible: controller.favorites.isNotEmpty,
            label: Text('${controller.favorites.length}'),
            child: const Icon(Icons.favorite_rounded),
          ),
          onPressed: () => _showFavoritesSheet(context, controller),
        );
      },
    );
  }

  void _showFavoritesSheet(BuildContext context, QuoteController controller) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Theme.of(context).cardTheme.color,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (_) => _FavoritesSheet(controller: controller),
    );
  }
}

// ─── More (hamburger) menu for additional actions like deleting user quotes
class _MoreMenuButton extends StatelessWidget {
  const _MoreMenuButton();

  @override
  Widget build(BuildContext context) {
    return Consumer<QuoteController>(
      builder: (context, controller, _) {
        return PopupMenuButton<String>(
          tooltip: 'More',
          onSelected: (value) async {
            if (value == 'delete') {
              final confirm = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Delete quote'),
                  content: const Text(
                    'Are you sure you want to delete this quote? This action cannot be undone.',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(false),
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(true),
                      child: const Text('Delete'),
                    ),
                  ],
                ),
              );

              if (confirm == true) {
                final deleted = await controller.deleteCurrentQuote();
                if (!context.mounted) return;

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text('Quote deleted'),
                    action: SnackBarAction(
                      label: 'Undo',
                      onPressed: () {
                        if (deleted != null)
                          controller.restoreUserQuote(deleted);
                      },
                    ),
                  ),
                );
              }
            } else if (value == 'edit') {
              // Open edit screen with current quote prefilled
              if (controller.currentQuote != null &&
                  controller.currentQuote!.isUserCreated) {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) =>
                        AddQuoteScreen(initialQuote: controller.currentQuote),
                  ),
                );
              }
            } else if (value == 'my_quotes') {
              // Show a sheet listing user-created quotes for quick access
              showModalBottomSheet<void>(
                context: context,
                isScrollControlled: true,
                backgroundColor: Theme.of(context).cardTheme.color,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
                ),
                builder: (_) => _MyQuotesSheet(controller: controller),
              );
            }
          },
          itemBuilder: (context) {
            return <PopupMenuEntry<String>>[
              PopupMenuItem<String>(
                value: 'edit',
                enabled: controller.isCurrentQuoteUserCreated,
                child: Row(
                  children: [
                    const Icon(Icons.edit_outlined),
                    const SizedBox(width: 8),
                    const Text('Edit quote'),
                  ],
                ),
              ),
              PopupMenuItem<String>(
                value: 'my_quotes',
                child: Row(
                  children: [
                    const Icon(Icons.list_alt_rounded),
                    const SizedBox(width: 8),
                    const Text('My quotes'),
                  ],
                ),
              ),
              PopupMenuItem<String>(
                value: 'delete',
                enabled: controller.isCurrentQuoteUserCreated,
                child: Row(
                  children: [
                    const Icon(Icons.delete_outline),
                    const SizedBox(width: 8),
                    const Text('Delete quote'),
                  ],
                ),
              ),
            ];
          },
          icon: const Icon(Icons.more_vert_rounded),
        );
      },
    );
  }
}

// ─── Favorites bottom sheet ────────────────────────────────────────────────────

class _FavoritesSheet extends StatelessWidget {
  const _FavoritesSheet({required this.controller});

  final QuoteController controller;

  @override
  Widget build(BuildContext context) {
    final favorites = controller.favorites;
    final theme = Theme.of(context);

    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.6,
      minChildSize: 0.3,
      maxChildSize: 0.92,
      builder: (context, scrollController) {
        return Column(
          children: [
            // Drag handle
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: theme.dividerColor,
                borderRadius: BorderRadius.circular(2),
              ),
            ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              child: Row(
                children: [
                  const Icon(
                    Icons.favorite_rounded,
                    color: Color(0xFFFF6B6B),
                    size: 22,
                  ),
                  const SizedBox(width: 10),
                  Text(
                    'Favorites',
                    style: theme.textTheme.displayMedium?.copyWith(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const Spacer(),
                  if (favorites.isNotEmpty)
                    Text(
                      '${favorites.length} '
                      'quote${favorites.length == 1 ? '' : 's'}',
                      style: theme.textTheme.bodyMedium,
                    ),
                ],
              ),
            ),

            const Divider(height: 1),

            Expanded(
              child: favorites.isEmpty
                  ? _EmptyFavorites(theme: theme)
                  : ListView.separated(
                      controller: scrollController,
                      padding: const EdgeInsets.all(16),
                      itemCount: favorites.length,
                      separatorBuilder: (context, index) =>
                          const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        return _FavoriteQuoteTile(quote: favorites[index]);
                      },
                    ),
            ),
          ],
        );
      },
    );
  }
}

// ─── My Quotes sheet ───────────────────────────────────────────────────────

class _MyQuotesSheet extends StatelessWidget {
  const _MyQuotesSheet({required this.controller});

  final QuoteController controller;

  @override
  Widget build(BuildContext context) {
    final quotes = controller.userQuotes;
    final theme = Theme.of(context);

    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.6,
      minChildSize: 0.3,
      maxChildSize: 0.92,
      builder: (context, scrollController) {
        return Column(
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: theme.dividerColor,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              child: Row(
                children: [
                  const Icon(
                    Icons.list_alt_rounded,
                    size: 22,
                    color: Color(0xFF6C63FF),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    'My quotes',
                    style: theme.textTheme.displayMedium?.copyWith(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const Spacer(),
                  if (quotes.isNotEmpty)
                    Text(
                      '${quotes.length} items',
                      style: theme.textTheme.bodyMedium,
                    ),
                ],
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: quotes.isEmpty
                  ? Center(
                      child: Text(
                        'You have not added any quotes yet.',
                        style: theme.textTheme.bodyMedium,
                      ),
                    )
                  : ListView.separated(
                      controller: scrollController,
                      padding: const EdgeInsets.all(16),
                      itemCount: quotes.length,
                      separatorBuilder: (context, index) =>
                          const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final q = quotes[index];
                        return _UserQuoteTile(quote: q, controller: controller);
                      },
                    ),
            ),
          ],
        );
      },
    );
  }
}

class _UserQuoteTile extends StatelessWidget {
  const _UserQuoteTile({required this.quote, required this.controller});

  final Quote quote;
  final QuoteController controller;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '"${quote.text}"',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodyMedium,
                ),
                const SizedBox(height: 6),
                Text(
                  '— ${quote.author}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: const Color(0xFF6C63FF),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Column(
            children: [
              IconButton(
                tooltip: 'Show',
                icon: const Icon(Icons.visibility_rounded),
                onPressed: () {
                  controller.showQuote(quote);
                  Navigator.of(context).pop();
                },
              ),
              IconButton(
                tooltip: 'Edit',
                icon: const Icon(Icons.edit_rounded),
                onPressed: () {
                  Navigator.of(context).pop();
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => AddQuoteScreen(initialQuote: quote),
                    ),
                  );
                },
              ),
              IconButton(
                tooltip: 'Delete',
                icon: const Icon(Icons.delete_outline_rounded),
                onPressed: () async {
                  final deleted = await controller.deleteCurrentQuote();
                  if (!context.mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text('Quote deleted'),
                      action: SnackBarAction(
                        label: 'Undo',
                        onPressed: () {
                          if (deleted != null)
                            controller.restoreUserQuote(deleted);
                        },
                      ),
                    ),
                  );
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _EmptyFavorites extends StatelessWidget {
  const _EmptyFavorites({required this.theme});

  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.favorite_border_rounded,
            size: 64,
            color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.3),
          ),
          const SizedBox(height: 16),
          Text(
            'No favorites yet',
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.6),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Tap \u2665 to save a quote',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.5),
            ),
          ),
        ],
      ),
    );
  }
}

class _FavoriteQuoteTile extends StatelessWidget {
  const _FavoriteQuoteTile({required this.quote});

  final Quote quote;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFF6C63FF).withValues(alpha: 0.1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '\u201C${quote.text}\u201D',
            style: theme.textTheme.bodyMedium?.copyWith(
              fontStyle: FontStyle.italic,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Text(
                '\u2014 ${quote.author}',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: const Color(0xFF6C63FF),
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
              if (quote.isUserCreated) ...[
                const SizedBox(width: 6),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF6C63FF).withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    'Mine',
                    style: GoogleFonts.poppins(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF6C63FF),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}
