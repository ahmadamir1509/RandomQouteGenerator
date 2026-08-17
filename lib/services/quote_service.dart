import 'dart:convert';
import 'dart:math';

import 'package:flutter/services.dart';

import '../models/quote_model.dart';

class QuoteService {
  static const String _quotesAssetPath = 'assets/quotes.json';

  List<Quote> _builtInQuotes = [];
  final List<Quote> _userQuotes = [];
  int _lastIndex = -1;
  final Random _random = Random();

  /// All quotes: built-in + user-created combined.
  List<Quote> get allQuotes => [..._builtInQuotes, ..._userQuotes];

  /// Returns the user-created quotes only.
  List<Quote> get userQuotes => List.unmodifiable(_userQuotes);

  /// Loads built-in quotes from the JSON asset file.
  Future<void> loadQuotes() async {
    try {
      final String jsonString = await rootBundle.loadString(_quotesAssetPath);
      final List<dynamic> jsonList = json.decode(jsonString) as List<dynamic>;

      if (jsonList.isEmpty) {
        throw Exception('Quotes list is empty in the asset file.');
      }

      _builtInQuotes = jsonList
          .map((e) => Quote.fromJson(e as Map<String, dynamic>))
          .toList();
    } on FormatException catch (e) {
      throw Exception('Invalid JSON format in quotes asset. ${e.message}');
    } catch (e) {
      throw Exception('Failed to load quotes: $e');
    }
  }

  /// Loads previously saved user quotes into the service.
  void initUserQuotes(List<Quote> quotes) {
    _userQuotes
      ..clear()
      ..addAll(quotes);
  }

  /// Adds a new user-created quote.
  void addUserQuote(Quote quote) {
    _userQuotes.add(quote);
  }

  /// Updates an existing user-created quote. Returns true if replaced.
  bool updateUserQuote(Quote oldQuote, Quote newQuote) {
    final idx = _userQuotes.indexWhere((q) => q == oldQuote);
    if (idx == -1) return false;
    _userQuotes[idx] = newQuote;
    return true;
  }

  /// Removes a user-created quote. No-op for built-in quotes.
  void removeUserQuote(Quote quote) {
    _userQuotes.removeWhere((q) => q == quote);
  }

  /// Returns a random [Quote] different from the last one shown.
  Quote getRandomQuote() {
    final all = allQuotes;
    if (all.isEmpty) {
      throw StateError('No quotes available. Call loadQuotes() first.');
    }
    if (all.length == 1) return all.first;

    int nextIndex;
    do {
      nextIndex = _random.nextInt(all.length);
    } while (nextIndex == _lastIndex);

    _lastIndex = nextIndex;
    return all[nextIndex];
  }

  /// Marks a quote as favorite / un-favorite across both lists.
  void updateFavorite(Quote quote, bool isFavorite) {
    for (final q in allQuotes) {
      if (q == quote) {
        q.isFavorite = isFavorite;
        return;
      }
    }
  }
}
