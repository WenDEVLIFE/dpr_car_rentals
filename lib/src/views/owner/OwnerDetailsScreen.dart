import 'package:dpr_car_rentals/src/helpers/SessionHelpers.dart';
import 'package:dpr_car_rentals/src/helpers/ThemeHelper.dart';
import 'package:dpr_car_rentals/src/repository/RegisterRepository.dart';
import 'package:dpr_car_rentals/src/views/owner/OwnerView.dart';
import 'package:dpr_car_rentals/src/widget/CustomButton.dart';
import 'package:dpr_car_rentals/src/widget/CustomText.dart';
import 'package:dpr_car_rentals/src/widget/CustomTextField.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class OwnerDetailsScreen extends StatefulWidget {
  const OwnerDetailsScreen({super.key});

  @override
  State<OwnerDetailsScreen> createState() => _OwnerDetailsScreenState();
}

class _OwnerDetailsScreenState extends State<OwnerDetailsScreen> {
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController bankNameController = TextEditingController();
  final TextEditingController bankAccountController = TextEditingController();
  String? selectedCountryCode;
  final List<String> countryCodes = [
    '+1 (US)',
    '+63 (PH)',
    '+65 (SG)',
    '+60 (MY)',
    '+62 (ID)'
  ];
  final RegisterRepositoryImpl registerRepository = RegisterRepositoryImpl();
  final SessionHelpers sessionHelpers = SessionHelpers();
  final _formKey = GlobalKey<FormState>();

  Future<void> saveDetails() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final phone = phoneController.text.trim();
    final address = addressController.text.trim();
    final bankName = bankNameController.text.trim();
    final bankAccount = bankAccountController.text.trim();

    if (selectedCountryCode == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select country code')),
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

      await registerRepository.updateOwnerDetails(uid, {
        'PhoneNumber': fullPhoneNumber,
        'Address': address,
        'BankName': bankName,
        'BankAccountNumber': bankAccount,
      });

      Fluttertoast.showToast(msg: 'Details saved successfully');

      // Navigate to OwnerView
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const OwnerView()),
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
                // Address Field
                SizedBox(
                  width: screenWidth * 0.8,
                  child: CustomTextField(
                    hintText: 'Enter your address',
                    controller: addressController,
                    labelText: 'Address',
                  ),
                ),
                const SizedBox(height: 16),
                // Bank Name Field
                SizedBox(
                  width: screenWidth * 0.8,
                  child: CustomTextField(
                    hintText: 'Enter your bank name',
                    controller: bankNameController,
                    labelText: 'Bank Name',
                  ),
                ),
                const SizedBox(height: 16),
                // Bank Account Number Field
                SizedBox(
                  width: screenWidth * 0.8,
                  child: TextFormField(
                    controller: bankAccountController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Bank Account Number',
                      hintText: 'Enter bank account number',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter bank account number';
                      }
                      final accountRegex = RegExp(r'^\d{10,16}$');
                      if (!accountRegex.hasMatch(value)) {
                        return 'Enter 10-16 digits only';
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
