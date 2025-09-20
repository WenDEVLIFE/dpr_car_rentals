import 'dart:async';
import 'package:dpr_car_rentals/src/bloc/UserHomeBloc.dart';
import 'package:dpr_car_rentals/src/bloc/event/UserHomeEvent.dart';
import 'package:dpr_car_rentals/src/bloc/state/UserHomeState.dart';
import 'package:dpr_car_rentals/src/bloc/ChatBloc.dart';
import 'package:dpr_car_rentals/src/bloc/event/ChatEvent.dart';
import 'package:dpr_car_rentals/src/bloc/state/ChatState.dart';
import 'package:dpr_car_rentals/src/helpers/ThemeHelper.dart';
import 'package:dpr_car_rentals/src/models/CarModel.dart';
import 'package:dpr_car_rentals/src/repository/ReservationRepository.dart';
import 'package:dpr_car_rentals/src/views/user/BookCarView.dart';
import 'package:dpr_car_rentals/src/views/user/ChatMessagesView.dart';
import 'package:dpr_car_rentals/src/widget/CustomButton.dart';
import 'package:dpr_car_rentals/src/widget/CustomText.dart';
import 'package:dpr_car_rentals/src/widget/ImageZoomView.dart';
import 'package:dpr_car_rentals/src/widget/CarDisplayWidgets.dart';
import 'package:dpr_car_rentals/src/widget/ChatWidgets.dart';
import 'package:dpr_car_rentals/src/widget/UnreadNotificationBadge.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';

class RentACarView extends StatefulWidget {
  const RentACarView({super.key});

  @override
  State<RentACarView> createState() => _RentACarViewState();
}

class _RentACarViewState extends State<RentACarView> {
  late double screenWidth;
  late double screenHeight;
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounceTimer;

  final ReservationRepositoryImpl _reservationRepository =
      ReservationRepositoryImpl();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  void initState() {
    super.initState();
    // Load home data when view initializes
    context.read<UserHomeBloc>().add(LoadHomeData());
  }

  @override
  void dispose() {
    _searchController.dispose();
    _debounceTimer?.cancel();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    // Cancel the previous timer
    _debounceTimer?.cancel();

    // Start a new timer
    _debounceTimer = Timer(const Duration(milliseconds: 300), () {
      context.read<UserHomeBloc>().add(SearchCars(query));
    });
  }

