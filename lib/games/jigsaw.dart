import 'dart:math';

import 'package:flutter/material.dart';

import '../core.dart';

/// بيرسم مشهد ملوّن بالحجم المطلوب (الأجزاء بتقصّ منه).
void drawScene(int id, Canvas c, Size s) {
  final w = s.width, h = s.height;
  final p = Paint();
  Offset o(double x, double y) => Offset(x * w, y * h);
  Rect r(double l, double t, double rr, double b) =>
      Rect.fromLTRB(l * w, t * h, rr * w, b * h);
  Path tri(double x1, double y1, double x2, double y2, double x3, double y3) =>
      Path()
        ..moveTo(x1 * w, y1 * h)
        ..lineTo(x2 * w, y2 * h)
        ..lineTo(x3 * w, y3 * h)
        ..close();
  void fill(Color col) => p
    ..style = PaintingStyle.fill
    ..color = col;

  switch (id % 3) {
    case 0: // بيت
      fill(const Color(0xFF8FD3FF));
      c.drawRect(Offset.zero & s, p);
      fill(const Color(0xFFFFD43B));
      c.drawCircle(o(.82, .18), w * .09, p);
      fill(Colors.white);
      c.drawCircle(o(.2, .16), w * .06, p);
      c.drawCircle(o(.27, .13), w * .07, p);
      c.drawCircle(o(.34, .17), w * .05, p);
      fill(const Color(0xFF6BCB77));
      c.drawOval(Rect.fromLTRB(-.2 * w, .72 * h, 1.2 * w, 1.5 * h), p);
      fill(const Color(0xFFFF9F43));
      c.drawRect(r(.3, .5, .7, .85), p);
      fill(const Color(0xFFD63031));
      c.drawPath(tri(.25, .5, .5, .26, .75, .5), p);
      fill(const Color(0xFF6D4C41));
      c.drawRect(r(.46, .64, .54, .85), p);
      fill(const Color(0xFF74B9FF));
      c.drawRect(r(.34, .56, .42, .64), p);
      c.drawRect(r(.58, .56, .66, .64), p);
      fill(const Color(0xFF8D6E63));
      c.drawRect(r(.84, .6, .87, .86), p);
      fill(const Color(0xFF2E9E4F));
      c.drawCircle(o(.855, .5), w * .09, p);
      break;
    case 1: // بحر
      fill(const Color(0xFF4CC9F0));
      c.drawRect(Offset.zero & s, p);
      fill(const Color(0xFF3A86FF));
      c.drawRect(r(0, .55, 1, 1), p);
      fill(const Color(0xFFFFE08A));
      c.drawRect(r(0, .88, 1, 1), p);
      fill(const Color(0xFFFF9F1C));
      c.drawOval(Rect.fromCenter(center: o(.4, .42), width: w * .32, height: h * .2), p);
      c.drawPath(tri(.54, .42, .68, .3, .68, .54), p);
      fill(Colors.white);
      c.drawCircle(o(.32, .39), w * .025, p);
      fill(Colors.black);
      c.drawCircle(o(.32, .39), w * .011, p);
      fill(const Color(0xFFFF5D8F));
      c.drawOval(Rect.fromCenter(center: o(.7, .74), width: w * .2, height: h * .12), p);
      c.drawPath(tri(.8, .74, .9, .66, .9, .82), p);
      fill(Colors.white);
      c.drawCircle(o(.65, .72), w * .015, p);
      p
        ..style = PaintingStyle.stroke
        ..strokeWidth = w * .008
        ..color = Colors.white;
      c.drawCircle(o(.2, .3), w * .05, p);
      c.drawCircle(o(.26, .2), w * .03, p);
      c.drawCircle(o(.16, .18), w * .02, p);
      p
        ..strokeWidth = w * .03
        ..strokeCap = StrokeCap.round
        ..color = const Color(0xFF2E9E4F);
      c.drawPath(
          Path()
            ..moveTo(.1 * w, .9 * h)
            ..quadraticBezierTo(.06 * w, .78 * h, .12 * w, .68 * h),
          p);
      c.drawPath(
          Path()
            ..moveTo(.2 * w, .9 * h)
            ..quadraticBezierTo(.24 * w, .8 * h, .18 * w, .7 * h),
          p);
      p.style = PaintingStyle.fill;
      break;
    default: // فضاء
      fill(const Color(0xFF1B1464));
      c.drawRect(Offset.zero & s, p);
      fill(Colors.white);
      const stars = [
        [.1, .1], [.3, .08], [.5, .12], [.7, .06], [.9, .12], [.15, .45],
        [.4, .3], [.75, .4], [.95, .55], [.6, .9], [.05, .7], [.85, .85]
      ];
      for (final st in stars) {
        c.drawCircle(o(st[0], st[1]), w * .008, p);
      }
      fill(const Color(0xFFFF7F50));
      c.drawCircle(o(.2, .25), w * .12, p);
      p
        ..style = PaintingStyle.stroke
        ..strokeWidth = w * .015
        ..color = const Color(0xFFFFD166);
      c.drawOval(Rect.fromCenter(center: o(.2, .25), width: w * .36, height: h * .08), p);
      fill(const Color(0xFFF1F2F6));
      c.drawCircle(o(.84, .16), w * .07, p);
      fill(const Color(0xFF2ECC71));
      c.drawCircle(o(.25, 1.0), w * .24, p);
      fill(Colors.white);
      c.drawRRect(
          RRect.fromRectAndRadius(r(.48, .38, .62, .72), Radius.circular(w * .05)), p);
      fill(const Color(0xFFE63946));
      c.drawPath(tri(.48, .4, .55, .22, .62, .4), p);
      c.drawPath(tri(.48, .6, .4, .76, .48, .72), p);
      c.drawPath(tri(.62, .6, .7, .76, .62, .72), p);
      fill(const Color(0xFF74B9FF));
      c.drawCircle(o(.55, .5), w * .035, p);
      fill(const Color(0xFFFFC300));
      c.drawPath(tri(.5, .72, .6, .72, .55, .86), p);
      break;
  }
}

