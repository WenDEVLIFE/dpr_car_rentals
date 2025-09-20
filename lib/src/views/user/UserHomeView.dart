import 'dart:async';
import 'package:dpr_car_rentals/src/bloc/UserHomeBloc.dart';
import 'package:dpr_car_rentals/src/bloc/event/UserHomeEvent.dart';
import 'package:dpr_car_rentals/src/bloc/state/UserHomeState.dart';
import 'package:dpr_car_rentals/src/bloc/ChatBloc.dart';
import 'package:dpr_car_rentals/src/bloc/event/ChatEvent.dart';
import 'package:dpr_car_rentals/src/bloc/state/ChatState.dart';
import 'package:dpr_car_rentals/src/helpers/ThemeHelper.dart';
import 'package:dpr_car_rentals/src/models/CarModel.dart';
import 'package:dpr_car_rentals/src/models/UserModel.dart';
import 'package:dpr_car_rentals/src/repository/ReservationRepository.dart';
import 'package:dpr_car_rentals/src/views/NotificationView.dart';
import 'package:dpr_car_rentals/src/views/user/BookCarView.dart';
import 'package:dpr_car_rentals/src/views/user/ChatMessagesView.dart';
import 'package:dpr_car_rentals/src/widget/CustomButton.dart';
import 'package:dpr_car_rentals/src/widget/CustomText.dart';
import 'package:dpr_car_rentals/src/widget/ImageZoomView.dart';
import 'package:dpr_car_rentals/src/views/user/UserBookingsView.dart';
import 'package:dpr_car_rentals/src/widget/ModernSearchBar.dart';
import 'package:dpr_car_rentals/src/widget/CarDisplayWidgets.dart';
import 'package:dpr_car_rentals/src/widget/ChatWidgets.dart';
import 'package:dpr_car_rentals/src/helpers/DebugHelper.dart';
import 'package:dpr_car_rentals/src/widget/UnreadNotificationBadge.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';

class UserHomeView extends StatefulWidget {
  const UserHomeView({super.key});

  @override
  State<UserHomeView> createState() => _UserHomeViewState();
}

