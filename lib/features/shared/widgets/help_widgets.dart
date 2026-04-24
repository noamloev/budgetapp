import 'package:flutter/material.dart';

class HelpIconButton extends StatelessWidget {
  const HelpIconButton({
    super.key,
    required this.title,
    required this.lines,
    this.tint,
  });

  final String title;
  final List<String> lines;
  final Color? tint;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: () {
        showDialog<void>(
          context: context,
          builder: (_) => AlertDialog(
            title: Text(title),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: lines
                  .map(
                    (line) => Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Text(line),
                    ),
                  )
                  .toList(),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Close'),
              ),
            ],
          ),
        );
      },
      icon: Icon(Icons.help_outline_rounded, color: tint),
      tooltip: 'What does this screen do?',
    );
  }
}

class ScreenHeader extends StatelessWidget {
  const ScreenHeader({
    super.key,
    required this.title,
    required this.subtitle,
    required this.helpTitle,
    required this.helpLines,
    this.action,
  });

  final String title;
  final String subtitle;
  final String helpTitle;
  final List<String> helpLines;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < 430;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title, style: Theme.of(context).textTheme.headlineMedium),
                      const SizedBox(height: 8),
                      Text(subtitle),
                    ],
                  ),
                ),
                HelpIconButton(
                  title: helpTitle,
                  lines: helpLines,
                ),
              ],
            ),
            if (action != null) ...[
              SizedBox(height: compact ? 12 : 10),
              Align(
                alignment: Alignment.centerLeft,
                child: action!,
              ),
            ],
          ],
        );
      },
    );
  }
}
