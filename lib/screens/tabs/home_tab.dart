import 'package:flutter/material.dart';
import '../../services/user_progress_service.dart';
import '../../theme/app_theme.dart';

class ArticleItem {
  final String id;
  final String category;
  final String title;
  final String summary;
  final String content;
  final String readTime;
  final bool isDarkCard;

  const ArticleItem({
    required this.id,
    required this.category,
    required this.title,
    required this.summary,
    required this.content,
    required this.readTime,
    this.isDarkCard = false,
  });
}

class HomeTab extends StatefulWidget {
  const HomeTab({super.key});

  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {
  final UserProgressService _progress = UserProgressService();

  int _selectedQuizAnswer = -1;
  bool _quizSubmitted = false;

  final List<ArticleItem> _articles = const [
    ArticleItem(
      id: 'bb_art_1',
      category: 'Единоборства',
      title: 'Тайминг и дистанция в стойке: ключ к точным ударам',
      summary: 'Разбор работы ног и дистанционного контроля в октагоне и ринге.',
      content: 'Умение контролировать дистанцию позволяет спортсмену находиться в безопасности и одновременно готовить взрывную контратаку. Ключевой элемент — непрерывное смещение по диагонали с линии атаки соперника и финты передней рукой.',
      readTime: '3 мин',
      isDarkCard: true,
    ),
    ArticleItem(
      id: 'bb_art_2',
      category: 'Киберспорт',
      title: 'Микроконтроль и командные передвижения на карте',
      summary: 'Как слаженные ротации решают исход турнирных матчей на высшем уровне.',
      content: 'В соревновательных дисциплинах тайминги захвата ключевых точек рассчитываются до секунды. Ошибочный шаг одного игрока раскрывает позицию всей команды и перехватывает инициативу.',
      readTime: '4 мин',
      isDarkCard: false,
    ),
    ArticleItem(
      id: 'bb_art_3',
      category: 'Футбол',
      title: 'Стандартные положения: заготовки и геометрия розыгрышей',
      summary: 'Почему угловые и штрафные удары приносят до 35% всех голов турнира.',
      content: 'Современные тренерские штабы держат отдельных аналитиков стандартов. Подача на ближнюю штангу со срезом на дальнюю создает хаос во вратарской и сводит на нет преимущество зонной опеки.',
      readTime: '2 мин',
      isDarkCard: true,
    ),
  ];

  final List<String> _facts = [
    'В киберспорте профессиональные игроки совершают до 400 осмысленных действий в минуту (APM).',
    'В боксе удар сильнейших тяжеловесов может достигать силы свыше 700 килограммов.',
    'Футбольное поле стандарта ФИФА имеет точные пропорции: 105 метров в длину и 68 метров в ширину.',
  ];

  void _openArticleDetails(ArticleItem article) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: article.isDarkCard ? AppTheme.darkCard : AppTheme.surfaceLightCard,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppTheme.cardRadius)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            final isSaved = _progress.savedArticleIds.contains(article.id);
            final titleColor = article.isDarkCard ? AppTheme.textLight : AppTheme.textDark;
            final bodyColor = article.isDarkCard ? AppTheme.textMutedDark : AppTheme.textSecondary;

