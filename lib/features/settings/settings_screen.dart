import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../app/app_localizations.dart';
import '../../data/github_release_service.dart';
import '../../features/shared/widgets/cards.dart';
import '../../features/shared/widgets/help_widgets.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({
    super.key,
    required this.cycleStartDay,
    required this.onUpdateCycleStartDay,
  });

  final int cycleStartDay;
  final ValueChanged<int> onUpdateCycleStartDay;

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final GitHubReleaseService releases = GitHubReleaseService();
  String currentVersion = 'Loading...';
  String? latestVersion;
  String? latestApkUrl;
  bool isChecking = false;

  @override
  void initState() {
    super.initState();
    _loadVersion();
  }

  Future<void> _loadVersion() async {
    final info = await PackageInfo.fromPlatform();
    if (!mounted) return;
    setState(() {
      currentVersion = '${info.version}+${info.buildNumber}';
    });
  }

  Future<void> _checkUpdates() async {
    setState(() => isChecking = true);
    final latest = await releases.fetchLatestRelease();
    if (!mounted) return;
    setState(() {
      latestVersion = latest?.version;
      latestApkUrl = latest?.apkUrl ?? latest?.releaseUrl;
      isChecking = false;
    });
  }

  Future<void> _openUpdateUrl() async {
    final url = latestApkUrl;
    if (url == null) return;
    await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    final localeController = context.localeController;

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          ScreenHeader(
            title: t.text('settings'),
            subtitle: t.isHebrew
                ? 'שלוט בשפה, בזמן מחזור התקציב, ובעדכוני האפליקציה.'
                : 'Control language, budget cycle timing, and app updates.',
            helpTitle: t.isHebrew ? 'עזרה להגדרות' : 'Settings Help',
            helpLines: [
              t.isHebrew
                  ? 'יום תחילת המחזור קובע מתי נפתח חודש תקציב חדש.'
                  : 'Budget cycle day decides when a new spending month starts.',
              t.isHebrew
                  ? 'החלפת שפה מעדכנת את כל האפליקציה מיד.'
                  : 'Changing language updates the full app immediately.',
            ],
          ),
          const SizedBox(height: 20),
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  t.isHebrew
                      ? 'חודש התקציב מתחיל ביום ${widget.cycleStartDay}'
                      : 'Budget month starts on day ${widget.cycleStartDay}',
                  style: Theme.of(
                    context,
                  ).textTheme.headlineMedium?.copyWith(color: Colors.white),
                ),
                const SizedBox(height: 10),
                Text(
                  t.isHebrew
                      ? 'היסטוריה, סיכומים והעברות חודשיות עובדים לפי היום הזה.'
                      : 'History, summaries, and monthly rollover use this day.',
                  style: const TextStyle(color: Colors.white70, height: 1.45),
                ),
                const SizedBox(height: 18),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.14),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: DropdownButtonFormField<int>(
                    value: widget.cycleStartDay,
                    dropdownColor: Colors.white,
                    items: List.generate(
                      28,
                      (index) => DropdownMenuItem(
                        value: index + 1,
                        child: Text('${t.text('day_prefix')} ${index + 1}'),
                      ),
                    ),
                    onChanged: (value) {
                      if (value != null) {
                        widget.onUpdateCycleStartDay(value);
                      }
                    },
                    decoration: InputDecoration(
                      labelText: t.text('cycle_start_day'),
                      fillColor: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          InfoCard(
            title: t.text('language'),
            value: t.isHebrew ? 'עברית / English' : 'English / עברית',
            subtitle: t.isHebrew ? 'שפת הממשק' : 'Interface language',
            child: Padding(
              padding: const EdgeInsets.only(top: 12),
              child: SegmentedButton<AppLanguage>(
                segments: [
                  ButtonSegment<AppLanguage>(
                    value: AppLanguage.english,
                    label: Text(t.text('english')),
                  ),
                  ButtonSegment<AppLanguage>(
                    value: AppLanguage.hebrew,
                    label: Text(t.text('hebrew')),
                  ),
                ],
                selected: {localeController.language},
                onSelectionChanged: (selection) {
                  localeController.updateLanguage(selection.first);
                },
              ),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: InfoCard(
                  title: t.text('current_version'),
                  value: currentVersion,
                  subtitle: t.text('installed_app_build'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: InfoCard(
                  title: t.text('latest_release'),
                  value: latestVersion ?? t.text('not_checked'),
                  subtitle: latestVersion == null
                      ? t.text('use_button_below')
                      : t.text('pulled_from_github'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(28),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  t.text('update_center'),
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                Text(
                  t.isHebrew
                      ? 'פרסם גרסת GitHub עם קובץ APK והאפליקציה תוכל לבדוק ולפתוח אותה.'
                      : 'Publish a GitHub release with an APK asset and the app can check and open it.',
                  style: const TextStyle(color: Colors.black54, height: 1.45),
                ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    FilledButton(
                      onPressed: isChecking ? null : _checkUpdates,
                      child: Text(
                        isChecking
                            ? t.text('checking')
                            : t.text('check_updates'),
                      ),
                    ),
                    if (latestApkUrl != null)
                      OutlinedButton(
                        onPressed: _openUpdateUrl,
                        child: Text(t.text('open_latest_apk')),
                      ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          InfoCard(
            title: t.text('github_source'),
            value: 'noamloev/budgetapp',
            subtitle: t.isHebrew
                ? 'המאגר שממנו נקראים נתוני הגרסאות וקבצי ה-APK.'
                : 'The repository used for release versions and APK assets.',
          ),
        ],
      ),
    );
  }
}
