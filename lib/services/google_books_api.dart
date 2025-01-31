import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/book.dart';

class GoogleBooksApi {
  static const String _baseUrl = 'https://www.googleapis.com/books/v1/volumes';

  // Поиск книг по названию
  static Future<List<Book>> fetchBooks(String title) async {
    final response = await http.get(Uri.parse('$_baseUrl?q=$title'));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['totalItems'] > 0) {
        final List<dynamic> items = data['items'];
        return items.map((item) {
          final bookData = item['volumeInfo'];
          return Book(
            title: bookData['title'] ?? 'Нет названия',
            author: bookData['authors'] != null
                ? bookData['authors'].join(', ')
                : 'Неизвестный автор',
            description: bookData['description'] ?? 'Нет описания',
            year: int.tryParse(bookData['publishedDate']?.substring(0, 4)) ?? 0,
            coverUrl: bookData['imageLinks'] != null
                ? bookData['imageLinks']['thumbnail']
                : '',
          );
        }).toList();
      }
    }
    return [];
  }
}