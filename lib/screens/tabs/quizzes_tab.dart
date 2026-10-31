import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../models/quiz_models.dart';
import '../../services/game_state_service.dart';
import '../../theme/app_theme.dart';
import '../blitz_game_screen.dart';
import '../quiz_game_screen.dart';
import '../word_game_screen.dart';

class QuizzesTab extends StatelessWidget {
  const QuizzesTab({super.key});

  @override
  Widget build(BuildContext context) {
    final gameState = context.watch<GameStateService>();
    final quizData = gameState.quizData;

    if (gameState.isLoading || quizData == null) {
      return const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primary),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Bar with Loyalty Balance & Club
              _buildTopBar(context, gameState),
              const SizedBox(height: 16),

              // Hero Banner: Match Center Highlight
              _buildHeroBanner(context, gameState),
              const SizedBox(height: 20),

              // Game Modes Section
              Text(
                'ИГРОВЫЕ РЕЖИМЫ',
                style: GoogleFonts.outfit(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.primary,
                  letterSpacing: 1.5,
                ),
              ),
              const SizedBox(height: 12),
              _buildQuickModesGrid(context, quizData),
              const SizedBox(height: 24),

              // Categories Section
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'КАТЕГОРИИ РПЛ',
                    style: GoogleFonts.outfit(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: AppTheme.textPrimary,
                      letterSpacing: 1.5,
                    ),
                  ),
                  Text(
                    '${quizData.categories.length} темы',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Category Cards
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: quizData.categories.length,
                separatorBuilder: (_, _) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final cat = quizData.categories[index];
                  return _buildCategoryCard(context, cat);
                },
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopBar(BuildContext context, GameStateService state) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: AppTheme.surfaceCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.surfaceBorder),
      ),
      child: Row(
        children: [
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              decoration: BoxDecoration(
                color: AppTheme.primary.withAlpha(35),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppTheme.primary.withAlpha(90)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.sports_soccer_rounded,
                    size: 16,
                    color: AppTheme.primary,
                  ),
                  const SizedBox(width: 6),
                  Flexible(
                    child: Text(
                      state.favoriteClub,
                      style: GoogleFonts.outfit(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textPrimary,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            decoration: BoxDecoration(
              color: AppTheme.accentGold.withAlpha(30),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppTheme.accentGold.withAlpha(90)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.star_rounded,
                  size: 15,
                  color: AppTheme.accentGold,
                ),
                const SizedBox(width: 4),
                Text(
                  '${state.coins}',
                  style: GoogleFonts.outfit(
                    fontSize: 13,
                    fontWeight: FontWeight.w900,
                    color: AppTheme.accentGold,
                  ),
                ),
                const SizedBox(width: 2),
                Text(
                  'б.',
                  style: GoogleFonts.inter(
                    fontSize: 10,
                    color: AppTheme.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeroBanner(BuildContext context, GameStateService state) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppTheme.surfaceCard,
            AppTheme.primary.withAlpha(25),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.primary.withAlpha(90)),
        boxShadow: AppTheme.neonGlow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Flexible(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppTheme.primary,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    'МАТЧ-ЦЕНТР РПЛ',
                    style: GoogleFonts.outfit(
                      fontSize: 10,
                      fontWeight: FontWeight.w900,
                      color: const Color(0xFF101116),
                      letterSpacing: 1,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
              const Spacer(),
              const Icon(
                Icons.emoji_events_rounded,
                color: AppTheme.primary,
                size: 22,
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Интеллектуальная Лига Болельщиков',
            style: GoogleFonts.outfit(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Отвечайте на вопросы, разгадывайте футбольные термины и приносите баллы в копилку клуба ${state.favoriteClub}!',
            style: GoogleFonts.inter(
              fontSize: 12,
              color: AppTheme.textSecondary,
              height: 1.3,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickModesGrid(BuildContext context, QuizData data) {
    return Row(
      children: [
        // Mode 1: Football Words
        Expanded(
          child: _buildModeCard(
            context,
            title: 'Эрудит Слов',
            subtitle: 'Угадай термин',
            badge: '${data.words.length} слов',
            icon: Icons.spellcheck_rounded,
            color: AppTheme.secondary, // BetBoom Signature Red
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => WordGameScreen(words: data.words),
                ),
              );
            },
          ),
        ),
        const SizedBox(width: 12),
        // Mode 2: Turbo Blitz
        Expanded(
          child: _buildModeCard(
            context,
            title: 'Турбо-Блиц',
            subtitle: 'Правда / Ложь',
            badge: 'На скорость',
            icon: Icons.bolt_rounded,
            color: AppTheme.primary, // BetBoom Electric Yellow
            onTap: () {
              // Find blitz category or fallback to all questions
              final blitzCat = data.categories.firstWhere(
                (c) => c.id == 'blitz_sprint',
                orElse: () => data.categories.first,
              );
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => BlitzGameScreen(category: blitzCat),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildModeCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required String badge,
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
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppTheme.surfaceCard,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: color.withAlpha(80)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    width: 30,
                    height: 30,
                    decoration: BoxDecoration(
                      color: color.withAlpha(35),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(icon, color: color, size: 16),
                  ),
                  const SizedBox(width: 4),
                  Flexible(
                    child: Container(
                      padding:
                          const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                      decoration: BoxDecoration(
                        color: color.withAlpha(25),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        badge,
                        style: GoogleFonts.inter(
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                          color: color,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                title,
                style: GoogleFonts.outfit(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                subtitle,
                style: GoogleFonts.inter(
                  fontSize: 11,
                  color: AppTheme.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryCard(BuildContext context, QuizCategory category) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => QuizGameScreen(category: category),
            ),
          );
        },
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppTheme.surfaceCard,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppTheme.surfaceBorder),
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: category.color.withAlpha(30),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: category.color.withAlpha(80)),
                ),
                child: Icon(
                  _getCategoryIcon(category.icon),
                  color: category.color,
                  size: 24,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      category.title,
                      style: GoogleFonts.outfit(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textPrimary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      category.description,
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: AppTheme.textSecondary,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppTheme.surface,
                ),
                child: const Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 14,
                  color: AppTheme.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getCategoryIcon(String iconName) {
    switch (iconName) {
      case 'emoji_events':
        return Icons.emoji_events_rounded;
      case 'sports_soccer':
        return Icons.sports_soccer_rounded;
      case 'analytics':
        return Icons.analytics_rounded;
      case 'bolt':
        return Icons.bolt_rounded;
      case 'psychology':
        return Icons.psychology_rounded;
      default:
        return Icons.sports_soccer_rounded;
    }
  }
}
