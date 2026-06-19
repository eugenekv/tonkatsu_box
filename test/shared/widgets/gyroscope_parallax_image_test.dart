import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:tonkatsu_box/shared/widgets/gyroscope_parallax_image.dart';

void main() {
  group('GyroscopeParallaxImage', () {
    Widget buildWidget(Stream<GyroscopeEvent> stream) {
      return Directionality(
        textDirection: TextDirection.ltr,
        child: GyroscopeParallaxImage(
          imageUrl: 'https://example.com/poster.jpg',
          gyroscopeStream: stream,
          errorWidget: (BuildContext context, String url, Object error) =>
              const SizedBox.shrink(),
        ),
      );
    }

    testWidgets(
      'swallows a gyroscope stream error (device without sensor) and '
      'cancels the subscription',
      (WidgetTester tester) async {
        final StreamController<GyroscopeEvent> controller =
            StreamController<GyroscopeEvent>();
        addTearDown(controller.close);

        await tester.pumpWidget(buildWidget(controller.stream));
        expect(controller.hasListener, isTrue);

        // A device without a gyroscope: sensors_plus throws a PlatformException.
        controller.addError(
          PlatformException(
            code: 'NO_SENSOR',
            message: 'Sensor not found',
            details: 'It seems that your device has no Gyroscope sensor',
          ),
        );
        await tester.pump();

        // The error is swallowed, the widget stays in the tree, and the sensor
        // subscription is cancelled (no leak / repeated errors).
        expect(tester.takeException(), isNull);
        expect(controller.hasListener, isFalse);
        expect(find.byType(GyroscopeParallaxImage), findsOneWidget);
      },
    );

    testWidgets('cancels the gyroscope subscription on dispose',
        (WidgetTester tester) async {
      final StreamController<GyroscopeEvent> controller =
          StreamController<GyroscopeEvent>();
      addTearDown(controller.close);

      await tester.pumpWidget(buildWidget(controller.stream));
      expect(controller.hasListener, isTrue);

      await tester.pumpWidget(const SizedBox.shrink());
      expect(controller.hasListener, isFalse);
    });
  });
}
