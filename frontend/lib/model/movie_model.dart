class Movie {
  final String id;
  final String title;
  final String overview;
  final int releaseYear;
  final List<String> genre;
  final int? runtime;
  final double? rating;
  final String? posterUrl;
  final String createdBy;
  final DateTime createdAt;

  Movie({
    required this.id,
    required this.title,
    required this.overview,
    required this.releaseYear,
    required this.genre,
    this.runtime,
    this.rating,
    this.posterUrl,
    required this.createdBy,
    required this.createdAt,
  });

  factory Movie.fromJson(Map<String, dynamic> json) {
    return Movie(
      id: json["id"],
      title: json["title"],
      overview: json["overview"],
      releaseYear: json["releaseYear"],
      genre: List<String>.from(json["genre"] ?? []),
      runtime: json["runtime"],
      rating: json["rating"],
      posterUrl: json["posterUrl"],
      createdBy: json["createdBy"],
      createdAt: DateTime.parse(json["createdAt"]),
    );
  }
}
