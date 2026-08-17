class Quote {
  final String text;
  final String author;
  bool isFavorite;
  final bool isUserCreated;

  Quote({
    required this.text,
    required this.author,
    this.isFavorite = false,
    this.isUserCreated = false,
  });

  factory Quote.fromJson(Map<String, dynamic> json) {
    return Quote(
      text: json['quote'] as String,
      author: json['author'] as String,
      isUserCreated: json['isUserCreated'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'quote': text,
      'author': author,
      'isUserCreated': isUserCreated,
    };
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Quote &&
          runtimeType == other.runtimeType &&
          text == other.text &&
          author == other.author;

  @override
  int get hashCode => text.hashCode ^ author.hashCode;
}
