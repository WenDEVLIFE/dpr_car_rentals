import 'package:dpr_car_rentals/src/helpers/ThemeHelper.dart';
import 'package:dpr_car_rentals/src/widget/CustomText.dart';
import 'package:flutter/material.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: ThemeHelper.primaryColor,
      appBar: AppBar(
        title: CustomText(
            text: 'Privacy Policy',
            size: 20,
            color: Colors.white,
            fontFamily: 'Inter',
            weight: FontWeight.w700),
        backgroundColor: Colors.blue,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.privacy_tip,
                    color: Colors.white,
                    size: 40,
                  ),
                  SizedBox(height: screenHeight * 0.01),
                  const CustomText(
                    text: 'Privacy Policy',
                    size: 24,
                    color: Colors.white,
                    fontFamily: 'Inter',
                    weight: FontWeight.w700,
                  ),
                  SizedBox(height: screenHeight * 0.005),
                  const CustomText(
                    text: 'Last updated: January 2025',
                    size: 14,
                    color: Colors.white70,
                    fontFamily: 'Inter',
                    weight: FontWeight.w400,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Introduction
            _buildSectionCard(
              icon: Icons.info_outline,
              title: 'Introduction',
              content:
                  'Welcome to DPR Car Rentals. We are committed to protecting your privacy and ensuring the security of your personal information. This Privacy Policy explains how we collect, use, and safeguard your data when you use our car rental services.',
            ),

            // Information We Collect
            _buildSectionCard(
              icon: Icons.data_usage,
              title: 'Information We Collect',
              content:
                  'We collect information you provide directly to us, such as your name, email address, phone number, driver\'s license details, and payment information when you create an account or make a reservation. We also automatically collect certain information about your device and usage of our services.',
            ),

            // How We Use Your Information
            _buildSectionCard(
              icon: Icons.settings_applications,
              title: 'How We Use Your Information',
              content:
                  'We use your information to provide and improve our car rental services, process your reservations, communicate with you about your bookings, send you important updates, and ensure compliance with legal requirements. We may also use your data for marketing purposes with your consent.',
            ),

            // Information Sharing
            _buildSectionCard(
              icon: Icons.share,
              title: 'Information Sharing',
              content:
                  'We do not sell, trade, or rent your personal information to third parties. We may share your information only in limited circumstances, such as with service providers who help us operate our business, when required by law, or to protect our rights and safety.',
            ),

            // Data Security
            _buildSectionCard(
              icon: Icons.security,
              title: 'Data Security',
              content:
                  'We implement appropriate technical and organizational measures to protect your personal information against unauthorized access, alteration, disclosure, or destruction. This includes encryption of sensitive data and regular security assessments.',
            ),

            // Your Rights
            _buildSectionCard(
              icon: Icons.account_circle,
              title: 'Your Rights',
              content:
                  'You have the right to access, update, or delete your personal information. You can also opt out of marketing communications at any time. To exercise these rights, please contact us using the information provided below.',
            ),

            // Contact Information
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.contact_mail,
                        color: Color(0xFF667EEA),
                        size: 24,
                      ),
                      SizedBox(width: screenWidth * 0.03),
                      const CustomText(
                        text: 'Contact Us',
                        size: 18,
                        color: Color(0xFF333333),
                        fontFamily: 'Inter',
                        weight: FontWeight.w700,
                      ),
                    ],
                  ),
                  SizedBox(height: screenHeight * 0.02),
                  const CustomText(
                    text:
                        'If you have any questions about this Privacy Policy, please contact us:',
                    size: 14,
                    color: Color(0xFF666666),
                    fontFamily: 'Inter',
                    weight: FontWeight.w400,
                  ),
                  SizedBox(height: screenHeight * 0.015),
                  const CustomText(
                    text:
                        '📧 Email: privacy@dprcarrentals.com\n📞 Phone: +63 (02) 123-4567\n🏢 Address: 123 Car Rental Street, Manila, Philippines',
                    size: 14,
                    color: Color(0xFF333333),
                    fontFamily: 'Inter',
                    weight: FontWeight.w400,
                  ),
                ],
              ),
            ),

             SizedBox(height: screenHeight * 0.03),
          ],
        ),
      ),
    );
  }

  static Widget _buildSectionCard({
    required IconData icon,
    required String title,
    required String content,
  }) {
    return Builder(
      builder: (context) {
        final double screenWidth = MediaQuery.of(context).size.width;
        final double screenHeight = MediaQuery.of(context).size.height;

        return Container(
          width: double.infinity,
          margin: EdgeInsets.only(bottom: screenHeight * 0.02),
          padding: EdgeInsets.all(screenWidth * 0.05),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    icon,
                    color: const Color(0xFF667EEA),
                    size: 24,
                  ),
                  SizedBox(width: screenWidth * 0.03),
                  Expanded(
                    child: CustomText(
                      text: title,
                      size: 18,
                      color: const Color(0xFF333333),
                      fontFamily: 'Inter',
                      weight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              SizedBox(height: screenHeight * 0.015),
              CustomText(
                text: content,
                size: 14,
                color: const Color(0xFF666666),
                fontFamily: 'Inter',
                weight: FontWeight.w400,
              ),
            ],
          ),
        );
      },
    );
  }
}
