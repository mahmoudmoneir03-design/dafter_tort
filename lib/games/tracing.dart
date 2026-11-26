import 'dart:math';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../core.dart';
import '../data.dart';

const int _n = 120; // دقة قناع الحرف
const double _brush = 7.0; // نصف قطر الفرشاة بالنسبة للقناع

TextPainter _tp(String s, double size) => TextPainter(
      text: TextSpan(
        text: s,
        style: TextStyle(
            fontSize: size * 0.8, fontWeight: FontWeight.w700, color: Colors.black),
      ),
      textDirection: TextDirection.rtl,
    )..layout();

class _TracePainter extends CustomPainter {
  final String ch;
  final List<List<Offset>> strokes;
  _TracePainter(this.ch, this.strokes);

  @override
  void paint(Canvas canvas, Size size) {
    final tp = TextPainter(
      text: TextSpan(
        text: ch,
        style: TextStyle(
            fontSize: size.width * 0.8,
            fontWeight: FontWeight.w700,
            color: Colors.black.withValues(alpha: 0.13)),
      ),
      textDirection: TextDirection.rtl,
    )..layout();
    tp.paint(canvas,
        Offset((size.width - tp.width) / 2, (size.height - tp.height) / 2));
    final brush = Paint()
      ..color = const Color(0xFF6C4CE0)
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..strokeWidth = size.width * (_brush * 2 / _n);
    final dot = Paint()..color = const Color(0xFF6C4CE0);
    for (final s in strokes) {
      if (s.length == 1) {
        canvas.drawCircle(s.first, size.width * (_brush / _n), dot);
      } else {
        final path = Path()..moveTo(s.first.dx, s.first.dy);
        for (var i = 1; i < s.length; i++) {
          path.lineTo(s[i].dx, s[i].dy);
        }
        canvas.drawPath(path, brush);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _TracePainter old) => true;
}

class TracingPage extends StatefulWidget {
  const TracingPage({super.key});

  @override
  State<TracingPage> createState() => _TracingPageState();
}

class _TracingPageState extends State<TracingPage> {
  static const cats = [arLetters, enLetters, numbers];
  static const catNames = ['حروف عربي', 'ABC', 'أرقام'];

  int cat = 0;
  int idx = 0;
  double side = 300;
  final List<List<Offset>> strokes = [];
  Uint8List? mask;
  int maskTotal = 0;
  List<bool> covered = List<bool>.filled(_n * _n, false);
  int coveredCount = 0, pts = 0, inside = 0;
  bool busy = false;

  String get ch => cats[cat][idx];

  @override
  void initState() {
    super.initState();
    _loadMask();
  }

  void _clear() {
    strokes.clear();
    covered = List<bool>.filled(_n * _n, false);
    coveredCount = 0;
    pts = 0;
    inside = 0;
  }

  Future<void> _loadMask() async {
    final id = ch;
    mask = null;
    final rec = ui.PictureRecorder();
    final c = Canvas(rec);
    final tp = _tp(id, _n.toDouble());
    tp.paint(c, Offset((_n - tp.width) / 2, (_n - tp.height) / 2));
    final img = await rec.endRecording().toImage(_n, _n);
    final bd = await img.toByteData(format: ui.ImageByteFormat.rawRgba);
    if (bd == null || !mounted || id != ch) return;
    final m = Uint8List(_n * _n);
    var t = 0;
    for (var i = 0; i < _n * _n; i++) {
      if (bd.getUint8(i * 4 + 3) > 100) {
        m[i] = 1;
        t++;
      }
    }
    setState(() {
      mask = m;
      maskTotal = t;
    });
  }

  void _mark(Offset p) {
    final m = mask;
    if (m == null) return;
    final mx = (p.dx / side * _n);
    final my = (p.dy / side * _n);
    pts++;
    final ix = mx.round(), iy = my.round();
    if (ix >= 0 && iy >= 0 && ix < _n && iy < _n && m[iy * _n + ix] == 1) {
      inside++;
    }
    final r = _brush.ceil();
    for (var y = iy - r; y <= iy + r; y++) {
      for (var x = ix - r; x <= ix + r; x++) {
        if (x < 0 || y < 0 || x >= _n || y >= _n) continue;
        final dx = x - mx, dy = y - my;
        if (dx * dx + dy * dy > _brush * _brush) continue;
        final k = y * _n + x;
        if (m[k] == 1 && !covered[k]) {
          covered[k] = true;
          coveredCount++;
        }
      }
    }
  }

  Future<void> _check() async {
    if (busy || maskTotal == 0 || pts == 0) return;
    final cover = coveredCount / maskTotal;
    final precision = inside / pts;
    if (cover >= 0.6 && precision >= 0.45) {
      busy = true;
      await celebrate(context, msg: 'كتبت "$ch" حلو! برافو');
      if (!mounted) return;
      busy = false;
      setState(() {
        idx = (idx + 1) % cats[cat].length;
        _clear();
      });
      _loadMask();
    }
  }

  @override
  Widget build(BuildContext context) {
    final letters = cats[cat];
    return GameScaffold(
      title: 'كتابة ✏️',
      color: const Color(0xFF51CF66),
      body: LayoutBuilder(
        builder: (context, box) {
          // الشاشة ثابتة (من غير سكرول) عشان الرسم بالصباع ما يتعارضش مع التمرير.
          side = max(160.0, min(box.maxWidth - 32, min(400.0, box.maxHeight - 250)));
          return Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Wrap(
                  spacing: 8,
                  children: [
                    for (var i = 0; i < 3; i++)
                      ChoiceChip(
                        label: Text(catNames[i], style: const TextStyle(fontSize: 17)),
                        selected: cat == i,
                        onSelected: (_) {
                          setState(() {
                            cat = i;
                            idx = 0;
                            _clear();
                          });
                          _loadMask();
                        },
                      ),
                  ],
                ),
                const SizedBox(height: 8),
                SizedBox(
                  height: 54,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: letters.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 6),
                    itemBuilder: (context, i) => GestureDetector(
                      onTap: () {
                        Sfx.play('tap');
                        setState(() {
                          idx = i;
                          _clear();
                        });
                        _loadMask();
                      },
                      child: Container(
                        width: 48,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: i == idx ? const Color(0xFF51CF66) : Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.black26),
                        ),
                        child: Text(letters[i],
                            style: TextStyle(
                                fontSize: 26,
                                fontWeight: FontWeight.w700,
                                color: i == idx ? Colors.white : Colors.black87)),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                const Text('امشي بصباعك على الحرف',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
                const SizedBox(height: 8),
                Container(
                  width: side,
                  height: side,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.black26, width: 2),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(18),
                    child: GestureDetector(
                      onPanStart: (d) {
                        setState(() {
                          strokes.add([d.localPosition]);
                          _mark(d.localPosition);
                        });
                      },
                      onPanUpdate: (d) {
                        setState(() {
                          strokes.last.add(d.localPosition);
                          _mark(d.localPosition);
                        });
                      },
                      onPanEnd: (_) => _check(),
                      child: CustomPaint(
                        size: Size(side, side),
                        painter: _TracePainter(ch, strokes),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  onPressed: () => setState(_clear),
                  icon: const Icon(Icons.refresh),
                  label: const Text('امسح وجرّب تاني', style: TextStyle(fontSize: 16)),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
