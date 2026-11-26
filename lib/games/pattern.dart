import 'dart:math';

import 'package:flutter/material.dart';

import '../core.dart';

const List<String> _symbols = ['🔴', '🔵', '🟡', '🟢', '⭐', '❤️', '🔺', '🟣'];

const List<List<int>> _templates = [
  [0, 1, 0, 1, 0, 1],
  [0, 0, 1, 0, 0, 1],
  [0, 1, 2, 0, 1, 2],
  [0, 1, 1, 0, 1, 1],
  [0, 0, 1, 1, 0, 0],
];

class PatternPage extends StatefulWidget {
  const PatternPage({super.key});

  @override
  State<PatternPage> createState() => _PatternPageState();
}

class _PatternPageState extends State<PatternPage> {
  int correct = 0;
  late List<String> seq;
  late List<String> opts;
  late String answer;
  int? wrongIdx;

  @override
  void initState() {
    super.initState();
    _next();
  }

  void _next() {
    final rnd = Random();
    final syms = [..._symbols]..shuffle(rnd);
    final t = _templates[rnd.nextInt(_templates.length)];
    final full = [for (final i in t) syms[i]];
    answer = full.last;
    seq = full.sublist(0, full.length - 1);
    final others = syms.where((s) => s != answer).take(2).toList();
    opts = [answer, ...others]..shuffle(rnd);
    wrongIdx = null;
  }

  Future<void> _pick(int i) async {
    if (opts[i] == answer) {
      Sfx.play('ok');
      correct++;
      if (correct >= 5) {
        correct = 0;
        await celebrate(context, msg: 'عبقري! ٥ أنماط صح');
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
      title: 'كمّل النمط 🔢',
      color: const Color(0xFFFAB005),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text('✅ $correct / 5',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
            const SizedBox(height: 10),
            const Text('إيه اللي جاي بعد كده؟',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800)),
            const SizedBox(height: 16),
            Directionality(
              textDirection: TextDirection.ltr,
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(color: Colors.black12, width: 2),
                ),
                child: Wrap(
                  alignment: WrapAlignment.center,
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final s in seq) Text(s, style: const TextStyle(fontSize: 44)),
                    Container(
                      width: 52,
                      height: 52,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFF3BF),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFFAB005), width: 3),
                      ),
                      child: const Text('❓', style: TextStyle(fontSize: 30)),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 28),
            Wrap(
              spacing: 16,
              runSpacing: 16,
              alignment: WrapAlignment.center,
              children: [
                for (var i = 0; i < opts.length; i++)
                  GestureDetector(
                    onTap: () => _pick(i),
                    child: Container(
                      width: 92,
                      height: 92,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: wrongIdx == i ? const Color(0xFFFFC9C9) : Colors.white,
                        borderRadius: BorderRadius.circular(22),
                        border: Border.all(
                            color: wrongIdx == i ? Colors.red : Colors.black12, width: 3),
                      ),
                      child: Text(opts[i], style: const TextStyle(fontSize: 50)),
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
