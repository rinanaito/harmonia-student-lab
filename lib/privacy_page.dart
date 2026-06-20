import 'package:flutter/material.dart';

class PrivacyPage extends StatelessWidget {
  const PrivacyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Privacy Policy'),
      ),
      body: const SingleChildScrollView(
        padding: EdgeInsets.all(24),
        child: SelectableText(
          '''
Privacy Policy

Last updated: June 20, 2026

We collect:
- Email
- Usage data

We use data to:
- Provide the service
- Improve reliability

We do not sell personal data.

Contact:
rina.anishot@gmail.com
''',
        ),
      ),
    );
  }
}