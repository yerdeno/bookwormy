import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import '../models/book.dart';
import '../services/database_helper.dart';
import '../widgets/book_list.dart';
import 'add_book_screen.dart';
import 'book_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Future<List<Book>> _booksFuture;
  String _searchQuery = '';

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

  List<Book> _filterBooks(List<Book> books) {
    return books.where((book) {
      final titleMatch = book.title.toLowerCase().contains(_searchQuery.toLowerCase());
      final authorMatch = book.author.toLowerCase().contains(_searchQuery.toLowerCase());
      return titleMatch || authorMatch;
    }).toList();
  }

  Future<void> _exportBooks() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final filePath = '${directory.path}/books.json';
      await DatabaseHelper().exportBooks(filePath);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Книги экспортированы в $filePath')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ошибка при экспорте: $e')),
      );
    }
  }

  Future<void> _importBooks() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
      );

      if (result != null) {
        final filePath = result.files.single.path!;
        await DatabaseHelper().importBooks(filePath);
        _refreshBooks();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Книги импортированы из $filePath')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ошибка при импорте: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Трекер книг'),
        actions: [
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () {
              showSearch(
                context: context,
                delegate: BookSearchDelegate(_refreshBooks),
              );
            },
          ),
          IconButton(
            icon: Icon(Icons.import_export),
            onPressed: () async {
              await showDialog(
                context: context,
                builder: (context) {
                  return AlertDialog(
                    title: Text('Экспорт/Импорт'),
                    content: Text('Выберите действие:'),
                    actions: [
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                          _exportBooks();
                        },
                        child: Text('Экспорт'),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                          _importBooks();
                        },
                        child: Text('Импорт'),
                      ),
                    ],
                  );
                },
              );
            },
          ),
        ],
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
            final books = _filterBooks(snapshot.data!);
            return BookList(
              books: books,
              onDelete: (id) async {
                await DatabaseHelper().deleteBook(id);
                _refreshBooks();
              },
              onTap: (book) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => BookDetailScreen(book: book),
                  ),
                );
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

class BookSearchDelegate extends SearchDelegate<String> {
  final Function refreshBooks;

  BookSearchDelegate(this.refreshBooks);

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.arrow_back),
      onPressed: () {
        close(context, '');
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return _buildSearchResults();
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return _buildSearchResults();
  }

  Widget _buildSearchResults() {
    return FutureBuilder<List<Book>>(
      future: DatabaseHelper().getBooks(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Ошибка: ${snapshot.error}'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(child: Text('Нет книг'));
        } else {
          final books = snapshot.data!.where((book) {
            final titleMatch = book.title.toLowerCase().contains(query.toLowerCase());
            final authorMatch = book.author.toLowerCase().contains(query.toLowerCase());
            return titleMatch || authorMatch;
          }).toList();
          return ListView.builder(
            itemCount: books.length,
            itemBuilder: (context, index) {
              final book = books[index];
              return ListTile(
                title: Text(book.title),
                subtitle: Text('Автор: ${book.author}'),
                onTap: () {
                  close(context, '');
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => BookDetailScreen(book: book),
                    ),
                  );
                },
              );
            },
          );
        }
      },
    );
  }
}