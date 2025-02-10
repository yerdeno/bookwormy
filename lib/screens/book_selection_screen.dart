import 'package:flutter/material.dart';
import '../models/book.dart';
import '../services/google_books_api.dart';

class BookSelectionScreen extends StatefulWidget {
  final String searchQuery;

  const BookSelectionScreen({super.key, required this.searchQuery});

  @override
  _BookSelectionScreenState createState() => _BookSelectionScreenState();
}

class _BookSelectionScreenState extends State<BookSelectionScreen> {
  late Future<List<Book>> _booksFuture;

  @override
  void initState() {
    super.initState();
    _booksFuture = GoogleBooksApi.fetchBooks(widget.searchQuery);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Выберите книгу'),
      ),
      body: FutureBuilder<List<Book>>(
        future: _booksFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Ошибка: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('Книги не найдены'));
          } else {
            final books = snapshot.data!;
            return ListView.builder(
              itemCount: books.length,
              itemBuilder: (context, index) {
                final book = books[index];
                return ListTile(
                  leading: book.coverUrl.isNotEmpty
                      ? Image.network(book.coverUrl, width: 50, height: 50, fit: BoxFit.cover)
                      : Icon(Icons.book),
                  title: Text(book.title),
                  subtitle: Text('Автор: ${book.author}'),
                  onTap: () {
                    Navigator.pop(context, book);
                  },
                );
              },
            );
          }
        },
      ),
    );
  }
}