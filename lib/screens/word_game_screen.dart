import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../models/quiz_models.dart';
import '../services/game_state_service.dart';
import '../theme/app_theme.dart';

class WordGameScreen extends StatefulWidget {
  final List<WordPuzzle> words;

  const WordGameScreen({super.key, required this.words});

  @override
  State<WordGameScreen> createState() => _WordGameScreenState();
}

class _WordGameScreenState extends State<WordGameScreen> {
  int _currentIndex = 0;
  List<String?> _userLetters = [];
  List<String> _bankLetters = [];
  List<bool> _bankUsed = [];
  bool _isSolved = false;

  @override
  void initState() {
    super.initState();
    _initPuzzle();
  }

  void _initPuzzle() {
    if (widget.words.isEmpty) return;
    final puzzle = widget.words[_currentIndex];
    final targetWord = puzzle.word.toUpperCase();

    _userLetters = List.filled(targetWord.length, null);
    _isSolved = false;

    // Create scrambled bank: correct letters + 4 random extra letters
    final letters = targetWord.split('');
    const extraAlphabet = 'АБВГДЕЖЗИКЛМНОПРСТУФХЦЧШЩЭЮЯ';
    final random = Random();
    for (int i = 0; i < 4; i++) {
      letters.add(extraAlphabet[random.nextInt(extraAlphabet.length)]);
    }
    letters.shuffle();

    _bankLetters = letters;
    _bankUsed = List.filled(letters.length, false);
  }

  void _onBankLetterTap(int bankIndex) {
    if (_bankUsed[bankIndex] || _isSolved) return;

    // Find first empty user slot
    final emptyIndex = _userLetters.indexOf(null);
    if (emptyIndex != -1) {
      setState(() {
        _userLetters[emptyIndex] = _bankLetters[bankIndex];
        _bankUsed[bankIndex] = true;
        _checkWord();
      });
    }
  }

  void _onUserSlotTap(int slotIndex) {
    if (_userLetters[slotIndex] == null || _isSolved) return;

    final letterToRemove = _userLetters[slotIndex];
    // Find the corresponding bank letter that was marked used
    for (int i = 0; i < _bankLetters.length; i++) {
      if (_bankLetters[i] == letterToRemove && _bankUsed[i]) {
        setState(() {
          _bankUsed[i] = false;
          _userLetters[slotIndex] = null;
        });
        break;
      }
    }
  }

  void _checkWord() {
    final puzzle = widget.words[_currentIndex];
    if (!_userLetters.contains(null)) {
      final formed = _userLetters.join();
      if (formed == puzzle.word.toUpperCase()) {
        _isSolved = true;
        final state = context.read<GameStateService>();
        state.recordWordSolved(pointsWon: puzzle.points);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final gameState = context.watch<GameStateService>();

    if (widget.words.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Футбольный Эрудит')),
        body: const Center(child: Text('Слова не найдены')),
      );
    }

    final puzzle = widget.words[_currentIndex];

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: Text(
          'Эрудит',
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
              // Header Indicator
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppTheme.accentPurple.withAlpha(25),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'Слово ${_currentIndex + 1} из ${widget.words.length}',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.accentPurple,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '+${puzzle.points} б.',
                    style: GoogleFonts.outfit(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Clue Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: AppTheme.surfaceCard,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: AppTheme.surfaceBorder),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: AppTheme.primary.withAlpha(30),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              puzzle.category.toUpperCase(),
                              style: GoogleFonts.outfit(
                                fontSize: 10,
                                fontWeight: FontWeight.w800,
                                color: AppTheme.primary,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Flexible(
                          child: Text(
                            'Сложность: ${puzzle.difficulty}',
                            style: GoogleFonts.inter(
                              fontSize: 11,
                              color: AppTheme.textSecondary,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      puzzle.hint,
                      style: GoogleFonts.outfit(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textPrimary,
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Letter Slots Row
              Center(
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  alignment: WrapAlignment.center,
                  children: List.generate(_userLetters.length, (index) {
                    final letter = _userLetters[index];
                    return GestureDetector(
                      onTap: () => _onUserSlotTap(index),
                      child: Container(
                        width: 40,
                        height: 48,
                        decoration: BoxDecoration(
                          color: _isSolved
                              ? AppTheme.accentGreen.withAlpha(30)
                              : AppTheme.surfaceCard,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: _isSolved
                                ? AppTheme.accentGreen
                                : letter != null
                                    ? AppTheme.primary
                                    : AppTheme.surfaceBorder,
                            width: 1.5,
                          ),
                        ),
                        child: Center(
                          child: Text(
                            letter ?? '',
                            style: GoogleFonts.outfit(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: _isSolved
                                  ? AppTheme.accentGreen
                                  : AppTheme.textPrimary,
                            ),
                          ),
                        ),
                      ),
                    );
                  }),
                ),
              ),
              const SizedBox(height: 24),

              // Celebration Card if Solved
              if (_isSolved) ...[
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppTheme.accentGreen.withAlpha(25),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppTheme.accentGreen.withAlpha(90)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.check_circle_rounded,
                          color: AppTheme.accentGreen, size: 28),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Великолепно! Слово отгадано!',
                              style: GoogleFonts.outfit(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.accentGreen,
                              ),
                            ),
                            Text(
                              '+${puzzle.points} очков добавлено на ваш счет',
                              style: GoogleFonts.inter(
                                fontSize: 11,
                                color: AppTheme.textPrimary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      if (_currentIndex < widget.words.length - 1) {
                        setState(() {
                          _currentIndex++;
                          _initPuzzle();
                        });
                      } else {
                        Navigator.of(context).pop();
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primary,
                      foregroundColor: AppTheme.background,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    child: Text(
                      _currentIndex < widget.words.length - 1
                          ? 'Следующее слово'
                          : 'Завершить игру',
                      style: GoogleFonts.outfit(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],

              // Letter Bank
              Text(
                'БАНК БУКВ',
                style: GoogleFonts.outfit(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.textSecondary,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 10),
              Center(
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  alignment: WrapAlignment.center,
                  children: List.generate(_bankLetters.length, (index) {
                    final letter = _bankLetters[index];
                    final isUsed = _bankUsed[index];

                    return GestureDetector(
                      onTap: () => _onBankLetterTap(index),
                      child: Container(
                        width: 42,
                        height: 44,
                        decoration: BoxDecoration(
                          color: isUsed
                              ? AppTheme.surface.withAlpha(50)
                              : AppTheme.surfaceCard,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: isUsed
                                ? Colors.transparent
                                : AppTheme.surfaceBorder,
                          ),
                        ),
                        child: Center(
                          child: Text(
                            isUsed ? '' : letter,
                            style: GoogleFonts.outfit(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.textPrimary,
                            ),
                          ),
                        ),
                      ),
                    );
                  }),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
