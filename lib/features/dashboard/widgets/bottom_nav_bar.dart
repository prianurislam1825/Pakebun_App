import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:pakebun_app/common/theme/app_theme.dart';
import 'package:flutter_svg/flutter_svg.dart';

class BottomNavBar extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onItemSelected;

  const BottomNavBar({
    super.key,
    required this.selectedIndex,
    required this.onItemSelected,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: AppTheme.spacingM,
          vertical: AppTheme.spacingS,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildNavItem(
              context,
              0,
              Icons.home_outlined,
              Icons.home,
              'Beranda',
              customIcon: SvgPicture.asset(
                'assets/icon/home.svg',
                width: 24.w,
                height: 24.w,
                colorFilter: ColorFilter.mode(
                  selectedIndex == 0
                      ? AppTheme.primaryGreen
                      : AppTheme.textLight,
                  BlendMode.srcIn,
                ),
              ),
            ),
            _buildNavItem(
              context,
              1,
              Icons.local_florist_outlined,
              Icons.local_florist,
              'Kebunku',
              customIcon: SvgPicture.asset(
                'assets/icon/kebunku.svg',
                width: 24.w,
                height: 24.w,
                colorFilter: ColorFilter.mode(
                  selectedIndex == 1
                      ? AppTheme.primaryGreen
                      : AppTheme.textLight,
                  BlendMode.srcIn,
                ),
              ),
            ),
            _buildNavItem(
              context,
              2,
              Icons.person_outline,
              Icons.person,
              'Akun',
              customIcon: SvgPicture.asset(
                'assets/icon/profile.svg',
                width: 24.w,
                height: 24.w,
                colorFilter: ColorFilter.mode(
                  selectedIndex == 2
                      ? AppTheme.primaryGreen
                      : AppTheme.textLight,
                  BlendMode.srcIn,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(
    BuildContext context,
    int index,
    IconData icon,
    IconData selectedIcon,
    String label, {
    Widget? customIcon,
  }) {
    final isSelected = selectedIndex == index;

    return GestureDetector(
      onTap: () {
        onItemSelected(index);
        // Navigate to different screens based on index
        switch (index) {
          case 0:
            context.go('/dashboard');
            break;
          case 1:
            context.go('/garden');
            break;
          case 2:
            context.go('/profile');
            break;
        }
      },
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: AppTheme.spacingM,
          vertical: AppTheme.spacingS,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            customIcon ??
                Icon(
                  isSelected ? selectedIcon : icon,
                  color: isSelected
                      ? AppTheme.primaryGreen
                      : AppTheme.textLight,
                  size: 24.sp,
                ),
            SizedBox(height: 4.h),
            Text(
              label,
              style: AppTheme.caption.copyWith(
                color: isSelected ? AppTheme.primaryGreen : AppTheme.textLight,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
