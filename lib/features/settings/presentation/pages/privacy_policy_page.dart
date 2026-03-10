import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Privacy Policy Page
class PrivacyPolicyPage extends StatelessWidget {
  const PrivacyPolicyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Privacy Policy'),
        actions: [
          IconButton(
            icon: const Icon(Icons.copy),
            onPressed: () => _copyToClipboard(context),
          ),
        ],
      ),
      body: const SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Privacy Policy',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              'Last Updated: February 28, 2026',
              style: TextStyle(color: Colors.grey),
            ),
            SizedBox(height: 24),
            
            _SectionTitle('Introduction'),
            _SectionText(
              'Open Bible ("we," "our," or "us") is committed to protecting your privacy. '
              'This Privacy Policy explains how we collect, use, and safeguard your information '
              'when you use our mobile application.',
            ),
            
            _SectionTitle('Information We Collect'),
            _SectionText(
              '• User Preferences: App settings, font size, theme preferences\n'
              '• Bookmarks: Bible verses you bookmark for quick access\n'
              '• Reading Plans: Progress on reading plans you create or follow\n'
              '• Prayer Journal: Prayer requests and notes you enter\n'
              '• Highlights: Verses you highlight within the app\n'
              '• Usage Data: Anonymous app usage statistics\n'
              '• Device Info: Device type, OS version (for compatibility)',
            ),
            
            _SectionTitle('How We Use Your Information'),
            _SectionText(
              '1. App Functionality: Provide Bible reading and study features\n'
              '2. Personalization: Remember your preferences and reading position\n'
              '3. Improvement: Analyze usage and improve the app experience\n'
              '4. Offline Support: Cache Bible content for offline reading',
            ),
            
            _SectionTitle('Data Storage'),
            _SectionText(
              'All personal data is stored locally on your device. We do not upload your '
              'bookmarks, notes, or prayer journal to our servers. Bible content is fetched '
              'from api.bible when internet is available.',
            ),
            
            _SectionTitle('Third-Party Services'),
            _SectionText(
              '• API.Bible: For fetching Bible translations and content\n'
              '• Analytics: Anonymous usage statistics (optional)',
            ),
            
            _SectionTitle('Data Security'),
            _SectionText(
              'All data is stored locally on your device. We do not sell or share your '
              'personal information. We implement industry-standard security practices.',
            ),
            
            _SectionTitle('Your Rights'),
            _SectionText(
              'You have the right to:\n'
              '• Delete all app data by uninstalling the app\n'
              '• Opt-out of analytics in app settings\n'
              '• Request your data (contact support)',
            ),
            
            _SectionTitle("Children's Privacy"),
            _SectionText(
              'Our app does not knowingly collect information from children under 13.',
            ),
            
            _SectionTitle('Contact Us'),
            _SectionText(
              'If you have questions about this Privacy Policy, please contact:\n'
              '• Developer: synth (synthalorian)',
            ),
            
            SizedBox(height: 32),
            Center(
              child: Text(
                'By using Open Bible, you agree to this Privacy Policy.',
                textAlign: TextAlign.center,
                style: TextStyle(fontStyle: FontStyle.italic),
              ),
            ),
            SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
  
  void _copyToClipboard(BuildContext context) {
    Clipboard.setData(const ClipboardData(
      text: '''Open Bible Privacy Policy

Last Updated: February 28, 2026

Open Bible is committed to protecting your privacy. All personal data (bookmarks, notes, prayer journal) is stored locally on your device. We do not upload your data to our servers.

Contact: synth (synthalorian)''',
    ));
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Privacy policy copied to clipboard')),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String text;
  const _SectionTitle(this.text);
  
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 24, bottom: 8),
      child: Text(
        text,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
    );
  }
}

class _SectionText extends StatelessWidget {
  final String text;
  const _SectionText(this.text);
  
  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(fontSize: 15, height: 1.5),
    );
  }
}
