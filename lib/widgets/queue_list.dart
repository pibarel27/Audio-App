import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../mock/mock_service.dart';

class QueueList extends StatelessWidget {
  final String? searchQuery;
  const QueueList({this.searchQuery});

  @override
  Widget build(BuildContext context) {
    final mock = Provider.of<MockService>(context);
    final list = mock.queue.where((item) {
      if (searchQuery == null || searchQuery!.isEmpty) return true;
      final q = searchQuery!.toLowerCase();
      final combined =
          '${item['title']} ${item['artist']} ${item['requestedByName']}'
              .toLowerCase();
      return combined.contains(q);
    }).toList();

    if (list.isEmpty) {
      return Center(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Icon(Icons.queue_music_outlined, size: 56, color: Colors.black26),
          SizedBox(height: 8),
          Text('No requests yet', style: TextStyle(color: Colors.black45)),
          SizedBox(height: 6),
          Text('Tap + to add a request',
              style: TextStyle(color: Colors.black38, fontSize: 13)),
        ]),
      );
    }

    return ListView.separated(
      itemCount: list.length,
      separatorBuilder: (_, __) => SizedBox(height: 8),
      itemBuilder: (context, index) {
        final item = list[index];
        final waitSeconds = mock.estimatedWaitSecondsForIndex(index);
        return Dismissible(
          key: ValueKey(item.hashCode),
          background: Container(
            decoration: BoxDecoration(
                color: Colors.redAccent,
                borderRadius: BorderRadius.circular(12)),
            padding: EdgeInsets.symmetric(horizontal: 16),
            alignment: Alignment.centerLeft,
            child: Icon(Icons.delete, color: Colors.white),
          ),
          direction: DismissDirection.startToEnd,
          onDismissed: (_) => mock.removeRequestAt(index),
          child: Card(
            elevation: 0,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: ListTile(
              contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              leading: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                    'https://picsum.photos/seed/${item['title'].hashCode}/80',
                    width: 56,
                    height: 56,
                    fit: BoxFit.cover),
              ),
              title: Text('${item['title']}',
                  style: TextStyle(fontWeight: FontWeight.w600)),
              subtitle: Text(
                  '${item['artist']} • By ${item['requestedByName']}',
                  style: TextStyle(color: Colors.black54)),
              trailing: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                        color: Colors.indigo.shade50,
                        borderRadius: BorderRadius.circular(8)),
                    child: Text(mock.formatSeconds(item['duration']),
                        style: TextStyle(
                            color: Colors.indigo.shade700,
                            fontWeight: FontWeight.w600)),
                  ),
                  SizedBox(height: 6),
                  Text('Wait: ${mock.formatSeconds(waitSeconds)}',
                      style: TextStyle(color: Colors.black45, fontSize: 12)),
                ],
              ),
              onTap: () {
                // demo action: immediately play this request
                mock.playRequestNow(index);
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text('Now playing "${item['title']}" (demo)')));
              },
            ),
          ),
        );
      },
    );
  }
}
