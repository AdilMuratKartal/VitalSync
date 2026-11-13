import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../presentation/screens/auth/forgot_password_screen.dart';
import '../../presentation/screens/auth/login_screen.dart';
import '../../presentation/screens/auth/register_screen.dart';
import '../../presentation/screens/doctor/create_prescription_screen.dart';
import '../../presentation/screens/doctor/doctor_agenda_screen.dart';
import '../../presentation/screens/doctor/doctor_messages_screen.dart';
import '../../presentation/screens/doctor/doctor_shell_screen.dart';
import '../../presentation/screens/doctor/past_patients_screen.dart';
import '../../presentation/screens/doctor/schedule_pricing_screen.dart';
import '../../presentation/screens/patient/appointment_detail_screen.dart';
import '../../presentation/screens/patient/book_appointment_calendar_screen.dart';
import '../../presentation/screens/patient/book_appointment_screen.dart';
import '../../presentation/screens/patient/my_appointments_screen.dart';
import '../../presentation/screens/patient/my_results_screen.dart';
import '../../presentation/screens/patient/my_vitals_screen.dart';
import '../../presentation/screens/patient/patient_chat_screen.dart';
import '../../presentation/screens/patient/patient_home_screen.dart';
import '../../presentation/screens/patient/patient_shell_screen.dart';
import '../../presentation/screens/patient/profile_settings_screen.dart';
import '../../presentation/screens/splash/splash_screen.dart';
import '../../presentation/screens/welcome/welcome_screen.dart';

final GlobalKey<NavigatorState> rootNavigatorKey = GlobalKey<NavigatorState>();

class AppRouter {
  static final GoRouter router = GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: '/splash',
    routes: [
      GoRoute(
        path: '/splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/welcome',
        builder: (context, state) => const WelcomeScreen(),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: '/forgot-password',
        builder: (context, state) => const ForgotPasswordScreen(),
      ),
      GoRoute(
        path: '/patient/appointment-detail',
        builder: (context, state) {
          final appointmentId = state.uri.queryParameters['id'] ?? '';
          final initialData = state.extra is Map<String, dynamic>
              ? state.extra as Map<String, dynamic>
              : (state.extra is Map
                  ? Map<String, dynamic>.from(state.extra as Map)
                  : null);
          return AppointmentDetailScreen(
            appointmentId: appointmentId,
            initialData: initialData,
          );
        },
      ),

      // PATIENT PORTAL SHELL ROUTE (5 persistent bottom tabs + sub-routes)
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return PatientShellScreen(navigationShell: navigationShell);
        },
        branches: [
          // Branch 0: Ana Sayfa + Randevu Al + Takvim + Profilim
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/patient/home',
                builder: (context, state) => const PatientHomeScreen(),
              ),
              GoRoute(
                path: '/patient/book',
                builder: (context, state) => const BookAppointmentScreen(),
              ),
              GoRoute(
                path: '/patient/book-calendar',
                builder: (context, state) =>
                    const BookAppointmentCalendarScreen(),
              ),
              GoRoute(
                path: '/patient/profile',
                builder: (context, state) => const ProfileSettingsScreen(),
              ),
            ],
          ),
          // Branch 1: Randevularım
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/patient/appointments',
                builder: (context, state) => const MyAppointmentsScreen(),
              ),
            ],
          ),
          // Branch 2: Sonuçlarım & Reçetelerim
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/patient/results',
                builder: (context, state) {
                  var prescriptionId =
                      state.uri.queryParameters['prescriptionId'] ??
                      (state.extra is String ? state.extra as String : null);
                  if (prescriptionId != null &&
                      (prescriptionId.trim().isEmpty ||
                          prescriptionId.trim().toLowerCase() == 'null')) {
                    prescriptionId = null;
                  }
                  return MyResultsScreen(
                    initialPrescriptionId: prescriptionId,
                  );
                },
              ),
            ],
          ),
          // Branch 3: Verilerim (Vital Takip)
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/patient/vitals',
                builder: (context, state) => const MyVitalsScreen(),
              ),
            ],
          ),
          // Branch 4: Doktor ile Mesajlaşma
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/patient/chat',
                builder: (context, state) => const PatientChatScreen(),
              ),
            ],
          ),
        ],
      ),

      // DOCTOR PORTAL SHELL ROUTE (5 persistent bottom tabs)
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return DoctorShellScreen(navigationShell: navigationShell);
        },
        branches: [
          // Branch 0: Doktor Ajandası (Bugünkü Hastalar)
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/doctor/agenda',
                builder: (context, state) => const DoctorAgendaScreen(),
              ),
            ],
          ),
          // Branch 1: Reçete Oluştur
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/doctor/prescription',
                builder: (context, state) => const CreatePrescriptionScreen(),
              ),
            ],
          ),
          // Branch 2: Geçmiş Hastalar
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/doctor/past-patients',
                builder: (context, state) => const PastPatientsScreen(),
              ),
            ],
          ),
          // Branch 3: Program & Fiyat Belirleme
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/doctor/schedule-pricing',
                builder: (context, state) => const SchedulePricingScreen(),
              ),
            ],
          ),
          // Branch 4: Doktor Mesajları
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/doctor/messages',
                builder: (context, state) => const DoctorMessagesScreen(),
              ),
            ],
          ),
        ],
      ),
    ],
  );
}