class _PiecePainter extends CustomPainter {
  final int scene, cols, rows, cx, cy;
  _PiecePainter(this.scene, this.cols, this.rows, this.cx, this.cy);

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.clipRect(Offset.zero & size);
    canvas.translate(-cx * size.width, -cy * size.height);
    drawScene(scene, canvas, Size(size.width * cols, size.height * rows));
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _PiecePainter old) =>
      old.scene != scene || old.cols != cols || old.rows != rows;
}

class JigsawPage extends StatefulWidget {
  const JigsawPage({super.key});

  @override
  State<JigsawPage> createState() => _JigsawPageState();
}

class _JigsawPageState extends State<JigsawPage> {
  static const grids = [
    [2, 2],
    [3, 2],
    [4, 3]
  ];
  static const levelNames = ['سهل', 'وسط', 'صعب'];

  int level = 0;
  int scene = 0;
  int cols = 2, rows = 2;
  List<bool> placed = [];
  List<int> tray = [];

  @override
  void initState() {
    super.initState();
    _newRound();
  }

  void _newRound() {
    final g = grids[level];
    cols = g[0];
    rows = g[1];
    placed = List<bool>.filled(cols * rows, false);
    tray = List<int>.generate(cols * rows, (i) => i)..shuffle(Random());
  }

  Widget _piece(int idx, double pw, double ph) {
    final cx = idx % cols, cy = idx ~/ cols;
    return Container(
      width: pw,
      height: ph,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.white, width: 2),
        boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 3)],
      ),
      child: CustomPaint(painter: _PiecePainter(scene, cols, rows, cx, cy)),
    );
  }

  Future<void> _drop(int cell, int data) async {
    if (data == cell) {
      Sfx.play('ok');
      setState(() => placed[cell] = true);
      if (placed.every((e) => e)) {
        await Future<void>.delayed(const Duration(milliseconds: 400));
        if (!mounted) return;
        await celebrate(context, msg: 'كمّلت البازل! برافو');
        if (!mounted) return;
        setState(() {
          scene++;
          _newRound();
        });
      }
    } else {
      Sfx.play('no');
    }
  }

  @override
  Widget build(BuildContext context) {
    return GameScaffold(
      title: 'بازل 🧩',
      color: const Color(0xFFFF6B6B),
      body: LayoutBuilder(
        builder: (context, box) {
          final bw = min(box.maxWidth - 32, 420.0);
          final bh = bw * 0.75;
          final pw = bw / cols, ph = bh / rows;
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Wrap(
                  spacing: 10,
                  children: [
                    for (var i = 0; i < 3; i++)
                      ChoiceChip(
                        label: Text(levelNames[i], style: const TextStyle(fontSize: 18)),
                        selected: level == i,
                        onSelected: (_) => setState(() {
                          level = i;
                          _newRound();
                        }),
                      ),
                  ],
                ),
                const SizedBox(height: 12),
                Container(
                  width: bw,
                  height: bh,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: Colors.black26, width: 2),
                  ),
                  child: Stack(
                    children: [
                      for (var i = 0; i < cols * rows; i++)
                        Positioned(
                          left: (i % cols) * pw,
                          top: (i ~/ cols) * ph,
                          width: pw,
                          height: ph,
                          child: DragTarget<int>(
                            onWillAcceptWithDetails: (d) => !placed[i],
                            onAcceptWithDetails: (d) => _drop(i, d.data),
                            builder: (context, cand, rej) {
                              if (placed[i]) return _piece(i, pw, ph);
                              return Container(
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: cand.isNotEmpty
                                        ? Colors.blue
                                        : Colors.black12,
                                    width: cand.isNotEmpty ? 3 : 1,
                                  ),
                                ),
                                child: Opacity(
                                  opacity: 0.2,
                                  child: CustomPaint(
                                    painter: _PiecePainter(
                                        scene, cols, rows, i % cols, i ~/ cols),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),
                const Text('اسحب القطع وحطها مكانها',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  alignment: WrapAlignment.center,
                  children: [
                    for (final idx in tray)
                      if (!placed[idx])
                        Draggable<int>(
                          data: idx,
                          feedback: Material(
                              color: Colors.transparent, child: _piece(idx, pw, ph)),
                          childWhenDragging:
                              Opacity(opacity: 0.25, child: _piece(idx, pw, ph)),
                          onDragEnd: (d) {
                            if (!d.wasAccepted) Sfx.play('no');
                          },
                          child: _piece(idx, pw, ph),
                        ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
