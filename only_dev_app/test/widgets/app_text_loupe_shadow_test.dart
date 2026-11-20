import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:only_dev_app/widgets/textfield/app_text_loupe.dart';

void main() {
  testWidgets('loupe shadow never tints the magnified content', (tester) async {
    final key = GlobalKey();
    await tester.pumpWidget(Directionality(
      textDirection: TextDirection.ltr,
      child: Center(
        child: RepaintBoundary(
          key: key,
          child: Container(
            width: 300,
            height: 200,
            color: Colors.white,
            child: Stack(children: [
              Positioned(
                  left: 90,
                  top: 58,
                  width: 115,
                  height: 84,
                  child: Stack(clipBehavior: Clip.none, children: [
                    const RawMagnifier(
                      size: Size(115, 84),
                      magnificationScale: 1.25,
                      decoration: MagnifierDecoration(
                        shape: StadiumBorder(
                            side: BorderSide(color: Colors.green, width: 2)),
                      ),
                    ),
                    Positioned.fill(
                        child: CustomPaint(
                            painter: LoupeOuterShadowPainter(opacity: 1))),
                  ])),
            ]),
          ),
        ),
      ),
    ));
    await tester.runAsync(() async {
      final b = key.currentContext!.findRenderObject() as RenderRepaintBoundary;
      final img = await b.toImage();
      final data = (await img.toByteData(format: ui.ImageByteFormat.rawRgba))!;
      List<int> at(int x, int y) {
        final i = (y * img.width + x) * 4;
        return [data.getUint8(i), data.getUint8(i + 1), data.getUint8(i + 2)];
      }

      // The lens shows the white field unchanged (the old RawMagnifier
      // shadow tinted it to 224 = 12% black).
      expect(at(147, 100), [255, 255, 255]);
      // The drop shadow is still there, just outside the lens.
      expect(at(147, 146)[0], lessThan(250));
      expect(at(10, 10), [255, 255, 255]);
    });
  });
}
