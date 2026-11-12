import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:vitalsync/core/widgets/dentora_state_view.dart';

void main() {
  Widget buildTestableWidget(Widget child) {
    return MaterialApp(
      home: Scaffold(
        body: child,
      ),
    );
  }

  group('DentoraStateView - Dört Durum Widget Testleri', () {
    testWidgets('Loading durumunda CircularProgressIndicator görüntülenir', (tester) async {
      await tester.pumpWidget(
        buildTestableWidget(
          const DentoraStateView(
            icon: Symbols.schedule,
            title: 'Veriler Yükleniyor...',
            isLoading: true,
          ),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('Veriler Yükleniyor...'), findsOneWidget);
    });

    testWidgets('Error durumunda hata başlığı, alt başlık ve tekrar dene butonu çalışır', (tester) async {
      bool retryPressed = false;

      await tester.pumpWidget(
        buildTestableWidget(
          DentoraStateView(
            icon: Symbols.error,
            title: 'Bağlantı Hatası',
            subtitle: 'Sunucuya erişilemedi. Lütfen tekrar deneyin.',
            onRetry: () {
              retryPressed = true;
            },
          ),
        ),
      );

      expect(find.text('Bağlantı Hatası'), findsOneWidget);
      expect(find.text('Sunucuya erişilemedi. Lütfen tekrar deneyin.'), findsOneWidget);
      expect(find.byType(TextButton), findsOneWidget);

      await tester.tap(find.byType(TextButton));
      await tester.pump();

      expect(retryPressed, isTrue);
    });

    testWidgets('Empty durumunda özel ikon ve açıklayıcı metin gösterilir', (tester) async {
      await tester.pumpWidget(
        buildTestableWidget(
          const DentoraStateView(
            icon: Symbols.event_busy,
            title: 'Randevunuz Bulunmuyor',
            subtitle: 'Yeni bir randevu planlamak için butona dokunun.',
          ),
        ),
      );

      expect(find.text('Randevunuz Bulunmuyor'), findsOneWidget);
      expect(find.text('Yeni bir randevu planlamak için butona dokunun.'), findsOneWidget);
      expect(find.byIcon(Symbols.event_busy), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsNothing);
    });
  });
}

