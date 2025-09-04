import 'package:flutter/material.dart';

class Marquee extends StatefulWidget {
  final String text;
  final TextStyle? style;
  final double velocity; // pixels per second

  const Marquee({
    Key? key,
    required this.text,
    this.style,
    this.velocity = 50.0,
  }) : super(key: key);

  @override
  _MarqueeState createState() => _MarqueeState();
}

class _MarqueeState extends State<Marquee> with SingleTickerProviderStateMixin {
  late ScrollController _scrollController;
  late double _textWidth;
  late double _containerWidth;
  late AnimationController _animController;
  bool _measured = false;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _animController = AnimationController(vsync: this);
    // We'll configure the animation after measuring sizes
  }

  @override
  void dispose() {
    _animController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  // measure text width
  double _measureTextWidth(String text, TextStyle style) {
    final tp = TextPainter(
      text: TextSpan(text: text, style: style),
      textDirection: TextDirection.ltr,
    )..layout();
    return tp.width;
  }

  void _startScroll() {
    if (!mounted) return;
    if (_textWidth <= _containerWidth) return; // no need to scroll

    final distance = _textWidth + _containerWidth; // scroll amount (loop)
    final durationSeconds = distance / widget.velocity;
    _animController.duration =
        Duration(milliseconds: (durationSeconds * 1000).toInt());
    _animController.repeat();

    _animController.addListener(() {
      if (!_scrollController.hasClients) return;
      final offset = _animController.value * (_textWidth + 20); // add small gap
      // We scroll from 0 -> textWidth + gap, and wrap with mod
      final pos = offset % (_textWidth + 20);
      _scrollController.jumpTo(pos);
    });
  }

  @override
  Widget build(BuildContext context) {
    final style = widget.style ?? DefaultTextStyle.of(context).style;
    return LayoutBuilder(builder: (context, constraints) {
      // measure once
      if (!_measured) {
        _containerWidth = constraints.maxWidth;
        _textWidth = _measureTextWidth(widget.text, style);
        _measured = true;
        WidgetsBinding.instance.addPostFrameCallback((_) => _startScroll());
      }

      return SizedBox(
        height: style.fontSize != null ? style.fontSize! * 1.6 : 20,
        child: SingleChildScrollView(
          controller: _scrollController,
          scrollDirection: Axis.horizontal,
          physics: const NeverScrollableScrollPhysics(),
          child: Row(
            children: [
              Text(widget.text, style: style),
              // a little gap then same text so it looks continuous when scrolling
              SizedBox(width: 20),
              Text(widget.text, style: style),
            ],
          ),
        ),
      );
    });
  }
}
