import 'package:flutter/material.dart';
import 'flashcard_learning_screen.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:provider/provider.dart'; 
import 'auth_provider.dart'; 

class SearchModulesScreen extends StatefulWidget {
  @override
  _SearchModulesScreenState createState() => _SearchModulesScreenState();
}

class _SearchModulesScreenState extends State<SearchModulesScreen> {
  List<Map<String, dynamic>> modules = [];
  String searchQuery = '';

  void searchModules() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    String? jwtToken = authProvider.token;

    if (jwtToken == null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Пожалуйста, войдите в систему')));
      return;
    }

    final headers = {'Authorization': 'Bearer $jwtToken'};

    final response = await http.get(
      Uri.parse('http://localhost:5000/modules/search?query=${Uri.encodeComponent(searchQuery)}'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      setState(() {
        modules = List<Map<String, dynamic>>.from(json.decode(response.body));
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Ошибка при поиске модулей')));
    }
  }

  void fetchTermsAndNavigate(int moduleId) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    String? jwtToken = authProvider.token;

    if (jwtToken == null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Токен не найден. Пожалуйста, войдите снова.')));
      return;
    }

    final headers = {'Authorization': 'Bearer $jwtToken'};

    final response = await http.get(
      Uri.parse('http://localhost:5000/modules/$moduleId/terms'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      List<Map<String, dynamic>> terms = List<Map<String, dynamic>>.from(json.decode(response.body));
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => FlashcardLearningScreen(terms: terms)),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Ошибка при загрузке терминов')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Поиск модулей')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              decoration: InputDecoration(
                labelText: 'Введите название или описание модуля',
                suffixIcon: IconButton(
                  icon: Icon(Icons.search),
                  onPressed: searchModules,
                ),
              ),
              onChanged: (value) {
                setState(() {
                  searchQuery = value;
                });
              },
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: modules.length,
              itemBuilder: (context, index) {
                final module = modules[index];
                return ListTile(
                  title: Text(module['title']),
                  subtitle: Text(module['description']),
                  onTap: () => fetchTermsAndNavigate(module['id']), // Переход к изучению терминов
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
