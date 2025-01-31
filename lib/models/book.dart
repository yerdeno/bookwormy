class Book {
  int? id;
  String title;
  String author;
  String description;
  int year;
  String coverUrl;

  Book({
    this.id,
    required this.title,
    required this.author,
    required this.description,
    required this.year,
    required this.coverUrl,
  });

  // Преобразование книги в Map для SQLite
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'author': author,
      'description': description,
      'year': year,
      'coverUrl': coverUrl,
    };
  }

  // Создание книги из Map
  factory Book.fromMap(Map<String, dynamic> map) {
    return Book(
      id: map['id'],
      title: map['title'],
      author: map['author'],
      description: map['description'],
      year: map['year'],
      coverUrl: map['coverUrl'],
    );
  }
}