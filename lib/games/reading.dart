import 'dart:math';

import 'package:flutter/material.dart';

import '../core.dart';
import '../data.dart';

/// قراءة: اقرأ الكلمة واختار الصورة الصح.
class ReadingPage extends StatefulWidget {
  const ReadingPage({super.key});

  @override
  State<ReadingPage> createState() => _ReadingPageState();
}

class _ReadingPageState extends State<ReadingPage> {
  bool ar = true;
  int correct = 0;
  late Word cur;
  late List<Word> opts;
  int? wrongIdx;

  @override
  void initState() {
    super.initState();
    _next();
  }

  void _next() {
    final list = [...(ar ? arWords : enWords)]..shuffle(Random());
    cur = list[0];
    opts = [list[0], list[1], list[2]]..shuffle(Random());
    wrongIdx = null;
  }

  Future<void> _pick(int i) async {
    if (opts[i] == cur) {
      Sfx.play('ok');
      correct++;
      if (correct >= 5) {
        correct = 0;
        await celebrate(context, msg: 'قرأت ٥ كلمات صح! برافو');
        if (!mounted) return;
      }
      setState(_next);
    } else {
      Sfx.play('no');
      setState(() => wrongIdx = i);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GameScaffold(
      title: 'قراءة 📖',
      color: const Color(0xFF339AF0),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            LangPicker(
              ar: ar,
              onChanged: (v) => setState(() {
                ar = v;
                correct = 0;
                _next();
              }),
            ),
            const SizedBox(height: 16),
            Text('✅ $correct / 5',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
            const SizedBox(height: 10),
            const Text('اقرأ الكلمة واختار صورتها',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
            const SizedBox(height: 14),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: Colors.black12, width: 2),
              ),
              child: Directionality(
                textDirection: ar ? TextDirection.rtl : TextDirection.ltr,
                child: Center(
                  child: Text(cur.text,
                      style: const TextStyle(
                          fontSize: 72, fontWeight: FontWeight.w800)),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Wrap(
              spacing: 14,
              runSpacing: 14,
              alignment: WrapAlignment.center,
              children: [
                for (var i = 0; i < opts.length; i++)
                  GestureDetector(
                    onTap: () => _pick(i),
                    child: Container(
                      width: 100,
                      height: 100,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: wrongIdx == i ? const Color(0xFFFFC9C9) : Colors.white,
                        borderRadius: BorderRadius.circular(22),
                        border: Border.all(
                            color: wrongIdx == i ? Colors.red : Colors.black12,
                            width: 3),
                      ),
                      child: Text(opts[i].emoji, style: const TextStyle(fontSize: 54)),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _Tile {
  final int id;
  final String ch;
  bool used = false;
  _Tile(this.id, this.ch);
}

/// كوّن الكلمة: رتّب الحروف تحت الصورة.
class SpellingPage extends StatefulWidget {
  const SpellingPage({super.key});

  @override
  State<SpellingPage> createState() => _SpellingPageState();
}

class _SpellingPageState extends State<SpellingPage> {
  bool ar = true;
  late Word cur;
  late List<String> chars;
  late List<_Tile> tiles;
  int filled = 0;
  int? wrongId;

  @override
  void initState() {
    super.initState();
    _next();
  }

  void _next() {
    final list = [...(ar ? arWords : enWords)]..shuffle(Random());
    cur = list.first;
    chars = cur.text.split('');
    tiles = [for (var i = 0; i < chars.length; i++) _Tile(i, chars[i])]
      ..shuffle(Random());
    filled = 0;
    wrongId = null;
  }

  Future<void> _tap(_Tile t) async {
    if (t.used) return;
    if (t.ch == chars[filled]) {
      Sfx.play('ok');
      setState(() {
        t.used = true;
        filled++;
      });
      if (filled == chars.length) {
        await Future<void>.delayed(const Duration(milliseconds: 300));
        if (!mounted) return;
        await celebrate(context, msg: '${cur.text} ${cur.emoji} برافو!');
        if (!mounted) return;
        setState(_next);
      }
    } else {
      Sfx.play('no');
      setState(() => wrongId = t.id);
      await Future<void>.delayed(const Duration(milliseconds: 450));
      if (mounted) setState(() => wrongId = null);
    }
  }

  @override
  Widget build(BuildContext context) {
    final dir = ar ? TextDirection.rtl : TextDirection.ltr;
    return GameScaffold(
      title: 'كوّن الكلمة 🔤',
      color: const Color(0xFF845EF4),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            LangPicker(
              ar: ar,
              onChanged: (v) => setState(() {
                ar = v;
                _next();
              }),
            ),
            const SizedBox(height: 16),
            Text(cur.emoji, style: const TextStyle(fontSize: 110)),
            const SizedBox(height: 8),
            const Text('رتّب الحروف بالترتيب',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
            const SizedBox(height: 14),
            Directionality(
              textDirection: dir,
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                alignment: WrapAlignment.center,
                children: [
                  for (var i = 0; i < chars.length; i++)
                    Container(
                      width: 56,
                      height: 68,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: i < filled ? const Color(0xFFD0F5D8) : Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                            color: i == filled ? const Color(0xFF845EF4) : Colors.black26,
                            width: i == filled ? 3 : 1.5),
                      ),
                      child: Text(i < filled ? chars[i] : '',
                          style: const TextStyle(
                              fontSize: 36, fontWeight: FontWeight.w800)),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 26),
            Directionality(
              textDirection: dir,
              child: Wrap(
                spacing: 10,
                runSpacing: 10,
                alignment: WrapAlignment.center,
                children: [
                  for (final t in tiles)
                    if (!t.used)
                      GestureDetector(
                        onTap: () => _tap(t),
                        child: Container(
                          width: 64,
                          height: 74,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: wrongId == t.id
                                ? const Color(0xFFFFC9C9)
                                : const Color(0xFFFFE066),
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: const [
                              BoxShadow(color: Colors.black26, blurRadius: 3, offset: Offset(0, 2))
                            ],
                          ),
                          child: Text(t.ch,
                              style: const TextStyle(
                                  fontSize: 40, fontWeight: FontWeight.w800)),
                        ),
                      ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
