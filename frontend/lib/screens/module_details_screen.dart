import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:provider/provider.dart';
import 'auth_provider.dart';
import 'edit_module_info_screen.dart';
import 'edit_terms_screen.dart';

class ModuleDetailsScreen extends StatefulWidget {
  final int moduleId;

  ModuleDetailsScreen({required this.moduleId});

  @override
  _ModuleDetailsScreenState createState() => _ModuleDetailsScreenState();
}

class _ModuleDetailsScreenState extends State<ModuleDetailsScreen> {
  Map<String, dynamic>? moduleData;
  bool isLoading = true;

  Future<void> _fetchModuleDetails() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final token = authProvider.token;

    final response = await http.get(
      Uri.parse('http://localhost:5000/modules/module/${widget.moduleId}'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      setState(() {
        moduleData = jsonDecode(response.body);
        isLoading = false;
      });
    } else {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Ошибка при загрузке данных')));
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchModuleDetails();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Детали модуля')),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : moduleData == null
              ? Center(child: Text('Модуль не найден'))
              : Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Название: ${moduleData!['title']}', style: TextStyle(fontSize: 24)),
                      SizedBox(height: 8),
                      Text('Описание: ${moduleData!['description']}'),
                      SizedBox(height: 16),
                      Text('Термины:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      ...moduleData!['terms'].map<Widget>((term) => Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4.0),
                            child: Text('${term['term_name']}: ${term['definition']}'),
                          )),
                      SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () async {
                          // Открываем экран редактирования модуля
                          final updated = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => EditModuleInfoScreen(
                                moduleId: widget.moduleId,
                                initialTitle: moduleData!['title'],
                                initialDescription: moduleData!['description'],
                              ),
                            ),
                          );
                          // Если данные были обновлены, перезагружаем данные
                          if (updated == true) {
                            _fetchModuleDetails();
                          }
                        },
                        child: Text('Редактировать модуль'),
                      ),
                      ElevatedButton(
                        onPressed: () async {
                          // Открываем экран редактирования терминов
                          final updated = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => EditTermsScreen(
                                moduleId: widget.moduleId,
                                initialTerms: List<Map<String, dynamic>>.from(moduleData!['terms']),
                              ),
                            ),
                          );
                          if (updated == true) {
                            _fetchModuleDetails();
                          }
                        },
                        child: Text('Редактировать термины'),
                      ),
                    ],
                  ),
                ),
    );
  }
}
