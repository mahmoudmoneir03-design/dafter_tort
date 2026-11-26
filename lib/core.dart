import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// النجوم وإعداد الصوت.
class Progress extends ChangeNotifier {
  int stars = 0;
  bool sound = true;
  SharedPreferences? _p;

  Future<void> load() async {
    try {
      _p = await SharedPreferences.getInstance();
      stars = _p!.getInt('stars') ?? 0;
      sound = _p!.getBool('sound') ?? true;
    } catch (_) {}
  }

  void addStar() {
    stars++;
    _p?.setInt('stars', stars);
    notifyListeners();
  }

  void toggleSound() {
    sound = !sound;
    _p?.setBool('sound', sound);
    notifyListeners();
  }
}

final Progress progress = Progress();

/// المؤثرات الصوتية: tap, pop, ok, no, win
class Sfx {
  static final Map<String, AudioPlayer> _players = {};

  static Future<void> play(String name) async {
    if (!progress.sound) return;
    try {
      final p = _players.putIfAbsent(name, () => AudioPlayer());
      await p.stop();
      await p.play(AssetSource('sounds/$name.wav'));
    } catch (_) {}
  }
}

class StarChip extends StatelessWidget {
  const StarChip({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: progress,
      builder: (context, _) => Container(
        margin: const EdgeInsetsDirectional.only(end: 12),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('⭐', style: TextStyle(fontSize: 18)),
            const SizedBox(width: 4),
            Text('${progress.stars}',
                style: const TextStyle(
                    fontWeight: FontWeight.w800, fontSize: 16, color: Colors.black87)),
          ],
        ),
      ),
    );
  }
}

/// إطار موحّد لكل لعبة.
class GameScaffold extends StatelessWidget {
  final String title;
  final Color color;
  final Widget body;
  const GameScaffold(
      {super.key, required this.title, required this.color, required this.body});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.alphaBlend(color.withValues(alpha: 0.12), Colors.white),
      appBar: AppBar(
        backgroundColor: color,
        foregroundColor: Colors.white,
        title: Text(title,
            style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 22)),
        actions: const [StarChip()],
      ),
      body: SafeArea(child: body),
    );
  }
}

/// نجمة وتهنئة بعد كل نجاح.
Future<void> celebrate(BuildContext context, {String msg = 'برافو! أحسنت'}) async {
  progress.addStar();
  Sfx.play('win');
  await showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (c) => Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.0, end: 1.0),
              duration: const Duration(milliseconds: 800),
              curve: Curves.elasticOut,
              builder: (context, v, _) => Transform.scale(
                scale: v,
                child: const Text('⭐', style: TextStyle(fontSize: 96)),
              ),
            ),
            const SizedBox(height: 8),
            Text(msg,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w800)),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: () => Navigator.pop(c),
              style: FilledButton.styleFrom(
                  minimumSize: const Size(160, 52),
                  textStyle: const TextStyle(fontSize: 20)),
              child: const Text('كمّل'),
            ),
          ],
        ),
      ),
    ),
  );
}

/// اختيار اللغة (عربي / English).
class LangPicker extends StatelessWidget {
  final bool ar;
  final ValueChanged<bool> onChanged;
  const LangPicker({super.key, required this.ar, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 10,
      children: [
        ChoiceChip(
          label: const Text('عربي', style: TextStyle(fontSize: 18)),
          selected: ar,
          onSelected: (_) => onChanged(true),
        ),
        ChoiceChip(
          label: const Text('English', style: TextStyle(fontSize: 18)),
          selected: !ar,
          onSelected: (_) => onChanged(false),
        ),
      ],
    );
  }
}
