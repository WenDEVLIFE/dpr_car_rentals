import 'package:dpr_car_rentals/src/helpers/SessionHelpers.dart';
import 'package:dpr_car_rentals/src/helpers/ThemeHelper.dart';
import 'package:dpr_car_rentals/src/repository/UserRepository.dart';
import 'package:dpr_car_rentals/src/views/user/UserMainView.dart';
import 'package:dpr_car_rentals/src/widget/CustomButton.dart';
import 'package:dpr_car_rentals/src/widget/CustomText.dart';
import 'package:dpr_car_rentals/src/widget/CustomTextField.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class UserDetailsScreen extends StatefulWidget {
  const UserDetailsScreen({super.key});

  @override
  State<UserDetailsScreen> createState() => _UserDetailsScreenState();
}

class _UserDetailsScreenState extends State<UserDetailsScreen> {
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController licenseController = TextEditingController();
  String? selectedPaymentPreference;
  String? selectedCountryCode;
  final List<String> paymentOptions = [
    'Cash',
    'Bank (Coming Soon)',
    'Online Payment (Coming Soon)'
  ];
  final List<String> countryCodes = [
    '+1 (US)',
    '+63 (PH)',
    '+65 (SG)',
    '+60 (MY)',
    '+62 (ID)'
  ];
  final UserRepositoryImpl userRepository = UserRepositoryImpl();
  final SessionHelpers sessionHelpers = SessionHelpers();
  final _formKey = GlobalKey<FormState>();

  Future<void> saveDetails() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final phone = phoneController.text.trim();
    final license = licenseController.text.trim();

    if (selectedPaymentPreference == null || selectedCountryCode == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all fields')),
      );
      return;
    }

    if (selectedPaymentPreference != 'Cash') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text(
                'Selected payment method is coming soon. Please select Cash for now.')),
      );
      return;
    }

    try {
      final userInfo = await sessionHelpers.getUserInfo();
      final uid = userInfo?['uid'];

      if (uid == null) {
        Fluttertoast.showToast(msg: 'User not logged in');
        return;
      }

      final fullPhoneNumber = '$selectedCountryCode $phone';

      await userRepository.updateUserDetails(uid, {
        'PhoneNumber': fullPhoneNumber,
        'DriverLicenseNumber': license,
        'PaymentPreference': selectedPaymentPreference,
      });

      Fluttertoast.showToast(msg: 'Details saved successfully');

      // Navigate to UserMainView
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const UserMainView()),
      );
    } catch (e) {
      Fluttertoast.showToast(msg: 'Error saving details: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: ThemeHelper.primaryColor,
      appBar: AppBar(
        title: CustomText(
            text: 'Complete Your Profile',
            size: 20,
            color: Colors.white,
            fontFamily: 'Inter',
            weight: FontWeight.w700),
        backgroundColor: Colors.blue,
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CustomText(
                  text: 'Please provide the following details',
                  size: 20,
                  color: Colors.black,
                  fontFamily: 'Inter',
                  weight: FontWeight.w600,
                ),
                const SizedBox(height: 20),
                // Country Code Dropdown
                SizedBox(
                  width: screenWidth * 0.8,
                  child: DropdownButtonFormField<String>(
                    value: selectedCountryCode,
                    hint: const Text('Select Country Code'),
                    items: countryCodes.map((String code) {
                      return DropdownMenuItem<String>(
                        value: code,
                        child: Text(code),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      setState(() {
                        selectedCountryCode = newValue;
                      });
                    },
                    decoration: const InputDecoration(
                      labelText: 'Country Code',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please select country code';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(height: 16),
                // Phone Number Field
                SizedBox(
                  width: screenWidth * 0.8,
                  child: TextFormField(
                    controller: phoneController,
                    keyboardType: TextInputType.phone,
                    decoration: const InputDecoration(
                      labelText: 'Phone Number',
                      hintText: 'Enter phone number (7-11 digits)',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter phone number';
                      }
                      final phoneRegex = RegExp(r'^\d{7,11}$');
                      if (!phoneRegex.hasMatch(value)) {
                        return 'Enter 7-11 digits only';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: screenWidth * 0.8,
                  child: CustomTextField(
                    hintText: 'Enter your driver license number',
                    controller: licenseController,
                    labelText: 'Driver License Number',
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: screenWidth * 0.8,
                  child: DropdownButtonFormField<String>(
                    value: selectedPaymentPreference,
                    hint: const Text('Select Payment Preference'),
                    items: paymentOptions.map((String option) {
                      return DropdownMenuItem<String>(
                        value: option,
                        enabled: option == 'Cash', // Only Cash is selectable
                        child: Text(option),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      if (newValue == 'Cash') {
                        setState(() {
                          selectedPaymentPreference = newValue;
                        });
                      }
                    },
                    decoration: const InputDecoration(
                      labelText: 'Payment Preference',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please select payment preference';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(height: 32),
                SizedBox(
                  width: screenWidth * 0.6,
                  height: 50,
                  child: CustomButton(
                    text: 'Save Details',
                    textColor: Colors.white,
                    backgroundColor: Colors.blue,
                    onPressed: saveDetails,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
