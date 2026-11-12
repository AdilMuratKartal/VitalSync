import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vitalsync/core/di/service_locator.dart';
import 'package:vitalsync/data/services/auth_service.dart';
import 'package:vitalsync/data/services/firestore_service.dart';
import 'package:vitalsync/data/services/storage_service.dart';
import 'package:vitalsync/presentation/cubits/appointment/appointment_cubit.dart';
import 'package:vitalsync/presentation/cubits/auth/auth_cubit.dart';
import 'package:vitalsync/presentation/screens/doctor/doctor_agenda_screen.dart';

class _FakeAuthService extends AuthService {}

class _FakeFirestoreService extends FirestoreService {
  @override
  Stream<List<Map<String, dynamic>>> streamAppointmentsByDoctor(String doctorId) {
    return Stream.value([
      {
        'id': 'apt-1',
        'patientId': 'pat-1',
        'patientName': 'Ahmet Arslan',
        'doctorId': doctorId,
        'doctorName': 'Dt. Selin Yılmaz',
        'serviceName': 'İmplant Kontrol',
        'date': '2026-03-18',
        'time': '11:15',
        'status': 'approved',
        'price': 1200,
      },
      {
        'id': 'apt-2',
        'patientId': 'pat-2',
        'patientName': 'Canan Demir',
        'doctorId': doctorId,
        'doctorName': 'Dt. Selin Yılmaz',
        'serviceName': 'Kanal Tedavisi',
        'date': '2026-03-18',
        'time': '14:30',
        'status': 'pending',
        'price': 2500,
      },
    ]);
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

  Widget buildTestableDoctorAgenda() {
    return MaterialApp(
      home: MultiBlocProvider(
        providers: [
          BlocProvider<AuthCubit>(
            create: (_) => AuthCubit(
              authService: ServiceLocator.get<AuthService>(),
              storageService: ServiceLocator.get<StorageService>(),
            ),
          ),
          BlocProvider<AppointmentCubit>(
            create: (_) => AppointmentCubit(
              firestoreService: ServiceLocator.get<FirestoreService>(),
            ),
          ),
        ],
        child: const DoctorAgendaScreen(),
      ),
    );
  }

  group('DoctorAgendaScreen Widget & Akış Testleri', () {
    testWidgets('Ajanda ekranı başlığı ve özet sayaçları başarıyla render edilir', (tester) async {
      await tester.pumpWidget(buildTestableDoctorAgenda());
      await tester.pumpAndSettle();

      expect(find.text('GÜNLÜK KLİNİK AJANDASI'), findsOneWidget);
      expect(find.text('Toplam'), findsOneWidget);
      expect(find.text('Tamamlandı'), findsWidgets);
      expect(find.text('Koltukta'), findsWidgets);
      expect(find.text('Bekleyen'), findsWidgets);
    });

    testWidgets('Filtre sekmeleri etkileşimlidir', (tester) async {
      await tester.pumpWidget(buildTestableDoctorAgenda());
      await tester.pumpAndSettle();

      final waitingFilter = find.textContaining('Bekleyenler');
      expect(waitingFilter, findsOneWidget);

      await tester.tap(waitingFilter);
      await tester.pumpAndSettle();

      expect(waitingFilter, findsOneWidget);
    });
  });
}
