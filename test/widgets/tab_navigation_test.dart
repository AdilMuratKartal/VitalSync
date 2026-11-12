import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vitalsync/core/di/service_locator.dart';
import 'package:vitalsync/core/router/app_router.dart';
import 'package:vitalsync/data/services/auth_service.dart';
import 'package:vitalsync/data/services/firestore_service.dart';
import 'package:vitalsync/data/services/storage_service.dart';
import 'package:vitalsync/presentation/cubits/appointment/appointment_cubit.dart';
import 'package:vitalsync/presentation/cubits/auth/auth_cubit.dart';
import 'package:vitalsync/presentation/cubits/chat/chat_cubit.dart';
import 'package:vitalsync/presentation/cubits/doctor_schedule/doctor_schedule_cubit.dart';
import 'package:vitalsync/presentation/cubits/medical_records/medical_records_cubit.dart';
import 'package:vitalsync/presentation/cubits/vital/vital_cubit.dart';

class _FakeAuthService extends AuthService {}

class _FakeFirestoreService extends FirestoreService {
  @override
  Stream<List<Map<String, dynamic>>> streamAppointmentsByPatient(String patientId) {
    return Stream.value([]);
  }

  @override
  Stream<List<Map<String, dynamic>>> streamAppointmentsByDoctor(String doctorId) {
    return Stream.value([]);
  }

  @override
  Stream<Map<String, dynamic>?> streamDoctorSchedule(String doctorId) {
    return Stream.value(null);
  }

  @override
  Stream<List<Map<String, dynamic>>> streamVitalsByPatient(String patientId) {
    return Stream.value([]);
  }

  @override
  Stream<List<Map<String, dynamic>>> streamResultsByPatient(String patientId) {
    return Stream.value([]);
  }

  @override
  Stream<List<Map<String, dynamic>>> streamPrescriptionsByPatient(String patientId) {
    return Stream.value([]);
  }

  @override
  Stream<List<Map<String, dynamic>>> streamMessagesByConversation(String conversationId) {
    return Stream.value([]);
  }
}

