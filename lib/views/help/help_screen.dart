import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../app/theme/app_theme.dart' as theme;
import '../../app/responsive/responsive_utils.dart';

class HelpScreen extends StatefulWidget {
  const HelpScreen({super.key});

  @override
  State<HelpScreen> createState() => _HelpScreenState();
}

class _HelpScreenState extends State<HelpScreen> {
  final List<FAQItem> _faqs = [
    FAQItem(
      question: 'How do I take a test?',
      answer: 'Navigate to the Tests section, select a test, and click "Start Test". Read the instructions carefully before beginning.',
    ),
    FAQItem(
      question: 'How are tests scored?',
      answer: 'Tests are automatically scored based on correct answers. You can view your detailed results in the Results section.',
    ),
    FAQItem(
      question: 'Can I retake a test?',
      answer: 'Test retake availability depends on your teacher\'s settings. Check with your teacher for retake policies.',
    ),
    FAQItem(
      question: 'How do I enroll in a course?',
      answer: 'Go to the Courses section, browse available courses, and click "Enroll" to join a course.',
    ),
    FAQItem(
      question: 'What if I forget my password?',
      answer: 'Click "Forgot Password" on the login screen and follow the instructions to reset your password via email.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Help & Support'),
        elevation: 0,
      ),
      body: ListView(
        padding: ResponsiveUtils.responsivePadding(context),
        children: [
          // Contact Support Card
          Card(
            margin: const EdgeInsets.only(bottom: 24),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Icon(
                    Icons.support_agent,
                    size: 48,
                    color: theme.AppTheme.primaryColor,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Need Help?',
                    style: TextStyle(
                      fontSize: ResponsiveUtils.responsiveFontSize(context, 20),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Our support team is here to help you',
                    style: TextStyle(
                      fontSize: ResponsiveUtils.responsiveFontSize(context, 14),
                      color: theme.AppTheme.textSecondary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () => _launchEmail(),
                          icon: const Icon(Icons.email),
                          label: const Text('Email Us'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: theme.AppTheme.primaryColor,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => _launchPhone(),
                          icon: const Icon(Icons.phone),
                          label: const Text('Call Us'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          
          // Quick Links
          _buildSectionHeader('Quick Links'),
          _buildQuickLink(
            icon: Icons.book,
            title: 'User Guide',
            subtitle: 'Learn how to use the app',
            onTap: () {
              Get.snackbar(
                'User Guide',
                'User guide coming soon',
                snackPosition: SnackPosition.BOTTOM,
              );
            },
          ),
          _buildQuickLink(
            icon: Icons.video_library,
            title: 'Video Tutorials',
            subtitle: 'Watch step-by-step tutorials',
            onTap: () {
              Get.snackbar(
                'Video Tutorials',
                'Video tutorials coming soon',
                snackPosition: SnackPosition.BOTTOM,
              );
            },
          ),
          _buildQuickLink(
            icon: Icons.description,
            title: 'Terms of Service',
            subtitle: 'Read our terms and conditions',
            onTap: () {
              Get.snackbar(
                'Terms of Service',
                'Terms of service coming soon',
                snackPosition: SnackPosition.BOTTOM,
              );
            },
          ),
          _buildQuickLink(
            icon: Icons.privacy_tip,
            title: 'Privacy Policy',
            subtitle: 'Learn about our privacy practices',
            onTap: () {
              Get.snackbar(
                'Privacy Policy',
                'Privacy policy coming soon',
                snackPosition: SnackPosition.BOTTOM,
              );
            },
            showDivider: false,
          ),
          const SizedBox(height: 24),
          
          // FAQ Section
          _buildSectionHeader('Frequently Asked Questions'),
          ...List.generate(
            _faqs.length,
            (index) => _buildFAQItem(_faqs[index], index),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Text(
        title,
        style: TextStyle(
          fontSize: ResponsiveUtils.responsiveFontSize(context, 18),
          fontWeight: FontWeight.bold,
          color: theme.AppTheme.textPrimary,
        ),
      ),
    );
  }

  Widget _buildQuickLink({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    bool showDivider = true,
  }) {
    return Column(
      children: [
        ListTile(
          leading: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: theme.AppTheme.primaryColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: theme.AppTheme.primaryColor,
              size: 24,
            ),
          ),
          title: Text(
            title,
            style: TextStyle(
              fontSize: ResponsiveUtils.responsiveFontSize(context, 16),
              fontWeight: FontWeight.w500,
            ),
          ),
          subtitle: Text(
            subtitle,
            style: TextStyle(
              fontSize: ResponsiveUtils.responsiveFontSize(context, 14),
              color: theme.AppTheme.textSecondary,
            ),
          ),
          trailing: Icon(
            Icons.arrow_forward_ios,
            size: 16,
            color: theme.AppTheme.textSecondary,
          ),
          onTap: onTap,
        ),
        if (showDivider)
          Divider(
            indent: 72,
            height: 1,
            color: theme.AppTheme.dividerColor,
          ),
      ],
    );
  }

  Widget _buildFAQItem(FAQItem faq, int index) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ExpansionTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: theme.AppTheme.primaryColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            '${index + 1}',
            style: TextStyle(
              color: theme.AppTheme.primaryColor,
              fontWeight: FontWeight.bold,
              fontSize: ResponsiveUtils.responsiveFontSize(context, 14),
            ),
          ),
        ),
        title: Text(
          faq.question,
          style: TextStyle(
            fontSize: ResponsiveUtils.responsiveFontSize(context, 16),
            fontWeight: FontWeight.w500,
          ),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              faq.answer,
              style: TextStyle(
                fontSize: ResponsiveUtils.responsiveFontSize(context, 14),
                color: theme.AppTheme.textSecondary,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _launchEmail() async {
    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: 'support@raintech.com',
      query: 'subject=RainTech Smart Test Support',
    );
    if (await canLaunchUrl(emailUri)) {
      await launchUrl(emailUri);
    } else {
      Get.snackbar(
        'Error',
        'Could not launch email client',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: theme.AppTheme.errorColor,
        colorText: Colors.white,
      );
    }
  }

  Future<void> _launchPhone() async {
    final Uri phoneUri = Uri(
      scheme: 'tel',
      path: '+1234567890',
    );
    if (await canLaunchUrl(phoneUri)) {
      await launchUrl(phoneUri);
    } else {
      Get.snackbar(
        'Error',
        'Could not launch phone dialer',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: theme.AppTheme.errorColor,
        colorText: Colors.white,
      );
    }
  }
}

class FAQItem {
  final String question;
  final String answer;

  FAQItem({
    required this.question,
    required this.answer,
  });
}
