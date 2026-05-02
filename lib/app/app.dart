import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../config/supabase_config.dart';
import '../features/auth/auth_page.dart';
import '../features/auth/missing_supabase_page.dart';
import '../features/home/home_page.dart';
import 'app_localizations.dart';
import 'theme.dart';

class BudgetApp extends StatefulWidget {
  const BudgetApp({super.key});

  @override
  State<BudgetApp> createState() => _BudgetAppState();
}

class _BudgetAppState extends State<BudgetApp> {
  final AppLocaleController localeController = AppLocaleController();

  @override
  void initState() {
    super.initState();
    localeController.load();
  }

  @override
  void dispose() {
    localeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppLocaleScope(
      notifier: localeController,
      child: AnimatedBuilder(
        animation: localeController,
        builder: (context, _) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'Budget Flow',
            theme: buildAppTheme(),
            locale: localeController.locale,
            supportedLocales: AppLocalizations.supportedLocales,
            localizationsDelegates: AppLocalizations.delegates,
            builder: (context, child) {
              final localizations = context.t;
              return Directionality(
                textDirection: localizations.textDirection,
                child: child ?? const SizedBox.shrink(),
              );
            },
            home: const AppRoot(),
          );
        },
      ),
    );
  }
}

class AppRoot extends StatelessWidget {
  const AppRoot({super.key});

  @override
  Widget build(BuildContext context) {
    if (!SupabaseConfig.isConfigured) {
      return const MissingSupabasePage();
    }

    return StreamBuilder<AuthState>(
      stream: Supabase.instance.client.auth.onAuthStateChange,
      builder: (context, snapshot) {
        final session =
            snapshot.data?.session ??
            Supabase.instance.client.auth.currentSession;
        if (session == null) {
          return const AuthPage();
        }
        return const HomePage();
      },
    );
  }
}
