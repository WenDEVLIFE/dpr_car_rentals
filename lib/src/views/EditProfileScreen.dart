import 'package:dpr_car_rentals/src/bloc/state/ProfileBloc.dart';
import 'package:dpr_car_rentals/src/bloc/event/ProfileEvent.dart';
import 'package:dpr_car_rentals/src/bloc/state/ProfileState.dart';
import 'package:dpr_car_rentals/src/helpers/SessionHelpers.dart';
import 'package:dpr_car_rentals/src/helpers/ThemeHelper.dart';
import 'package:dpr_car_rentals/src/repository/RegisterRepository.dart';
import 'package:dpr_car_rentals/src/widget/CustomButton.dart';
import 'package:dpr_car_rentals/src/widget/CustomText.dart';
import 'package:dpr_car_rentals/src/widget/CustomTextField.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final SessionHelpers sessionHelpers = SessionHelpers();
  final RegisterRepositoryImpl registerRepository = RegisterRepositoryImpl();

  // Controllers for user fields
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController driverLicenseController = TextEditingController();
  final TextEditingController paymentPreferenceController =
      TextEditingController();

  // Controllers for owner fields
  final TextEditingController ownerPhoneController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController bankNameController = TextEditingController();
  final TextEditingController bankAccountController = TextEditingController();

  // Country code selection
  String? selectedCountryCode;
  final List<String> countryCodes = [
    '+1 (US)',
    '+63 (PH)',
    '+65 (SG)',
    '+60 (MY)',
    '+62 (ID)'
  ];

  String? userRole;
  String? userId;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final userInfo = await sessionHelpers.getUserInfo();
    if (userInfo != null) {
      userId = userInfo['uid'];
      userRole = userInfo['role'];

      if (userId != null) {
        context.read<ProfileBloc>().add(LoadProfile(userId!));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ThemeHelper.primaryColor,
      appBar: AppBar(
        title: CustomText(
            text: 'Edit Profile',
            size: 20,
            color: Colors.white,
            fontFamily: 'Inter',
            weight: FontWeight.w700),
        backgroundColor: Colors.blue,
      ),
      body: BlocConsumer<ProfileBloc, ProfileState>(
        listener: (context, state) {
          if (state is ProfileUpdated) {
            Fluttertoast.showToast(msg: state.message);
            Navigator.pop(context);
          } else if (state is ProfileError) {
            Fluttertoast.showToast(msg: state.message);
          }
        },
        builder: (context, state) {
          if (state is ProfileLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is ProfileLoaded) {
            // Pre-populate fields with existing data
            _populateFields(state.userData);
            return _buildForm();
          } else if (state is ProfileError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(state.message),
                  ElevatedButton(
                    onPressed: () => _loadUserData(),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }
          return _buildForm();
        },
      ),
    );
  }

  void _populateFields(Map<String, dynamic> userData) {
    if (userRole == 'user') {
      phoneController.text = _extractPhoneNumber(userData['PhoneNumber'] ?? '');
      driverLicenseController.text = userData['DriverLicenseNumber'] ?? '';
      paymentPreferenceController.text = userData['PaymentPreference'] ?? '';
    } else if (userRole == 'owner') {
      ownerPhoneController.text =
          _extractPhoneNumber(userData['PhoneNumber'] ?? '');
      addressController.text = userData['Address'] ?? '';
      bankNameController.text = userData['BankName'] ?? '';
      bankAccountController.text = userData['BankAccountNumber'] ?? '';
    }
  }

  String _extractPhoneNumber(String fullPhone) {
    if (fullPhone.isEmpty) return '';
    // Extract just the phone number part (remove country code)
    final parts = fullPhone.split(' ');
    if (parts.length > 1) {
      return parts.sublist(1).join(' ');
    }
    return fullPhone;
  }

  Widget _buildForm() {
    final double screenWidth = MediaQuery.of(context).size.width;

    return Center(
      child: SingleChildScrollView(
        child: Form(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CustomText(
                text: 'Edit Your Profile',
                size: 24,
                color: Colors.black,
                fontFamily: 'Inter',
                weight: FontWeight.w600,
              ),
              const SizedBox(height: 20),
              if (userRole == 'user') ..._buildUserFields(screenWidth),
              if (userRole == 'owner') ..._buildOwnerFields(screenWidth),
              const SizedBox(height: 32),
              SizedBox(
                width: screenWidth * 0.6,
                height: 50,
                child: CustomButton(
                  text: 'Save Changes',
                  textColor: Colors.white,
                  backgroundColor: Colors.blue,
                  onPressed: _saveProfile,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _buildUserFields(double screenWidth) {
    return [
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
      // Driver License Number Field
      SizedBox(
        width: screenWidth * 0.8,
        child: CustomTextField(
          hintText: 'Enter your driver license number',
          controller: driverLicenseController,
          labelText: 'Driver License Number',
        ),
      ),
      const SizedBox(height: 16),
      // Payment Preference Field
      SizedBox(
        width: screenWidth * 0.8,
        child: CustomTextField(
          hintText: 'Enter your payment preference',
          controller: paymentPreferenceController,
          labelText: 'Payment Preference',
        ),
      ),
    ];
  }

  List<Widget> _buildOwnerFields(double screenWidth) {
    return [
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
        ),
      ),
      const SizedBox(height: 16),
      // Phone Number Field
      SizedBox(
        width: screenWidth * 0.8,
        child: TextFormField(
          controller: ownerPhoneController,
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
    ];
  }

  void _saveProfile() {
    if (userId == null) {
      Fluttertoast.showToast(msg: 'User not found');
      return;
    }

    Map<String, dynamic> details = {};

    if (userRole == 'user') {
      final phone = phoneController.text.trim();
      if (selectedCountryCode == null) {
        Fluttertoast.showToast(msg: 'Please select country code');
        return;
      }
      final fullPhoneNumber = '$selectedCountryCode $phone';
      details = {
        'PhoneNumber': fullPhoneNumber,
        'DriverLicenseNumber': driverLicenseController.text.trim(),
        'PaymentPreference': paymentPreferenceController.text.trim(),
      };
    } else if (userRole == 'owner') {
      final phone = ownerPhoneController.text.trim();
      if (selectedCountryCode == null) {
        Fluttertoast.showToast(msg: 'Please select country code');
        return;
      }
      final fullPhoneNumber = '$selectedCountryCode $phone';
      details = {
        'PhoneNumber': fullPhoneNumber,
        'Address': addressController.text.trim(),
        'BankName': bankNameController.text.trim(),
        'BankAccountNumber': bankAccountController.text.trim(),
      };
    }

    context.read<ProfileBloc>().add(UpdateProfile(userId!, details));
  }
}
