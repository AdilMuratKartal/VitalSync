import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'core/di/service_locator.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'firebase_options.dart';
import 'presentation/cubits/appointment/appointment_cubit.dart';
import 'presentation/cubits/auth/auth_cubit.dart';
import 'presentation/cubits/chat/chat_cubit.dart';
import 'presentation/cubits/doctor_schedule/doctor_schedule_cubit.dart';
import 'presentation/cubits/medical_records/medical_records_cubit.dart';
import 'presentation/cubits/vital/vital_cubit.dart';
import 'presentation/widgets/dentora_logo.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Firebase servislerini mevcut platform yapılandırmasıyla başlatır.
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  ServiceLocator.setup();
  runApp(const DentoraApp());
}

class DentoraApp extends StatelessWidget {
  const DentoraApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthCubit>(
          create: (_) => AuthCubit()..checkSession(),
        ),
        BlocProvider<AppointmentCubit>(
          create: (_) => AppointmentCubit(),
        ),
        BlocProvider<DoctorScheduleCubit>(
          create: (_) => DoctorScheduleCubit(),
        ),
        BlocProvider<MedicalRecordsCubit>(
          create: (_) => MedicalRecordsCubit(),
        ),
        BlocProvider<VitalCubit>(
          create: (_) => VitalCubit(),
        ),
        BlocProvider<ChatCubit>(
          create: (_) => ChatCubit(),
        ),
      ],
      child: ValueListenableBuilder<ThemeMode>(
        valueListenable: AppTheme.themeModeNotifier,
        builder: (context, currentMode, _) {
          return MaterialApp.router(
            title: 'Dentora Clinical Mobile',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: currentMode,
            routerConfig: AppRouter.router,
            builder: (context, child) {
              return MobileViewportFrame(
                child: child ?? const SizedBox.shrink(),
              );
            },
          );
        },
      ),
    );
  }
}
