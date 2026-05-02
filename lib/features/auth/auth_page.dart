import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../app/app_localizations.dart';
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
    final t = context.t;
    final email = emailController.text.trim();
    final password = passwordController.text;
    if (email.isEmpty || password.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            t.isHebrew
                ? 'הכנס אימייל תקין וסיסמה של לפחות 6 תווים.'
                : 'Enter a valid email and a password with at least 6 characters.',
          ),
        ),
      );
      return;
    }

    setState(() => isLoading = true);
    try {
      if (isCreating) {
        await supabase.auth.signUp(email: email, password: password);
      } else {
        await supabase.auth.signInWithPassword(
          email: email,
          password: password,
        );
      }
    } on AuthException catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error.message)));
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 460),
            child: ListView(
              padding: const EdgeInsets.all(24),
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Budget Flow',
                        style: TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                    HelpIconButton(
                      title: t.isHebrew ? 'עזרה להתחברות' : 'Login Help',
                      lines: [
                        t.isHebrew
                            ? 'השתמשו באותו אימייל וסיסמה אם שני בני הזוג צריכים את אותו התקציב.'
                            : 'Use one shared email and password if both partners should access the same budget.',
                        t.isHebrew
                            ? 'יצירת חשבון מיועדת להגדרה ראשונה, והתחברות לכל מכשיר נוסף.'
                            : 'Create Account is for the first setup. Log In is for every later device.',
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [
                        Color(0xFF081B2E),
                        Color(0xFF0F766E),
                        Color(0xFFE76F51),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Text(
                    t.isHebrew
                        ? 'חשבון משותף אחד לשני הטלפונים ולאתר. התחברו מכל מקום וערכו יחד את אותו התקציב.'
                        : 'One shared account for both phones and the website. Log in anywhere and edit the same budget together.',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      height: 1.45,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                SegmentedButton<bool>(
                  segments: [
                    ButtonSegment<bool>(
                      value: false,
                      label: Text(t.text('log_in')),
                    ),
                    ButtonSegment<bool>(
                      value: true,
                      label: Text(t.text('register')),
                    ),
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
                  decoration: InputDecoration(
                    labelText: t.text('shared_email'),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: passwordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: t.text('shared_password'),
                  ),
                ),
                const SizedBox(height: 18),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: isLoading ? null : _submit,
                    child: Text(
                      isLoading
                          ? t.text('please_wait')
                          : isCreating
                          ? t.text('register_shared_account')
                          : t.text('log_in'),
                    ),
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
