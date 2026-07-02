import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/material.dart';

class AiTutorService {
  // Secure: API key loaded from Firebase Remote Config
  String get _geminiApiKey {
    try {
      return FirebaseRemoteConfig.instance.getString('gemini_api_key');
    } catch (e) {
      debugPrint('Remote Config error: $e');
      return '';
    }
  }

  // Using latest Gemini 1.5 Flash model
  final String _geminiBaseUrl = 
      'https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent';

  Future<String> explainGrammarQuestion({
    required String question,
    required String correctAnswer,
    required String userAnswer,
    required String category,
  }) async {
    final prompt = 
        "You are an expert Arabic grammar teacher. The student question is:
"
        '"' + question + '"

'
        "Correct answer: " + correctAnswer + "
"
        "Student answer: " + userAnswer + "

"
        "Explain in Arabic in a simple and friendly way:
"
        "1. Why is the correct answer right?
"
        "2. What is wrong with the student answer (if wrong)?
"
        "3. What grammar rule is learned from this question?
"
        "4. Give a similar example to reinforce learning.

"
        "Make it easy and understandable for beginners and school students.";

    return await _generateContent(prompt, isJson: false);
  }

  Future<Map<String, dynamic>> generateQuestion(String topic, String difficulty) async {
    final prompt = 
        "Create one Arabic grammar question about: " + topic + "
"
        "For level: " + difficulty + "

"
        "Return ONLY valid JSON matching this structure:
"
        '{
'
        '  "question": "question text here",
'
        '  "options": ["option1", "option2", "option3", "option4"],
'
        '  "correctAnswer": 0,
'
        '  "explanation": "detailed explanation",
'
        '  "rule": "grammar rule summary"
'
        '}
'
        "Note: correctAnswer is the index (0-3) of the correct option.";

    final response = await _generateContent(prompt, isJson: true);
    try {
      return jsonDecode(response);
    } catch (e) {
      return {
        'question': 'Sorry, failed to generate question.',
        'options': ['A', 'B', 'C', 'D'],
        'correctAnswer': 0,
        'explanation': 'Error processing data.',
        'rule': '',
      };
    }
  }

  Future<String> answerStudentQuestion(String question) async {
    final prompt = 
        'You are "The Smart Grammar Teacher" - an expert Arabic language teacher.
'
        "The student asks: "" + question + ""

"
        "Answer with:
"
        "1. Simple, engaging style appropriate for the age group.
"
        "2. Clear illustrative examples with proper grammar marks.
"
        "3. Summarize the grammar rule at the end.
"
        "4. Start and end with motivational words encouraging love for Arabic.";

    return await _generateContent(prompt, isJson: false);
  }

  Future<Map<String, dynamic>> generateDailyChallenge() async {
    final prompt = 
        "Create an exciting daily challenge in Arabic grammar rules.
"
        "The challenge should include one smart, short question.

"
        "Return ONLY valid JSON:
"
        '{
'
        '  "title": "Daily Challenge Title",
'
        '  "description": "Exciting challenge description",
'
        '  "questions": [{
'
        '    "question": "Grammar question text",
'
        '    "options": ["A", "B", "C", "D"],
'
        '    "correct": 0
'
        '  }],
'
        '  "reward": "Badges or points",
'
        '  "timeLimit": 5
'
        '}';

    final response = await _generateContent(prompt, isJson: true);
    try {
      return jsonDecode(response);
    } catch (e) {
      return {
        'title': 'Daily Grammar Challenge',
        'description': 'Ready to test your skills today?',
        'questions': [],
        'reward': '50 excellence points',
        'timeLimit': 5,
      };
    }
  }

  Future<String> _generateContent(String prompt, {required bool isJson}) async {
    if (_geminiApiKey.isEmpty) {
      return 'Warning: API key not configured. Please contact admin.';
    }

    try {
      final response = await http.post(
        Uri.parse(_geminiBaseUrl + '?key=' + _geminiApiKey),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'contents': [
            {
              'parts': [
                {'text': prompt},
              ],
            },
          ],
          'generationConfig': {
            'temperature': 0.7,
            'maxOutputTokens': 1000,
            if (isJson) 'responseMimeType': 'application/json',
          },
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['candidates'][0]['content']['parts'][0]['text'];
      } else {
        throw Exception('API Error: ' + response.statusCode.toString());
      }
    } catch (e) {
      debugPrint('AI Service Error: $e');
      return isJson 
          ? '{}' 
          : 'Sorry, connection issue with AI teacher. Please try again later!';
    }
  }
}