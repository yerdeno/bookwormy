import 'package:flutter/material.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'screens/home_screen.dart';

void main() {
  // Инициализация sqflite для настольных приложений
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;

  runApp(BookTrackerApp());
}

class BookTrackerApp extends StatelessWidget {
  const BookTrackerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Трекер книг',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: HomeScreen(),
    );
  }
}