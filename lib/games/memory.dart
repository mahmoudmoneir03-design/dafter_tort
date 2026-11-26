import 'dart:math';

import 'package:flutter/material.dart';

import '../core.dart';
import '../data.dart';

class MemoryPage extends StatefulWidget {
  const MemoryPage({super.key});

  @override
  State<MemoryPage> createState() => _MemoryPageState();
}

class _MemoryPageState extends State<MemoryPage> {
  int pairs = 3;
  late List<String> cards;
  late List<bool> up;
  late List<bool> done;
  int? first;
  bool busy = false;
  int moves = 0;

  @override
  void initState() {
    super.initState();
    _deal();
  }

  void _deal() {
    final pool = [...funEmoji]..shuffle(Random());
    final pick = pool.take(pairs).toList();
    cards = [...pick, ...pick]..shuffle(Random());
    up = List<bool>.filled(cards.length, false);
    done = List<bool>.filled(cards.length, false);
    first = null;
    busy = false;
    moves = 0;
  }

  Future<void> _tap(int i) async {
    if (busy || up[i] || done[i]) return;
    Sfx.play('tap');
    setState(() => up[i] = true);
    final f = first;
    if (f == null) {
      first = i;
      return;
    }
    moves++;
    busy = true;
    if (cards[f] == cards[i]) {
      Sfx.play('ok');
      setState(() {
        done[f] = true;
        done[i] = true;
      });
      first = null;
      busy = false;
      if (done.every((e) => e)) {
        await Future<void>.delayed(const Duration(milliseconds: 400));
        if (!mounted) return;
        await celebrate(context, msg: 'لقيت كل الأزواج! برافو');
        if (!mounted) return;
        setState(() {
          pairs = min(8, pairs + 1);
          _deal();
        });
      }
    } else {
      await Future<void>.delayed(const Duration(milliseconds: 800));
      if (!mounted) return;
      setState(() {
        up[f] = false;
        up[i] = false;
        first = null;
        busy = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final cross = pairs <= 3 ? 3 : 4;
    return GameScaffold(
      title: 'الذاكرة 🃏',
      color: const Color(0xFFF06595),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Text('افتح كارتين زي بعض',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
            const SizedBox(height: 4),
            Text('عدد الأزواج: $pairs   ·   المحاولات: $moves',
                style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 12),
            Expanded(
              child: GridView.count(
                crossAxisCount: cross,
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
                children: [
                  for (var i = 0; i < cards.length; i++)
                    GestureDetector(
                      onTap: () => _tap(i),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 250),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: done[i]
                              ? const Color(0xFFD0F5D8)
                              : up[i]
                                  ? Colors.white
                                  : const Color(0xFFF06595),
                          borderRadius: BorderRadius.circular(18),
                          boxShadow: const [
                            BoxShadow(color: Colors.black26, blurRadius: 3, offset: Offset(0, 2))
                          ],
                        ),
                        child: Text(
                          (up[i] || done[i]) ? cards[i] : '❓',
                          style: TextStyle(
                              fontSize: cross == 3 ? 52 : 40,
                              color: Colors.white),
                        ),
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
