import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/localization/tamil_strings.dart';
import '../../core/router/app_router.dart';
import 'package:go_router/go_router.dart';

/// Placeholder home screen with feature grid
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          TamilStrings.appName,
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w700,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {},
          ),
        ],
      ),
      floatingActionButton: Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.45),
              blurRadius: 20,
              spreadRadius: 2,
            ),
          ],
        ),
        child: FloatingActionButton.large(
          heroTag: 'home_voice_hero',
          onPressed: () => context.push(AppRouter.screening),
          backgroundColor: AppColors.secondary,
          foregroundColor: Colors.white,
          elevation: 6,
          child: const Icon(Icons.mic_rounded, size: 36),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Welcome Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.primary, AppColors.primaryDark],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      TamilStrings.welcome,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 26,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      TamilStrings.welcomeMessage,
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Features heading
              const Text(
                'சேவைகள்', // Services
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 16),

              // Feature Grid
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                mainAxisSpacing: 14,
                crossAxisSpacing: 14,
                childAspectRatio: 1.1,
                children: const [
                  FeatureCard(
                    icon: Icons.medical_services_outlined,
                    label: TamilStrings.screening,
                    color: AppColors.screening,
                    route: AppRouter.screening,
                  ),
                  FeatureCard(
                    icon: Icons.calendar_month_outlined,
                    label: TamilStrings.cycleTracker,
                    color: AppColors.cycleTracker,
                    route: AppRouter.cycleTracker,
                  ),
                  FeatureCard(
                    icon: Icons.menu_book_outlined,
                    label: TamilStrings.healthNotebook,
                    color: AppColors.healthNotebook,
                    route: AppRouter.healthNotebook,
                  ),
                  FeatureCard(
                    icon: Icons.video_call_outlined,
                    label: TamilStrings.teleconsult,
                    color: AppColors.teleconsult,
                    route: AppRouter.teleconsult,
                  ),
                  FeatureCard(
                    icon: Icons.alarm_outlined,
                    label: TamilStrings.reminders,
                    color: AppColors.reminders,
                    route: AppRouter.reminders,
                  ),
                  FeatureCard(
                    icon: Icons.restaurant_menu_outlined,
                    label: TamilStrings.nutrition,
                    color: AppColors.nutrition,
                    route: AppRouter.home, // nutrition screen not yet implemented
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 8,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        height: 64,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            IconButton(
              tooltip: TamilStrings.home,
              icon: const Icon(Icons.home_rounded, size: 28),
              color: AppColors.primary,
              onPressed: () {},
            ),
            IconButton(
              tooltip: TamilStrings.cycleTracker,
              icon: const Icon(Icons.calendar_month_rounded, size: 28),
              color: AppColors.textSecondary,
              onPressed: () => context.push(AppRouter.cycleTracker),
            ),
            const SizedBox(width: 56),
            IconButton(
              tooltip: TamilStrings.healthNotebook,
              icon: const Icon(Icons.menu_book_rounded, size: 28),
              color: AppColors.textSecondary,
              onPressed: () => context.push(AppRouter.healthNotebook),
            ),
            IconButton(
              tooltip: TamilStrings.vhnMode,
              icon: const Icon(Icons.local_hospital_rounded, size: 28),
              color: AppColors.textSecondary,
              onPressed: () => context.push(AppRouter.vhnMode),
            ),
          ],
        ),
      ),
    );
  }
}

/// Reusable feature card widget
class FeatureCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final String route;

  const FeatureCard({
    super.key,
    required this.icon,
    required this.label,
    required this.color,
    required this.route,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: () => context.push(route),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 32),
              ),
              const SizedBox(height: 12),
              Text(
                label,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