class _UserHomeViewState extends State<UserHomeView> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final GlobalKey _featuredCarsKey = GlobalKey();
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
    _scrollController.dispose();
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
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    return BlocBuilder<UserHomeBloc, UserHomeState>(
      builder: (context, state) {
        if (state is UserHomeLoading) {
          return Scaffold(
            backgroundColor: ThemeHelper.backgroundColor,
            appBar: AppBar(
              title: CustomText(
                  text: 'Home',
                  size: 20,
                  color: Colors.white,
                  fontFamily: 'Inter',
                  weight: FontWeight.w700),
              elevation: 0,
              backgroundColor: Colors.blue,
              foregroundColor: Colors.blue,
              actions: [
                UnreadNotificationBadge(
                  child: IconButton(
                    icon: const Icon(Icons.notifications, color: Colors.white),
                    onPressed: null, // Handled by UnreadNotificationBadge
                  ),
                ),
              ],
            ),
            body: const Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        if (state is UserHomeError) {
          return Scaffold(
            backgroundColor: ThemeHelper.backgroundColor,
            appBar: AppBar(
              title: CustomText(
                  text: 'Home',
                  size: 20,
                  color: Colors.white,
                  fontFamily: 'Inter',
                  weight: FontWeight.w700),
              elevation: 0,
              backgroundColor: Colors.blue,
              foregroundColor: Colors.blue,
              actions: [
                UnreadNotificationBadge(
                  child: IconButton(
                    icon: const Icon(Icons.notifications, color: Colors.white),
                    onPressed: null, // Handled by UnreadNotificationBadge
                  ),
                ),
              ],
            ),
            body: Center(
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
                    text: 'Error loading data',
                    size: 18,
                    color: ThemeHelper.textColor,
                    fontFamily: 'Inter',
                    weight: FontWeight.w500,
                  ),
                  SizedBox(height: screenHeight * 0.01),
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
            ),
          );
        }

        if (state is UserHomeLoaded) {
          return Scaffold(
            backgroundColor: ThemeHelper.backgroundColor,
            appBar: AppBar(
              title: CustomText(
                  text: 'Home',
                  size: 20,
                  color: Colors.white,
                  fontFamily: 'Inter',
                  weight: FontWeight.w700),
              elevation: 0,
              backgroundColor: Colors.blue,
              foregroundColor: Colors.blue,
              actions: [
                UnreadNotificationBadge(
                  child: IconButton(
                    icon: const Icon(Icons.notifications, color: Colors.white),
                    onPressed: null, // Handled by UnreadNotificationBadge
                  ),
                ),
              ],
            ),
            body: SafeArea(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header Section
                      _buildHeader(state.user),

                      const SizedBox(height: 24),

                      // Search Bar
                      ModernSearchBar(
                        controller: _searchController,
                        hintText: 'Search for cars...',
                        onChanged: (query) {
                          _onSearchChanged(query);
                        },
                        onClear: () {
                          context.read<UserHomeBloc>().add(SearchCars(''));
                        },
                      ),

                      SizedBox(height: screenHeight * 0.03),

                      // Quick Actions
                      _buildQuickActions(),

                      SizedBox(height: screenHeight * 0.03),

                      // Approved Cars Section
                      _buildApprovedCars(state.activeCars),

                      SizedBox(height: screenHeight * 0.03),
                    ],
                  ),
                ),
              ),
            ),
          );
        }

        return Scaffold(
          backgroundColor: ThemeHelper.backgroundColor,
          appBar: AppBar(
            title: CustomText(
                text: 'Home',
                size: 20,
                color: Colors.white,
                fontFamily: 'Inter',
                weight: FontWeight.w700),
            elevation: 0,
            backgroundColor: Colors.blue,
            foregroundColor: Colors.blue,
            actions: [
              UnreadNotificationBadge(
                child: IconButton(
                  icon: const Icon(Icons.notifications, color: Colors.white),
                  onPressed: null, // Handled by UnreadNotificationBadge
                ),
              ),
            ],
          ),
          body: const Center(
            child: Text('Welcome to DPR Car Rentals'),
          ),
        );
      },
    );
  }

  Widget _buildHeader(UserModel? user) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CustomText(
                  text: 'Welcome back!',
                  size: 16,
                  color: ThemeHelper.textColor1,
                  fontFamily: 'Inter',
                  weight: FontWeight.w400,
                ),
                const SizedBox(height: 4),
                CustomText(
                  text: user?.fullName ?? 'User',
                  size: 24,
                  color: ThemeHelper.textColor,
                  fontFamily: 'Inter',
                  weight: FontWeight.w600,
                ),
              ],
            ),
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: ThemeHelper.accentColor,
                borderRadius: BorderRadius.circular(25),
              ),
              child: const Icon(
                Icons.person,
                color: Colors.white,
                size: 24,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildQuickActions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CustomText(
          text: 'Quick Actions',
          size: 20,
          color: ThemeHelper.textColor,
          fontFamily: 'Inter',
          weight: FontWeight.w600,
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildActionCard(
                icon: Icons.directions_car,
                title: 'Rent a Car',
                subtitle: 'Browse available vehicles',
                color: ThemeHelper.buttonColor,
                onTap: () {
                  _scrollToFeaturedCars();
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildActionCard(
                icon: Icons.history,
                title: 'My Bookings',
                subtitle: 'View rental history',
                color: ThemeHelper.accentColor,
                onTap: () {
                  // Navigate to bookings screen
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const UserBookingsView(),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
      ],
    );
  }

  Widget _buildActionCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
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
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                color: color,
                size: 20,
              ),
            ),
            const SizedBox(height: 12),
            CustomText(
              text: title,
              size: 14,
              color: ThemeHelper.textColor,
              fontFamily: 'Inter',
              weight: FontWeight.w600,
            ),
            const SizedBox(height: 4),
            CustomText(
              text: subtitle,
              size: 12,
              color: ThemeHelper.textColor1,
              fontFamily: 'Inter',
              weight: FontWeight.w400,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeaturedCars(List<FeaturedCar> featuredCars) {
    double screenHeight = MediaQuery.of(context).size.height;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            CustomText(
              text: 'Featured Cars',
              size: 20,
              color: ThemeHelper.textColor,
              fontFamily: 'Inter',
              weight: FontWeight.w600,
            ),
            TextButton(
              onPressed: () {
                // TODO: Navigate to all cars
              },
              child: CustomText(
                text: 'View All',
                size: 14,
                color: ThemeHelper.buttonColor,
                fontFamily: 'Inter',
                weight: FontWeight.w500,
              ),
            ),
          ],
        ),
        SizedBox(height: screenHeight * 0.01),
        SizedBox(
          height: screenHeight * 0.25,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: featuredCars.length,
            itemBuilder: (context, index) {
              return _buildCarCard(featuredCars[index]);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildCarCard(FeaturedCar car) {
    return Container(
      width: 160,
      margin: const EdgeInsets.only(right: 12),
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
          Container(
            height: 100,
            decoration: BoxDecoration(
              color: ThemeHelper.secondaryColor,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Center(
              child: Text(
                car.image,
                style: const TextStyle(fontSize: 40),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CustomText(
                  text: car.name,
                  size: 14,
                  color: ThemeHelper.textColor,
                  fontFamily: 'Inter',
                  weight: FontWeight.w600,
                ),
                const SizedBox(height: 4),
                CustomText(
                  text: car.price,
                  size: 12,
                  color: ThemeHelper.buttonColor,
                  fontFamily: 'Inter',
                  weight: FontWeight.w500,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildApprovedCars(List<CarModel> cars) {
    return Column(
      key: _featuredCarsKey,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            CustomText(
              text: 'Featured Cars',
              size: 20,
              color: ThemeHelper.textColor,
              fontFamily: 'Inter',
              weight: FontWeight.w600,
            ),
            TextButton(
              onPressed: () {
                // TODO: Navigate to all available cars
              },
              child: CustomText(
                text: 'View All',
                size: 14,
                color: ThemeHelper.buttonColor,
                fontFamily: 'Inter',
                weight: FontWeight.w500,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        CarGridWidget(
          cars: cars,
          onCarTap: (car) => _showCarDetailsDialog(context, car),
          emptyMessage: 'No cars available',
          crossAxisCount: 2,
          childAspectRatio: 0.75,
        ),
      ],
    );
  }

  void _scrollToFeaturedCars() {
    Scrollable.ensureVisible(
      _featuredCarsKey.currentContext!,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    );
  }

  Widget _buildApprovedCarCard(CarModel car) {
    return Container(
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
          // Car Image
          Expanded(
            flex: 3,
            child: Container(
              decoration: BoxDecoration(
                color: ThemeHelper.secondaryColor,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  topRight: Radius.circular(12),
                ),
              ),
              child: car.photoUrl != null
                  ? ClipRRect(
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(12),
                        topRight: Radius.circular(12),
                      ),
                      child: Image.network(
                        car.photoUrl!,
                        fit: BoxFit.cover,
                        width: double.infinity,
                        height: double.infinity,
                        errorBuilder: (context, error, stackTrace) {
                          return const Center(
                            child: Icon(
                              Icons.directions_car,
                              size: 40,
                              color: Colors.grey,
                            ),
                          );
                        },
                      ),
                    )
                  : const Center(
                      child: Icon(
                        Icons.directions_car,
                        size: 40,
                        color: Colors.grey,
                      ),
                    ),
            ),
          ),
          // Car Details
          Expanded(
            flex: 2,
            child: Padding(
              padding: const EdgeInsets.all(6),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Car info - takes available space
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '${car.name} ${car.model}',
                          style: TextStyle(
                            fontSize: 11,
                            color: ThemeHelper.textColor,
                            fontFamily: 'Inter',
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 1),
                        Text(
                          '₱${car.dailyRate.toStringAsFixed(0)}/day',
                          style: TextStyle(
                            fontSize: 10,
                            color: ThemeHelper.buttonColor,
                            fontFamily: 'Inter',
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 1),
                        Text(
                          car.location,
                          style: TextStyle(
                            fontSize: 9,
                            color: ThemeHelper.textColor1,
                            fontFamily: 'Inter',
                            fontWeight: FontWeight.w400,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),

                  // View Details Button - fixed minimal size
                  SizedBox(
                    height: 24,
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: ThemeHelper.buttonColor,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 2, vertical: 0),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4),
                        ),
                        minimumSize: const Size(0, 24),
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      onPressed: () {
                        _showCarDetailsDialog(context, car);
                      },
                      child: Text(
                        'View',
                        style: TextStyle(
                          fontSize: 9,
                          color: Colors.white,
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
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

  Widget _buildRecentActivity(List<RecentActivity> activities) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CustomText(
          text: 'Recent Activity',
          size: 20,
          color: ThemeHelper.textColor,
          fontFamily: 'Inter',
          weight: FontWeight.w600,
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
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
            children: activities.asMap().entries.map((entry) {
              final index = entry.key;
              final activity = entry.value;
              return Column(
                children: [
                  _buildActivityItem(
                    icon: _getIconData(activity.icon),
                    title: activity.title,
                    subtitle: activity.subtitle,
                    color: _getColor(activity.color),
                  ),
                  if (index < activities.length - 1) const Divider(height: 16),
                ],
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildActivityItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: color,
            size: 16,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CustomText(
                text: title,
                size: 14,
                color: ThemeHelper.textColor,
                fontFamily: 'Inter',
                weight: FontWeight.w500,
              ),
              CustomText(
                text: subtitle,
                size: 12,
                color: ThemeHelper.textColor1,
                fontFamily: 'Inter',
                weight: FontWeight.w400,
              ),
            ],
          ),
        ),
      ],
    );
  }

  IconData _getIconData(String iconName) {
    switch (iconName) {
      case 'directions_car':
        return Icons.directions_car;
      case 'location_on':
        return Icons.location_on;
      case 'payment':
        return Icons.payment;
      default:
        return Icons.info;
    }
  }

  Color _getColor(String colorName) {
    switch (colorName) {
      case 'green':
        return Colors.green;
      case 'blue':
        return Colors.blue;
      case 'orange':
        return Colors.orange;
      case 'red':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  Widget _buildWelcomeSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Colors.blue, Colors.blueAccent],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: const Icon(
                  Icons.account_circle,
                  color: Colors.white,
                  size: 30,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CustomText(
                      text: 'Welcome back!',
                      size: 18,
                      color: Colors.white,
                      fontFamily: 'Inter',
                      weight: FontWeight.w600,
                    ),
                    const SizedBox(height: 4),
                    CustomText(
                      text: 'Ready to rent a car today?',
                      size: 14,
                      color: Colors.white.withOpacity(0.9),
                      fontFamily: 'Inter',
                      weight: FontWeight.w400,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Debug buttons for testing notifications
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              ElevatedButton(
                onPressed: DebugHelper.checkUserInfo,
                child: const Text('Check User Info'),
              ),
              ElevatedButton(
                onPressed: DebugHelper.checkNotifications,
                child: const Text('Check Notifications'),
              ),
              ElevatedButton(
                onPressed: DebugHelper.createTestNotification,
                child: const Text('Create Test Notification'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const NotificationView(),
                    ),
                  );
                },
                child: const Text('View Notifications'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
