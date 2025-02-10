import 'package:flutter/material.dart';
import '../models/book.dart';
import '../services/database_helper.dart';
import 'book_selection_screen.dart';

class AddBookScreen extends StatefulWidget {
  const AddBookScreen({super.key});

  @override
  _AddBookScreenState createState() => _AddBookScreenState();
}

class _AddBookScreenState extends State<AddBookScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _authorController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _yearController = TextEditingController();
  final _coverUrlController = TextEditingController();

  Future<void> _fetchBookData() async {
    final title = _titleController.text;
    if (title.isEmpty) return;

    final selectedBook = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BookSelectionScreen(searchQuery: title),
      ),
    );

    if (selectedBook != null) {
      setState(() {
        _titleController.text = selectedBook.title;
        _authorController.text = selectedBook.author;
        _descriptionController.text = selectedBook.description;
        _yearController.text = selectedBook.year.toString();
        _coverUrlController.text = selectedBook.coverUrl;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Добавить книгу'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _titleController,
                decoration: InputDecoration(labelText: 'Название'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Введите название';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _authorController,
                decoration: InputDecoration(labelText: 'Автор'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Введите автора';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _descriptionController,
                decoration: InputDecoration(labelText: 'Аннотация'),
                maxLines: 3,
              ),
              TextFormField(
                controller: _yearController,
                decoration: InputDecoration(labelText: 'Год'),
                keyboardType: TextInputType.number,
              ),
              TextFormField(
                controller: _coverUrlController,
                decoration: InputDecoration(labelText: 'Ссылка на обложку'),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _fetchBookData,
                child: Text('Найти книгу через Google Books API'),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    final book = Book(
                      title: _titleController.text,
                      author: _authorController.text,
                      description: _descriptionController.text,
                      year: int.tryParse(_yearController.text) ?? 0,
                      coverUrl: _coverUrlController.text,
                    );
                    await DatabaseHelper().insertBook(book);
                    Navigator.pop(context);
                  }
                },
                child: Text('Добавить книгу'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}