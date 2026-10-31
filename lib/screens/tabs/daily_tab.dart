import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../models/quiz_models.dart';
import '../../services/game_state_service.dart';
import '../../theme/app_theme.dart';

class DailyTab extends StatelessWidget {
  const DailyTab({super.key});

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

    final streak = gameState.dailyLoginStreak;

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
                'ДЕЙЛИ ЧЕЛЛЕНДЖИ',
                style: GoogleFonts.outfit(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Выполняйте задания каждый день и забирайте бонусные баллы',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  color: AppTheme.textSecondary,
                ),
              ),
              const SizedBox(height: 16),

              // Streak Card
              _buildAttendanceCard(context, gameState, streak),
              const SizedBox(height: 24),

              // Challenges List Title
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    child: Text(
                      'ЗАДАНИЯ ДНЯ',
                      style: GoogleFonts.outfit(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: AppTheme.primary,
                        letterSpacing: 1.5,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Каждые 24ч',
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Challenges List
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: quizData.dailyChallenges.length,
                separatorBuilder: (_, _) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final challenge = quizData.dailyChallenges[index];
                  return _buildChallengeCard(context, gameState, challenge);
                },
              ),
              const SizedBox(height: 20),

              // Fact of the Day Card
              _buildFactCard(),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAttendanceCard(
      BuildContext context, GameStateService state, int currentStreak) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceCard,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.surfaceBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: AppTheme.accentGold.withAlpha(35),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.local_fire_department_rounded,
                  color: AppTheme.accentGold,
                  size: 22,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Серия Посещений: $currentStreak / 7 дней',
                      style: GoogleFonts.outfit(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    Text(
                      'Заходите ежедневно для максимального множителя',
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // 7 Days Circles
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            child: Row(
              children: List.generate(7, (index) {
                final dayNum = index + 1;
                final isCompleted = dayNum <= currentStreak;
                final isToday = dayNum == currentStreak;

                return Padding(
                  padding: EdgeInsets.only(
                    right: index == 6 ? 0 : 8,
                  ),
                  child: Column(
                    children: [
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: isCompleted
                              ? AppTheme.primary
                              : AppTheme.surface,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isToday
                                ? AppTheme.accentGold
                                : isCompleted
                                    ? AppTheme.primary
                                    : AppTheme.surfaceBorder,
                            width: isToday ? 2 : 1,
                          ),
                          boxShadow: isToday ? AppTheme.neonGlow : null,
                        ),
                        child: Center(
                          child: isCompleted
                              ? const Icon(
                                  Icons.check_rounded,
                                  size: 18,
                                  color: AppTheme.background,
                                )
                              : Text(
                                  '+${50 * dayNum}',
                                  style: GoogleFonts.outfit(
                                    fontSize: 9,
                                    fontWeight: FontWeight.bold,
                                    color: AppTheme.textSecondary,
                                  ),
                                ),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Д$dayNum',
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          fontWeight:
                              isToday ? FontWeight.bold : FontWeight.normal,
                          color: isToday
                              ? AppTheme.accentGold
                              : AppTheme.textSecondary,
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChallengeCard(
    BuildContext context,
    GameStateService state,
    DailyChallenge challenge,
  ) {
    final progress = state.dailyProgress[challenge.id] ?? 0;
    final isClaimed = state.claimedDailyIds.contains(challenge.id);
    final isReadyToClaim = progress >= challenge.targetCount && !isClaimed;
    final progressRatio = (progress / challenge.targetCount).clamp(0.0, 1.0);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isReadyToClaim
              ? AppTheme.primary.withAlpha(120)
              : AppTheme.surfaceBorder,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppTheme.primary.withAlpha(25),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  _getChallengeIcon(challenge.icon),
                  color: AppTheme.primary,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      challenge.title,
                      style: GoogleFonts.outfit(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      challenge.description,
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppTheme.accentGold.withAlpha(25),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.star_rounded,
                      size: 14,
                      color: AppTheme.accentGold,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '+${challenge.rewardCoins}',
                      style: GoogleFonts.outfit(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.accentGold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Progress bar & Action
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: progressRatio,
                        minHeight: 6,
                        backgroundColor: AppTheme.surface,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          isClaimed ? AppTheme.secondary : AppTheme.primary,
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Прогресс: $progress / ${challenge.targetCount}',
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 14),
              // Button
              ElevatedButton(
                onPressed: isReadyToClaim
                    ? () {
                        state.claimDailyChallenge(challenge);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            backgroundColor: AppTheme.secondary,
                            content: Text(
                              'Награда +${challenge.rewardCoins} баллов получена!',
                              style: GoogleFonts.inter(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        );
                      }
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: isReadyToClaim
                      ? AppTheme.primary
                      : isClaimed
                          ? AppTheme.surface
                          : AppTheme.surfaceBorder,
                  foregroundColor: isReadyToClaim
                      ? AppTheme.background
                      : AppTheme.textSecondary,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  isClaimed
                      ? 'Получено'
                      : isReadyToClaim
                          ? 'Забрать'
                          : 'В процессе',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFactCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.surfaceBorder),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.lightbulb_outline_rounded,
            color: AppTheme.accentGold,
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Футбольный факт дня',
                  style: GoogleFonts.outfit(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Рекордсменом по числу матчей в чемпионатах России является Игорь Акинфеев, проведший более 550 игр за ЦСКА!',
                  style: GoogleFonts.inter(
                    fontSize: 12,
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

  IconData _getChallengeIcon(String iconName) {
    switch (iconName) {
      case 'psychology':
        return Icons.psychology_rounded;
      case 'spellcheck':
        return Icons.spellcheck_rounded;
      case 'bolt':
        return Icons.bolt_rounded;
      case 'confirmation_number':
        return Icons.confirmation_number_rounded;
      default:
        return Icons.stars_rounded;
    }
  }
}
