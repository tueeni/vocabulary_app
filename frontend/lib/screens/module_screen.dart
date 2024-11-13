import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'auth_provider.dart';
import 'dart:convert';
import 'flashcard_learning_screen.dart';
import 'module_details_screen.dart'; 

class ModulesScreen extends StatefulWidget {
  @override
  _ModulesScreenState createState() => _ModulesScreenState();
}

class _ModulesScreenState extends State<ModulesScreen> {
  List _modules = [];

  Future<void> _fetchModules() async {
    final token = Provider.of<AuthProvider>(context, listen: false).token;
    final response = await http.get(
      Uri.parse('http://localhost:5000/modules/my-modules'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      setState(() {
        _modules = jsonDecode(response.body);
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ошибка загрузки модулей')),
      );
    }
  }

  Future<void> _fetchTermsAndNavigate(int moduleId) async {
    final token = Provider.of<AuthProvider>(context, listen: false).token;
    final response = await http.get(
      Uri.parse('http://localhost:5000/modules/$moduleId/terms'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      List<Map<String, dynamic>> terms = List<Map<String, dynamic>>.from(jsonDecode(response.body));
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => FlashcardLearningScreen(terms: terms),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ошибка загрузки терминов')),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchModules();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Мои модули')),
      body: ListView.builder(
        itemCount: _modules.length,
        itemBuilder: (context, index) {
          final module = _modules[index];
          return ListTile(
            title: Text(module['title']),
            subtitle: Text(module['description']),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: Icon(Icons.arrow_forward),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ModuleDetailsScreen(moduleId: module['id']),
                      ),
                    );
                  },
                ),
                IconButton(
                  icon: Icon(Icons.school),
                  onPressed: () {
                    _fetchTermsAndNavigate(module['id']);
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
