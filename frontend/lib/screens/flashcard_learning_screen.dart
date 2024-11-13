import 'package:flutter/material.dart';

class FlashcardLearningScreen extends StatefulWidget {
  final List<Map<String, dynamic>> terms;

  FlashcardLearningScreen({required this.terms});

  @override
  _FlashcardLearningScreenState createState() => _FlashcardLearningScreenState();
}

class _FlashcardLearningScreenState extends State<FlashcardLearningScreen> {
  int _currentIndex = 0;
  bool _showDefinition = false;
  List<bool> _learnedTerms = [];

  @override
  void initState() {
    super.initState();
    if (widget.terms.isNotEmpty) {
      _learnedTerms = List.generate(widget.terms.length, (_) => false);
    }
  }

  void _nextCard() {
    setState(() {
      if (_currentIndex < widget.terms.length - 1) _currentIndex++;
      _showDefinition = false;
    });
  }

  void _previousCard() {
    setState(() {
      if (_currentIndex > 0) _currentIndex--;
      _showDefinition = false;
    });
  }

  void _flipCard() {
    setState(() {
      _showDefinition = !_showDefinition;
    });
  }

  void _markAsLearned() {
    setState(() {
      _learnedTerms[_currentIndex] = !_learnedTerms[_currentIndex];
    });
  }

  @override
  Widget build(BuildContext context) {
    if (widget.terms.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: Text('Learn Terms')),
        body: Center(
          child: Text(
            'No terms available for this module.',
            style: TextStyle(fontSize: 18, color: Colors.grey),
          ),
        ),
      );
    }

    final term = widget.terms[_currentIndex]['term']?.toString() ?? '';
    final definition = widget.terms[_currentIndex]['definition']?.toString() ?? '';

    return Scaffold(
      appBar: AppBar(title: Text('Learn Terms')),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          LinearProgressIndicator(
            value: (_currentIndex + 1) / widget.terms.length,
          ),
          SizedBox(height: 20),
          GestureDetector(
            onTap: _flipCard,
            child: AnimatedSwitcher(
              duration: Duration(milliseconds: 300),
              transitionBuilder: (Widget child, Animation<double> animation) {
                return ScaleTransition(scale: animation, child: child);
              },
              child: _showDefinition
                  ? _buildCardContent(definition, 'Определение')
                  : _buildCardContent(term, 'Термин'),
            ),
          ),
          SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                icon: Icon(Icons.arrow_back),
                onPressed: _previousCard,
              ),
              IconButton(
                icon: Icon(
                  _learnedTerms[_currentIndex]
                      ? Icons.check_circle
                      : Icons.check_circle_outline,
                ),
                onPressed: _markAsLearned,
              ),
              IconButton(
                icon: Icon(Icons.arrow_forward),
                onPressed: _nextCard,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCardContent(String text, String label) {
    return Container(
      key: ValueKey(text),
      width: 300,
      height: 200,
      decoration: BoxDecoration(
        color: Colors.blueAccent,
        borderRadius: BorderRadius.circular(12),
      ),
      alignment: Alignment.center,
      child: Text(
        text,
        style: TextStyle(
          color: Colors.white,
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}
