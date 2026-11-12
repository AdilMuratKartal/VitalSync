import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vitalsync/core/di/service_locator.dart';
import 'package:vitalsync/data/services/auth_service.dart';
import 'package:vitalsync/data/services/firestore_service.dart';
import 'package:vitalsync/presentation/cubits/auth/auth_cubit.dart';
import 'package:vitalsync/presentation/screens/auth/login_screen.dart';

class _FakeAuthService extends AuthService {}

class _FakeFirestoreService extends FirestoreService {}

void main() {
  setUp(() {
    ServiceLocator.registerSingleton<AuthService>(_FakeAuthService());
    ServiceLocator.registerSingleton<FirestoreService>(_FakeFirestoreService());
  });

  Widget buildTestableLoginScreen() {
    return MaterialApp(
      home: BlocProvider<AuthCubit>(
        create: (_) => AuthCubit(authService: ServiceLocator.get<AuthService>()),
        child: const LoginScreen(),
      ),
    );
  }

  group('LoginScreen Widget & Form Validation Testleri', () {
    testWidgets('Giriş ekranı bileşenleri doğru şekilde render edilir', (tester) async {
      await tester.pumpWidget(buildTestableLoginScreen());
      await tester.pumpAndSettle();

      expect(find.text('Dentora'), findsOneWidget);
      expect(find.text('Giriş Yap'), findsWidgets);
      expect(find.text('Hızlı Demo (Hasta)'), findsOneWidget);
      expect(find.text('Kayıt Ol'), findsOneWidget);
      expect(find.byType(TextFormField), findsNWidgets(2)); // TC and Password
    });

    testWidgets('Boş form gönderildiğinde validasyon uyarıları tetiklenir', (tester) async {
      await tester.pumpWidget(buildTestableLoginScreen());
      await tester.pumpAndSettle();

      // Find CTA button "Giriş Yap"
      final submitBtn = find.widgetWithText(ElevatedButton, 'Giriş Yap');
      expect(submitBtn, findsOneWidget);

      await tester.tap(submitBtn);
      await tester.pumpAndSettle();

      // Should show validation error for empty fields
      expect(find.text('TC Kimlik / Sicil numarası zorunludur.'), findsOneWidget);
      expect(find.text('Şifre alanı boş bırakılamaz.'), findsOneWidget);
    });

    testWidgets('Geçersiz TC girildiğinde hata gösterilir', (tester) async {
      await tester.pumpWidget(buildTestableLoginScreen());
      await tester.pumpAndSettle();

      final textFields = find.byType(TextFormField);
      await tester.enterText(textFields.at(0), '12345');
      await tester.enterText(textFields.at(1), 'kisa');

      final submitBtn = find.widgetWithText(ElevatedButton, 'Giriş Yap');
      await tester.tap(submitBtn);
      await tester.pumpAndSettle();

      expect(
        find.text('Lütfen 11 haneli geçerli bir numara giriniz.'),
        findsOneWidget,
      );
    });

    testWidgets('Hasta / Doktor rol sekmeleri arasında geçiş yapılabilir', (tester) async {
      await tester.pumpWidget(buildTestableLoginScreen());
      await tester.pumpAndSettle();

      final doctorTab = find.text('Doktor');
      expect(doctorTab, findsOneWidget);

      await tester.tap(doctorTab);
      await tester.pumpAndSettle();

      expect(find.text('Doktor'), findsOneWidget);
      expect(find.text('Hasta'), findsOneWidget);
    });
  });
}
