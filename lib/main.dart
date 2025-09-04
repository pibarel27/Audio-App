import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';

import 'mock/mock_service.dart';
import 'widgets/now_playing_banner.dart';
import 'widgets/queue_list.dart';
import 'widgets/request_form.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => MockService(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Radio Queue (UI Demo)',
        theme: ThemeData(
          primarySwatch: Colors.indigo,
          textTheme: GoogleFonts.interTextTheme(),
          scaffoldBackgroundColor: Color(0xFFF6F7FB),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              padding: EdgeInsets.symmetric(vertical: 12, horizontal: 20),
            ),
          ),
        ),
        home: HomeScreen(),
      ),
    );
  }
}

class HomeScreen extends StatefulWidget {
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _search = '';

  @override
  Widget build(BuildContext context) {
    final mock = Provider.of<MockService>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        title: Text('Live Radio + Requests',
            style: TextStyle(fontWeight: FontWeight.w600)),
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.refresh_rounded),
            onPressed: () => mock.refreshDemo(),
            tooltip: 'Refresh demo data',
          ),
          IconButton(
            icon: Icon(Icons.add_box_rounded),
            onPressed: () => _openRequestSheet(context),
            tooltip: 'Request a song',
          ),
        ],
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(56),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: _buildSearchBar(),
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            NowPlayingBanner(),
            Expanded(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: RefreshIndicator(
                  onRefresh: () async =>
                      Provider.of<MockService>(context, listen: false)
                          .refreshDemo(),
                  child: QueueList(searchQuery: _search),
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openRequestSheet(context),
        label: Text('Request'),
        icon: Icon(Icons.music_note),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      height: 42,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 2))
        ],
      ),
      child: Row(
        children: [
          SizedBox(width: 12),
          Icon(Icons.search, color: Colors.black45),
          SizedBox(width: 8),
          Expanded(
            child: TextField(
              decoration: InputDecoration.collapsed(
                  hintText: 'Search by title, artist or requester'),
              onChanged: (v) =>
                  setState(() => _search = v.trim().toLowerCase()),
            ),
          ),
          IconButton(icon: Icon(Icons.filter_list), onPressed: () {}),
        ],
      ),
    );
  }

  void _openRequestSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (_) => Padding(
        padding:
            EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: RequestForm(),
      ),
    );
  }
}
