import 'package:dpr_car_rentals/src/helpers/ThemeHelper.dart';
import 'package:dpr_car_rentals/src/widget/CustomText.dart';
import 'package:flutter/material.dart';
import '../helpers/SessionHelpers.dart';
import 'LoginScreen.dart';
import 'ChangePasswordView.dart';

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
        title: CustomText(text: 'Menu', size: 20, color: Colors.black, fontFamily: 'Inter', weight: FontWeight.w700),
        elevation: 0,
        backgroundColor: ThemeHelper.primaryColor,
        foregroundColor: ThemeHelper.primaryColor,
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
                          icon: Icons.privacy_tip,
                          title: 'Privacy Policy',
                          onTap: () {
                            // Navigate to privacy policy screen
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      const PrivacyPolicyView()),
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
                                  builder: (context) => const AboutUsView()),
                            );
                          },
                        ),
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

// Placeholder screens for Privacy Policy and About Us
class PrivacyPolicyView extends StatelessWidget {
  const PrivacyPolicyView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Privacy Policy')),
      body: const Center(child: Text('Privacy Policy content here.')),
    );
  }
}

class AboutUsView extends StatelessWidget {
  const AboutUsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('About Us')),
      body: const Center(child: Text('About Us content here.')),
    );
  }
}
