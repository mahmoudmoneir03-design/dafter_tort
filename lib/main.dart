import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'core.dart';
import 'games/assemble.dart';
import 'games/coloring.dart';
import 'games/jigsaw.dart';
import 'games/memory.dart';
import 'games/pattern.dart';
import 'games/reading.dart';
import 'games/tracing.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  await progress.load();
  runApp(const KidsApp());
}

class KidsApp extends StatelessWidget {
  const KidsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ذكي',
      debugShowCheckedModeBanner: false,
      locale: const Locale('ar', 'EG'),
      supportedLocales: const [Locale('ar', 'EG')],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF6C4CE0)),
      ),
      home: const HomePage(),
    );
  }
}

class _Tile {
  final String emoji, title;
  final Color color;
  final Widget Function() page;
  const _Tile(this.emoji, this.title, this.color, this.page);
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final tiles = <_Tile>[
      _Tile('🧩', 'بازل', const Color(0xFFFF6B6B), () => const JigsawPage()),
      _Tile('🎨', 'تلوين', const Color(0xFFFFA94D), () => const ColoringPage()),
      _Tile('✏️', 'كتابة', const Color(0xFF51CF66), () => const TracingPage()),
      _Tile('📖', 'قراءة', const Color(0xFF339AF0), () => const ReadingPage()),
      _Tile('🔤', 'كوّن الكلمة', const Color(0xFF845EF4), () => const SpellingPage()),
      _Tile('🔧', 'فك وتركيب', const Color(0xFF20C997), () => const AssemblePage()),
      _Tile('🃏', 'الذاكرة', const Color(0xFFF06595), () => const MemoryPage()),
      _Tile('🔢', 'كمّل النمط', const Color(0xFFFAB005), () => const PatternPage()),
    ];
    return Scaffold(
      backgroundColor: const Color(0xFFF6F1FF),
      appBar: AppBar(
        backgroundColor: const Color(0xFF6C4CE0),
        foregroundColor: Colors.white,
        title: const Text('ذكي 🧠',
            style: TextStyle(fontWeight: FontWeight.w800, fontSize: 26)),
        actions: [
          const StarChip(),
          ListenableBuilder(
            listenable: progress,
            builder: (context, _) => IconButton(
              tooltip: 'الصوت',
              icon: Icon(progress.sound ? Icons.volume_up : Icons.volume_off),
              onPressed: progress.toggleSound,
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: GridView.count(
          crossAxisCount: 2,
          padding: const EdgeInsets.all(16),
          mainAxisSpacing: 14,
          crossAxisSpacing: 14,
          children: [
            for (final t in tiles)
              Material(
                color: t.color,
                borderRadius: BorderRadius.circular(26),
                elevation: 3,
                child: InkWell(
                  borderRadius: BorderRadius.circular(26),
                  onTap: () {
                    Sfx.play('tap');
                    Navigator.push(
                        context, MaterialPageRoute(builder: (_) => t.page()));
                  },
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(t.emoji, style: const TextStyle(fontSize: 58)),
                      const SizedBox(height: 6),
                      Text(t.title,
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.w800)),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
