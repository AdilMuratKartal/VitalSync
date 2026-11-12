/// Uygulama genelinde kullanılan sabit değerler, rota yolları ve Firestore koleksiyon adları.
class AppConstants {
  AppConstants._();

  // Uygulama Bilgileri
  static const String appName = 'Dentora';
  static const String appSubtitle = 'Ağız ve Diş Sağlığı Kliniği';
  static const String appVersion = '2.4.0';

  // Firestore Koleksiyon İsimleri (Geliştirici 3 ve 4 için ortak standart)
  static const String usersCollection = 'users';
  static const String appointmentsCollection = 'appointments';
  static const String vitalsCollection = 'vitals';
  static const String prescriptionsCollection = 'prescriptions';
  static const String messagesCollection = 'messages';
  static const String resultsCollection = 'results';
  static const String doctorSchedulesCollection = 'doctor_schedules';

  // Kullanıcı Rolleri
  static const String rolePatient = 'patient';
  static const String roleDoctor = 'doctor';

  // Hızlı Demo Hesap Bilgileri
  static const String demoPatientTc = '34891204829';
  static const String demoPatientName = 'Ahmet Arslan';
  static const String demoDoctorTc = '10948271650';
  static const String demoDoctorName = 'Dr. Selin Yılmaz';
  static const String demoPassword = 'Dentora2026!';

  // GoRouter Rota Sabitleri
  static const String routeSplash = '/splash';
  static const String routeWelcome = '/welcome';
  static const String routeLogin = '/login';
  static const String routeRegister = '/register';
  static const String routeForgotPassword = '/forgot-password';

  // Hasta Portalı Rotaları
  static const String routePatientHome = '/patient/home';
  static const String routePatientBook = '/patient/book';
  static const String routePatientBookCalendar = '/patient/book-calendar';
  static const String routePatientAppointments = '/patient/appointments';
  static const String routePatientResults = '/patient/results';
  static const String routePatientVitals = '/patient/vitals';
  static const String routePatientChat = '/patient/chat';
  static const String routePatientProfile = '/patient/profile';

  // Doktor Portalı Rotaları
  static const String routeDoctorAgenda = '/doctor/agenda';
  static const String routeDoctorPrescription = '/doctor/prescription';
  static const String routeDoctorPastPatients = '/doctor/past-patients';
  static const String routeDoctorSchedulePricing = '/doctor/schedule-pricing';
  static const String routeDoctorMessages = '/doctor/messages';
}

