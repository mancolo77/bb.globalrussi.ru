import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/quiz_models.dart';

class GameStateService extends ChangeNotifier {
  QuizData? _quizData;
  bool _isLoading = true;
  String? _error;

  int _coins = 750;
  String _favoriteClub = 'Спартак';
  int _boosterFiftyCount = 2;
  int _boosterSkipCount = 1;
  int _boosterDoubleCount = 1;

  int _totalQuizzesPlayed = 0;
  int _totalCorrectAnswers = 0;
  int _totalWordsGuessed = 0;
  int _currentStreak = 0;
  int _bestStreak = 0;

  final Set<String> _ownedItemIds = {};
  final Set<String> _claimedDailyIds = {};
  final Map<String, int> _dailyProgress = {};

  int _dailyLoginStreak = 1;
  String? _lastLoginDateString;

  QuizData? get quizData => _quizData;
  bool get isLoading => _isLoading;
  String? get error => _error;

  int get coins => _coins;
  String get favoriteClub => _favoriteClub;
  int get boosterFiftyCount => _boosterFiftyCount;
  int get boosterSkipCount => _boosterSkipCount;
  int get boosterDoubleCount => _boosterDoubleCount;

  int get totalQuizzesPlayed => _totalQuizzesPlayed;
  int get totalCorrectAnswers => _totalCorrectAnswers;
  int get totalWordsGuessed => _totalWordsGuessed;
  int get currentStreak => _currentStreak;
  int get bestStreak => _bestStreak;

  Set<String> get ownedItemIds => _ownedItemIds;
  Set<String> get claimedDailyIds => _claimedDailyIds;
  Map<String, int> get dailyProgress => _dailyProgress;
  int get dailyLoginStreak => _dailyLoginStreak;

  GameStateService() {
    init();
  }

  Future<void> init() async {
    _isLoading = true;
    notifyListeners();

    try {
      await _loadLocalPrefs();
      await _loadQuizData();
      _checkDailyLogin();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void setQuizDataForTesting(QuizData data) {
    _quizData = data;
    _isLoading = false;
    notifyListeners();
  }

  Future<void> _loadQuizData() async {
    String jsonString = '';
    try {
      jsonString = await rootBundle.loadString('assets/quiz_data.json');
    } catch (_) {
      jsonString = await rootBundle.loadString('assets/words.json');
    }

    final decoded = jsonDecode(jsonString) as Map<String, dynamic>;
    _quizData = QuizData.fromJson(decoded);
  }

  Future<void> _loadLocalPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _coins = prefs.getInt('player_coins') ?? 750;
      _favoriteClub = prefs.getString('player_fav_club') ?? 'Спартак';
      _boosterFiftyCount = prefs.getInt('booster_fifty') ?? 2;
      _boosterSkipCount = prefs.getInt('booster_skip') ?? 1;
      _boosterDoubleCount = prefs.getInt('booster_double') ?? 1;

      _totalQuizzesPlayed = prefs.getInt('total_quizzes') ?? 0;
      _totalCorrectAnswers = prefs.getInt('total_correct') ?? 0;
      _totalWordsGuessed = prefs.getInt('total_words') ?? 0;
      _currentStreak = prefs.getInt('current_streak') ?? 0;
      _bestStreak = prefs.getInt('best_streak') ?? 0;

      final owned = prefs.getStringList('owned_items') ?? [];
      _ownedItemIds.addAll(owned);

      final claimed = prefs.getStringList('claimed_daily') ?? [];
      _claimedDailyIds.addAll(claimed);

      _dailyLoginStreak = prefs.getInt('daily_login_streak') ?? 1;
      _lastLoginDateString = prefs.getString('last_login_date');
    } catch (e) {
      if (kDebugMode) {
        print('Error loading preferences: $e');
      }
    }
  }

  Future<void> _saveLocalPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('player_coins', _coins);
      await prefs.setString('player_fav_club', _favoriteClub);
      await prefs.setInt('booster_fifty', _boosterFiftyCount);
      await prefs.setInt('booster_skip', _boosterSkipCount);
      await prefs.setInt('booster_double', _boosterDoubleCount);

      await prefs.setInt('total_quizzes', _totalQuizzesPlayed);
      await prefs.setInt('total_correct', _totalCorrectAnswers);
      await prefs.setInt('total_words', _totalWordsGuessed);
      await prefs.setInt('current_streak', _currentStreak);
      await prefs.setInt('best_streak', _bestStreak);

