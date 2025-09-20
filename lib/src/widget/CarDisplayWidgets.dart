import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../helpers/ThemeHelper.dart';
import '../models/CarModel.dart';
import 'CustomText.dart';
import 'ImageZoomView.dart';

/// Displays cars in a grid layout (for user views)
class CarGridWidget extends StatelessWidget {
  final List<CarModel> cars;
  final Function(CarModel) onCarTap;
  final String? emptyMessage;
  final int crossAxisCount;
  final double childAspectRatio;

  const CarGridWidget({
    super.key,
    required this.cars,
    required this.onCarTap,
    this.emptyMessage,
    this.crossAxisCount = 2,
    this.childAspectRatio = 0.75,
  });

  @override
  Widget build(BuildContext context) {
    if (cars.isEmpty) {
      return _buildEmptyState();
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount:
            MediaQuery.of(context).size.width > 600 ? 3 : crossAxisCount,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: childAspectRatio,
      ),
      itemCount: cars.length,
      itemBuilder: (context, index) {
        return CarGridCard(
          car: cars[index],
          onTap: () => onCarTap(cars[index]),
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(40),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.directions_car,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          CustomText(
            text: emptyMessage ?? 'No cars available',
            size: 18,
            color: Colors.grey[600]!,
            fontFamily: 'Inter',
            weight: FontWeight.w500,
          ),
          const SizedBox(height: 8),
          CustomText(
            text: 'Check back later for available vehicles',
            size: 14,
            color: Colors.grey[500]!,
            fontFamily: 'Inter',
            weight: FontWeight.w400,
          ),
        ],
      ),
    );
  }
}

/// Grid card component for user views
class CarGridCard extends StatelessWidget {
  final CarModel car;
  final VoidCallback onTap;

  const CarGridCard({
    super.key,
    required this.car,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
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
            child: CarImageWidget(
              imageUrl: car.photoUrl,
              heroTag: 'car_image_${car.id}',
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
              iconSize: 40,
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

                  // View Details Button
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
                      onPressed: onTap,
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
}

/// List widget for admin/owner views
class CarListWidget extends StatelessWidget {
  final List<CarModel> cars;
  final Function(CarModel) onCarTap;
  final String? emptyMessage;
  final String? emptySubMessage;
  final Widget? emptyActionButton;
  final List<Widget> Function(CarModel)? actionButtons;

  const CarListWidget({
    super.key,
    required this.cars,
    required this.onCarTap,
    this.emptyMessage,
    this.emptySubMessage,
    this.emptyActionButton,
    this.actionButtons,
  });

  @override
  Widget build(BuildContext context) {
    if (cars.isEmpty) {
      return _buildEmptyState();
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: cars.length,
      itemBuilder: (context, index) {
        return CarListCard(
          car: cars[index],
          onTap: () => onCarTap(cars[index]),
          actionButtons: actionButtons?.call(cars[index]) ?? [],
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.directions_car_outlined,
            size: 64,
            color: ThemeHelper.textColor1,
          ),
          const SizedBox(height: 16),
          CustomText(
            text: emptyMessage ?? 'No cars found',
            size: 18,
            color: ThemeHelper.textColor,
            fontFamily: 'Inter',
            weight: FontWeight.w500,
          ),
          if (emptySubMessage != null) ...[
            const SizedBox(height: 8),
            CustomText(
              text: emptySubMessage!,
              size: 14,
              color: ThemeHelper.textColor1,
              fontFamily: 'Inter',
              weight: FontWeight.w400,
            ),
          ],
          if (emptyActionButton != null) ...[
            const SizedBox(height: 16),
            emptyActionButton!,
          ],
        ],
      ),
    );
  }
}

/// List card component for admin/owner views
class CarListCard extends StatelessWidget {
  final CarModel car;
  final VoidCallback onTap;
  final List<Widget> actionButtons;

  const CarListCard({
    super.key,
    required this.car,
    required this.onTap,
    required this.actionButtons,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Car Header
              Row(
                children: [
                  // Car Image
                  CarImageWidget(
                    imageUrl: car.photoUrl,
                    heroTag: 'car_${car.id}',
                    width: 80,
                    height: 80,
                    iconSize: 40,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  const SizedBox(width: 12),
                  // Car Info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CustomText(
                          text: '${car.name} ${car.model}',
                          size: 18,
                          color: ThemeHelper.textColor,
                          fontFamily: 'Inter',
                          weight: FontWeight.w600,
                        ),
                        const SizedBox(height: 4),
                        CustomText(
                          text: '${car.year} • ${car.licensePlate}',
                          size: 14,
                          color: ThemeHelper.textColor1,
                          fontFamily: 'Inter',
                          weight: FontWeight.w400,
                        ),
                        CustomText(
                          text: car.location,
                          size: 14,
                          color: ThemeHelper.textColor1,
                          fontFamily: 'Inter',
                          weight: FontWeight.w400,
                        ),
                      ],
                    ),
                  ),
                  // Status Badge
                  CarStatusBadge(status: car.status),
                ],
              ),

              const SizedBox(height: 12),

              // Car Details and Actions
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CustomText(
                          text: '₱${car.dailyRate.toStringAsFixed(0)}/day',
                          size: 16,
                          color: ThemeHelper.buttonColor,
                          fontFamily: 'Inter',
                          weight: FontWeight.w600,
                        ),
                        CustomText(
                          text:
                              'Added: ${DateFormat('MMM dd, yyyy').format(car.createdAt)}',
                          size: 12,
                          color: ThemeHelper.textColor1,
                          fontFamily: 'Inter',
                          weight: FontWeight.w400,
                        ),
                      ],
                    ),
                  ),
                  // Action Buttons
                  if (actionButtons.isNotEmpty) Row(children: actionButtons),
                ],
              ),

              // Status Messages
              _buildStatusMessage(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusMessage() {
    Widget? statusWidget;

    if (car.status == CarStatus.pending) {
      statusWidget = Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.orange.withOpacity(0.1),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Row(
          children: [
            const Icon(Icons.pending, size: 16, color: Colors.orange),
            const SizedBox(width: 8),
            Expanded(
              child: CustomText(
                text: 'Car is pending approval from admin',
                size: 12,
                color: Colors.orange,
                fontFamily: 'Inter',
                weight: FontWeight.w400,
              ),
            ),
          ],
        ),
      );
    } else if (car.status == CarStatus.rejected &&
        car.rejectionReason != null) {
      statusWidget = Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.red.withOpacity(0.1),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Row(
          children: [
            const Icon(Icons.error, size: 16, color: Colors.red),
            const SizedBox(width: 8),
            Expanded(
              child: CustomText(
                text: 'Rejected: ${car.rejectionReason}',
                size: 12,
                color: Colors.red,
                fontFamily: 'Inter',
                weight: FontWeight.w400,
              ),
            ),
          ],
        ),
      );
    }

    return statusWidget != null
        ? Padding(
            padding: const EdgeInsets.only(top: 8),
            child: statusWidget,
          )
        : const SizedBox.shrink();
  }
}

