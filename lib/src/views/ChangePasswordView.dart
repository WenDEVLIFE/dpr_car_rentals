import 'package:flutter/material.dart';
import '../helpers/ThemeHelper.dart';
import '../repository/RegisterRepository.dart';
import '../widget/CustomButton.dart';
import '../widget/CustomPasswordField.dart';
import '../widget/CustomText.dart';

class ChangePasswordView extends StatefulWidget {
  const ChangePasswordView({super.key});

  @override
  State<ChangePasswordView> createState() => _ChangePasswordViewState();
}

class _ChangePasswordViewState extends State<ChangePasswordView> {
  final TextEditingController _currentPasswordController =
      TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  final RegisterRepository _registerRepository = RegisterRepositoryImpl();
  bool _isLoading = false;

  void _handleChangePassword() async {
    final currentPassword = _currentPasswordController.text;
    final newPassword = _newPasswordController.text;
    final confirmPassword = _confirmPasswordController.text;

    // Basic validation
    if (currentPassword.isEmpty ||
        newPassword.isEmpty ||
        confirmPassword.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill in all fields'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (newPassword != confirmPassword) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('New passwords do not match'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (newPassword.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('New password must be at least 6 characters'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final success = await _registerRepository.changePassword(
      currentPassword: currentPassword,
      newPassword: newPassword,
    );

    setState(() {
      _isLoading = false;
    });

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Password changed successfully'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to change password. Check current password.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar:AppBar(
        title: CustomText(text: 'Menu', size: 20, color: Colors.black, fontFamily: 'Inter', weight: FontWeight.w700),
        elevation: 0,
        backgroundColor: ThemeHelper.primaryColor,
        foregroundColor: ThemeHelper.primaryColor,
      ),
      backgroundColor: ThemeHelper.primaryColor,
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CustomText(
                text: 'Change Password',
                size: 32,
                color: Colors.black,
                fontFamily: 'Inter',
                weight: FontWeight.w700,
              ),
              SizedBox(
                width: screenWidth * 0.8,
                height: screenWidth * 0.20,
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                  child: CustomOutlinePassField(
                    labelText: 'Current Password',
                    hintText: 'Enter your current password',
                    controller: _currentPasswordController,
                  ),
                ),
              ),
              SizedBox(
                width: screenWidth * 0.8,
                height: screenWidth * 0.20,
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                  child: CustomOutlinePassField(
                    labelText: 'New Password',
                    hintText: 'Enter your new password',
                    controller: _newPasswordController,
                  ),
                ),
              ),
              SizedBox(
                width: screenWidth * 0.8,
                height: screenWidth * 0.20,
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                  child: CustomOutlinePassField(
                    labelText: 'Confirm New Password',
                    hintText: 'Confirm your new password',
                    controller: _confirmPasswordController,
                  ),
                ),
              ),
              SizedBox(
                width: screenWidth * 0.6,
                height: screenWidth * 0.18,
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                  child: _isLoading
                      ? const CircularProgressIndicator()
                      : CustomButton(
                          text: 'Change Password',
                          textColor: Colors.white,
                          backgroundColor: ThemeHelper.accentColor,
                          onPressed: _handleChangePassword,
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