      await prefs.setStringList('owned_items', _ownedItemIds.toList());
      await prefs.setStringList('claimed_daily', _claimedDailyIds.toList());
      await prefs.setInt('daily_login_streak', _dailyLoginStreak);
      if (_lastLoginDateString != null) {
        await prefs.setString('last_login_date', _lastLoginDateString!);
      }
    } catch (_) {}
  }

  void _checkDailyLogin() {
    final now = DateTime.now();
    final todayStr = '${now.year}-${now.month}-${now.day}';

    if (_lastLoginDateString == null) {
      _lastLoginDateString = todayStr;
      _dailyLoginStreak = 1;
      incrementDailyProgress('daily_4', 1);
      _saveLocalPrefs();
    } else if (_lastLoginDateString != todayStr) {
      final prevDate = DateTime.tryParse(_lastLoginDateString!);
      if (prevDate != null) {
        final diffDays = now.difference(prevDate).inDays;
        if (diffDays == 1) {
          _dailyLoginStreak = (_dailyLoginStreak % 7) + 1;
        } else if (diffDays > 1) {
          _dailyLoginStreak = 1;
        }
      }
      _lastLoginDateString = todayStr;
      _claimedDailyIds.clear();
      _dailyProgress.clear();
      incrementDailyProgress('daily_4', 1);
      _saveLocalPrefs();
    }
  }

  void addCoins(int amount) {
    if (amount <= 0) return;
    _coins += amount;
    _saveLocalPrefs();
    notifyListeners();
  }

  bool spendCoins(int amount) {
    if (amount <= 0 || _coins < amount) return false;
    _coins -= amount;
    _saveLocalPrefs();
    notifyListeners();
    return true;
  }

  void setFavoriteClub(String clubName) {
    _favoriteClub = clubName;
    _saveLocalPrefs();
    notifyListeners();
  }

  bool useBoosterFifty() {
    if (_boosterFiftyCount > 0) {
      _boosterFiftyCount--;
      _saveLocalPrefs();
      notifyListeners();
      return true;
    }
    return false;
  }

  bool useBoosterSkip() {
    if (_boosterSkipCount > 0) {
      _boosterSkipCount--;
      _saveLocalPrefs();
      notifyListeners();
      return true;
    }
    return false;
  }

  bool useBoosterDouble() {
    if (_boosterDoubleCount > 0) {
      _boosterDoubleCount--;
      _saveLocalPrefs();
      notifyListeners();
      return true;
    }
    return false;
  }

  void recordQuizResult({
    required int correctCount,
    required int totalCount,
    required int pointsWon,
  }) {
    _totalQuizzesPlayed++;
    _totalCorrectAnswers += correctCount;
    if (correctCount == totalCount && totalCount > 0) {
      _currentStreak++;
      if (_currentStreak > _bestStreak) {
        _bestStreak = _currentStreak;
      }
    } else {
      _currentStreak = 0;
    }

    _coins += pointsWon;
    incrementDailyProgress('daily_1', correctCount);
    _saveLocalPrefs();
    notifyListeners();
  }

  void recordWordSolved({required int pointsWon}) {
    _totalWordsGuessed++;
    _coins += pointsWon;
    incrementDailyProgress('daily_2', 1);
    _saveLocalPrefs();
    notifyListeners();
  }

  void recordBlitzCompleted({required int pointsWon, required int streak}) {
    _coins += pointsWon;
    if (streak > _bestStreak) {
      _bestStreak = streak;
    }
    incrementDailyProgress('daily_3', 1);
    _saveLocalPrefs();
    notifyListeners();
  }

  void incrementDailyProgress(String challengeId, int amount) {
    final current = _dailyProgress[challengeId] ?? 0;
    _dailyProgress[challengeId] = current + amount;
    notifyListeners();
  }

  bool claimDailyChallenge(DailyChallenge challenge) {
    if (_claimedDailyIds.contains(challenge.id)) return false;
    final progress = _dailyProgress[challenge.id] ?? 0;
    if (progress >= challenge.targetCount) {
      _claimedDailyIds.add(challenge.id);
      _coins += challenge.rewardCoins;
      _saveLocalPrefs();
      notifyListeners();
      return true;
    }
    return false;
  }

  bool buyStoreItem(StoreItem item) {
    if (_coins < item.cost) return false;

    _coins -= item.cost;
    if (item.type == 'booster_fifty') {
      _boosterFiftyCount += 3;
    } else if (item.type == 'booster_skip') {
      _boosterSkipCount += 2;
    } else if (item.type == 'booster_double') {
      _boosterDoubleCount += 2;
    } else {
      _ownedItemIds.add(item.id);
    }

    _saveLocalPrefs();
    notifyListeners();
    return true;
  }

  String getRankTitle() {
    if (_coins >= 6000) return 'Легенда РПЛ';
    if (_coins >= 3000) return 'Мастер РПЛ';
    if (_coins >= 1500) return 'Тактический Аналитик';
    if (_coins >= 500) return 'Преданный Фанат';
    return 'Новичок Трибун';
  }

  int getNextRankThreshold() {
    if (_coins >= 6000) return 10000;
    if (_coins >= 3000) return 6000;
    if (_coins >= 1500) return 3000;
    if (_coins >= 500) return 1500;
    return 500;
  }

  double getRankProgress() {
    if (_coins >= 6000) {
      return ((_coins - 6000) / 4000).clamp(0.0, 1.0);
    }
    if (_coins >= 3000) {
      return ((_coins - 3000) / 3000).clamp(0.0, 1.0);
    }
    if (_coins >= 1500) {
      return ((_coins - 1500) / 1500).clamp(0.0, 1.0);
    }
    if (_coins >= 500) {
      return ((_coins - 500) / 1000).clamp(0.0, 1.0);
    }
    return (_coins / 500).clamp(0.0, 1.0);
  }
}
