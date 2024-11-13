import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'auth_provider.dart';
import 'dart:convert';

class EditTermsScreen extends StatefulWidget {
  final int moduleId;
  final List<Map<String, dynamic>> initialTerms;

  EditTermsScreen({
    required this.moduleId,
    required this.initialTerms,
  });

  @override
  _EditTermsScreenState createState() => _EditTermsScreenState();
}

class _EditTermsScreenState extends State<EditTermsScreen> {
  List<Map<String, dynamic>> _terms = [];
  List<TextEditingController> _termNameControllers = [];
  List<TextEditingController> _termDefinitionControllers = [];

  @override
  void initState() {
    super.initState();
    _terms = List.from(widget.initialTerms);

    for (var term in _terms) {
      _termNameControllers.add(TextEditingController(text: term['term_name']));
      _termDefinitionControllers.add(TextEditingController(text: term['definition']));
    }
  }

  Future<void> _updateTerms() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final token = authProvider.token;

    final termsToSend = _terms.map((term) {
      return {
        'term_id': term['term_id'],
        'term_name': term['term_name'],
        'definition': term['definition'],
      };
    }).toList();

    final response = await http.put(
      Uri.parse('http://localhost:5000/modules/${widget.moduleId}/update_terms'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({'terms': termsToSend}),
    );

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Термины обновлены')));
      Navigator.pop(context, true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Ошибка обновления терминов')));
    }
  }

  void _addTerm() {
    setState(() {
      _terms.add({'term_id': null, 'term_name': '', 'definition': ''});
      _termNameControllers.add(TextEditingController());
      _termDefinitionControllers.add(TextEditingController());
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Редактировать термины')),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: _terms.length,
              itemBuilder: (context, index) {
                return Column(
                  children: [
                    TextField(
                      controller: _termNameControllers[index],
                      onChanged: (value) => _terms[index]['term_name'] = value,
                      decoration: InputDecoration(labelText: 'Термин'),
                    ),
                    TextField(
                      controller: _termDefinitionControllers[index],
                      onChanged: (value) => _terms[index]['definition'] = value,
                      decoration: InputDecoration(labelText: 'Определение'),
                    ),
                    IconButton(
                      icon: Icon(Icons.delete),
                      onPressed: () {
                        setState(() {
                          _terms.removeAt(index);
                          _termNameControllers.removeAt(index);
                          _termDefinitionControllers.removeAt(index);
                        });
                      },
                    ),
                  ],
                );
              },
            ),
          ),
          ElevatedButton(onPressed: _addTerm, child: Text('Добавить термин')),
          ElevatedButton(onPressed: _updateTerms, child: Text('Сохранить изменения')),
        ],
      ),
    );
  }

  @override
  void dispose() {
    for (var controller in _termNameControllers) controller.dispose();
    for (var controller in _termDefinitionControllers) controller.dispose();
    super.dispose();
  }
}