/// Reusable car image widget
class CarImageWidget extends StatelessWidget {
  final String? imageUrl;
  final String heroTag;
  final double? width;
  final double? height;
  final BorderRadiusGeometry? borderRadius;
  final double iconSize;

  const CarImageWidget({
    super.key,
    required this.imageUrl,
    required this.heroTag,
    this.width,
    this.height,
    this.borderRadius,
    this.iconSize = 30,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: imageUrl != null
          ? () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ImageZoomView(
                    imageUrl: imageUrl!,
                    heroTag: heroTag,
                  ),
                ),
              )
          : null,
      child: Hero(
        tag: heroTag,
        child: Container(
          width: width,
          height: height,
          decoration: BoxDecoration(
            color: ThemeHelper.secondaryColor,
            borderRadius: borderRadius ?? BorderRadius.circular(8),
          ),
          child: imageUrl != null
              ? ClipRRect(
                  borderRadius: borderRadius ?? BorderRadius.circular(8),
                  child: Image.network(
                    imageUrl!,
                    fit: BoxFit.cover,
                    width: double.infinity,
                    height: double.infinity,
                    errorBuilder: (context, error, stackTrace) {
                      return Center(
                        child: Icon(
                          Icons.directions_car,
                          size: iconSize,
                          color: Colors.grey,
                        ),
                      );
                    },
                  ),
                )
              : Center(
                  child: Icon(
                    Icons.directions_car,
                    size: iconSize,
                    color: Colors.grey,
                  ),
                ),
        ),
      ),
    );
  }
}

/// Status badge widget
class CarStatusBadge extends StatelessWidget {
  final CarStatus status;

  const CarStatusBadge({
    super.key,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    Color color;
    String text;

    switch (status) {
      case CarStatus.pending:
        color = Colors.orange;
        text = 'Pending';
        break;
      case CarStatus.active:
        color = Colors.green;
        text = 'Active';
        break;
      case CarStatus.inactive:
        color = Colors.grey;
        text = 'Inactive';
        break;
      case CarStatus.rejected:
        color = Colors.red;
        text = 'Rejected';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: CustomText(
        text: text,
        size: 12,
        color: color,
        fontFamily: 'Inter',
        weight: FontWeight.w500,
      ),
    );
  }
}
