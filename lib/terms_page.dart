import 'package:flutter/material.dart';

class TermsPage extends StatelessWidget {
  const TermsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Terms of Service'),
      ),
      body: const SingleChildScrollView(
        padding: EdgeInsets.all(24),
        child: SelectableText(
          '''
Terms of Service

Last updated: June 20, 2026

1. Use of Service
You may use this app only as permitted.

2. Accounts
You are responsible for account activity.

3. Content
Users retain ownership of uploaded content.

4. Termination
Accounts may be suspended for abuse.

5. Contact
rina.anishot@gmail.com
''',
        ),
      ),
    );
  }
}