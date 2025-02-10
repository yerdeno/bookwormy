import 'package:flutter/material.dart';
import '../models/book.dart';

class BookDetailScreen extends StatelessWidget {
  final Book book;

  const BookDetailScreen({super.key, required this.book});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(book.title),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (book.coverUrl.isNotEmpty)
              Center(
                child: Image.network(
                  book.coverUrl,
                  height: 300,
                  fit: BoxFit.cover,
                ),
              ),
            SizedBox(height: 16.0),
            Text(
              book.title,
              style: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8.0),
            Text(
              'Автор: ${book.author}',
              style: TextStyle(fontSize: 18.0, color: Colors.grey[600]),
            ),
            SizedBox(height: 8.0),
            Text(
              'Год: ${book.year}',
              style: TextStyle(fontSize: 16.0, color: Colors.grey[600]),
            ),
            SizedBox(height: 16.0),
            Text(
              'Описание:',
              style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8.0),
            Text(
              book.description,
              style: TextStyle(fontSize: 16.0),
            ),
          ],
        ),
      ),
    );
  }
}