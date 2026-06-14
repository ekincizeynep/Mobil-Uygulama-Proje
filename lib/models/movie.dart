class Movie {

  int? id;

  String title;

  String type;

  String category;

  bool watched;

  int rating; // 0-5 arası yıldız puanı (0 = puanlanmamış)

  Movie({
    this.id,
    required this.title,
    required this.type,
    required this.category,
    required this.watched,
    this.rating = 0,
  });

  Map<String, dynamic> toMap() {

    return {
      'id': id,
      'title': title,
      'type': type,
      'category': category,
      'watched': watched ? 1 : 0,
      'rating': rating,
    };
  }

  factory Movie.fromMap(Map<String, dynamic> map) {

    return Movie(
      id: map['id'],
      title: map['title'],
      type: map['type'],
      category: map['category'],
      watched: map['watched'] == 1,
      rating: map['rating'] ?? 0,
    );
  }
}