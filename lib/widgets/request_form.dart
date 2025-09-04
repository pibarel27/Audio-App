import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../mock/mock_service.dart';

class RequestForm extends StatefulWidget {
  @override
  State<RequestForm> createState() => _RequestFormState();
}

class _RequestFormState extends State<RequestForm> {
  final _titleCtrl = TextEditingController();
  final _artistCtrl = TextEditingController();
  final _dedicationCtrl = TextEditingController();
  bool _sending = false;

  // simple suggestions for autocomplete (demo)
  final _popular = [
    {'title': 'Believer', 'artist': 'Imagine Dragons'},
    {'title': 'Levitating', 'artist': 'Dua Lipa'},
    {'title': 'Blinding Lights', 'artist': 'The Weeknd'},
    {'title': 'Shape of You', 'artist': 'Ed Sheeran'},
  ];

  @override
  Widget build(BuildContext context) {
    final mock = Provider.of<MockService>(context, listen: false);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
              height: 6,
              width: 60,
              decoration: BoxDecoration(
                  color: Colors.black12,
                  borderRadius: BorderRadius.circular(6))),
          SizedBox(height: 12),
          Text('Request a Song',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
          SizedBox(height: 8),

          // popular quick choices
          SizedBox(
            height: 44,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemBuilder: (_, i) {
                final p = _popular[i];
                return ActionChip(
                  label: Text(p['title']!),
                  onPressed: () {
                    _titleCtrl.text = p['title']!;
                    _artistCtrl.text = p['artist']!;
                  },
                );
              },
              separatorBuilder: (_, __) => SizedBox(width: 8),
              itemCount: _popular.length,
            ),
          ),
          SizedBox(height: 12),

          TextField(
              controller: _titleCtrl,
              decoration: InputDecoration(labelText: 'Song Title')),
          SizedBox(height: 8),
          TextField(
              controller: _artistCtrl,
              decoration: InputDecoration(labelText: 'Artist')),
          SizedBox(height: 8),
          TextField(
              controller: _dedicationCtrl,
              decoration: InputDecoration(labelText: 'Dedicate to (optional)')),
          SizedBox(height: 12),

          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  icon: _sending
                      ? SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white))
                      : Icon(Icons.send_rounded),
                  label: Text(_sending ? 'Adding...' : 'Add to Queue'),
                  onPressed: _sending
                      ? null
                      : () async {
                          final title = _titleCtrl.text.trim();
                          final artist = _artistCtrl.text.trim();
                          final ded = _dedicationCtrl.text.trim();
                          if (title.isEmpty || artist.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                content:
                                    Text('Please enter title and artist')));
                            return;
                          }
                          setState(() => _sending = true);
                          // Demo: add with random-ish duration
                          final dur = 180 + (title.length % 60);
                          mock.addRequest(title, artist, 'DemoUser', ded,
                              duration: dur);
                          await Future.delayed(Duration(milliseconds: 600));
                          setState(() => _sending = false);
                          Navigator.of(context).pop();
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                              content: Text('Request added to queue')));
                        },
                ),
              ),
            ],
          ),
          SizedBox(height: 18),
        ],
      ),
    );
  }
}