  Future<void> _navigateToBooking(CarModel car) async {
    // Check if user is logged in
    final currentUser = _auth.currentUser;
    if (currentUser == null) {
      _showToast('Please login to book a car');
      return;
    }

    // Check if user already has an active reservation
    final hasActiveReservation =
        await _reservationRepository.hasUserActiveReservation(currentUser.uid);
    if (hasActiveReservation) {
      _showToast(
          'You already have an active reservation. Please complete or cancel it first.');
      return;
    }

    // Navigate to booking screen
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BookCarView(car: car),
      ),
    );

    // Refresh if booking was successful
    if (result == true) {
      context.read<UserHomeBloc>().add(LoadHomeData());
    }
  }

  Future<void> _navigateToChat(CarModel car) async {
    // Check if user is logged in
    final currentUser = _auth.currentUser;
    if (currentUser == null) {
      _showToast('Please login to chat with the owner');
      return;
    }

    try {
      // Start chat with owner using ChatBloc
      context.read<ChatBloc>().add(StartChatWithOwner(
            ownerId: car.ownerId,
            carId: car.id,
            carName: '${car.name} ${car.model}',
          ));

      // Show loading toast
      _showToast('Starting chat with owner...');
    } catch (e) {
      _showToast('Failed to start chat: $e');
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    screenWidth = MediaQuery.of(context).size.width;
    screenHeight = MediaQuery.of(context).size.height;
  }

  void _showToast(String message) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: Colors.black87,
      textColor: Colors.white,
    );
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        BlocListener<ChatBloc, ChatState>(
          listener: (context, state) {
            if (state is ChatWithOwnerStarted) {
              // Navigate to chat messages
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ChatMessagesView(
                    chatId: state.chatId,
                    conversation: null, // Will be loaded in the view
                  ),
                ),
              );
            } else if (state is ChatError) {
              _showToast(state.message);
            }
          },
        ),
      ],
      child: _buildMainContent(),
    );
  }

  Widget _buildMainContent() {
    return Scaffold(
      backgroundColor: ThemeHelper.backgroundColor,
      appBar: AppBar(
        title: CustomText(
          text: 'Rent a Car',
          size: 20,
          color: Colors.white,
          fontFamily: 'Inter',
          weight: FontWeight.w700,
        ),
        actions: [
          UnreadNotificationBadge(
            child: IconButton(
              icon: const Icon(Icons.notifications, color: Colors.white),
              onPressed: null, // Handled by UnreadNotificationBadge
            ),
          ),
        ],
        elevation: 0,
        backgroundColor: Colors.blue,
        foregroundColor: Colors.blue,
      ),
      body: BlocBuilder<UserHomeBloc, UserHomeState>(
        builder: (context, state) {
          if (state is UserHomeLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (state is UserHomeError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.error_outline,
                    size: 64,
                    color: Colors.red,
                  ),
                  const SizedBox(height: 16),
                  CustomText(
                    text: 'Error loading cars',
                    size: 18,
                    color: ThemeHelper.textColor,
                    fontFamily: 'Inter',
                    weight: FontWeight.w500,
                  ),
                  const SizedBox(height: 8),
                  CustomText(
                    text: state.message,
                    size: 14,
                    color: ThemeHelper.textColor1,
                    fontFamily: 'Inter',
                    weight: FontWeight.w400,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      context.read<UserHomeBloc>().add(LoadHomeData());
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          if (state is UserHomeLoaded) {
            return SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header
                    CustomText(
                      text: 'Available Cars',
                      size: 24,
                      color: ThemeHelper.textColor,
                      fontFamily: 'Inter',
                      weight: FontWeight.w600,
                    ),
                    const SizedBox(height: 8),
                    CustomText(
                      text:
                          'Browse and rent from our collection of approved vehicles',
                      size: 14,
                      color: ThemeHelper.textColor1,
                      fontFamily: 'Inter',
                      weight: FontWeight.w400,
                    ),
                    const SizedBox(height: 24),

                    // Search Bar
                    Container(
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
                      child: TextField(
                        controller: _searchController,
                        decoration: InputDecoration(
                          hintText:
                              'Search cars by name, model, or location...',
                          hintStyle: TextStyle(
                            color: Colors.grey[400],
                            fontFamily: 'Inter',
                          ),
                          prefixIcon: const Icon(
                            Icons.search,
                            color: Colors.grey,
                          ),
                          suffixIcon: _searchController.text.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(
                                    Icons.clear,
                                    color: Colors.grey,
                                  ),
                                  onPressed: () {
                                    _searchController.clear();
                                    context
                                        .read<UserHomeBloc>()
                                        .add(SearchCars(''));
                                  },
                                )
                              : null,
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 16,
                          ),
                        ),
                        style: const TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 14,
                        ),
                        onChanged: (query) {
                          setState(() {}); // Update UI for clear button
                          _onSearchChanged(query);
                        },
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Cars Grid
                    CarGridWidget(
                      cars: state.activeCars,
                      onCarTap: (car) => _showCarDetailsDialog(context, car),
                      emptyMessage: 'No cars available',
                      crossAxisCount: screenWidth > 600 ? 3 : 2,
                      childAspectRatio: 0.75,
                    ),
                  ],
                ),
              ),
            );
          }

          return const Center(
            child: Text('Welcome to Car Rentals'),
          );
        },
      ),
    );
  }

  void _showCarDetailsDialog(BuildContext context, CarModel car) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Container(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.85,
              maxWidth: MediaQuery.of(context).size.width * 0.9,
            ),
            child: SingleChildScrollView(
              physics: const ClampingScrollPhysics(),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Car Image
                    Container(
                      height: 200,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: ThemeHelper.secondaryColor,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: car.photoUrl != null
                          ? GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => ImageZoomView(
                                      imageUrl: car.photoUrl!,
                                      heroTag: 'car_image_${car.id}',
                                    ),
                                  ),
                                );
                              },
                              child: Hero(
                                tag: 'car_image_${car.id}',
                                child: Image.network(
                                  car.photoUrl!,
                                  fit: BoxFit.cover,
                                  width: double.infinity,
                                  errorBuilder: (context, error, stackTrace) {
                                    return const Icon(
                                      Icons.directions_car,
                                      size: 80,
                                      color: Colors.grey,
                                    );
                                  },
                                ),
                              ),
                            )
                          : const Icon(
                              Icons.directions_car,
                              size: 80,
                              color: Colors.grey,
                            ),
                    ),
                    const SizedBox(height: 16),

                    // Car Details
                    CustomText(
                      text: '${car.name} ${car.model}',
                      size: 24,
                      color: ThemeHelper.textColor,
                      fontFamily: 'Inter',
                      weight: FontWeight.w600,
                    ),
                    const SizedBox(height: 8),

                    CustomText(
                      text: '₱${car.dailyRate.toStringAsFixed(0)}/day',
                      size: 20,
                      color: ThemeHelper.buttonColor,
                      fontFamily: 'Inter',
                      weight: FontWeight.w500,
                    ),
                    const SizedBox(height: 16),

                    // Car Information
                    Row(
                      children: [
                        const Icon(Icons.location_on,
                            size: 16, color: Colors.grey),
                        const SizedBox(width: 4),
                        Expanded(
                          child: CustomText(
                            text: car.location,
                            size: 14,
                            color: ThemeHelper.textColor1,
                            fontFamily: 'Inter',
                            weight: FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),

                    Row(
                      children: [
                        const Icon(Icons.calendar_today,
                            size: 16, color: Colors.grey),
                        const SizedBox(width: 4),
                        CustomText(
                          text: '${car.year} Model',
                          size: 14,
                          color: ThemeHelper.textColor1,
                          fontFamily: 'Inter',
                          weight: FontWeight.w400,
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),

                    Row(
                      children: [
                        const Icon(Icons.confirmation_number,
                            size: 16, color: Colors.grey),
                        const SizedBox(width: 4),
                        CustomText(
                          text: car.licensePlate,
                          size: 14,
                          color: ThemeHelper.textColor1,
                          fontFamily: 'Inter',
                          weight: FontWeight.w400,
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Action Buttons
                    Row(
                      children: [
                        Expanded(
                          child: CustomButton(
                            text: 'Book Now',
                            textColor: Colors.white,
                            backgroundColor: Colors.blue,
                            onPressed: () async {
                              Navigator.of(context).pop();
                              await _navigateToBooking(car);
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ChatWidgets.chatWithOwnerButton(
                            onPressed: () async {
                              Navigator.of(context).pop();
                              await _navigateToChat(car);
                            },
                            text: 'Chat Owner',
                            backgroundColor: Colors.green,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Close Button
                    SizedBox(
                      width: double.infinity,
                      child: CustomButton(
                        text: 'Close',
                        textColor: ThemeHelper.buttonColor,
                        backgroundColor: Colors.transparent,
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
