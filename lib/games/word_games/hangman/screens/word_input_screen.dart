import 'package:flutter/material.dart';
import '../models/game_state.dart';
import '../services/word_service.dart';
import 'game_screen.dart';

class WordInputScreen extends StatefulWidget {
  const WordInputScreen({super.key});

  @override
  State<WordInputScreen> createState() => _WordInputScreenState();
}

class _WordInputScreenState extends State<WordInputScreen> {
  final _formKey = GlobalKey<FormState>();
  final _wordController = TextEditingController();
  String? _errorMessage;

  @override
  void dispose() {
    _wordController.dispose();
    super.dispose();
  }

  void _onSubmit() {
    if (_formKey.currentState!.validate()) {
      final word = _wordController.text.toUpperCase();

      if (!WordService.isValidWord(word)) {
        setState(() {
          _errorMessage = 'Word can only contain letters and spaces';
        });
        return;
      }

      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => HangmanGameScreen(
            initialState: HangmanGameState(
              word: word,
              mode: HangmanGameMode.twoPlayers,
              category: WordCategory.custom,
              startTime: DateTime.now(),
            ),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Enter Word'),
        centerTitle: true,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Theme.of(context).primaryColor.withValues(
                    red: Theme.of(context).primaryColor.r.toDouble(),
                    green: Theme.of(context).primaryColor.g.toDouble(),
                    blue: Theme.of(context).primaryColor.b.toDouble(),
                    alpha: 0.8 * 255,
                  ),
              Theme.of(context).primaryColor.withValues(
                    red: Theme.of(context).primaryColor.r.toDouble(),
                    green: Theme.of(context).primaryColor.g.toDouble(),
                    blue: Theme.of(context).primaryColor.b.toDouble(),
                    alpha: 0.2 * 255,
                  ),
            ],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          'Enter a word for your friend to guess',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 20),
                        TextFormField(
                          controller: _wordController,
                          textCapitalization: TextCapitalization.characters,
                          decoration: InputDecoration(
                            labelText: 'Word',
                            hintText: 'Enter a word',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            errorText: _errorMessage,
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter a word';
                            }
                            if (value.length < 3) {
                              return 'Word must be at least 3 letters long';
                            }
                            return null;
                          },
                          onChanged: (_) {
                            if (_errorMessage != null) {
                              setState(() {
                                _errorMessage = null;
                              });
                            }
                          },
                        ),
                        const SizedBox(height: 20),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _onSubmit,
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child: const Text(
                              'Start Game',
                              style: TextStyle(fontSize: 18),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Make sure your friend isn\'t looking!',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
