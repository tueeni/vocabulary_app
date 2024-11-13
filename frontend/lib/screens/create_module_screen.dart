import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:provider/provider.dart';
import 'auth_provider.dart'; 

class CreateModuleScreen extends StatefulWidget {
  @override
  _CreateModuleScreenState createState() => _CreateModuleScreenState();
}

class _CreateModuleScreenState extends State<CreateModuleScreen> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  List<Map<String, String>> _terms = [];

  void _addTerm() {
    setState(() {
      _terms.add({'term_name': '', 'definition': ''});
    });
  }

  Future<void> _createModule() async {
    // Получение токена из AuthProvider
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final token = authProvider.token; 

    final response = await http.post(
      Uri.parse('http://localhost:5000/modules/create'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token', 
      },
      body: jsonEncode({
        'title': _titleController.text,
        'description': _descriptionController.text,
        'terms': _terms,
      }),
    );

    if (response.statusCode == 201) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Модуль успешно создан')));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Ошибка создания модуля')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Создать модуль')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _titleController,
              decoration: InputDecoration(labelText: 'Название модуля'),
            ),
            TextField(
              controller: _descriptionController,
              decoration: InputDecoration(labelText: 'Описание'),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: _terms.length,
                itemBuilder: (context, index) {
                  return Column(
                    children: [
                      TextField(
                        onChanged: (value) => _terms[index]['term_name'] = value,
                        decoration: InputDecoration(labelText: 'Термин'),
                      ),
                      TextField(
                        onChanged: (value) => _terms[index]['definition'] = value,
                        decoration: InputDecoration(labelText: 'Определение'),
                      ),
                    ],
                  );
                },
              ),
            ),
            ElevatedButton(
              onPressed: _addTerm,
              child: Text('Добавить термин'),
            ),
            ElevatedButton(
              onPressed: _createModule,
              child: Text('Создать модуль'),
            ),
          ],
        ),
      ),
    );
  }
}
