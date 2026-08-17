import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/quote_model.dart';
import '../services/quote_service.dart';

enum AppStatus { initial, loading, loaded, error }

class QuoteController extends ChangeNotifier {
  QuoteController(this._quoteService);

  final QuoteService _quoteService;

  AppStatus _status = AppStatus.initial;
  Quote? _currentQuote;
  String _errorMessage = '';
  final List<Quote> _favorites = [];

  /// True while the 3-D card transition animation is in progress.
  bool _isAnimating = false;

  // ─── Getters ──────────────────────────────────────────────────────────────

  AppStatus get status => _status;
  Quote? get currentQuote => _currentQuote;
  String get errorMessage => _errorMessage;
  List<Quote> get favorites => List.unmodifiable(_favorites);
  bool get isAnimating => _isAnimating;

  bool get isCurrentFavorite =>
      _currentQuote != null && _favorites.any((q) => q == _currentQuote);

  /// True only when the currently displayed quote was created by the user.
  bool get isCurrentQuoteUserCreated => _currentQuote?.isUserCreated ?? false;

  /// User-created quotes available in the app.
  List<Quote> get userQuotes => _quoteService.userQuotes;

  // ─── Lifecycle ────────────────────────────────────────────────────────────

  Future<void> init() async {
    _status = AppStatus.loading;
    notifyListeners();

    try {
      await _quoteService.loadQuotes();
      await _loadFavoritesFromPrefs();
      await _loadUserQuotesFromPrefs();
      _currentQuote = _quoteService.getRandomQuote();
      _status = AppStatus.loaded;
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      _status = AppStatus.error;
    }

    notifyListeners();
  }

  // ─── Quote transitions ────────────────────────────────────────────────────

  /// Picks the next random quote and signals the UI to start a transition.
  void nextQuote() {
    if (_isAnimating || _status != AppStatus.loaded) return;
    _isAnimating = true;
    _currentQuote = _quoteService.getRandomQuote();
    notifyListeners();
  }

  /// Called by the [QuoteSwitcher] widget when its 3-D animation finishes.
  void onTransitionComplete() {
    _isAnimating = false;
    notifyListeners();
  }

  // ─── Favorites ────────────────────────────────────────────────────────────

  Future<void> toggleFavorite() async {
    if (_currentQuote == null) return;

    final quote = _currentQuote!;
    final alreadyFav = _favorites.any((q) => q == quote);

    if (alreadyFav) {
      _favorites.removeWhere((q) => q == quote);
      quote.isFavorite = false;
    } else {
      quote.isFavorite = true;
      _favorites.add(quote);
    }

    notifyListeners();
    await _saveFavoritesToPrefs();
  }

  // ─── User quote CRUD ──────────────────────────────────────────────────────

  /// Adds a new user-created quote and immediately displays it with a
  /// transition animation.
  Future<void> addUserQuote(String text, String author) async {
    if (_status != AppStatus.loaded) return;

    final newQuote = Quote(
      text: text.trim(),
      author: author.trim(),
      isUserCreated: true,
    );

    _quoteService.addUserQuote(newQuote);

    // Trigger transition to the newly added quote.
    _isAnimating = true;
    _currentQuote = newQuote;
    notifyListeners();

    await _saveUserQuotesToPrefs();
  }

  /// Deletes the current quote (only if it is user-created), then transitions
  /// to a new random quote. Returns the deleted quote so callers can undo.
  Future<Quote?> deleteCurrentQuote() async {
    if (_currentQuote == null || !_currentQuote!.isUserCreated) return null;

    final toDelete = _currentQuote!;

    _quoteService.removeUserQuote(toDelete);
    _favorites.removeWhere((q) => q == toDelete);

    // Try to pick a new random quote, but handle empty list gracefully.
    try {
      _isAnimating = true;
      _currentQuote = _quoteService.getRandomQuote();
    } catch (_) {
      _isAnimating = false;
      _currentQuote = null;
    }

    notifyListeners();

    await _saveUserQuotesToPrefs();
    await _saveFavoritesToPrefs();
    return toDelete;
  }

  /// Restores a previously deleted user quote and makes it the current quote.
  Future<void> restoreUserQuote(Quote quote) async {
    _quoteService.addUserQuote(quote);
    _currentQuote = quote;
    notifyListeners();
    await _saveUserQuotesToPrefs();
  }

  /// Immediately show the provided quote without triggering the random
  /// selection animation. Useful for user-driven selection from lists.
  void showQuote(Quote quote) {
    _currentQuote = quote;
    notifyListeners();
  }

  /// Edits the currently displayed user-created quote.
  Future<bool> editCurrentQuote(String newText, String newAuthor) async {
    if (_currentQuote == null || !_currentQuote!.isUserCreated) return false;

    final old = _currentQuote!;
    final updated = Quote(
      text: newText.trim(),
      author: newAuthor.trim().isEmpty ? 'Unknown Author' : newAuthor.trim(),
      isFavorite: old.isFavorite,
      isUserCreated: true,
    );

    final replaced = _quoteService.updateUserQuote(old, updated);
    if (!replaced) return false;

    // Update favorites list if needed
    final favIdx = _favorites.indexWhere((q) => q == old);
    if (favIdx != -1) {
      _favorites[favIdx] = updated;
    }

    _currentQuote = updated;
    notifyListeners();
    await _saveUserQuotesToPrefs();
    await _saveFavoritesToPrefs();
    return true;
  }

  // ─── Persistence ──────────────────────────────────────────────────────────

  static const String _favoritesKey = 'favorite_quotes';
  static const String _userQuotesKey = 'user_quotes';

  Future<void> _loadFavoritesFromPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonStr = prefs.getString(_favoritesKey);
      if (jsonStr == null) return;

      final List<dynamic> decoded = json.decode(jsonStr) as List<dynamic>;
      final loaded = decoded
          .map((e) => Quote.fromJson(e as Map<String, dynamic>))
          .toList();

      _favorites
        ..clear()
        ..addAll(loaded);

      for (final fav in _favorites) {
        _quoteService.updateFavorite(fav, true);
      }
    } catch (_) {
      // Non-critical — start with no favorites
    }
  }

  Future<void> _saveFavoritesToPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonStr = json.encode(_favorites.map((q) => q.toJson()).toList());
      await prefs.setString(_favoritesKey, jsonStr);
    } catch (_) {
      // Non-critical
    }
  }

  Future<void> _loadUserQuotesFromPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonStr = prefs.getString(_userQuotesKey);
      if (jsonStr == null) return;

      final List<dynamic> decoded = json.decode(jsonStr) as List<dynamic>;
      final userQuotes = decoded
          .map((e) => Quote.fromJson(e as Map<String, dynamic>))
          .toList();

      _quoteService.initUserQuotes(userQuotes);
    } catch (_) {
      // Non-critical — start with no user quotes
    }
  }

  Future<void> _saveUserQuotesToPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userQuotes = _quoteService.allQuotes
          .where((q) => q.isUserCreated)
          .map((q) => q.toJson())
          .toList();
      await prefs.setString(_userQuotesKey, json.encode(userQuotes));
    } catch (_) {
      // Non-critical
    }
  }
}
