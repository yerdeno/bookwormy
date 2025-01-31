import 'package:flutter/material.dart';
import '../models/book.dart';
import '../services/database_helper.dart';
import '../widgets/book_list.dart';
import 'add_book_screen.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Future<List<Book>> _booksFuture;

  @override
  void initState() {
    super.initState();
    _refreshBooks();
  }

  void _refreshBooks() {
    setState(() {
      _booksFuture = DatabaseHelper().getBooks();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Трекер книг'),
      ),
      body: FutureBuilder<List<Book>>(
        future: _booksFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Ошибка: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('Нет книг'));
          } else {
            return BookList(
              books: snapshot.data!,
              onDelete: (id) async {
                await DatabaseHelper().deleteBook(id);
                _refreshBooks();
              },
            );
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AddBookScreen()),
          );
          _refreshBooks();
        },
        child: Icon(Icons.add),
      ),
    );
  }
}