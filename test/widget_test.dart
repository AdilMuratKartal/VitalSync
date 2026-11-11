import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vitalsync/core/router/app_router.dart';
import 'package:vitalsync/main.dart';
import 'package:vitalsync/presentation/widgets/dentora_logo.dart';

void main() {
  setUpAll(() async {
    final plusJakarta = File('assets/fonts/PlusJakartaSans-Regular.ttf');
    final inter = File('assets/fonts/Inter-Regular.ttf');
    if (plusJakarta.existsSync()) {
      final bytes = await plusJakarta.readAsBytes();
      final loader = FontLoader('Plus Jakarta Sans')
        ..addFont(Future.value(ByteData.view(bytes.buffer)));
      await loader.load();
    }
    if (inter.existsSync()) {
      final bytes = await inter.readAsBytes();
      final loader = FontLoader('Inter')
        ..addFont(Future.value(ByteData.view(bytes.buffer)));
      await loader.load();
    }
  });
  testWidgets('Dentora splash -> login -> all patient & doctor screens render without overflow',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const DentoraApp());
    await tester.pump(const Duration(milliseconds: 500));

    // Splash screen has only the giant DentoraLogo
    expect(find.byType(DentoraLogo), findsOneWidget);

    // Advance past 2.7s splash timer -> navigates to /login
    await tester.pump(const Duration(milliseconds: 2500));
    await tester.pumpAndSettle();

    expect(find.text('Dentora'), findsOneWidget);
    expect(find.text('Hasta Girişi'), findsOneWidget);
    expect(find.text('Doktor Girişi'), findsOneWidget);

    // Test every route on 390x844 mobile viewport to ensure zero RenderFlex overflow
    final routesToVerify = [
      '/register',
      '/forgot-password',
      '/patient/home',
      '/patient/book',
      '/patient/book-calendar',
      '/patient/appointments',
      '/patient/results',
      '/patient/vitals',
      '/patient/chat',
      '/patient/profile',
      '/doctor/agenda',
      '/doctor/prescription',
      '/doctor/past-patients',
      '/doctor/schedule-pricing',
      '/doctor/messages',
    ];

    final errors = <String>[];
    for (final route in routesToVerify) {
      AppRouter.router.go(route);
      await tester.pumpAndSettle();
      dynamic err = tester.takeException();
      while (err != null) {
        final detail = err is FlutterError ? err.toStringDeep() : err.toString();
        errors.add('$route -> $detail');
        err = tester.takeException();
      }
    }
    expect(errors, isEmpty, reason: errors.join('\n\n'));
  });
}
