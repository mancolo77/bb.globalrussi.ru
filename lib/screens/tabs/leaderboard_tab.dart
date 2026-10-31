import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../models/quiz_models.dart';
import '../../services/game_state_service.dart';
import '../../theme/app_theme.dart';

class LeaderboardTab extends StatefulWidget {
  const LeaderboardTab({super.key});

  @override
  State<LeaderboardTab> createState() => _LeaderboardTabState();
}

class _LeaderboardTabState extends State<LeaderboardTab> {
  int _selectedSegment = 0; // 0 = Fans, 1 = Clubs

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
              // Header
              Text(
                'РЕЙТИНГ & ТУРНИР',
                style: GoogleFonts.outfit(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Зарабатывайте баллы и поднимайте свой любимый клуб в таблице',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  color: AppTheme.textSecondary,
                ),
              ),
              const SizedBox(height: 16),

              // Player Stats Bar
              _buildPlayerRankBanner(gameState),
              const SizedBox(height: 16),

              // Segmented Switch
              _buildSegmentSwitch(),
              const SizedBox(height: 16),

              if (_selectedSegment == 0)
                _buildFansList(quizData.leaderboard, gameState)
              else
                _buildClubsList(quizData.clubs, gameState),

              const SizedBox(height: 20),
              _buildSeasonPrizeCard(),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPlayerRankBanner(GameStateService state) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.surfaceCard,
            AppTheme.primary.withAlpha(25),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.primary.withAlpha(90)),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppTheme.primary.withAlpha(30),
              shape: BoxShape.circle,
            ),
            child: const Center(
              child: Icon(
                Icons.military_tech_rounded,
                color: AppTheme.primary,
                size: 26,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Ваш статус: ${state.getRankTitle()}',
                  style: GoogleFonts.outfit(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Клуб: ${state.favoriteClub} • ${state.coins} очков',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: AppTheme.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: AppTheme.surface,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppTheme.surfaceBorder),
            ),
            child: Text(
              'ТОП-15%',
              style: GoogleFonts.outfit(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: AppTheme.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSegmentSwitch() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppTheme.surfaceCard,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.surfaceBorder),
      ),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _selectedSegment = 0),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: _selectedSegment == 0
                      ? AppTheme.primary
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: Text(
                    'Фанаты Лиги',
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: _selectedSegment == 0
                          ? AppTheme.background
                          : AppTheme.textSecondary,
                    ),
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _selectedSegment = 1),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: _selectedSegment == 1
                      ? AppTheme.primary
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: Text(
                    'Битва Клубов РПЛ',
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: _selectedSegment == 1
                          ? AppTheme.background
                          : AppTheme.textSecondary,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFansList(
      List<LeaderboardEntry> leaderboard, GameStateService state) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: leaderboard.length,
      separatorBuilder: (_, _) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final entry = leaderboard[index];
        final isTop3 = entry.rank <= 3;
        final rankColor = entry.rank == 1
            ? AppTheme.accentGold
            : entry.rank == 2
                ? const Color(0xFFC0C0C0) // Silver
                : entry.rank == 3
                    ? const Color(0xFFCD7F32) // Bronze
                    : AppTheme.textSecondary;

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: AppTheme.surfaceCard,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isTop3
                  ? rankColor.withAlpha(80)
                  : AppTheme.surfaceBorder,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: rankColor.withAlpha(30),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    '#${entry.rank}',
                    style: GoogleFonts.outfit(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: rankColor,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      entry.name,
                      style: GoogleFonts.outfit(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    Text(
                      'Болельщик ФК «${entry.club}» • ${entry.badge}',
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                '${entry.points} б.',
                style: GoogleFonts.outfit(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primary,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildClubsList(List<ClubInfo> clubs, GameStateService state) {
    // Generate mock accumulated club fan points
    final clubScores = [
      {'club': 'Спартак', 'points': 84200, 'fans': 1240},
      {'club': 'Зенит', 'points': 79500, 'fans': 1180},
      {'club': 'ЦСКА', 'points': 73100, 'fans': 990},
      {'club': 'Краснодар', 'points': 62400, 'fans': 840},
      {'club': 'Динамо', 'points': 54800, 'fans': 720},
      {'club': 'Локомотив', 'points': 49200, 'fans': 650},
      {'club': 'Ростов', 'points': 38600, 'fans': 430},
      {'club': 'Рубин', 'points': 29400, 'fans': 360},
    ];

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: clubScores.length,
      separatorBuilder: (_, _) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final item = clubScores[index];
        final clubName = item['club'] as String;
        final points = item['points'] as int;
        final fans = item['fans'] as int;
        final isUserClub = clubName == state.favoriteClub;

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: isUserClub
                ? AppTheme.primary.withAlpha(25)
                : AppTheme.surfaceCard,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isUserClub
                  ? AppTheme.primary.withAlpha(120)
                  : AppTheme.surfaceBorder,
            ),
          ),
          child: Row(
            children: [
              Text(
                '#${index + 1}',
                style: GoogleFonts.outfit(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: index == 0
                      ? AppTheme.accentGold
                      : AppTheme.textSecondary,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          'ФК $clubName',
                          style: GoogleFonts.outfit(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                        if (isUserClub) ...[
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppTheme.primary,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              'ВАШ ВЫБОР',
                              style: GoogleFonts.inter(
                                fontSize: 9,
                                fontWeight: FontWeight.w900,
                                color: AppTheme.background,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    Text(
                      '$fans активных фанатов в лиге',
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                '$points б.',
                style: GoogleFonts.outfit(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.accentGold,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSeasonPrizeCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.surfaceBorder),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.card_giftcard_rounded,
            color: AppTheme.primary,
            size: 28,
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Призовой фонд сезона',
                  style: GoogleFonts.outfit(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Лучшие знатоки РПЛ по итогам месяца получат памятные трофеи и эксклюзивные статусы клуба',
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    color: AppTheme.textSecondary,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
