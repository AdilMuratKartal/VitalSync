import 'package:flutter/material.dart';
import 'core/di/service_locator.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'presentation/widgets/dentora_logo.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
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
