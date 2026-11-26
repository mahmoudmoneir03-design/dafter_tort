import 'dart:math';

import 'package:flutter/material.dart';

import '../core.dart';

class _Part {
  final int kind; // 0 مستطيل، 1 دايرة، 2 مثلث، 3 مستطيل مدوّر
  final Color color;
  final double l, t, w, h;
  final int group; // القطع المتشابهة ليها نفس المجموعة
  const _Part(this.kind, this.color, this.l, this.t, this.w, this.h, this.group);
}

const List<String> _names = ['الروبوت', 'العربية', 'البيت'];

const List<List<_Part>> _builds = [
  // روبوت
  [
    _Part(1, Color(0xFFE63946), .45, .03, .10, .10, 0),
    _Part(3, Color(0xFF339AF0), .30, .14, .40, .22, 1),
    _Part(1, Colors.white, .37, .21, .08, .08, 2),
    _Part(1, Colors.white, .55, .21, .08, .08, 2),
    _Part(0, Color(0xFF51CF66), .28, .38, .44, .30, 3),
    _Part(3, Color(0xFFFF922B), .14, .40, .10, .26, 4),
    _Part(3, Color(0xFFFF922B), .76, .40, .10, .26, 4),
    _Part(3, Color(0xFF845EF4), .33, .70, .12, .25, 5),
    _Part(3, Color(0xFF845EF4), .55, .70, .12, .25, 5),
  ],
  // عربية
  [
    _Part(3, Color(0xFFE63946), .10, .50, .80, .20, 0),
    _Part(3, Color(0xFF339AF0), .28, .32, .40, .19, 1),
    _Part(0, Color(0xFFA5D8FF), .34, .36, .12, .11, 2),
    _Part(0, Color(0xFFA5D8FF), .50, .36, .12, .11, 2),
    _Part(1, Color(0xFF343A40), .18, .64, .20, .20, 3),
    _Part(1, Color(0xFF343A40), .62, .64, .20, .20, 3),
    _Part(1, Color(0xFFFFD43B), .84, .54, .07, .07, 4),
  ],
  // بيت
  [
    _Part(1, Color(0xFFFFD43B), .78, .03, .14, .14, 0),
    _Part(0, Color(0xFF868E96), .66, .14, .08, .16, 1),
    _Part(2, Color(0xFFE63946), .12, .20, .76, .26, 2),
    _Part(0, Color(0xFFFFB84D), .20, .45, .60, .40, 3),
    _Part(0, Color(0xFF8D6E63), .44, .62, .14, .23, 4),
    _Part(0, Color(0xFFA5D8FF), .27, .52, .13, .13, 5),
    _Part(0, Color(0xFFA5D8FF), .62, .52, .13, .13, 5),
  ],
];

class _PartPainter extends CustomPainter {
  final int kind;
  final Color color;
  _PartPainter(this.kind, this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final r = Offset.zero & size;
    final fill = Paint()..color = color;
    final line = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..strokeJoin = StrokeJoin.round
      ..color = Colors.black87;
    switch (kind) {
      case 0:
        canvas.drawRect(r, fill);
        canvas.drawRect(r, line);
        break;
      case 1:
        canvas.drawOval(r, fill);
        canvas.drawOval(r, line);
        break;
      case 2:
        final p = Path()
          ..moveTo(size.width / 2, 0)
          ..lineTo(size.width, size.height)
          ..lineTo(0, size.height)
          ..close();
        canvas.drawPath(p, fill);
        canvas.drawPath(p, line);
        break;
      default:
        final rr = RRect.fromRectAndRadius(
            r, Radius.circular(min(size.width, size.height) * 0.25));
        canvas.drawRRect(rr, fill);
        canvas.drawRRect(rr, line);
    }
  }

  @override
  bool shouldRepaint(covariant _PartPainter old) =>
      old.kind != kind || old.color != color;
}

class AssemblePage extends StatefulWidget {
  const AssemblePage({super.key});

  @override
  State<AssemblePage> createState() => _AssemblePageState();
}

