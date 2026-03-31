import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

/// Icon-only Bottom Navigation Bar designed for low-vision rural users.
/// Minimal cognitive load, 5 tabs, large 28px icons, active indicator styling,
/// and support for risk badges on specific tabs.
class IconNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;
  final bool hasAlert; // E.g., unread health risks or pending reminder alerts

  const IconNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
    this.hasAlert = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(bottom: 16, top: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            offset: const Offset(0, -4),
            blurRadius: 16,
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            // Home
            _buildNavItem(0, Icons.home_outlined, Icons.home),
            // Health / Screening (supports alert badge)
            _buildNavItem(1, Icons.medical_services_outlined, Icons.medical_services, showBadge: hasAlert),
            // Cycle/Calendar Tracker
            _buildNavItem(2, Icons.calendar_month_outlined, Icons.calendar_month),
            // Health Notebook / Records
            _buildNavItem(3, Icons.menu_book_outlined, Icons.menu_book),
            // Profile / VHN Interaction
            _buildNavItem(4, Icons.person_outline, Icons.person),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, IconData outlineIcon, IconData filledIcon, {bool showBadge = false}) {
    final bool isActive = currentIndex == index;
    
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => onTap(index),
      child: Container(
        height: 56, // Huge touch area boundary vertically
        width: 64,  // Huge touch area boundary horizontally
        alignment: Alignment.center,
        child: Stack(
          alignment: Alignment.center,
          clipBehavior: Clip.none,
          children: [
            Icon(
              isActive ? filledIcon : outlineIcon,
              color: isActive ? AppColors.primary : AppColors.textSecondary,
              size: 28, // Scaled up icon size specifically for visual accessibility
            ),
            
            // Risk / Notification Badge Layer
            if (showBadge)
              Positioned(
                top: -2,
                right: -4,
                child: Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: AppColors.riskRed,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppColors.surface,
                      width: 2, // Cut-out illusion against the main icon
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
