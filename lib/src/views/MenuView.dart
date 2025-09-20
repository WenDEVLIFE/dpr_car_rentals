import 'package:dpr_car_rentals/src/helpers/ThemeHelper.dart';
import 'package:dpr_car_rentals/src/widget/CustomText.dart';
import 'package:dpr_car_rentals/src/widget/UnreadNotificationBadge.dart';
import 'package:flutter/material.dart';
import '../helpers/SessionHelpers.dart';
import 'LoginScreen.dart';
import 'ChangePasswordView.dart';
import 'EditProfileScreen.dart';
import 'PrivacyPolicyScreen.dart';
import 'AboutUsScreen.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/state/ProfileBloc.dart';
import '../bloc/FeedbackBloc.dart';
import '../repository/RegisterRepository.dart';
import '../repository/FeedbackRepository.dart';
import 'user/UserFeedbackView.dart';

class MenuView extends StatefulWidget {
  const MenuView({super.key});

  @override
  State<MenuView> createState() => _MenuViewState();
}

class _MenuViewState extends State<MenuView> {
  final SessionHelpers _sessionHelpers = SessionHelpers();
  Map<String, dynamic>? _userInfo;

  @override
  void initState() {
    super.initState();
    _loadUserInfo();
  }

  Future<void> _loadUserInfo() async {
    final userInfo = await _sessionHelpers.getUserInfo();
    setState(() {
      _userInfo = userInfo;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ThemeHelper.primaryColor,
      appBar: AppBar(
        title: CustomText(
            text: 'Menu',
            size: 20,
            color: Colors.white,
            fontFamily: 'Inter',
            weight: FontWeight.w700),
        elevation: 0,
        backgroundColor: Colors.blue,
        actions: [
          UnreadNotificationBadge(
            child: IconButton(
              icon: const Icon(Icons.notifications, color: Colors.white),
              onPressed: null, // Handled by UnreadNotificationBadge
            ),
          ),
        ],
      ),
      body: _userInfo == null
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  // User Info Card
                  Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 40,
                            backgroundColor: Colors.blue,
                            child: Text(
                              _userInfo!['fullName']
                                      ?.substring(0, 1)
                                      .toUpperCase() ??
                                  'U',
                              style: const TextStyle(
                                fontSize: 24,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _userInfo!['fullName'] ?? 'Unknown',
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  _userInfo!['email'] ?? 'No email',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey[600],
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Role: ${_userInfo!['role'] ?? 'User'}',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Menu Items
                  Expanded(
                    child: ListView(
                      children: [
                        _buildMenuItem(
                          icon: Icons.lock,
                          title: 'Change Password',
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      const ChangePasswordView()),
                            );
                          },
                        ),
                        _buildMenuItem(
                          icon: Icons.edit,
                          title: 'Edit Profile',
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => BlocProvider(
                                  create: (context) =>
                                      ProfileBloc(RegisterRepositoryImpl()),
                                  child: const EditProfileScreen(),
                                ),
                              ),
                            );
                          },
                        ),
                        _buildMenuItem(
                          icon: Icons.privacy_tip,
                          title: 'Privacy Policy',
                          onTap: () {
                            // Navigate to privacy policy screen
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      const PrivacyPolicyScreen()),
                            );
                          },
                        ),
                        _buildMenuItem(
                          icon: Icons.info,
                          title: 'About Us',
                          onTap: () {
                            // Navigate to about us screen
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const AboutUsScreen()),
                            );
                          },
                        ),
                        // Show feedback option only for non-admin users
                        if (_userInfo?['role'] != 'admin') ...[
                          _buildMenuItem(
                            icon: Icons.feedback,
                            title: 'Send Feedback',
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => BlocProvider(
                                    create: (context) =>
                                        FeedbackBloc(FeedbackRepositoryImpl()),
                                    child: const UserFeedbackView(),
                                  ),
                                ),
                              );
                            },
                          ),
                        ],
                        const Divider(),
                        _buildMenuItem(
                          icon: Icons.logout,
                          title: 'Logout',
                          onTap: () async {
                            await SessionHelpers.clearUserInfo();
                            Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const LoginScreen()),
                              (route) => false,
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: Colors.blue),
      title: Text(title),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: onTap,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
    );
  }
}
