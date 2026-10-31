import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:app_/models/quiz_models.dart';
import 'package:app_/screens/blitz_game_screen.dart';
import 'package:app_/screens/main_navigation_screen.dart';
import 'package:app_/screens/quiz_game_screen.dart';
import 'package:app_/screens/word_game_screen.dart';
import 'package:app_/services/game_state_service.dart';
import 'package:app_/theme/app_theme.dart';

const String mockQuizJson = '''
{
  "app_info": {
    "name": "Матч-Центр РПЛ",
    "tagline": "Премьер-Квиз",
    "theme": "РПЛ",
    "version": "1.0.0"
  },
  "clubs": [
    {"id": "spartak", "name": "Спартак", "city": "Москва", "stadium": "Лукойл Арена", "color": "#E63946"},
    {"id": "zenit", "name": "Зенит", "city": "Санкт-Петербург", "stadium": "Газпром Арена", "color": "#00B4D8"}
  ],
  "categories": [
    {
      "id": "rpl_history",
      "title": "История и Чемпионы",
      "description": "Проверьте знания о триумфаторах и сезонах",
      "icon": "emoji_events",
      "color": "#FFE600",
      "questions": [
        {
          "id": 1,
          "question": "Какой клуб выиграл первый чемпионат России в 1992 году?",
          "options": ["Спартак", "ЦСКА", "Динамо", "Локомотив"],
          "correct_index": 0,
          "explanation": "Московский Спартак стал первым чемпионом России.",
          "points": 100
        }
      ]
    },
    {
      "id": "blitz_sprint",
      "title": "Турбо-Блиц РПЛ",
      "description": "Быстрые футбольные утверждения",
      "icon": "bolt",
      "color": "#FF7A00",
      "questions": [
        {
          "id": 15,
          "question": "Локомотив становился чемпионом России с Юрием Сёминым.",
          "options": ["Правда", "Ложь"],
          "correct_index": 0,
          "explanation": "Да, все чемпионства Локо были с Сёминым.",
          "points": 50
        }
      ]
    }
  ],
  "words": [
    {
      "word": "СПАРТАК",
      "hint": "Московский клуб народной команды с красно-белыми цветами",
      "category": "Клубы",
      "difficulty": "Легкий",
      "points": 100
    }
  ],
  "daily_challenges": [
    {
      "id": "daily_1",
      "title": "Тактический разбор",
      "description": "Пройдите любой квиз",
      "target_count": 1,
      "reward_coins": 100,
      "icon": "psychology"
    }
  ],
  "loyalty_store": [
    {
      "id": "booster_5050",
      "title": "Бустер 50/50",
      "cost": 300,
      "icon": "filter_2",
      "type": "booster_fifty",
      "description": "Убирает 2 неверных варианта"
    }
  ],
  "leaderboard": [
    {"rank": 1, "name": "Форвард", "club": "Зенит", "points": 14200, "badge": "Золото"}
  ]
}
''';

Widget createTestApp(GameStateService gameState, {Widget? home}) {
  return ChangeNotifierProvider<GameStateService>.value(
    value: gameState,
    child: MaterialApp(
      theme: AppTheme.darkTheme,
      home: home ?? const MainNavigationScreen(),
    ),
  );
}

void main() {
  setUpAll(() {
    TestWidgetsFlutterBinding.ensureInitialized();
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  setUp(() {
    SharedPreferences.setMockInitialValues({
      'player_coins': 950,
      'player_fav_club': 'Спартак',
    });

  });

  group('РПЛ Матч-Центр Navigation & Overflow Tests', () {
    const screenSizes = [
      Size(320, 568),  // Compact screen (iPhone SE 1st gen)
      Size(375, 667),  // Standard phone (iPhone 8)
      Size(390, 844),  // Modern phone (iPhone 14)
      Size(412, 915),  // Pixel 7
      Size(800, 1280), // Tablet
    ];

    testWidgets('Has exactly 4 navigation tabs and renders without overflow on all screen sizes',
        (WidgetTester tester) async {
      final parsed = QuizData.fromJson(jsonDecode(mockQuizJson));
      final gameState = GameStateService();
      gameState.setQuizDataForTesting(parsed);

      for (final size in screenSizes) {
        tester.view.physicalSize = size;
        tester.view.devicePixelRatio = 1.0;

        await tester.pumpWidget(createTestApp(gameState));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 200));

        // 1. Verify 4 tabs in bottom navigation
        expect(find.byType(BottomNavigationBar), findsOneWidget);
        expect(find.text('Квизы'), findsOneWidget);
        expect(find.text('Дейли'), findsOneWidget);
        expect(find.text('Рейтинг'), findsOneWidget);
        expect(find.text('Профиль'), findsOneWidget);

        // 2. Tab 0: Quizzes
        expect(tester.takeException(), isNull, reason: 'Tab 0 overflow at $size');

        // 3. Tab 1: Daily
        await tester.tap(find.text('Дейли'));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 200));
        expect(tester.takeException(), isNull, reason: 'Tab 1 overflow at $size');

        // 4. Tab 2: Leaderboard
        await tester.tap(find.text('Рейтинг'));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 200));
        expect(tester.takeException(), isNull, reason: 'Tab 2 overflow at $size');

        // 5. Tab 3: Profile
        await tester.tap(find.text('Профиль'));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 200));
        expect(tester.takeException(), isNull, reason: 'Tab 3 overflow at $size');
      }

      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });
    });

    testWidgets('Game screens (Quiz, Word, Blitz) render with zero RenderFlex overflow',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(320, 568);
      tester.view.devicePixelRatio = 1.0;

      final parsed = QuizData.fromJson(jsonDecode(mockQuizJson));
      final gameState = GameStateService();
      gameState.setQuizDataForTesting(parsed);

      // Test QuizGameScreen
      await tester.pumpWidget(
        createTestApp(
          gameState,
          home: QuizGameScreen(category: parsed.categories[0]),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));
      expect(tester.takeException(), isNull, reason: 'QuizGameScreen has no overflow');

      // Test WordGameScreen
      await tester.pumpWidget(
        createTestApp(
          gameState,
          home: WordGameScreen(words: parsed.words),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));
      expect(tester.takeException(), isNull, reason: 'WordGameScreen has no overflow');

      // Test BlitzGameScreen
      await tester.pumpWidget(
        createTestApp(
          gameState,
          home: BlitzGameScreen(category: parsed.categories[1]),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));
      expect(tester.takeException(), isNull, reason: 'BlitzGameScreen has no overflow');

      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });
    });
  });
}
