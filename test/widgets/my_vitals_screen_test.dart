import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vitalsync/core/di/service_locator.dart';
import 'package:vitalsync/data/models/vital_model.dart';
import 'package:vitalsync/data/services/auth_service.dart';
import 'package:vitalsync/data/services/firestore_service.dart';
import 'package:vitalsync/data/services/storage_service.dart';
import 'package:vitalsync/presentation/cubits/auth/auth_cubit.dart';
import 'package:vitalsync/presentation/cubits/vital/vital_cubit.dart';
import 'package:vitalsync/presentation/screens/patient/my_vitals_screen.dart';

class _FakeAuthService extends AuthService {}

class _FakeFirestoreService extends FirestoreService {
  final List<VitalModel> mockVitals;

  _FakeFirestoreService({this.mockVitals = const []});

  @override
  Stream<List<Map<String, dynamic>>> streamVitalsByPatient(String patientId) {
    return Stream.value(mockVitals.map((v) => v.toJson()).toList());
  }
}

class _FakeStorageService extends StorageService {
  _FakeStorageService() : super(firestoreService: _FakeFirestoreService());
}

void main() {
  setUp(() {
    ServiceLocator.registerSingleton<AuthService>(_FakeAuthService());
    ServiceLocator.registerSingleton<FirestoreService>(_FakeFirestoreService());
    ServiceLocator.registerSingleton<StorageService>(_FakeStorageService());
  });

  Widget buildTestableVitalsScreen({List<VitalModel> vitals = const []}) {
    return MaterialApp(
      home: MultiBlocProvider(
        providers: [
          BlocProvider<AuthCubit>(
            create: (_) => AuthCubit(
              authService: ServiceLocator.get<AuthService>(),
              storageService: ServiceLocator.get<StorageService>(),
            ),
          ),
          BlocProvider<VitalCubit>(
            create: (_) => VitalCubit(
              firestoreService: _FakeFirestoreService(mockVitals: vitals),
            ),
          ),
        ],
        child: const MyVitalsScreen(),
      ),
    );
  }

  group('MyVitalsScreen Widget & Kritik Eşik Testleri', () {
    testWidgets('VitalSync ekranı ve Bento kartları başarıyla render edilir', (tester) async {
      await tester.pumpWidget(buildTestableVitalsScreen());
      await tester.pumpAndSettle();

      expect(find.text('Günlük Sağlık Verilerim'), findsOneWidget);
      expect(find.text('Tansiyon (KB)'), findsOneWidget);
      expect(find.text('Açlık Şekeri'), findsOneWidget);
      expect(find.text('Kalp Atışı (Nabız)'), findsOneWidget);
      expect(find.text('Hızlı Ölçüm Güncelle'), findsOneWidget);
    });

    testWidgets('Kritik vital eşiği aşıldığında uyarı bannerı görüntülenir', (tester) async {
      final criticalVital = VitalModel(
        id: 'vtl-crit',
        patientId: 'pat-123',
        systolic: 155, // Critical >= 140
        diastolic: 95,  // Critical >= 90
        bloodSugar: 210, // Critical >= 180
        pulse: 115,      // Critical > 110
        oxygen: 92,      // Critical < 94
        createdAt: DateTime.now(),
      );

      await tester.pumpWidget(buildTestableVitalsScreen(vitals: [criticalVital]));
      await tester.pumpAndSettle();

      expect(find.text('Kritik Değer Uyarısı'), findsOneWidget);
      expect(find.text('Yüksek'), findsWidgets);
    });
  });
}
