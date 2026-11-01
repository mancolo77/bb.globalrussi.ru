import 'package:flutter/material.dart';
import '../../services/user_progress_service.dart';
import '../../theme/app_theme.dart';

class EventData {
  final String id;
  final String sport;
  final String tournament;
  final String date;
  final String time;
  final String participantA;
  final String participantB;
  final String? score;
  final bool isLive;

  const EventData({
    required this.id,
    required this.sport,
    required this.tournament,
    required this.date,
    required this.time,
    required this.participantA,
    required this.participantB,
    this.score,
    this.isLive = false,
  });
}

class EventsTab extends StatefulWidget {
  const EventsTab({super.key});

  @override
  State<EventsTab> createState() => _EventsTabState();
}

class _EventsTabState extends State<EventsTab> {
  final UserProgressService _progress = UserProgressService();
  String _selectedSport = 'Все';
  final List<String> _sports = ['Все', 'Футбол', 'Единоборства', 'Киберспорт'];

  final List<EventData> _allEvents = const [
    EventData(
      id: 'bb_ev_1',
      sport: 'Футбол',
      tournament: 'Чемпионат России',
      date: 'Сегодня',
      time: '19:45',
      participantA: 'Локомотив',
      participantB: 'ЦСКА',
      score: '1 : 1',
      isLive: true,
    ),
    EventData(
      id: 'bb_ev_2',
      sport: 'Единоборства',
      tournament: 'Главный кард • Титульный бой',
      date: 'Сегодня',
      time: '23:00',
      participantA: 'И. Махачев',
      participantB: 'А. Волкановски',
      score: 'Победа (раунд 3)',
      isLive: false,
    ),
    EventData(
      id: 'bb_ev_3',
      sport: 'Киберспорт',
      tournament: 'Гранд-финал серии Major',
      date: 'Завтра',
      time: '18:00',
      participantA: 'Team Spirit',
      participantB: 'Gaimin Gladiators',
      score: null,
      isLive: false,
    ),
    EventData(
      id: 'bb_ev_4',
      sport: 'Футбол',
      tournament: 'Кубок',
      date: 'Завтра',
      time: '20:30',
      participantA: 'Спартак',
      participantB: 'Ростов',
      score: null,
      isLive: false,
    ),
    EventData(
      id: 'bb_ev_5',
      sport: 'Киберспорт',
      tournament: 'Плей-офф • CS2',
      date: 'Вчера',
      time: '19:00',
      participantA: 'NaVi',
      participantB: 'FaZe Clan',
      score: '2 : 0',
      isLive: false,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final filtered = _allEvents.where((e) {
      if (_selectedSport == 'Все') return true;
      return e.sport == _selectedSport;
    }).toList();

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
                    'События',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textDark,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppTheme.surfaceBlock,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: AppTheme.border),
                    ),
                    child: const Text(
                      'Пример',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              const Text(
                'Расписание турниров и результаты встреч',
                style: TextStyle(fontSize: 14, color: AppTheme.textSecondary),
              ),
              const SizedBox(height: 18),

              // Filter chips
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: _sports.map((sport) {
                    final isSelected = _selectedSport == sport;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ChoiceChip(
                        label: Text(sport),
                        selected: isSelected,
                        onSelected: (val) {
                          if (val) setState(() => _selectedSport = sport);
                        },
                        selectedColor: AppTheme.primary,
                        backgroundColor: AppTheme.surfaceLightCard,
                        labelStyle: TextStyle(
                          fontSize: 13,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          color: isSelected ? AppTheme.onPrimary : AppTheme.textSecondary,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppTheme.buttonRadius),
                          side: BorderSide(
                            color: isSelected ? AppTheme.primary : AppTheme.border,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 18),

              // Event list
              if (filtered.isEmpty)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 40),
                  child: Column(
                    children: const [
                      Icon(Icons.event_busy_rounded, size: 48, color: AppTheme.textSecondary),
                      SizedBox(height: 12),
                      Text(
                        'Нет событий в выбранной категории',
                        style: TextStyle(color: AppTheme.textSecondary, fontSize: 14),
                      ),
                    ],
                  ),
                )
              else
                ...filtered.map((event) {
                  final isFav = _progress.favoriteMatchIds.contains(event.id);
                  return Container(
                    margin: const EdgeInsets.only(bottom: 14),
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: AppTheme.surfaceLightCard,
                      borderRadius: BorderRadius.circular(AppTheme.cardRadius),
                      border: Border.all(
                        color: event.isLive ? AppTheme.primary : AppTheme.border,
                        width: event.isLive ? 2.0 : 1.0,
                      ),
                      boxShadow: AppTheme.cardShadow,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: AppTheme.surfaceBlock,
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    event.sport,
                                    style: const TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                      color: AppTheme.textDark,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  event.tournament,
                                  style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary),
                                ),
                              ],
                            ),
                            IconButton(
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                              icon: Icon(
                                isFav ? Icons.star_rounded : Icons.star_border_rounded,
                                color: isFav ? AppTheme.primary : AppTheme.textSecondary,
                                size: 22,
                              ),
                              onPressed: () => _progress.toggleFavoriteMatch(event.id),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                event.participantA,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.textDark,
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 10),
                              child: Column(
                                children: [
                                  if (event.score != null)
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: event.isLive ? AppTheme.primary : AppTheme.surfaceBlock,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        event.score!,
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: event.isLive ? AppTheme.onPrimary : AppTheme.textDark,
                                        ),
                                      ),
                                    )
                                  else
                                    Text(
                                      event.time,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: AppTheme.textDark,
                                      ),
                                    ),
                                  const SizedBox(height: 4),
                                  Text(
                                    event.isLive ? 'LIVE' : event.date,
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                      color: event.isLive ? AppTheme.accentRose : AppTheme.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Expanded(
                              child: Text(
                                event.participantB,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.textDark,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                }),
            ],
          ),
        );
      },
    );
  }
}