            return Container(
              padding: const EdgeInsets.all(AppTheme.screenPadding),
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.85,
              ),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: AppTheme.border,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppTheme.primary,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            article.category,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.onPrimary,
                            ),
                          ),
                        ),
                        IconButton(
                          icon: Icon(
                            isSaved ? Icons.bookmark_rounded : Icons.bookmark_border_rounded,
                            color: AppTheme.primary,
                          ),
                          onPressed: () {
                            _progress.toggleSaveArticle(article.id);
                            setModalState(() {});
                            setState(() {});
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      article.title,
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: titleColor,
                        height: 1.3,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Время чтения: ${article.readTime}',
                      style: TextStyle(fontSize: 13, color: bodyColor),
                    ),
                    const SizedBox(height: 16),
                    const Divider(color: AppTheme.border),
                    const SizedBox(height: 16),
                    Text(
                      article.content,
                      style: TextStyle(
                        fontSize: 15,
                        color: titleColor,
                        height: 1.6,
                      ),
                    ),
                    const SizedBox(height: 28),
                    SizedBox(
                      width: double.infinity,
                      height: AppTheme.buttonHeight,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primary,
                          foregroundColor: AppTheme.onPrimary,
                        ),
                        onPressed: () => Navigator.of(ctx).pop(),
                        child: const Text('Закрыть'),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _progress,
      builder: (context, _) {
        return SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.all(AppTheme.screenPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Главная',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textDark,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppTheme.darkCard,
                      borderRadius: BorderRadius.circular(AppTheme.buttonRadius),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.flash_on_rounded, color: AppTheme.primary, size: 16),
                        const SizedBox(width: 4),
                        Text(
                          '${_progress.points} баллов',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.textLight,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              const Text(
                'Футбол, единоборства и киберспорт в одном приложении',
                style: TextStyle(fontSize: 14, color: AppTheme.textSecondary),
              ),
              const SizedBox(height: 20),

              // 1. Викторина дня (Контрастная тёмная карточка с жёлтым акцентом)
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
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppTheme.primary,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Text(
                            'ВИКТОРИНА ДНЯ',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.onPrimary,
                            ),
                          ),
                        ),
                        const Spacer(),
                        const Text(
                          '+40 баллов',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.primary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Какой максимальный вес бойца в полутяжёлой весовой категории в ММА?',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textLight,
                        height: 1.3,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ...[
                      '84.0 кг',
                      '93.0 кг',
                      '105.0 кг',
                    ].asMap().entries.map((entry) {
                      final idx = entry.key;
                      final optionText = entry.value;
                      final isSelected = _selectedQuizAnswer == idx;
                      final isCorrect = (idx == 1);

                      Color cardColor = AppTheme.darkSurface;
                      if (_quizSubmitted) {
                        if (isCorrect) cardColor = const Color(0xFF1B5E20);
                        if (isSelected && !isCorrect) cardColor = const Color(0xFFB71C1C);
                      }

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: InkWell(
                          onTap: _quizSubmitted
                              ? null
                              : () {
                                  setState(() {
                                    _selectedQuizAnswer = idx;
                                    _quizSubmitted = true;
                                    if (isCorrect) {
                                      _progress.recordQuizCompleted(40);
                                    }
                                  });
                                },
                          borderRadius: BorderRadius.circular(AppTheme.buttonRadius),
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            decoration: BoxDecoration(
                              color: cardColor,
                              borderRadius: BorderRadius.circular(AppTheme.buttonRadius),
                              border: Border.all(
                                color: isSelected ? AppTheme.primary : Colors.white12,
                              ),
                            ),
                            child: Row(
                              children: [
                                Text(
                                  optionText,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: AppTheme.textLight,
                                  ),
                                ),
                                const Spacer(),
                                if (_quizSubmitted && isCorrect)
                                  const Icon(Icons.check_circle_rounded, color: AppTheme.primary, size: 20)
                                else if (_quizSubmitted && isSelected && !isCorrect)
                                  const Icon(Icons.cancel_rounded, color: Colors.redAccent, size: 20),
                              ],
                            ),
                          ),
                        ),
                      );
                    }),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // 2. Статьи (Чередование тёмных и светлых карточек по ТЗ)
              const Text(
                'Спортивные статьи',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textDark,
                ),
              ),
              const SizedBox(height: 12),
              ..._articles.map((art) {
                final isSaved = _progress.savedArticleIds.contains(art.id);
                final cardBg = art.isDarkCard ? AppTheme.darkCard : AppTheme.surfaceLightCard;
                final textMain = art.isDarkCard ? AppTheme.textLight : AppTheme.textDark;
                final textSub = art.isDarkCard ? AppTheme.textMutedDark : AppTheme.textSecondary;

                return Container(
                  margin: const EdgeInsets.only(bottom: 14),
                  decoration: BoxDecoration(
                    color: cardBg,
                    borderRadius: BorderRadius.circular(AppTheme.cardRadius),
                    border: Border.all(color: art.isDarkCard ? Colors.transparent : AppTheme.border),
                    boxShadow: art.isDarkCard ? AppTheme.darkCardShadow : AppTheme.cardShadow,
                  ),
                  child: InkWell(
                    onTap: () => _openArticleDetails(art),
                    borderRadius: BorderRadius.circular(AppTheme.cardRadius),
                    child: Padding(
                      padding: const EdgeInsets.all(18),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: AppTheme.primary,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  art.category,
                                  style: const TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: AppTheme.onPrimary,
                                  ),
                                ),
                              ),
                              IconButton(
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(),
                                icon: Icon(
                                  isSaved ? Icons.bookmark_rounded : Icons.bookmark_border_rounded,
                                  color: AppTheme.primary,
                                  size: 22,
                                ),
                                onPressed: () => _progress.toggleSaveArticle(art.id),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Text(
                            art.title,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: textMain,
                              height: 1.3,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            art.summary,
                            style: TextStyle(
                              fontSize: 13,
                              color: textSub,
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }),
              const SizedBox(height: 16),

              // 3. Факты дня
              const Text(
                'Интересный факт',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textDark,
                ),
              ),
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.surfaceBlock,
                  borderRadius: BorderRadius.circular(AppTheme.cardRadius),
                  border: Border.all(color: AppTheme.border),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.info_outline_rounded, color: AppTheme.textDark, size: 22),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        _facts[DateTime.now().minute % _facts.length],
                        style: const TextStyle(
                          fontSize: 13,
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
}

