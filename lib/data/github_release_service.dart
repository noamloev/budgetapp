import 'dart:convert';

import 'package:http/http.dart' as http;

class GitHubReleaseInfo {
  GitHubReleaseInfo({
    required this.version,
    required this.releaseUrl,
    required this.apkUrl,
  });

  final String version;
  final String releaseUrl;
  final String? apkUrl;
}

class GitHubReleaseService {
  GitHubReleaseService({this.repo = 'noamloev/budgetapp'});

  final String repo;

  Future<GitHubReleaseInfo?> fetchLatestRelease() async {
    final response = await http.get(
      Uri.parse('https://api.github.com/repos/$repo/releases/latest'),
      headers: const {
        'Accept': 'application/vnd.github+json',
      },
    );

    if (response.statusCode != 200) {
      return null;
    }

    final json = jsonDecode(response.body) as Map<String, dynamic>;
    final assets = json['assets'] as List<dynamic>? ?? const [];
    String? apkUrl;
    for (final asset in assets) {
      final map = Map<String, dynamic>.from(asset as Map);
      final name = (map['name'] as String? ?? '').toLowerCase();
      if (name.endsWith('.apk')) {
        apkUrl = map['browser_download_url'] as String?;
        break;
      }
    }

    return GitHubReleaseInfo(
      version: (json['tag_name'] as String? ?? '').trim(),
      releaseUrl: json['html_url'] as String? ?? 'https://github.com/$repo/releases',
      apkUrl: apkUrl,
    );
  }
}
