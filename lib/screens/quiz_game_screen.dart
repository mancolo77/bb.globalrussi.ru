import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../models/quiz_models.dart';
import '../services/game_state_service.dart';
import '../theme/app_theme.dart';

class QuizGameScreen extends StatefulWidget {
  final QuizCategory category;

  const QuizGameScreen({super.key, required this.category});

  @override
  State<QuizGameScreen> createState() => _QuizGameScreenState();
}

class _QuizGameScreenState extends State<QuizGameScreen> {
  int _currentIndex = 0;
  int? _selectedOptionIndex;
  bool _answered = false;
  int _correctCount = 0;
  int _totalEarnedPoints = 0;

  bool _isImmunityActive = false;
  final Set<int> _hiddenOptionIndices = {};

  @override
  Widget build(BuildContext context) {
    final gameState = context.watch<GameStateService>();
    final questions = widget.category.questions;

    if (questions.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: Text(widget.category.title)),
        body: const Center(child: Text('Вопросы в данной категории пока отсутствуют')),
      );
    }

    final currentQuestion = questions[_currentIndex];
    final progress = (_currentIndex + 1) / questions.length;

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: Text(
          widget.category.title,
          style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        actions: [
          InkWell(
            onTap: () {
              ScaffoldMessenger.of(context).hideCurrentSnackBar();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Текущие очки в игре'),
                  behavior: SnackBarBehavior.floating,
                  duration: Duration(seconds: 1),
                ),
              );
            },
            borderRadius: BorderRadius.circular(10),
            child: Container(
              margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: AppTheme.accentGold.withAlpha(25),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.star_rounded,
                    size: 16, color: AppTheme.accentGold),
                const SizedBox(width: 4),
                Text(
                  '${gameState.coins}',
                  style: GoogleFonts.outfit(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.accentGold,
                  ),
                ),
              ],
            ),
          ),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Progress Bar & Counter
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Вопрос ${_currentIndex + 1} из ${questions.length}',
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                  Text(
                    '+${currentQuestion.points} б.',
                    style: GoogleFonts.outfit(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: progress,
                  minHeight: 6,
                  backgroundColor: AppTheme.surfaceCard,
                  valueColor: AlwaysStoppedAnimation<Color>(widget.category.color),
                ),
              ),
              const SizedBox(height: 16),

              // Boosters Row
              _buildBoostersBar(gameState, currentQuestion),
              const SizedBox(height: 16),

              // Question Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppTheme.surfaceCard,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppTheme.surfaceBorder),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: widget.category.color.withAlpha(30),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        'МАТЧ-ВОПРОС',
                        style: GoogleFonts.outfit(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: widget.category.color,
                          letterSpacing: 1,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      currentQuestion.question,
                      style: GoogleFonts.outfit(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textPrimary,
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Options
              ...List.generate(currentQuestion.options.length, (index) {
                if (_hiddenOptionIndices.contains(index)) {
                  return const SizedBox.shrink();
                }
                return _buildOptionButton(currentQuestion, index);
              }),
              const SizedBox(height: 12),

              // Explanation Card if answered
              if (_answered) ...[
                _buildExplanationCard(currentQuestion),
                const SizedBox(height: 16),
                _buildNextButton(questions.length, gameState),
              ],
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBoostersBar(GameStateService gameState, QuizQuestion question) {
    return Row(
      children: [
        // 50/50 Booster
        Expanded(
          child: OutlinedButton.icon(
            onPressed: (!_answered &&
                    gameState.boosterFiftyCount > 0 &&
                    _hiddenOptionIndices.isEmpty)
                ? () {
                    if (gameState.useBoosterFifty()) {
                      _applyFiftyFifty(question);
                    }
                  }
                : null,
            icon: const Icon(Icons.filter_2_rounded, size: 16),
            label: Text('50/50 (${gameState.boosterFiftyCount})',
                style: const TextStyle(fontSize: 11)),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppTheme.primary,
              side: BorderSide(color: AppTheme.primary.withAlpha(80)),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
              padding: const EdgeInsets.symmetric(vertical: 8),
            ),
          ),
        ),
        const SizedBox(width: 8),
        // Immunity Booster
        Expanded(
          child: OutlinedButton.icon(
            onPressed: (!_answered &&
                    gameState.boosterSkipCount > 0 &&
                    !_isImmunityActive)
                ? () {
                    if (gameState.useBoosterSkip()) {
                      setState(() => _isImmunityActive = true);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Иммунитет активирован на этот вопрос!'),
                          duration: Duration(seconds: 1),
                        ),
                      );
                    }
                  }
                : null,
            icon: Icon(
              Icons.shield_rounded,
              size: 16,
              color: _isImmunityActive ? AppTheme.accentGold : AppTheme.secondary,
            ),
            label: Text(
              _isImmunityActive ? 'Щит Активен' : 'Щит (${gameState.boosterSkipCount})',
              style: const TextStyle(fontSize: 11),
            ),
            style: OutlinedButton.styleFrom(
              foregroundColor:
                  _isImmunityActive ? AppTheme.accentGold : AppTheme.secondary,
              side: BorderSide(
                color: _isImmunityActive
                    ? AppTheme.accentGold
                    : AppTheme.secondary.withAlpha(80),
              ),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
              padding: const EdgeInsets.symmetric(vertical: 8),
            ),
          ),
        ),
      ],
    );
  }

  void _applyFiftyFifty(QuizQuestion question) {
    final wrongIndices = <int>[];
    for (int i = 0; i < question.options.length; i++) {
      if (i != question.correctIndex) {
        wrongIndices.add(i);
      }
    }
    wrongIndices.shuffle();
    setState(() {
      _hiddenOptionIndices.addAll(wrongIndices.take(2));
    });
  }

  Widget _buildOptionButton(QuizQuestion question, int index) {
    Color borderColor = AppTheme.surfaceBorder;
    Color bgColor = AppTheme.surfaceCard;
    Color textColor = AppTheme.textPrimary;
    Widget? iconTrailing;

    if (_answered) {
      if (index == question.correctIndex) {
        borderColor = AppTheme.accentGreen;
        bgColor = AppTheme.accentGreen.withAlpha(30);
        iconTrailing = const Icon(Icons.check_circle_rounded,
            color: AppTheme.accentGreen, size: 20);
      } else if (index == _selectedOptionIndex) {
        borderColor = AppTheme.accentRed;
        bgColor = AppTheme.accentRed.withAlpha(30);
        iconTrailing =
            const Icon(Icons.cancel_rounded, color: AppTheme.accentRed, size: 20);
      }
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: _answered ? null : () => _onOptionSelected(question, index),
          borderRadius: BorderRadius.circular(14),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: borderColor, width: 1.5),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    question.options[index],
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: textColor,
                    ),
                  ),
                ),
                ?iconTrailing,
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _onOptionSelected(QuizQuestion question, int index) {
    setState(() {
      _selectedOptionIndex = index;
      _answered = true;

      final isCorrect = (index == question.correctIndex);
      if (isCorrect || _isImmunityActive) {
        _correctCount++;
        _totalEarnedPoints += question.points;
      }
    });
  }

  Widget _buildExplanationCard(QuizQuestion question) {
    final isCorrect = _selectedOptionIndex == question.correctIndex;
    final isShielded = !isCorrect && _isImmunityActive;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isCorrect
            ? AppTheme.accentGreen.withAlpha(20)
            : isShielded
                ? AppTheme.accentGold.withAlpha(20)
                : AppTheme.accentRed.withAlpha(20),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isCorrect
              ? AppTheme.accentGreen.withAlpha(80)
              : isShielded
                  ? AppTheme.accentGold.withAlpha(80)
                  : AppTheme.accentRed.withAlpha(80),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                isCorrect
                    ? Icons.check_circle_rounded
                    : isShielded
                        ? Icons.shield_rounded
                        : Icons.info_outline_rounded,
                size: 18,
                color: isCorrect
                    ? AppTheme.accentGreen
                    : isShielded
                        ? AppTheme.accentGold
                        : AppTheme.accentRed,
              ),
              const SizedBox(width: 8),
              Text(
                isCorrect
                    ? 'Верно! +${question.points} баллов'
                    : isShielded
                        ? 'Иммунитет сработал! Очки сохранены'
                        : 'Неверный ответ',
                style: GoogleFonts.outfit(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: isCorrect
                      ? AppTheme.accentGreen
                      : isShielded
                          ? AppTheme.accentGold
                          : AppTheme.accentRed,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            question.explanation,
            style: GoogleFonts.inter(
              fontSize: 12,
              color: AppTheme.textPrimary,
              height: 1.3,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNextButton(int totalQuestions, GameStateService state) {
    final isLast = _currentIndex == totalQuestions - 1;

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () {
          if (isLast) {
            state.recordQuizResult(
              correctCount: _correctCount,
              totalCount: totalQuestions,
              pointsWon: _totalEarnedPoints,
            );
            _showFinishDialog(state, totalQuestions);
          } else {
            setState(() {
              _currentIndex++;
              _answered = false;
              _selectedOptionIndex = null;
              _isImmunityActive = false;
              _hiddenOptionIndices.clear();
            });
          }
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.primary,
          foregroundColor: AppTheme.background,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          elevation: 0,
        ),
        child: Text(
          isLast ? 'Завершить квиз' : 'Следующий вопрос',
          style: GoogleFonts.outfit(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  void _showFinishDialog(GameStateService state, int totalQuestions) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: AppTheme.surfaceCard,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text(
            'Квиз Завершен!',
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
                Icons.emoji_events_rounded,
                color: AppTheme.accentGold,
                size: 54,
              ),
              const SizedBox(height: 14),
              Text(
                'Правильных ответов: $_correctCount из $totalQuestions',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  color: AppTheme.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: AppTheme.primary.withAlpha(25),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '+$_totalEarnedPoints баллов лояльности',
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
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('В Главное Меню'),
              ),
            ),
          ],
        );
      },
    );
  }
}
