import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../models/quiz_models.dart';
import '../../services/game_state_service.dart';
import '../../theme/app_theme.dart';

class ProfileTab extends StatelessWidget {
  const ProfileTab({super.key});

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
                'ПРОФИЛЬ & ЛОЯЛЬНОСТЬ',
                style: GoogleFonts.outfit(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Управляйте наградами, инвентарем и любимым клубом',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  color: AppTheme.textSecondary,
                ),
              ),
              const SizedBox(height: 16),

              // Player Card
              _buildPlayerCard(context, gameState, quizData.clubs),
              const SizedBox(height: 20),

              // Boosters Inventory
              _buildBoostersInventory(gameState),
              const SizedBox(height: 24),

              // Loyalty Store Section
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    child: Text(
                      'МАГАЗИН НАГРАД',
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
                    '${gameState.coins} баллов',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.accentGold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Store Items List
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: quizData.loyaltyStore.length,
                separatorBuilder: (_, _) => const SizedBox(height: 10),
                itemBuilder: (context, index) {
                  final item = quizData.loyaltyStore[index];
                  return _buildStoreItemCard(context, gameState, item);
                },
              ),
              const SizedBox(height: 24),

              // Career Statistics
              Text(
                'СТАТИСТИКА КАРЬЕРЫ',
                style: GoogleFonts.outfit(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.textPrimary,
                  letterSpacing: 1.5,
                ),
              ),
              const SizedBox(height: 12),
              _buildStatsGrid(gameState),
              const SizedBox(height: 24),

              // App Info & Settings
              _buildSettingsCard(context),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPlayerCard(
    BuildContext context,
    GameStateService state,
    List<ClubInfo> clubs,
  ) {
    final rankProgress = state.getRankProgress();
    final nextThreshold = state.getNextRankThreshold();

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppTheme.surfaceCard,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.surfaceBorder),
        boxShadow: AppTheme.neonGlow,
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppTheme.primary.withAlpha(30),
                  border: Border.all(color: AppTheme.primary, width: 2),
                ),
                child: const Icon(
                  Icons.person_rounded,
                  size: 36,
                  color: AppTheme.primary,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      state.getRankTitle(),
                      style: GoogleFonts.outfit(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            'Клуб: ${state.favoriteClub}',
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              color: AppTheme.textSecondary,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 6),
                        GestureDetector(
                          onTap: () => _showClubSelector(context, state, clubs),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppTheme.surface,
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(color: AppTheme.surfaceBorder),
                            ),
                            child: Text(
                              'Изменить',
                              style: GoogleFonts.inter(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.primary,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Rank progress bar
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    child: Text(
                      'Прогресс ранга',
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        color: AppTheme.textSecondary,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    '${state.coins} / $nextThreshold очков',
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.accentGold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: LinearProgressIndicator(
                  value: rankProgress,
                  minHeight: 8,
                  backgroundColor: AppTheme.surface,
                  valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.primary),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBoostersInventory(GameStateService state) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.surfaceBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Инвентарь Бустеров',
            style: GoogleFonts.outfit(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Expanded(
                child: _buildInventoryBadge(
                  icon: Icons.filter_2_rounded,
                  title: '50 / 50',
                  count: state.boosterFiftyCount,
                  color: AppTheme.primary,
                ),
              ),
              Expanded(
                child: _buildInventoryBadge(
                  icon: Icons.shield_rounded,
                  title: 'Иммунитет',
                  count: state.boosterSkipCount,
                  color: AppTheme.secondary,
                ),
              ),
              Expanded(
                child: _buildInventoryBadge(
                  icon: Icons.trending_up_rounded,
                  title: 'Двойные (x2)',
                  count: state.boosterDoubleCount,
                  color: AppTheme.accentGold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInventoryBadge({
    required IconData icon,
    required String title,
    required int count,
    required Color color,
  }) {
    return Column(
      children: [
        Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: color.withAlpha(25),
                shape: BoxShape.circle,
                border: Border.all(color: color.withAlpha(80)),
              ),
              child: Icon(icon, color: color, size: 22),
            ),
            Positioned(
              right: -4,
              top: -4,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '$count',
                  style: GoogleFonts.outfit(
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                    color: AppTheme.background,
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Text(
          title,
          style: GoogleFonts.inter(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: AppTheme.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildStoreItemCard(
    BuildContext context,
    GameStateService state,
    StoreItem item,
  ) {
    final canAfford = state.coins >= item.cost;
    final isOwned = state.ownedItemIds.contains(item.id);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.surfaceCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.surfaceBorder),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppTheme.accentGold.withAlpha(25),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              _getStoreIcon(item.icon),
              color: AppTheme.accentGold,
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title,
                  style: GoogleFonts.outfit(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  item.description,
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    color: AppTheme.textSecondary,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          ElevatedButton(
            onPressed: (canAfford && !isOwned)
                ? () {
                    final success = state.buyStoreItem(item);
                    if (success) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          backgroundColor: AppTheme.secondary,
                          content: Text(
                            '«${item.title}» успешно приобретено!',
                            style: GoogleFonts.inter(color: Colors.white),
                          ),
                        ),
                      );
                    }
                  }
                : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: isOwned
                  ? AppTheme.surface
                  : canAfford
                      ? AppTheme.primary
                      : AppTheme.surfaceBorder,
              foregroundColor: isOwned
                  ? AppTheme.textSecondary
                  : canAfford
                      ? AppTheme.background
                      : AppTheme.textSecondary,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              elevation: 0,
            ),
            child: isOwned
                ? const Text('Куплено', style: TextStyle(fontSize: 11))
                : Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.star_rounded, size: 12),
                      const SizedBox(width: 4),
                      Text(
                        '${item.cost}',
                        style: GoogleFonts.outfit(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsGrid(GameStateService state) {
    final accuracy = state.totalQuizzesPlayed > 0
        ? ((state.totalCorrectAnswers / (state.totalQuizzesPlayed * 4)) * 100)
            .clamp(0, 100)
            .toStringAsFixed(0)
        : '0';

    return Row(
      children: [
        _buildStatTile('Игр сыграно', '${state.totalQuizzesPlayed}',
            Icons.sports_soccer_rounded, AppTheme.primary),
        const SizedBox(width: 10),
        _buildStatTile('Слов отгадано', '${state.totalWordsGuessed}',
            Icons.spellcheck_rounded, AppTheme.accentPurple),
        const SizedBox(width: 10),
        _buildStatTile('Точность', '$accuracy%',
            Icons.crisis_alert_rounded, AppTheme.secondary),
      ],
    );
  }

  Widget _buildStatTile(
      String title, String value, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppTheme.surfaceCard,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppTheme.surfaceBorder),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 18),
            const SizedBox(height: 8),
            Text(
              value,
              style: GoogleFonts.outfit(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              title,
              style: GoogleFonts.inter(
                fontSize: 10,
                color: AppTheme.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.surfaceBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'О Матч-Центре РПЛ',
            style: GoogleFonts.outfit(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Интерактивное фанатское квиз-приложение российской футбольной Премьер-лиги. Версия 1.0.0.',
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

  void _showClubSelector(
    BuildContext context,
    GameStateService state,
    List<ClubInfo> clubs,
  ) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.surfaceCard,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Выберите любимый клуб РПЛ',
                  style: GoogleFonts.outfit(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 14),
                Flexible(
                  child: ListView.separated(
                    shrinkWrap: true,
                    itemCount: clubs.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 8),
                    itemBuilder: (_, index) {
                      final club = clubs[index];
                      final isSelected = club.name == state.favoriteClub;
                      return ListTile(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(
                            color: isSelected
                                ? AppTheme.primary
                                : AppTheme.surfaceBorder,
                          ),
                        ),
                        tileColor: isSelected
                            ? AppTheme.primary.withAlpha(20)
                            : AppTheme.surface,
                        leading: CircleAvatar(
                          backgroundColor: club.color.withAlpha(40),
                          child: Icon(
                            Icons.sports_soccer_rounded,
                            color: club.color,
                            size: 20,
                          ),
                        ),
                        title: Text(
                          club.name,
                          style: GoogleFonts.outfit(
                            fontWeight: FontWeight.bold,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                        subtitle: Text(
                          '${club.city} • ${club.stadium}',
                          style: GoogleFonts.inter(
                            fontSize: 11,
                            color: AppTheme.textSecondary,
                          ),
                        ),
                        trailing: isSelected
                            ? const Icon(Icons.check_circle_rounded,
                                color: AppTheme.primary)
                            : null,
                        onTap: () {
                          state.setFavoriteClub(club.name);
                          Navigator.of(ctx).pop();
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  IconData _getStoreIcon(String iconName) {
    switch (iconName) {
      case 'filter_2':
        return Icons.filter_2_rounded;
      case 'shield':
        return Icons.shield_rounded;
      case 'trending_up':
        return Icons.trending_up_rounded;
      case 'palette':
        return Icons.palette_rounded;
      case 'military_tech':
        return Icons.military_tech_rounded;
      default:
        return Icons.star_rounded;
    }
  }
}
