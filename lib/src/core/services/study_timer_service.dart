import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';

class StudyTimerService {
  static const String _timerKey = 'study_timer_elapsed';
  static const String _isRunningKey = 'study_timer_running';
  static const String _startTimeKey = 'study_timer_start_time';

  Timer? _timer;
  int _elapsedSeconds = 0;
  bool _isRunning = false;
  DateTime? _startTime;

  final StreamController<int> _timerController = StreamController<int>.broadcast();
  Stream<int> get timerStream => _timerController.stream;

  StudyTimerService() {
    _loadTimerState();
  }

  Future<void> _loadTimerState() async {
    final prefs = await SharedPreferences.getInstance();
    _elapsedSeconds = prefs.getInt(_timerKey) ?? 0;
    _isRunning = prefs.getBool(_isRunningKey) ?? false;
    final startTimeMillis = prefs.getInt(_startTimeKey);
    
    if (startTimeMillis != null) {
      _startTime = DateTime.fromMillisecondsSinceEpoch(startTimeMillis);
    }

    if (_isRunning && _startTime != null) {
      _startTimer();
    }
  }

  Future<void> _saveTimerState() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_timerKey, _elapsedSeconds);
    await prefs.setBool(_isRunningKey, _isRunning);
    await prefs.setInt(_startTimeKey, _startTime?.millisecondsSinceEpoch ?? 0);
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _elapsedSeconds++;
      _timerController.add(_elapsedSeconds);
      _saveTimerState();
    });
  }

  void start() {
    if (!_isRunning) {
      _isRunning = true;
      _startTime = DateTime.now();
      _startTimer();
      _saveTimerState();
    }
  }

  void pause() {
    if (_isRunning) {
      _isRunning = false;
      _timer?.cancel();
      _saveTimerState();
    }
  }

  void resume() {
    if (!_isRunning) {
      _isRunning = true;
      _startTime = DateTime.now();
      _startTimer();
      _saveTimerState();
    }
  }

  void reset() {
    _timer?.cancel();
    _elapsedSeconds = 0;
    _isRunning = false;
    _startTime = null;
    _timerController.add(0);
    _saveTimerState();
  }

  int get elapsedSeconds => _elapsedSeconds;

  String get formattedTime {
    final hours = _elapsedSeconds ~/ 3600;
    final minutes = (_elapsedSeconds % 3600) ~/ 60;
    final seconds = _elapsedSeconds % 60;
    
    if (hours > 0) {
      return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    } else {
      return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    }
  }

  bool get isRunning => _isRunning;

  Future<void> dispose() async {
    _timer?.cancel();
    await _timerController.close();
  }

  // Clear timer state when session is completed
  Future<void> clearSession() async {
    _timer?.cancel();
    _elapsedSeconds = 0;
    _isRunning = false;
    _startTime = null;
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_timerKey);
    await prefs.remove(_isRunningKey);
    await prefs.remove(_startTimeKey);
  }
}