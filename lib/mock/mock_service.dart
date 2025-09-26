import 'package:flutter/foundation.dart';

class MockService extends ChangeNotifier {
  Map<String, dynamic> nowPlaying = {
    'title': 'Shape of You',
    'artist': 'Ed Sheeran',
    'requestedByName': 'Rahul',
    'dedicationTo': 'Lin',
    'duration': 240, // seconds
    'position': 42, // demo current playback position
  };

  final List<Map<String, dynamic>> _queue = [
    {
      'title': 'Believer',
      'artist': 'Imagine Dragons',
      'requestedByName': 'Tomba',
      'dedicationTo': 'Team',
      'duration': 204,
    },
    {
      'title': 'Levitating',
      'artist': 'Dua Lipa',
      'requestedByName': 'Chaoba',
      'dedicationTo': 'Frnd',
      'duration': 203,
    },
    {
      'title': 'Blinding Lights',
      'artist': 'The Weeknd',
      'requestedByName': 'Tombi',
      'dedicationTo': 'All',
      'duration': 200,
    },
  ];

  List<Map<String, dynamic>> get queue => List.unmodifiable(_queue);

  void addRequest(String title, String artist, String by, String forWhom,
      {int duration = 180}) {
    final item = {
      'title': title,
      'artist': artist,
      'requestedByName': by,
      'dedicationTo': forWhom,
      'duration': duration,
    };
    _queue.add(item);
    notifyListeners();
  }

  void removeRequestAt(int index) {
    if (index >= 0 && index < _queue.length) {
      _queue.removeAt(index);
      notifyListeners();
    }
  }

  // compute estimated wait time (seconds) for item at index (0 = next)
  int estimatedWaitSecondsForIndex(int index) {
    int wait = (nowPlaying['duration'] ?? 0) - (nowPlaying['position'] ?? 0);
    for (int i = 0; i < index; i++) {
      wait += _queue[i]['duration'] as int;
    }
    return wait < 0 ? 0 : wait;
  }

  String formatSeconds(int s) {
    final m = (s / 60).floor();
    final sec = s % 60;
    return '${m}:${sec.toString().padLeft(2, '0')}';
  }

  // demo helper: refresh / nudge positions
  void refreshDemo() {
    // advance the playback position slightly (demo only)
    nowPlaying['position'] =
        ((nowPlaying['position'] ?? 0) + 8) % (nowPlaying['duration'] ?? 180);
    notifyListeners();
  }

  // optional: set a request to now playing (demo)
  void playRequestNow(int queueIndex) {
    if (queueIndex < 0 || queueIndex >= _queue.length) return;
    final item = _queue.removeAt(queueIndex);
    nowPlaying = {
      'title': item['title'],
      'artist': item['artist'],
      'requestedByName': item['requestedByName'],
      'dedicationTo': item['dedicationTo'],
      'duration': item['duration'],
      'position': 0,
    };
    notifyListeners();
  }

  /// ✅ NEW: Update playback position (fixes error in NowPlayingBanner)
  void updatePosition(int newPos) {
    nowPlaying['position'] = newPos;
    notifyListeners();
  }
}
