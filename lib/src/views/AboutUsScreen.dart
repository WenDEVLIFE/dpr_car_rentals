import 'package:dpr_car_rentals/src/helpers/ThemeHelper.dart';
import 'package:dpr_car_rentals/src/widget/CustomText.dart';
import 'package:flutter/material.dart';

class AboutUsScreen extends StatelessWidget {
  const AboutUsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      backgroundColor: ThemeHelper.primaryColor,
      appBar: AppBar(
        title: CustomText(
            text: 'About Us',
            size: 20,
            color: Colors.white,
            fontFamily: 'Inter',
            weight: FontWeight.w700),
        backgroundColor: Colors.blue,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
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
                    Icons.business,
                    color: Colors.white,
                    size: 40,
                  ),
                  SizedBox(height: screenHeight * 0.01),
                  const CustomText(
                      text: 'DPR Car Rentals',
                      size: 24,
                      color: Colors.white,
                      fontFamily: 'Inter',
                      weight: FontWeight.w700),
                  SizedBox(height: screenHeight * 0.005),
                  const CustomText(
                      text: 'Your Trusted Car Rental Partner',
                      size: 16,
                      color: Colors.white70,
                      fontFamily: 'Inter',
                      weight: FontWeight.w700),
                ],
              ),
            ),

            SizedBox(height: screenHeight * 0.03),

            // Company Overview
            _buildAboutSectionCard(
              icon: Icons.apartment,
              title: 'Company Overview',
              content:
                  'DPR Car Rentals is a leading car rental company in the Philippines, committed to providing exceptional transportation solutions to our customers. With years of experience in the industry, we have built a reputation for reliability, quality service, and customer satisfaction.',
            ),

            // Our Mission
            _buildAboutSectionCard(
              icon: Icons.flag,
              title: 'Our Mission',
              content:
                  'To provide safe, reliable, and affordable car rental services that exceed our customers\' expectations. We strive to make transportation accessible and convenient for everyone, whether for business travel, family vacations, or daily commuting needs.',
            ),

            // What We Offer
            Container(
              width: double.infinity,
              margin: const EdgeInsets.only(bottom: 16),
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
                        Icons.car_rental,
                        color: Color(0xFF667EEA),
                        size: 24,
                      ),
                      SizedBox(width: screenWidth * 0.03),
                      const CustomText(
                        text: 'What We Offer',
                        size: 18,
                        color: Color(0xFF333333),
                        fontFamily: 'Inter',
                        weight: FontWeight.w700,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildServiceItem(
                    icon: Icons.directions_car,
                    title: 'Wide Range of Vehicles',
                    description:
                        'From compact cars to luxury SUVs, we have the perfect vehicle for every occasion.',
                  ),
                  const SizedBox(height: 12),
                  _buildServiceItem(
                    icon: Icons.location_on,
                    title: 'Convenient Locations',
                    description:
                        'Multiple pickup and drop-off locations across major cities in the Philippines.',
                  ),
                  const SizedBox(height: 12),
                  _buildServiceItem(
                    icon: Icons.support_agent,
                    title: '24/7 Customer Support',
                    description:
                        'Round-the-clock assistance for all your rental needs and emergencies.',
                  ),
                  const SizedBox(height: 12),
                  _buildServiceItem(
                    icon: Icons.security,
                    title: 'Insurance Coverage',
                    description:
                        'Comprehensive insurance options to protect you and your rental vehicle.',
                  ),
                ],
              ),
            ),

            // Our Values
            _buildAboutSectionCard(
              icon: Icons.favorite,
              title: 'Our Values',
              content:
                  '• Customer First: Your satisfaction is our top priority\n• Safety: Ensuring the well-being of our customers and vehicles\n• Integrity: Transparent and honest business practices\n• Innovation: Continuously improving our services\n• Sustainability: Committed to eco-friendly practices',
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
                        Icons.contact_phone,
                        color: Color(0xFF667EEA),
                        size: 24,
                      ),
                      SizedBox(width: screenWidth * 0.03),
                      const CustomText(
                        text: 'Get In Touch',
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
                        'Ready to experience the best car rental service? Contact us today!',
                    size: 14,
                    color: Color(0xFF666666),
                    fontFamily: 'Inter',
                    weight: FontWeight.w400,
                  ),
                  SizedBox(height: screenHeight * 0.01),
                  const CustomText(
                    text:
                        '📧 Email: info@dprcarrentals.com\n📞 Phone: +63 (02) 123-4567\n📱 Mobile: +63 917 123 4567\n🏢 Address: 123 Car Rental Street, BGC, Taguig City, Philippines\n🌐 Website: www.dprcarrentals.com',
                    size: 14,
                    color: Color(0xFF333333),
                    fontFamily: 'Inter',
                    weight: FontWeight.w400,
                  ),
                  SizedBox(height: screenHeight * 0.01),
                  const CustomText(
                    text:
                        'Follow us on social media for the latest updates and special offers!',
                    size: 14,
                    color: Color(0xFF666666),
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

  static Widget _buildAboutSectionCard({
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

  static Widget _buildServiceItem({
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Builder(
      builder: (context) {
        final double screenWidth = MediaQuery.of(context).size.width;
        final double screenHeight = MediaQuery.of(context).size.height;

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              icon,
              color: const Color(0xFF667EEA),
              size: 20,
            ),
            SizedBox(width: screenWidth * 0.03),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CustomText(
                    text: title,
                    size: 14,
                    color: const Color(0xFF333333),
                    fontFamily: 'Inter',
                    weight: FontWeight.w600,
                  ),
                  SizedBox(height: screenHeight * 0.005),
                  CustomText(
                    text: description,
                    size: 12,
                    color: const Color(0xFF666666),
                    fontFamily: 'Inter',
                    weight: FontWeight.w400,
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}
