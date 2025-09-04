import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';

class ExamTimerService {
  static const String _remainingKey = 'exam_timer_remaining';
  static const String _isRunningKey = 'exam_timer_running';
  static const String _startTimeKey = 'exam_timer_start_time';
  static const String _pausedDurationKey = 'exam_timer_paused_duration';
  static const String _totalDurationKey = 'exam_timer_total_duration';

  Timer? _timer;
  int _remainingSeconds;
  bool _isRunning = false;
  DateTime? _startTime;
  int _totalPausedDuration = 0;
  final int _totalDuration;

  final StreamController<int> _timerController = StreamController<int>.broadcast();
  Stream<int> get timerStream => _timerController.stream;

  ExamTimerService({required int totalDurationSeconds})
      : _remainingSeconds = totalDurationSeconds,
        _totalDuration = totalDurationSeconds {
    _loadTimerState();
  }

  Future<void> _loadTimerState() async {
    final prefs = await SharedPreferences.getInstance();
    final savedRemaining = prefs.getInt(_remainingKey);
    _isRunning = prefs.getBool(_isRunningKey) ?? false;
    final startTimeMillis = prefs.getInt(_startTimeKey);
    _totalPausedDuration = prefs.getInt(_pausedDurationKey) ?? 0;
    
    if (savedRemaining != null) {
      _remainingSeconds = savedRemaining;
    }

    if (startTimeMillis != null) {
      _startTime = DateTime.fromMillisecondsSinceEpoch(startTimeMillis);
    }

    if (_isRunning && _startTime != null) {
      _startTimer();
    } else {
      _timerController.add(_remainingSeconds);
    }
  }

  Future<void> _saveTimerState() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_remainingKey, _remainingSeconds);
    await prefs.setBool(_isRunningKey, _isRunning);
    await prefs.setInt(_startTimeKey, _startTime?.millisecondsSinceEpoch ?? 0);
    await prefs.setInt(_pausedDurationKey, _totalPausedDuration);
    await prefs.setInt(_totalDurationKey, _totalDuration);
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSeconds > 0) {
        _remainingSeconds--;
        _timerController.add(_remainingSeconds);
        _saveTimerState();
        
        if (_remainingSeconds == 0) {
          _timer?.cancel();
          _isRunning = false;
          _saveTimerState();
        }
      }
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
      _totalPausedDuration += DateTime.now().difference(_startTime!).inSeconds;
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
    _remainingSeconds = _totalDuration;
    _isRunning = false;
    _startTime = null;
    _totalPausedDuration = 0;
    _timerController.add(_remainingSeconds);
    _saveTimerState();
  }

  int get remainingSeconds => _remainingSeconds;

  String get formattedTime {
    final minutes = _remainingSeconds ~/ 60;
    final seconds = _remainingSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  bool get isRunning => _isRunning;
  bool get hasExpired => _remainingSeconds <= 0;

  Future<void> dispose() async {
    _timer?.cancel();
    await _timerController.close();
  }

  // Clear timer state when exam is completed
  Future<void> clearExam() async {
    _timer?.cancel();
    _remainingSeconds = _totalDuration;
    _isRunning = false;
    _startTime = null;
    _totalPausedDuration = 0;
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_remainingKey);
    await prefs.remove(_isRunningKey);
    await prefs.remove(_startTimeKey);
    await prefs.remove(_pausedDurationKey);
    await prefs.remove(_totalDurationKey);
  }

  // Handle app lifecycle events
  void onPause() {
    if (_isRunning) {
      pause();
    }
  }

  void onResume() {
    if (!_isRunning && _remainingSeconds > 0) {
      resume();
    }
  }
}