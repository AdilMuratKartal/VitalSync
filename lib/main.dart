import 'package:flutter/material.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'presentation/widgets/dentora_logo.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const DentoraApp());
}

class DentoraApp extends StatelessWidget {
  const DentoraApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Dentora Clinical Mobile',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      routerConfig: AppRouter.router,
      builder: (context, child) {
        return MobileViewportFrame(
          child: child ?? const SizedBox.shrink(),
        );
      },
    );
  }
}