void main() {
  setUp(() {
    ServiceLocator.registerSingleton<AuthService>(_FakeAuthService());
    final firestore = _FakeFirestoreService();
    ServiceLocator.registerSingleton<FirestoreService>(firestore);
    ServiceLocator.registerSingleton<StorageService>(
      StorageService(firestoreService: firestore),
    );
  });

  Widget buildTestableApp() {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthCubit>(
          create: (_) => AuthCubit(
            authService: ServiceLocator.get<AuthService>(),
            firestoreService: ServiceLocator.get<FirestoreService>(),
            storageService: ServiceLocator.get<StorageService>(),
          ),
        ),
        BlocProvider<AppointmentCubit>(
          create: (_) => AppointmentCubit(
            firestoreService: ServiceLocator.get<FirestoreService>(),
          ),
        ),
        BlocProvider<DoctorScheduleCubit>(
          create: (_) => DoctorScheduleCubit(
            firestoreService: ServiceLocator.get<FirestoreService>(),
          ),
        ),
        BlocProvider<MedicalRecordsCubit>(
          create: (_) => MedicalRecordsCubit(
            firestoreService: ServiceLocator.get<FirestoreService>(),
            storageService: ServiceLocator.get<StorageService>(),
          ),
        ),
        BlocProvider<VitalCubit>(
          create: (_) => VitalCubit(
            firestoreService: ServiceLocator.get<FirestoreService>(),
          ),
        ),
        BlocProvider<ChatCubit>(
          create: (_) => ChatCubit(
            firestoreService: ServiceLocator.get<FirestoreService>(),
          ),
        ),
      ],
      child: MaterialApp.router(
        routerConfig: AppRouter.router,
      ),
    );
  }

  testWidgets(
    'Hasta sekmeleri arasında (Randevularım, Sonuçlarım, Verilerim, Mesajlaşma) geçiş yapıldığında Cubit hatası alınmaz',
    (tester) async {
      tester.view.physicalSize = const Size(800, 1400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(buildTestableApp());
      await tester.pumpAndSettle();

      // GoRouter başlangıçta /splash'te olabilir, doğrudan /patient/home'a git
      AppRouter.router.go('/patient/home');
      await tester.pumpAndSettle();

      // 1. Randevularım sekmesine tıkla
      final appointmentsTab = find.text('Randevularım');
      expect(appointmentsTab, findsWidgets);
      await tester.tap(appointmentsTab.first);
      await tester.pumpAndSettle();
      expect(find.text('Randevularım'), findsWidgets);

      // 2. Sonuçlarım sekmesine tıkla
      final resultsTab = find.text('Sonuçlarım');
      expect(resultsTab, findsWidgets);
      await tester.tap(resultsTab.first);
      await tester.pumpAndSettle();
      expect(find.text('Sonuçlarım'), findsWidgets);

      // 3. Verilerim sekmesine tıkla
      final vitalsTab = find.text('Verilerim');
      expect(vitalsTab, findsWidgets);
      await tester.tap(vitalsTab.first);
      await tester.pumpAndSettle();
      expect(find.text('Pre-Operatif Takip Aktif'), findsWidgets);

      // 4. Mesajlaşma sekmesine tıkla
      final chatTab = find.text('Mesajlaşma');
      expect(chatTab, findsWidgets);
      await tester.tap(chatTab.first);
      await tester.pumpAndSettle();
      expect(find.text('Mesajlaşma'), findsWidgets);

      // 5. Ana Sayfa sekmesine geri dön
      final homeTab = find.text('Ana Sayfa');
      expect(homeTab, findsWidgets);
      await tester.tap(homeTab.first);
      await tester.pumpAndSettle();

      // Tüm geçişler Provider<AuthCubit>, Provider<VitalCubit>, Provider<ChatCubit> vb.
      // hatası atmaksızın başarıyla tamamlandı.
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'Hekim sekmeleri arasında (Ajanda, Reçete Yaz, Geçmiş, Program, Mesajlar) geçiş yapıldığında Cubit hatası alınmaz',
    (tester) async {
      tester.view.physicalSize = const Size(800, 1400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(buildTestableApp());
      await tester.pumpAndSettle();

      // Doktor portalına git
      AppRouter.router.go('/doctor/agenda');
      await tester.pumpAndSettle();
      expect(find.text('Ajanda'), findsWidgets);

      // 1. Reçete Yaz sekmesine tıkla
      final prescriptionTab = find.text('Reçete Yaz');
      expect(prescriptionTab, findsWidgets);
      await tester.tap(prescriptionTab.first);
      await tester.pumpAndSettle();
      expect(find.text('Reçete Yaz'), findsWidgets);

      // 2. Geçmiş sekmesine tıkla
      final historyTab = find.text('Geçmiş');
      expect(historyTab, findsWidgets);
      await tester.tap(historyTab.first);
      await tester.pumpAndSettle();
      expect(find.text('Geçmiş'), findsWidgets);

      // 3. Program sekmesine tıkla
      final programTab = find.text('Program');
      expect(programTab, findsWidgets);
      await tester.tap(programTab.first);
      await tester.pumpAndSettle();
      expect(find.text('Program'), findsWidgets);

      // 4. Mesajlar sekmesine tıkla
      final messagesTab = find.text('Mesajlar');
      expect(messagesTab, findsWidgets);
      await tester.tap(messagesTab.first);
      await tester.pumpAndSettle();
      expect(find.text('Mesajlar'), findsWidgets);

      // 5. Ajanda sekmesine geri dön
      final agendaTab = find.text('Ajanda');
      expect(agendaTab, findsWidgets);
      await tester.tap(agendaTab.first);
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
    },
  );
}
