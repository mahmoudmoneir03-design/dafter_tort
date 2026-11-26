import 'dart:math';

import 'package:flutter/material.dart';

import '../core.dart';

class _Region {
  final Path Function(Size) build;
  const _Region(this.build);
}

class _Pic {
  final String name;
  final List<_Region> regions;
  const _Pic(this.name, this.regions);
}

Path _oval(Size s, double cx, double cy, double rx, double ry) => Path()
  ..addOval(Rect.fromCenter(
      center: Offset(cx * s.width, cy * s.height),
      width: rx * 2 * s.width,
      height: ry * 2 * s.height));

Path _rect(Size s, double l, double t, double r, double b) => Path()
  ..addRect(Rect.fromLTRB(l * s.width, t * s.height, r * s.width, b * s.height));

Path _poly(Size s, List<double> pts) {
  final p = Path()..moveTo(pts[0] * s.width, pts[1] * s.height);
  for (var i = 2; i < pts.length; i += 2) {
    p.lineTo(pts[i] * s.width, pts[i + 1] * s.height);
  }
  return p..close();
}

final List<_Pic> _pics = [
  _Pic('وردة', [
    _Region((s) => _rect(s, .47, .45, .53, .88)),
    _Region((s) => _poly(s, [.5, .7, .3, .58, .36, .74])),
    _Region((s) => _poly(s, [.5, .76, .7, .64, .64, .8])),
    _Region((s) => _poly(s, [.36, .86, .64, .86, .6, .98, .4, .98])),
    for (var k = 0; k < 6; k++)
      _Region((s) => _oval(s, .5 + .19 * cos(k * pi / 3), .3 + .19 * sin(k * pi / 3), .11, .11)),
    _Region((s) => _oval(s, .5, .3, .09, .09)),
  ]),
  _Pic('سمكة', [
    _Region((s) => _rect(s, 0, 0, 1, 1)),
    _Region((s) => _poly(s, [.7, .5, .92, .3, .92, .7])),
    _Region((s) => _poly(s, [.38, .34, .5, .16, .6, .36])),
    _Region((s) => _oval(s, .45, .5, .28, .2)),
    _Region((s) => _oval(s, .3, .45, .04, .04)),
    _Region((s) => _oval(s, .15, .22, .05, .05)),
    _Region((s) => _oval(s, .22, .12, .03, .03)),
    _Region((s) => _oval(s, .12, .1, .02, .02)),
  ]),
  _Pic('بيت', [
    _Region((s) => _rect(s, 0, 0, 1, 1)),
    _Region((s) => _oval(s, .85, .15, .09, .09)),
    _Region((s) => _rect(s, 0, .85, 1, 1)),
    _Region((s) => _rect(s, .66, .16, .75, .4)),
    _Region((s) => _rect(s, .2, .42, .8, .85)),
    _Region((s) => _poly(s, [.12, .44, .5, .12, .88, .44])),
    _Region((s) => _rect(s, .44, .6, .56, .85)),
    _Region((s) => _rect(s, .26, .5, .38, .62)),
    _Region((s) => _rect(s, .62, .5, .74, .62)),
  ]),
  _Pic('فراشة', [
    _Region((s) => _oval(s, .3, .35, .2, .17)),
    _Region((s) => _oval(s, .7, .35, .2, .17)),
    _Region((s) => _oval(s, .34, .64, .14, .13)),
    _Region((s) => _oval(s, .66, .64, .14, .13)),
    _Region((s) => _oval(s, .5, .5, .045, .22)),
    _Region((s) => _oval(s, .5, .27, .055, .055)),
    _Region((s) => _oval(s, .3, .35, .06, .05)),
    _Region((s) => _oval(s, .7, .35, .06, .05)),
  ]),
];

const List<Color> _palette = [
  Color(0xFFE63946),
  Color(0xFFFF922B),
  Color(0xFFFFD43B),
  Color(0xFF51CF66),
  Color(0xFF20C997),
  Color(0xFF339AF0),
  Color(0xFF845EF4),
  Color(0xFFF06595),
  Color(0xFF8D6E63),
  Color(0xFF212529),
  Colors.white,
];

class _PicPainter extends CustomPainter {
  final _Pic pic;
  final List<Color> fills;
  _PicPainter(this.pic, this.fills);

  @override
  void paint(Canvas canvas, Size size) {
    final fill = Paint()..style = PaintingStyle.fill;
    final line = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeJoin = StrokeJoin.round
      ..color = Colors.black87;
    for (var i = 0; i < pic.regions.length; i++) {
      final path = pic.regions[i].build(size);
      fill.color = fills[i];
      canvas.drawPath(path, fill);
      canvas.drawPath(path, line);
    }
  }

  @override
  bool shouldRepaint(covariant _PicPainter old) => true;
}

class ColoringPage extends StatefulWidget {
  const ColoringPage({super.key});

  @override
  State<ColoringPage> createState() => _ColoringPageState();
}

class _ColoringPageState extends State<ColoringPage> {
  int pic = 0;
  Color selected = _palette[0];
  late List<Color> fills;

  @override
  void initState() {
    super.initState();
    _reset();
  }

  void _reset() {
    fills = List<Color>.filled(_pics[pic].regions.length, Colors.white);
  }

  Future<void> _tap(Offset pos, Size size) async {
    final regions = _pics[pic].regions;
    for (var i = regions.length - 1; i >= 0; i--) {
      if (regions[i].build(size).contains(pos)) {
        setState(() => fills[i] = selected);
        Sfx.play('pop');
        if (fills.every((c) => c != Colors.white)) {
          await Future<void>.delayed(const Duration(milliseconds: 300));
          if (!mounted) return;
          await celebrate(context, msg: 'تلوين حلو! برافو');
          if (!mounted) return;
          setState(() {
            pic = (pic + 1) % _pics.length;
            _reset();
          });
        }
        return;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return GameScaffold(
      title: 'تلوين 🎨',
      color: const Color(0xFFFFA94D),
      body: LayoutBuilder(
        builder: (context, box) {
          final side = min(box.maxWidth - 32, 420.0);
          final size = Size(side, side);
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Wrap(
                  spacing: 8,
                  children: [
                    for (var i = 0; i < _pics.length; i++)
                      ChoiceChip(
                        label: Text(_pics[i].name, style: const TextStyle(fontSize: 17)),
                        selected: pic == i,
                        onSelected: (_) => setState(() {
                          pic = i;
                          _reset();
                        }),
                      ),
                  ],
                ),
                const SizedBox(height: 10),
                Container(
                  width: side,
                  height: side,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: Colors.black26, width: 2),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: GestureDetector(
                      onTapDown: (d) => _tap(d.localPosition, size),
                      child: CustomPaint(
                        size: size,
                        painter: _PicPainter(_pics[pic], fills),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  alignment: WrapAlignment.center,
                  children: [
                    for (final c in _palette)
                      GestureDetector(
                        onTap: () {
                          Sfx.play('tap');
                          setState(() => selected = c);
                        },
                        child: Container(
                          width: 46,
                          height: 46,
                          decoration: BoxDecoration(
                            color: c,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: selected == c ? Colors.black : Colors.black26,
                              width: selected == c ? 4 : 1.5,
                            ),
                          ),
                          child: c == Colors.white
                              ? const Icon(Icons.cleaning_services, size: 22)
                              : null,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  onPressed: () => setState(_reset),
                  icon: const Icon(Icons.refresh),
                  label: const Text('امسح وابدأ من الأول', style: TextStyle(fontSize: 16)),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
