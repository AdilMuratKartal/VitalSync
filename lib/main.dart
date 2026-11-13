import 'dart:ui';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'core/di/service_locator.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'firebase_options.dart';
import 'presentation/widgets/dentora_logo.dart';

/// Yatay kaydırma, fare ve dokunmatik etkileşimlerinin masaüstü/web ve mobilde
/// kusursuz çalışmasını sağlayan global scroll davranışı.
class AppScrollBehavior extends MaterialScrollBehavior {
  const AppScrollBehavior();

  @override
  Set<PointerDeviceKind> get dragDevices => {
    PointerDeviceKind.touch,
    PointerDeviceKind.mouse,
    PointerDeviceKind.trackpad,
    PointerDeviceKind.stylus,
  };
}

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
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: AppTheme.themeModeNotifier,
      builder: (context, currentMode, _) {
        return MaterialApp.router(
          title: 'Dentora Clinical Mobile',
          debugShowCheckedModeBanner: false,
          scrollBehavior: const AppScrollBehavior(),
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
    );
  }
}
