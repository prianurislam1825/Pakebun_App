import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pakebun_app/common/theme/app_theme.dart';
import 'package:pakebun_app/common/widgets/custom_card.dart';

class GardenCard extends StatelessWidget {
  final String name;
  final String plantType;
  final String status;
  final Color statusColor;
  final String imagePath;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const GardenCard({
    super.key,
    required this.name,
    required this.plantType,
    required this.status,
    required this.statusColor,
    required this.imagePath,
    this.onTap,
    this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return CustomCard(
      onTap: onTap,
      margin: EdgeInsets.only(bottom: AppTheme.spacingM),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Garden Image
          Container(
            height: 120.h,
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppTheme.radiusM),
              image: DecorationImage(
                image: AssetImage(imagePath),
                fit: BoxFit.cover,
              ),
            ),
            child: Stack(
              children: [
                // Status Badge
                Positioned(
                  top: AppTheme.spacingS,
                  right: AppTheme.spacingS,
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: AppTheme.spacingS,
                      vertical: 4.h,
                    ),
                    decoration: BoxDecoration(
                      color: statusColor.withValues(alpha: 0.9),
                      borderRadius: BorderRadius.circular(AppTheme.radiusS),
                    ),
                    child: Text(
                      status,
                      style: AppTheme.caption.copyWith(
                        color: AppTheme.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                // Action Buttons
                Positioned(
                  top: AppTheme.spacingS,
                  left: AppTheme.spacingS,
                  child: Row(
                    children: [
                      if (onEdit != null)
                        Container(
                          padding: EdgeInsets.all(6.w),
                          decoration: BoxDecoration(
                            color: AppTheme.white.withValues(alpha: 0.9),
                            borderRadius: BorderRadius.circular(
                              AppTheme.radiusS,
                            ),
                          ),
                          child: GestureDetector(
                            onTap: onEdit,
                            child: Icon(
                              Icons.edit,
                              size: 16.sp,
                              color: AppTheme.primaryGreen,
                            ),
                          ),
                        ),
                      if (onDelete != null) ...[
                        SizedBox(width: AppTheme.spacingS),
                        Container(
                          padding: EdgeInsets.all(6.w),
                          decoration: BoxDecoration(
                            color: AppTheme.white.withValues(alpha: 0.9),
                            borderRadius: BorderRadius.circular(
                              AppTheme.radiusS,
                            ),
                          ),
                          child: GestureDetector(
                            onTap: onDelete,
                            child: Icon(
                              Icons.delete,
                              size: 16.sp,
                              color: AppTheme.error,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: AppTheme.spacingM),
          // Garden Info
          Text(
            name,
            style: AppTheme.heading3,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          SizedBox(height: 4.h),
          Text(
            plantType,
            style: AppTheme.bodyMedium.copyWith(color: AppTheme.textSecondary),
          ),
          SizedBox(height: AppTheme.spacingM),
          // Garden Stats
          Row(
            children: [
              Expanded(
                child: _buildStatItem(
                  'Suhu',
                  '28°C',
                  Icons.thermostat,
                  AppTheme.warning,
                ),
              ),
              SizedBox(width: AppTheme.spacingM),
              Expanded(
                child: _buildStatItem(
                  'Kelembapan',
                  '65%',
                  Icons.water_drop,
                  AppTheme.info,
                ),
              ),
              SizedBox(width: AppTheme.spacingM),
              Expanded(
                child: _buildStatItem(
                  'pH',
                  '6.8',
                  Icons.science,
                  AppTheme.success,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Column(
      children: [
        Icon(icon, color: color, size: 16.sp),
        SizedBox(height: 4.h),
        Text(
          value,
          style: AppTheme.bodySmall.copyWith(
            fontWeight: FontWeight.w600,
            color: AppTheme.textPrimary,
          ),
        ),
        Text(label, style: AppTheme.caption),
      ],
    );
  }
}
