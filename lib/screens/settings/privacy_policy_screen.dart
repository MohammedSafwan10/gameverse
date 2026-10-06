import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../widgets/gameverse_utility_widgets.dart';

/// Displays the same policy source published with the release documentation.
class PrivacyPolicyScreen extends StatefulWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  State<PrivacyPolicyScreen> createState() => _PrivacyPolicyScreenState();
}

class _PrivacyPolicyScreenState extends State<PrivacyPolicyScreen> {
  late final Future<String> _policy =
      rootBundle.loadString('docs/PRIVACY_POLICY.md');

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: GameVerseUtilityColors.cream,
        appBar: AppBar(
          backgroundColor: GameVerseUtilityColors.cream,
          foregroundColor: GameVerseUtilityColors.ink,
          title: const Text('Privacy Policy',
              style: TextStyle(color: GameVerseUtilityColors.ink)),
        ),
        body: FutureBuilder<String>(
          future: _policy,
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.all(24),
                  child: Text(
                    'Policy unavailable. Contact nexdarksolutions@gmail.com.',
                    style: TextStyle(color: GameVerseUtilityColors.ink),
                  ),
                ),
              );
            }
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }
            return SelectionArea(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(24, 12, 24, 36),
                children: [
                  for (final paragraph in snapshot.data!.split('\n\n'))
                    Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: Text(
                        paragraph.replaceFirst(RegExp(r'^#{1,2} '), '').trim(),
                        style: TextStyle(
                          fontFamily: 'Inter',
                          color: GameVerseUtilityColors.ink,
                          height: 1.5,
                          fontSize: paragraph.startsWith('#') ? 19 : 14,
                          fontWeight: paragraph.startsWith('#')
                              ? FontWeight.w700
                              : FontWeight.w400,
                        ),
                      ),
                    ),
                ],
              ),
            );
          },
        ),
      );
}
