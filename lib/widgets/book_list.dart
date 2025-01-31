import 'package:flutter/material.dart';
import '../models/book.dart';

class BookList extends StatelessWidget {
  final List<Book> books;
  final Function(int) onDelete;
  final Function(Book) onTap;

  BookList({
    required this.books,
    required this.onDelete,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 6, // Карточки в ряд
        childAspectRatio: 0.6,
        crossAxisSpacing: 8.0,
        mainAxisSpacing: 8.0,
      ),
      padding: EdgeInsets.all(8.0),
      itemCount: books.length,
      itemBuilder: (context, index) {
        final book = books[index];
        return Card(
          elevation: 4.0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
          child: InkWell(
            borderRadius: BorderRadius.circular(8.0),
            onTap: () => onTap(book),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(8.0),
                    ),
                    child: book.coverUrl.isNotEmpty
                        ? Image.network(
                            book.coverUrl,
                            fit: BoxFit.cover,
                          )
                        : Center(
                            child: Icon(Icons.book, size: 50, color: Colors.grey),
                          ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        book.title,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14.0, // Уменьшаем размер шрифта
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 4.0),
                      Text(
                        'Автор: ${book.author}',
                        style: TextStyle(fontSize: 12.0, color: Colors.grey[600]),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.delete, color: Colors.red, size: 20),
                  onPressed: () => onDelete(book.id!),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}