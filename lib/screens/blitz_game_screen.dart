import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../models/quiz_models.dart';
import '../services/game_state_service.dart';
import '../theme/app_theme.dart';

class BlitzGameScreen extends StatefulWidget {
  final QuizCategory category;

  const BlitzGameScreen({super.key, required this.category});

  @override
  State<BlitzGameScreen> createState() => _BlitzGameScreenState();
}

class _BlitzGameScreenState extends State<BlitzGameScreen> {
  int _currentIndex = 0;
  int _score = 0;
  int _streak = 0;
  int _maxStreak = 0;
  bool _answered = false;
  bool _lastAnswerCorrect = false;

  @override
  Widget build(BuildContext context) {
    final questions = widget.category.questions;

    if (questions.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Турбо-Блиц')),
        body: const Center(child: Text('Вопросы отсутствуют')),
      );
    }

    final question = questions[_currentIndex];

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: Text(
          'Турбо-Блиц',
          style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Stats Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppTheme.accentOrange.withAlpha(25),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'Вопрос ${_currentIndex + 1} / ${questions.length}',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.accentOrange,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.local_fire_department_rounded,
                          color: AppTheme.accentGold, size: 16),
                      const SizedBox(width: 3),
                      Text(
                        'x$_streak',
                        style: GoogleFonts.outfit(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.accentGold,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '$_score б.',
                        style: GoogleFonts.outfit(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Question Statement Box
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  color: AppTheme.surfaceCard,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppTheme.surfaceBorder),
                  boxShadow: AppTheme.neonGlow,
                ),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppTheme.accentOrange.withAlpha(30),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'ПРАВДА ИЛИ ЛОЖЬ?',
                        style: GoogleFonts.outfit(
                          fontSize: 11,
                          fontWeight: FontWeight.w900,
                          color: AppTheme.accentOrange,
                          letterSpacing: 1,
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),
                    Text(
                      question.question,
                      style: GoogleFonts.outfit(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textPrimary,
                        height: 1.35,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Explanation Box if Answered
              if (_answered) ...[
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: _lastAnswerCorrect
                        ? AppTheme.accentGreen.withAlpha(20)
                        : AppTheme.secondary.withAlpha(20),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: _lastAnswerCorrect
                          ? AppTheme.accentGreen.withAlpha(80)
                          : AppTheme.secondary.withAlpha(80),
                    ),
                  ),
                  child: Column(
                    children: [
                      Text(
                        _lastAnswerCorrect
                            ? 'Верно! Отличная реакция'
                            : 'Неверно!',
                        style: GoogleFonts.outfit(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: _lastAnswerCorrect
                              ? AppTheme.accentGreen
                              : AppTheme.secondary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        question.explanation,
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: AppTheme.textSecondary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => _goToNextQuestion(questions),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primary,
                      foregroundColor: AppTheme.background,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    child: Text(
                      _currentIndex == questions.length - 1
                          ? 'Завершить блиц'
                          : 'Следующее утверждение',
                      style: GoogleFonts.outfit(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ] else ...[
                // True & False Action Buttons
                Row(
                  children: [
                    Expanded(
                      child: _buildChoiceButton(
                        label: 'ПРАВДА',
                        icon: Icons.check_circle_outline_rounded,
                        color: AppTheme.accentGreen,
                        onTap: () => _handleAnswer(question, 0),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: _buildChoiceButton(
                        label: 'ЛОЖЬ',
                        icon: Icons.cancel_outlined,
                        color: AppTheme.secondary,
                        onTap: () => _handleAnswer(question, 1),
                      ),
                    ),
                  ],
                ),
              ],
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildChoiceButton({
    required String label,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 20),
          decoration: BoxDecoration(
            color: color.withAlpha(25),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: color.withAlpha(90), width: 1.5),
          ),
          child: Column(
            children: [
              Icon(icon, color: color, size: 36),
              const SizedBox(height: 8),
              Text(
                label,
                style: GoogleFonts.outfit(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _handleAnswer(QuizQuestion question, int selectedIndex) {
    setState(() {
      _answered = true;
      _lastAnswerCorrect = (selectedIndex == question.correctIndex);
      if (_lastAnswerCorrect) {
        _streak++;
        if (_streak > _maxStreak) {
          _maxStreak = _streak;
        }
        _score += question.points * (_streak > 2 ? 2 : 1);
      } else {
        _streak = 0;
      }
    });
  }

  void _goToNextQuestion(List<QuizQuestion> questions) {
    if (_currentIndex < questions.length - 1) {
      setState(() {
        _currentIndex++;
        _answered = false;
      });
    } else {
      final state = context.read<GameStateService>();
      state.recordBlitzCompleted(pointsWon: _score, streak: _maxStreak);
      _showFinishDialog();
    }
  }

  void _showFinishDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: AppTheme.surfaceCard,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text(
            'Блиц Завершен!',
            style: GoogleFonts.outfit(
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimary,
            ),
            textAlign: TextAlign.center,
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.bolt_rounded,
                color: AppTheme.accentOrange,
                size: 50,
              ),
              const SizedBox(height: 12),
              Text(
                'Максимальный стрик: $_maxStreak подряд',
                style: GoogleFonts.inter(
                  fontSize: 13,
                  color: AppTheme.textSecondary,
                ),
              ),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: AppTheme.primary.withAlpha(25),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '+$_score очков лояльности',
                  style: GoogleFonts.outfit(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primary,
                  ),
                ),
              ),
            ],
          ),
          actions: [
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(ctx).pop();
                  Navigator.of(context).pop();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primary,
                  foregroundColor: AppTheme.background,
                ),
                child: const Text('Завершить'),
              ),
            ),
          ],
        );
      },
    );
  }
}
