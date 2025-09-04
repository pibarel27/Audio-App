import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../mock/mock_service.dart';

class NowPlayingBanner extends StatefulWidget {
  @override
  State<NowPlayingBanner> createState() => _NowPlayingBannerState();
}

class _NowPlayingBannerState extends State<NowPlayingBanner> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    // demo timer to advance the progress bar
    _timer = Timer.periodic(Duration(seconds: 1), (_) {
      final mock = Provider.of<MockService>(context, listen: false);
      final pos = (mock.nowPlaying['position'] ?? 0) as int;
      final dur = (mock.nowPlaying['duration'] ?? 180) as int;
      mock.updatePosition((pos + 1) % (dur + 1));
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final mock = Provider.of<MockService>(context);
    final data = mock.nowPlaying;
    final titleLine = '${data['title']} — ${data['artist']}';
    final dedication = data['dedicationTo'] ?? '';
    final duration = data['duration'] ?? 180;
    final position = data['position'] ?? 0;
    final progress = (duration > 0) ? (position / duration) : 0.0;

    return AnimatedSwitcher(
      duration: Duration(milliseconds: 400),
      child: Container(
        key: ValueKey(titleLine + dedication),
        margin: EdgeInsets.all(16),
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.indigo.shade400, Colors.purple.shade400],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 12,
              offset: Offset(0, 6),
            )
          ],
        ),
        child: Row(
          children: [
            _ArtworkAndEqualizer(),
            SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Scrolling marquee-like effect
                  SizedBox(
                    height: 24,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: [
                        Text(
                          titleLine,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(width: 40),
                        Text(
                          titleLine,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 6),
                  Text(
                    'Selected by ${data['requestedByName']}' +
                        (dedication.isNotEmpty ? ' (for $dedication)' : ''),
                    style: TextStyle(color: Colors.white70, fontSize: 13),
                  ),
                  SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(6),
                          child: LinearProgressIndicator(
                            value: progress,
                            minHeight: 8,
                            backgroundColor: Colors.white24,
                            color: Colors.greenAccent,
                          ),
                        ),
                      ),
                      SizedBox(width: 10),
                      Text(
                        '${mock.formatSeconds(position)} / ${mock.formatSeconds(duration)}',
                        style: TextStyle(color: Colors.white70, fontSize: 12),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(width: 8),
            Column(
              children: [
                IconButton(
                  onPressed: () {},
                  icon: Icon(Icons.skip_previous_rounded,
                      color: Colors.white, size: 24),
                ),
                IconButton(
                  onPressed: () {},
                  icon: Icon(Icons.play_arrow_rounded,
                      color: Colors.white, size: 32),
                ),
                IconButton(
                  onPressed: () {},
                  icon: Icon(Icons.skip_next_rounded,
                      color: Colors.white, size: 24),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ArtworkAndEqualizer extends StatefulWidget {
  @override
  _ArtworkAndEqualizerState createState() => _ArtworkAndEqualizerState();
}

class _ArtworkAndEqualizerState extends State<_ArtworkAndEqualizer>
    with SingleTickerProviderStateMixin {
  late AnimationController _anim;

  @override
  void initState() {
    super.initState();
    _anim =
        AnimationController(vsync: this, duration: Duration(milliseconds: 600))
          ..repeat(reverse: true);
  }

  @override
  void dispose() {
    _anim.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 72,
          height: 72,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: Colors.grey.shade200,
            image: DecorationImage(
              image: NetworkImage('https://picsum.photos/seed/music/200'),
              fit: BoxFit.cover,
            ),
          ),
        ),
        SizedBox(height: 8),
        SizedBox(
          width: 72,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(4, (i) {
              return AnimatedBuilder(
                animation: _anim,
                builder: (context, child) {
                  final t = _anim.value;
                  final height = 6 + (i + 1) * (t * (6 + i * 4));
                  return Container(
                    width: 6,
                    height: height,
                    decoration: BoxDecoration(
                      color: Colors.greenAccent,
                      borderRadius: BorderRadius.circular(3),
                    ),
                  );
                },
              );
            }),
          ),
        ),
      ],
    );
  }
}
