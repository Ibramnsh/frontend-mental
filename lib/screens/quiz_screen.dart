import 'package:flutter/material.dart';
import '../services/quiz_service.dart';

class QuizScreen extends StatefulWidget {
  const QuizScreen({super.key});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  // Palet Warna
  final Color _primaryColor = const Color(0xFF5B9A8B);
  final Color _backgroundColor = const Color(0xFFF7F9F9);
  final Color _surfaceColor = Colors.white;
  final Color _textColor = const Color(0xFF2D3B38);

  // Daftar Pertanyaan
  final List<Map<String, dynamic>> _questions = [
    {
      'question':
          'How often do you have little interest or pleasure in doing things?',
      'options': [
        {'text': 'Not at all', 'score': 0},
        {'text': 'Several days', 'score': 1},
        {'text': 'More than half the days', 'score': 2},
        {'text': 'Nearly every day', 'score': 3},
      ]
    },
    {
      'question': 'How often do you feel down, depressed, or hopeless?',
      'options': [
        {'text': 'Not at all', 'score': 0},
        {'text': 'Several days', 'score': 1},
        {'text': 'More than half the days', 'score': 2},
        {'text': 'Nearly every day', 'score': 3},
      ]
    },
    {
      'question': 'Trouble falling or staying asleep, or sleeping too much?',
      'options': [
        {'text': 'Not at all', 'score': 0},
        {'text': 'Several days', 'score': 1},
        {'text': 'More than half the days', 'score': 2},
        {'text': 'Nearly every day', 'score': 3},
      ]
    },
    {
      'question': 'Feeling tired or having little energy?',
      'options': [
        {'text': 'Not at all', 'score': 0},
        {'text': 'Several days', 'score': 1},
        {'text': 'More than half the days', 'score': 2},
        {'text': 'Nearly every day', 'score': 3},
      ]
    },
    {
      'question': 'Feeling bad about yourself - or that you are a failure?',
      'options': [
        {'text': 'Not at all', 'score': 0},
        {'text': 'Several days', 'score': 1},
        {'text': 'More than half the days', 'score': 2},
        {'text': 'Nearly every day', 'score': 3},
      ]
    },
  ];

  int _currentQuestionIndex = 0;
  int _totalScore = 0;
  bool _isFinished = false;
  String _resultCategory = "";
  String _resultAdvice = "";

  void _answerQuestion(int score) {
    setState(() {
      _totalScore += score;
      if (_currentQuestionIndex < _questions.length - 1) {
        _currentQuestionIndex++;
      } else {
        _finishQuiz();
      }
    });
  }

  void _finishQuiz() {
    if (_totalScore <= 4) {
      _resultCategory = "Stable & Healthy";
      _resultAdvice =
          "Your emotional state seems stable. Keep up your good habits!";
    } else if (_totalScore <= 9) {
      _resultCategory = "Mild Stress";
      _resultAdvice =
          "You might be feeling a bit of pressure. Try the breathing exercises in Tools.";
    } else if (_totalScore <= 14) {
      _resultCategory = "Moderate Stress";
      _resultAdvice =
          "You seem to have a lot on your mind. Consider talking to our AI Companion.";
    } else {
      _resultCategory = "Severe Stress";
      _resultAdvice =
          "Your condition needs attention. Please consider seeking professional help.";
    }

    _isFinished = true;
    QuizService.submitQuizResult(_totalScore, _resultCategory);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _backgroundColor,
      appBar: AppBar(
        title: Text("Mood Check-up",
            style: TextStyle(color: _textColor, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.close_rounded, color: _textColor),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: _isFinished ? _buildResultView() : _buildQuestionView(),
        ),
      ),
    );
  }

  Widget _buildQuestionView() {
    final question = _questions[_currentQuestionIndex];
    double progress = (_currentQuestionIndex + 1) / _questions.length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Progress Bar
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: 10,
            backgroundColor: Colors.grey.shade200,
            color: _primaryColor,
          ),
        ),
        const SizedBox(height: 32),

        Text(
          "Question ${_currentQuestionIndex + 1}/${_questions.length}",
          style: TextStyle(
              color: _primaryColor, fontWeight: FontWeight.bold, fontSize: 14),
        ),
        const SizedBox(height: 12),
        Text(
          question['question'],
          style: TextStyle(
              color: _textColor,
              fontSize: 24,
              fontWeight: FontWeight.bold,
              height: 1.3),
        ),

        const Spacer(),

        ...(question['options'] as List<Map<String, Object>>).map((option) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: ElevatedButton(
              onPressed: () => _answerQuestion(option['score'] as int),
              style: ElevatedButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
                  backgroundColor: _surfaceColor,
                  foregroundColor: _primaryColor,
                  elevation: 0,
                  alignment: Alignment.centerLeft,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  side: BorderSide(
                      color: Colors.transparent) // Atau border halus jika mau
                  ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    option['text'] as String,
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: _textColor),
                  ),
                  Icon(Icons.arrow_forward_ios_rounded,
                      size: 16, color: Colors.grey.shade300)
                ],
              ),
            ),
          );
        }).toList(),
        const Spacer(),
      ],
    );
  }

  Widget _buildResultView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: _primaryColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.check_circle_rounded,
                size: 80, color: _primaryColor),
          ),
          const SizedBox(height: 32),
          Text(
            "Your Result:",
            style: TextStyle(color: Colors.grey.shade500, fontSize: 16),
          ),
          const SizedBox(height: 8),
          Text(
            _resultCategory,
            style: TextStyle(
                fontSize: 28, color: _textColor, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 32),
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
                color: _surfaceColor,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 20,
                      offset: const Offset(0, 5))
                ]),
            child: Column(
              children: [
                Icon(Icons.lightbulb_outline_rounded,
                    color: Colors.amber.shade600, size: 32),
                const SizedBox(height: 16),
                Text(
                  _resultAdvice,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontSize: 16, color: Colors.grey.shade700, height: 1.5),
                ),
              ],
            ),
          ),
          const SizedBox(height: 48),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: _primaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 18),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
              ),
              child: const Text("Back to Home",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ),
          )
        ],
      ),
    );
  }
}
