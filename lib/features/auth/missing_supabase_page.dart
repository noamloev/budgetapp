import 'package:flutter/material.dart';

class MissingSupabasePage extends StatelessWidget {
  const MissingSupabasePage({super.key});

  @override
  Widget build(BuildContext context) {
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
                children: const [
                  Text(
                    'Supabase Setup Needed',
                    style: TextStyle(fontSize: 30, fontWeight: FontWeight.w900),
                  ),
                  SizedBox(height: 12),
                  Text(
                    'Run the app with your Supabase keys so login and syncing work on Android and Web.',
                    style: TextStyle(fontSize: 16),
                  ),
                  SizedBox(height: 20),
                  SelectableText(
                    'flutter run --dart-define=SUPABASE_URL=https://YOUR_PROJECT.supabase.co --dart-define=SUPABASE_ANON_KEY=YOUR_KEY',
                  ),
                  SizedBox(height: 12),
                  Text(
                    'For web build or web run, use the same two --dart-define values.',
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
