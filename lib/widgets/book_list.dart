import 'package:flutter/material.dart';
import '../models/book.dart';

class BookList extends StatelessWidget {
  final List<Book> books;
  final Function(int) onDelete;

  BookList({required this.books, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: books.length,
      itemBuilder: (context, index) {
        final book = books[index];
        return Card(
          margin: EdgeInsets.all(8.0),
          child: ListTile(
            leading: book.coverUrl.isNotEmpty
                ? Image.network(book.coverUrl, width: 50, height: 50, fit: BoxFit.cover)
                : Icon(Icons.book),
            title: Text(book.title),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Автор: ${book.author}'),
                Text('Год: ${book.year}'),
                if (book.description.isNotEmpty)
                  Text(
                    book.description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
              ],
            ),
            trailing: IconButton(
              icon: Icon(Icons.delete),
              onPressed: () => onDelete(book.id!),
            ),
          ),
        );
      },
    );
  }
}