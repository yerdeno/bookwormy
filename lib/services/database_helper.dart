import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/book.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;

  factory DatabaseHelper() {
    return _instance;
  }

  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'books.db');

    return await openDatabase(
      path,
      version: 2,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE books(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT,
        author TEXT,
        description TEXT,
        year INTEGER,
        coverUrl TEXT
      )
    ''');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute('ALTER TABLE books ADD COLUMN description TEXT');
      await db.execute('ALTER TABLE books ADD COLUMN coverUrl TEXT');
    }
  }

  Future<int> insertBook(Book book) async {
    final db = await database;
    return await db.insert('books', book.toMap());
  }

  Future<List<Book>> getBooks() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('books');
    return List.generate(maps.length, (i) {
      return Book.fromMap(maps[i]);
    });
  }

  Future<void> deleteBook(int id) async {
    final db = await database;
    await db.delete('books', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> exportBooks(String filePath) async {
    final books = await getBooks();
    final jsonData = json.encode(books.map((book) => book.toMap()).toList());
    final file = File(filePath);
    await file.writeAsString(jsonData);
  }

  Future<void> importBooks(String filePath) async {
    final file = File(filePath);
    final jsonData = await file.readAsString();
    final List<dynamic> data = json.decode(jsonData);
    for (var item in data) {
      final book = Book.fromMap(item);
      await insertBook(book);
    }
  }
}

