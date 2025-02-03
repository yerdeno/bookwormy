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
  int _selectedIndex = 0; // Индекс текущей вкладки

  // Вкладки
  final List<Widget> _tabs = [
    LibraryTab(), // Вкладка "Библиотека"
    ProfileTab(), // Вкладка "Профиль"
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _tabs[_selectedIndex], // Отображаем текущую вкладку
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.library_books),
            label: 'Библиотека',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Профиль',
          ),
        ],
      ),
    );
  }
}

// Вкладка "Библиотека"
class LibraryTab extends StatefulWidget {
  @override
  _LibraryTabState createState() => _LibraryTabState();
}

class _LibraryTabState extends State<LibraryTab> {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Библиотека'),
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

// Вкладка "Профиль"
class ProfileTab extends StatelessWidget {
  Future<void> _exportBooks(BuildContext context) async {
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

  Future<void> _importBooks(BuildContext context) async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
      );

      if (result != null) {
        final filePath = result.files.single.path!;
        await DatabaseHelper().importBooks(filePath);
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
        title: Text('Профиль'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () => _exportBooks(context), // Передаём контекст
              child: Text('Экспорт книг'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => _importBooks(context), // Передаём контекст
              child: Text('Импорт книг'),
            ),
          ],
        ),
      ),
    );
  }
}

// Делегат для поиска
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