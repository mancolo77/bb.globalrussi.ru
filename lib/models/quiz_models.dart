import 'package:flutter/material.dart';

class ClubInfo {
  final String id;
  final String name;
  final String city;
  final String stadium;
  final Color color;

  const ClubInfo({
    required this.id,
    required this.name,
    required this.city,
    required this.stadium,
    required this.color,
  });

  factory ClubInfo.fromJson(Map<String, dynamic> json) {
    Color parsedColor = const Color(0xFF00F5D4);
    if (json['color'] != null) {
      final hex = (json['color'] as String).replaceAll('#', '');
      if (hex.length == 6) {
        parsedColor = Color(int.parse('FF$hex', radix: 16));
      }
    }
    return ClubInfo(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      city: json['city'] as String? ?? '',
      stadium: json['stadium'] as String? ?? '',
      color: parsedColor,
    );
  }
}

class QuizQuestion {
  final int id;
  final String question;
  final List<String> options;
  final int correctIndex;
  final String explanation;
  final int points;

  const QuizQuestion({
    required this.id,
    required this.question,
    required this.options,
    required this.correctIndex,
    required this.explanation,
    required this.points,
  });

  factory QuizQuestion.fromJson(Map<String, dynamic> json) {
    return QuizQuestion(
      id: json['id'] as int? ?? 0,
      question: json['question'] as String? ?? '',
      options: (json['options'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      correctIndex: json['correct_index'] as int? ?? 0,
      explanation: json['explanation'] as String? ?? '',
      points: json['points'] as int? ?? 100,
    );
  }
}

class QuizCategory {
  final String id;
  final String title;
  final String description;
  final String icon;
  final Color color;
  final List<QuizQuestion> questions;

  const QuizCategory({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
    required this.questions,
  });

  factory QuizCategory.fromJson(Map<String, dynamic> json) {
    Color parsedColor = const Color(0xFF00F5D4);
    if (json['color'] != null) {
      final hex = (json['color'] as String).replaceAll('#', '');
      if (hex.length == 6) {
        parsedColor = Color(int.parse('FF$hex', radix: 16));
      }
    }

    final questionsList = (json['questions'] as List<dynamic>?)
            ?.map((q) => QuizQuestion.fromJson(q as Map<String, dynamic>))
            .toList() ??
        [];

    return QuizCategory(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      icon: json['icon'] as String? ?? 'sports_soccer',
      color: parsedColor,
      questions: questionsList,
    );
  }
}

class WordPuzzle {
  final String word;
  final String hint;
  final String category;
  final String difficulty;
  final int points;

  const WordPuzzle({
    required this.word,
    required this.hint,
    required this.category,
    required this.difficulty,
    required this.points,
  });

  factory WordPuzzle.fromJson(Map<String, dynamic> json) {
    return WordPuzzle(
      word: (json['word'] as String? ?? '').toUpperCase(),
      hint: json['hint'] as String? ?? '',
      category: json['category'] as String? ?? 'Общее',
      difficulty: json['difficulty'] as String? ?? 'Легкий',
      points: json['points'] as int? ?? 100,
    );
  }
}

class DailyChallenge {
  final String id;
  final String title;
  final String description;
  final int targetCount;
  final int rewardCoins;
  final String icon;

  const DailyChallenge({
    required this.id,
    required this.title,
    required this.description,
    required this.targetCount,
    required this.rewardCoins,
    required this.icon,
  });

  factory DailyChallenge.fromJson(Map<String, dynamic> json) {
    return DailyChallenge(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      targetCount: json['target_count'] as int? ?? 1,
      rewardCoins: json['reward_coins'] as int? ?? 100,
      icon: json['icon'] as String? ?? 'stars',
    );
  }
}

class StoreItem {
  final String id;
  final String title;
  final int cost;
  final String icon;
  final String type;
  final String description;

  const StoreItem({
    required this.id,
    required this.title,
    required this.cost,
    required this.icon,
    required this.type,
    required this.description,
  });

  factory StoreItem.fromJson(Map<String, dynamic> json) {
    return StoreItem(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      cost: json['cost'] as int? ?? 100,
      icon: json['icon'] as String? ?? 'star',
      type: json['type'] as String? ?? 'misc',
      description: json['description'] as String? ?? '',
    );
  }
}

class LeaderboardEntry {
  final int rank;
  final String name;
  final String club;
  final int points;
  final String badge;

  const LeaderboardEntry({
    required this.rank,
    required this.name,
    required this.club,
    required this.points,
    required this.badge,
  });

  factory LeaderboardEntry.fromJson(Map<String, dynamic> json) {
    return LeaderboardEntry(
      rank: json['rank'] as int? ?? 0,
      name: json['name'] as String? ?? '',
      club: json['club'] as String? ?? '',
      points: json['points'] as int? ?? 0,
      badge: json['badge'] as String? ?? '',
    );
  }
}

class QuizData {
  final String appName;
  final String tagline;
  final String theme;
  final List<ClubInfo> clubs;
  final List<QuizCategory> categories;
  final List<WordPuzzle> words;
  final List<DailyChallenge> dailyChallenges;
  final List<StoreItem> loyaltyStore;
  final List<LeaderboardEntry> leaderboard;

  const QuizData({
    required this.appName,
    required this.tagline,
    required this.theme,
    required this.clubs,
    required this.categories,
    required this.words,
    required this.dailyChallenges,
    required this.loyaltyStore,
    required this.leaderboard,
  });

  factory QuizData.fromJson(Map<String, dynamic> json) {
    final appInfo = json['app_info'] as Map<String, dynamic>? ?? {};

    return QuizData(
      appName: appInfo['name'] as String? ?? 'Матч-Центр РПЛ',
      tagline: appInfo['tagline'] as String? ?? 'Премьер-Квиз',
      theme: appInfo['theme'] as String? ?? 'РПЛ',
      clubs: (json['clubs'] as List<dynamic>?)
              ?.map((e) => ClubInfo.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      categories: (json['categories'] as List<dynamic>?)
              ?.map((e) => QuizCategory.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      words: (json['words'] as List<dynamic>?)
              ?.map((e) => WordPuzzle.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      dailyChallenges: (json['daily_challenges'] as List<dynamic>?)
              ?.map((e) => DailyChallenge.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      loyaltyStore: (json['loyalty_store'] as List<dynamic>?)
              ?.map((e) => StoreItem.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      leaderboard: (json['leaderboard'] as List<dynamic>?)
              ?.map((e) => LeaderboardEntry.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}
