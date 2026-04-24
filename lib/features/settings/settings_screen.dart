import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

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
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const ScreenHeader(
            title: 'Settings',
            subtitle: 'Control cycle timing, understand updates, and manage how the app behaves.',
            helpTitle: 'Settings Help',
            helpLines: [
              'Budget cycle day decides when a new spending month starts.',
              'If your salary comes on the 10th, set the cycle start to 10.',
              'Update check reads the latest GitHub release and opens the APK download link on Android.',
            ],
          ),
          const SizedBox(height: 20),
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Budget month starts on day ${widget.cycleStartDay}',
                  style: Theme.of(context)
                      .textTheme
                      .headlineMedium
                      ?.copyWith(color: Colors.white),
                ),
                const SizedBox(height: 10),
                const Text(
                  'This controls when one budget month ends and the next one begins. History and dashboard summaries follow this cycle.',
                  style: TextStyle(color: Colors.white70, height: 1.45),
                ),
                const SizedBox(height: 18),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
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
                        child: Text('Day ${index + 1}'),
                      ),
                    ),
                    onChanged: (value) {
                      if (value != null) {
                        widget.onUpdateCycleStartDay(value);
                      }
                    },
                    decoration: const InputDecoration(
                      labelText: 'Cycle start day',
                      fillColor: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: InfoCard(
                  title: 'Current Version',
                  value: currentVersion,
                  subtitle: 'Installed app build',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: InfoCard(
                  title: 'Latest Release',
                  value: latestVersion ?? 'Not checked',
                  subtitle: latestVersion == null
                      ? 'Use the button below'
                      : 'Pulled from GitHub',
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
                Text('Update Center', style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 8),
                const Text(
                  'Publish a GitHub release with an APK asset. The app checks that release and opens the latest APK download.',
                  style: TextStyle(color: Colors.black54, height: 1.45),
                ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    FilledButton(
                      onPressed: isChecking ? null : _checkUpdates,
                      child: Text(isChecking ? 'Checking...' : 'Check Updates'),
                    ),
                    if (latestApkUrl != null)
                      OutlinedButton(
                        onPressed: _openUpdateUrl,
                        child: const Text('Open Latest APK'),
                      ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          InfoCard(
            title: 'GitHub Source',
            value: 'noamloev/budgetapp',
            subtitle: 'This is the repository used for reading release versions and APK assets.',
          ),
        ],
      ),
    );
  }
}
