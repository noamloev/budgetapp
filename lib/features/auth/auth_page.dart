import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../features/shared/widgets/help_widgets.dart';

class AuthPage extends StatefulWidget {
  const AuthPage({super.key});

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  bool isLoading = false;
  bool isCreating = false;

  SupabaseClient get supabase => Supabase.instance.client;

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final email = emailController.text.trim();
    final password = passwordController.text;
    if (email.isEmpty || password.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Enter a valid email and a password with at least 6 characters.'),
        ),
      );
      return;
    }

    setState(() => isLoading = true);
    try {
      if (isCreating) {
        await supabase.auth.signUp(email: email, password: password);
      } else {
        await supabase.auth.signInWithPassword(email: email, password: password);
      }
    } on AuthException catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.message)),
      );
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 460),
            child: ListView(
              padding: const EdgeInsets.all(24),
              children: [
                Row(
                  children: const [
                    Expanded(
                      child: Text(
                        'Budget Flow',
                        style: TextStyle(fontSize: 30, fontWeight: FontWeight.w900),
                      ),
                    ),
                    HelpIconButton(
                      title: 'Login Help',
                      lines: [
                        'Use one shared email and password if both partners should access the same budget.',
                        'Create Account is for the first setup. Log In is for every later device.',
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF081B2E), Color(0xFF0F766E), Color(0xFFE76F51)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: const Text(
                    'One shared account for both phones and the website. Log in anywhere and edit the same budget together.',
                    style: TextStyle(color: Colors.white, fontSize: 16, height: 1.45),
                  ),
                ),
                const SizedBox(height: 24),
                SegmentedButton<bool>(
                  segments: const [
                    ButtonSegment<bool>(value: false, label: Text('Log In')),
                    ButtonSegment<bool>(value: true, label: Text('Register')),
                  ],
                  selected: {isCreating},
                  onSelectionChanged: (selection) {
                    setState(() => isCreating = selection.first);
                  },
                ),
                const SizedBox(height: 18),
                TextField(
                  controller: emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(labelText: 'Shared email'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: passwordController,
                  obscureText: true,
                  decoration: const InputDecoration(labelText: 'Shared password'),
                ),
                const SizedBox(height: 18),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: isLoading ? null : _submit,
                    child: Text(isLoading
                        ? 'Please wait...'
                        : isCreating
                            ? 'Register Shared Account'
                            : 'Log In'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
