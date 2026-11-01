import 'package:flutter/material.dart';
import '../../services/user_progress_service.dart';
import '../../theme/app_theme.dart';

class BadgeItem {
  final String id;
  final String title;
  final String description;
  final IconData icon;

  const BadgeItem({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
  });
}

class ProgressTab extends StatelessWidget {
  const ProgressTab({super.key});

  final List<BadgeItem> _badges = const [
    BadgeItem(
      id: 'badge_starter',
      title: 'Первый вход',
      description: 'Успешная регистрация личного прогресса',
      icon: Icons.sports_score_rounded,
    ),
    BadgeItem(
      id: 'badge_quiz_1',
      title: 'Интеллектуал',
      description: 'Правильный ответ в викторине дня',
      icon: Icons.lightbulb_rounded,
    ),
    BadgeItem(
      id: 'badge_reader',
      title: 'Аналитик спорта',
      description: 'Статья добавлена в сохранённые',
      icon: Icons.bookmark_added_rounded,
    ),
    BadgeItem(
      id: 'badge_fan',
      title: 'Спортивный фанат',
      description: 'Два события добавлены в избранное',
      icon: Icons.stars_rounded,
    ),
    BadgeItem(
      id: 'badge_level2',
      title: 'Любитель спорта',
      description: 'Достигнут 2-й уровень активности',
      icon: Icons.military_tech_rounded,
    ),
    BadgeItem(
      id: 'badge_level3',
      title: 'Спортивный Мастер',
      description: 'Высший 3-й уровень мастерства',
      icon: Icons.emoji_events_rounded,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final progress = UserProgressService();

    return AnimatedBuilder(
      animation: progress,
      builder: (context, _) {
        return SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.all(AppTheme.screenPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              const Text(
                'Мой прогресс',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textDark,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Ранг активности, уровни и коллекция значков',
                style: TextStyle(fontSize: 14, color: AppTheme.textSecondary),
              ),
              const SizedBox(height: 20),

              // 1. Уровень участника (Тёмная контрастная карточка с жёлтой шкалой)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppTheme.darkCard,
                  borderRadius: BorderRadius.circular(AppTheme.cardRadius),
                  boxShadow: AppTheme.darkCardShadow,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 56,
                          height: 56,
                          decoration: BoxDecoration(
                            color: AppTheme.primary,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: const Center(
                            child: Icon(Icons.workspace_premium_rounded, color: AppTheme.onPrimary, size: 32),
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                    decoration: BoxDecoration(
                                      color: AppTheme.darkSurface,
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      'УРОВЕНЬ ${progress.levelNumber} ИЗ 3',
                                      style: const TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                        color: AppTheme.primary,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              Text(
                                progress.levelName,
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.textLight,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${progress.points} баллов активности',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.primary,
                          ),
                        ),
                        Text(
                          progress.levelNumber < 3 ? 'До след. уровня: 750' : 'Максимальный ранг',
                          style: const TextStyle(fontSize: 12, color: AppTheme.textMutedDark),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: LinearProgressIndicator(
                        value: progress.levelProgress,
                        minHeight: 10,
                        backgroundColor: AppTheme.darkSurface,
                        valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.primary),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // 2. Статистика
              const Text(
                'Сводка активности',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textDark,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _buildMetricCard(
                      title: 'Викторины',
                      value: '${progress.quizzesCompleted}',
                      icon: Icons.quiz_rounded,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildMetricCard(
                      title: 'Сохранено статей',
                      value: '${progress.savedArticleIds.length}',
                      icon: Icons.bookmark_rounded,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildMetricCard(
                      title: 'Избранные события',
                      value: '${progress.favoriteMatchIds.length}',
                      icon: Icons.star_rounded,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // 3. Виртуальные значки
              const Text(
                'Коллекция значков',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textDark,
                ),
              ),
              const SizedBox(height: 12),
              ..._badges.map((badge) {
                final isUnlocked = progress.unlockedBadges.contains(badge.id);
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppTheme.surfaceLightCard,
                    borderRadius: BorderRadius.circular(AppTheme.cardRadius),
                    border: Border.all(
                      color: isUnlocked ? AppTheme.primary : AppTheme.border,
                      width: isUnlocked ? 1.5 : 1.0,
                    ),
                    boxShadow: AppTheme.cardShadow,
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 46,
                        height: 46,
                        decoration: BoxDecoration(
                          color: isUnlocked ? AppTheme.primary : AppTheme.surfaceBlock,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Icon(
                          badge.icon,
                          color: isUnlocked ? AppTheme.onPrimary : AppTheme.textSecondary,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              badge.title,
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.textDark,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              badge.description,
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppTheme.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (isUnlocked)
                        const Icon(Icons.check_circle_rounded, color: Colors.green, size: 22)
                      else
                        const Icon(Icons.lock_outline_rounded, color: AppTheme.textSecondary, size: 20),
                    ],
                  ),
                );
              }),
              const SizedBox(height: 16),

              // 4. Дисклеймер
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.surfaceBlock,
                  borderRadius: BorderRadius.circular(AppTheme.cardRadius),
                  border: Border.all(color: AppTheme.border),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Icon(Icons.verified_user_rounded, color: AppTheme.textDark, size: 20),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Баллы отражают только личную активность, их нельзя покупать, передавать или обменивать. Приложение носит информационный характер.',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppTheme.textSecondary,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMetricCard({
    required String title,
    required String value,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.surfaceLightCard,
        borderRadius: BorderRadius.circular(AppTheme.cardRadius),
        border: Border.all(color: AppTheme.border),
        boxShadow: AppTheme.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppTheme.primary, size: 22),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppTheme.textDark,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            title,
            style: const TextStyle(fontSize: 11, color: AppTheme.textSecondary),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

