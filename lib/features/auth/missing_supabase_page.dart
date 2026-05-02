import 'package:flutter/material.dart';

import '../../app/app_localizations.dart';

class MissingSupabasePage extends StatelessWidget {
  const MissingSupabasePage({super.key});

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 640),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    t.isHebrew
                        ? 'נדרשת הגדרת Supabase'
                        : 'Supabase Setup Needed',
                    style: TextStyle(fontSize: 30, fontWeight: FontWeight.w900),
                  ),
                  SizedBox(height: 12),
                  Text(
                    t.isHebrew
                        ? 'הרץ את האפליקציה עם מפתחות Supabase כדי שהתחברות וסנכרון יעבדו באנדרואיד ובווב.'
                        : 'Run the app with your Supabase keys so login and syncing work on Android and Web.',
                    style: TextStyle(fontSize: 16),
                  ),
                  SizedBox(height: 20),
                  const SelectableText(
                    'flutter run --dart-define=SUPABASE_URL=https://YOUR_PROJECT.supabase.co --dart-define=SUPABASE_ANON_KEY=YOUR_KEY',
                  ),
                  SizedBox(height: 12),
                  Text(
                    t.isHebrew
                        ? 'גם להרצת ווב או בניית ווב השתמש באותם שני ערכי --dart-define.'
                        : 'For web build or web run, use the same two --dart-define values.',
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