class _AssemblePageState extends State<AssemblePage> {
  int b = 0;
  late List<int> filledBy; // لكل مكان: رقم القطعة اللي فيه أو -1
  late List<bool> used;
  late List<int> order;

  List<_Part> get parts => _builds[b];

  @override
  void initState() {
    super.initState();
    _reset();
  }

  void _reset() {
    filledBy = List<int>.filled(parts.length, -1);
    used = List<bool>.filled(parts.length, false);
    order = List<int>.generate(parts.length, (i) => i)..shuffle(Random());
  }

  Widget _partWidget(_Part p, double board, {double opacity = 1}) {
    return Opacity(
      opacity: opacity,
      child: SizedBox(
        width: p.w * board,
        height: p.h * board,
        child: CustomPaint(painter: _PartPainter(p.kind, p.color)),
      ),
    );
  }

  Future<void> _accept(int slot, int part) async {
    Sfx.play('ok');
    setState(() {
      filledBy[slot] = part;
      used[part] = true;
    });
    if (filledBy.every((e) => e >= 0)) {
      await Future<void>.delayed(const Duration(milliseconds: 400));
      if (!mounted) return;
      await celebrate(context, msg: 'ركّبت ${_names[b]}! برافو');
      if (!mounted) return;
      setState(() {
        b = (b + 1) % _builds.length;
        _reset();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return GameScaffold(
      title: 'فك وتركيب 🔧',
      color: const Color(0xFF20C997),
      body: LayoutBuilder(
        builder: (context, box) {
          final board = min(box.maxWidth - 32, 380.0);
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Wrap(
                  spacing: 8,
                  children: [
                    for (var i = 0; i < _names.length; i++)
                      ChoiceChip(
                        label: Text(_names[i], style: const TextStyle(fontSize: 17)),
                        selected: b == i,
                        onSelected: (_) => setState(() {
                          b = i;
                          _reset();
                        }),
                      ),
                  ],
                ),
                const SizedBox(height: 10),
                Container(
                  width: board,
                  height: board,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.black26, width: 2),
                  ),
                  child: Stack(
                    children: [
                      for (var i = 0; i < parts.length; i++)
                        Positioned(
                          left: parts[i].l * board,
                          top: parts[i].t * board,
                          width: parts[i].w * board,
                          height: parts[i].h * board,
                          child: DragTarget<int>(
                            onWillAcceptWithDetails: (d) =>
                                filledBy[i] < 0 &&
                                parts[d.data].group == parts[i].group,
                            onAcceptWithDetails: (d) => _accept(i, d.data),
                            builder: (context, cand, rej) {
                              if (filledBy[i] >= 0) {
                                // دوس على القطعة المركّبة عشان تفكّها
                                return GestureDetector(
                                  onTap: () {
                                    Sfx.play('pop');
                                    setState(() {
                                      used[filledBy[i]] = false;
                                      filledBy[i] = -1;
                                    });
                                  },
                                  child: _partWidget(parts[filledBy[i]], board),
                                );
                              }
                              return Opacity(
                                opacity: cand.isNotEmpty ? 0.5 : 0.16,
                                child: CustomPaint(
                                  painter: _PartPainter(
                                      parts[i].kind, Colors.black),
                                ),
                              );
                            },
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                const Text('اسحب القطع وركّبها. دوس على أي قطعة مركّبة عشان تفكّها',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  alignment: WrapAlignment.center,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    for (final i in order)
                      if (!used[i])
                        Draggable<int>(
                          data: i,
                          feedback: Material(
                              color: Colors.transparent,
                              child: _partWidget(parts[i], board)),
                          childWhenDragging:
                              _partWidget(parts[i], board, opacity: 0.25),
                          onDragEnd: (d) {
                            if (!d.wasAccepted) Sfx.play('no');
                          },
                          child: _partWidget(parts[i], board),
                        ),
                  ],
                ),
                const SizedBox(height: 14),
                OutlinedButton.icon(
                  onPressed: () => setState(_reset),
                  icon: const Icon(Icons.build_circle_outlined),
                  label: const Text('فكّ الكل وابدأ تاني', style: TextStyle(fontSize: 16)),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
