import 'package:flutter/material.dart';
import '../../../core/utils/simple_responsive.dart';
import '../../../config/theme/app_colors.dart';

/// Simple example showing the easiest way to use proportional responsive
class SimpleResponsiveExample extends StatelessWidget {
  const SimpleResponsiveExample({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Simple Responsive Example',
          style: TextStyle(fontSize: SR.sp(context, 18)),
        ),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: SR.p(context, 16), // 16px padding on all sides
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Device Info Card
            _buildDeviceInfoCard(context),

            SR.vSpace(context, 20), // 20px vertical spacing
            // Simple Container Example
            _buildSimpleContainer(context),

            SR.vSpace(context, 20),

            // Text Examples
            _buildTextExamples(context),

            SR.vSpace(context, 20),

            // Button Example
            _buildButtonExample(context),

            SR.vSpace(context, 20),

            // Layout Example
            _buildLayoutExample(context),
          ],
        ),
      ),
    );
  }

  Widget _buildDeviceInfoCard(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: SR.p(context, 16),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(SR.r(context, 12)),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Device Information',
            style: TextStyle(
              fontSize: SR.sp(context, 18),
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),
          SR.vSpace(context, 8),
          Text(
            SR.deviceInfo(context),
            style: TextStyle(
              fontSize: SR.sp(context, 14),
              color: AppColors.textDark,
            ),
          ),
          SR.vSpace(context, 8),
          Text(
            'Formula: (widget_size / 360) * device_width',
            style: TextStyle(
              fontSize: SR.sp(context, 12),
              color: AppColors.textGray,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSimpleContainer(BuildContext context) {
    return Container(
      width: SR.w(context, 300), // 300px on reference device
      height: SR.h(context, 120), // 120px on reference device
      padding: SR.p(context, 20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.success, AppColors.info],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(SR.r(context, 16)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Scaled Container',
            style: TextStyle(
              fontSize: SR.sp(context, 16),
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          SR.vSpace(context, 8),
          Text(
            'Width: ${SR.w(context, 300).toStringAsFixed(1)}px\n'
            'Height: ${SR.h(context, 120).toStringAsFixed(1)}px',
            style: TextStyle(
              fontSize: SR.sp(context, 12),
              color: Colors.white70,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextExamples(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: SR.p(context, 16),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(SR.r(context, 12)),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Text Size Examples',
            style: TextStyle(
              fontSize: SR.sp(context, 18),
              fontWeight: FontWeight.bold,
              color: AppColors.textDark,
            ),
          ),
          SR.vSpace(context, 12),

          Text(
            'Small Text (12sp)',
            style: TextStyle(
              fontSize: SR.sp(context, 12),
              color: AppColors.textGray,
            ),
          ),
          SR.vSpace(context, 4),

          Text(
            'Medium Text (14sp)',
            style: TextStyle(
              fontSize: SR.sp(context, 14),
              color: AppColors.textDark,
            ),
          ),
          SR.vSpace(context, 4),

          Text(
            'Large Text (16sp)',
            style: TextStyle(
              fontSize: SR.sp(context, 16),
              fontWeight: FontWeight.w600,
              color: AppColors.textDark,
            ),
          ),
          SR.vSpace(context, 4),

          Text(
            'Title Text (20sp)',
            style: TextStyle(
              fontSize: SR.sp(context, 20),
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildButtonExample(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Button Examples',
          style: TextStyle(
            fontSize: SR.sp(context, 18),
            fontWeight: FontWeight.bold,
            color: AppColors.textDark,
          ),
        ),
        SR.vSpace(context, 12),

        // Small Button
        SizedBox(
          width: SR.w(context, 120),
          height: SR.h(context, 40),
          child: ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.success,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(SR.r(context, 8)),
              ),
            ),
            child: Text(
              'Small',
              style: TextStyle(
                fontSize: SR.sp(context, 14),
                color: Colors.white,
              ),
            ),
          ),
        ),

        SR.vSpace(context, 8),

        // Medium Button
        SizedBox(
          width: SR.w(context, 160),
          height: SR.h(context, 48),
          child: ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(SR.r(context, 12)),
              ),
            ),
            child: Text(
              'Medium',
              style: TextStyle(
                fontSize: SR.sp(context, 16),
                color: Colors.white,
              ),
            ),
          ),
        ),

        SR.vSpace(context, 8),

        // Large Button
        SizedBox(
          width: SR.w(context, 200),
          height: SR.h(context, 56),
          child: ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.warning,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(SR.r(context, 16)),
              ),
            ),
            child: Text(
              'Large Button',
              style: TextStyle(
                fontSize: SR.sp(context, 18),
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLayoutExample(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: SR.p(context, 16),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(SR.r(context, 12)),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Layout Example',
            style: TextStyle(
              fontSize: SR.sp(context, 18),
              fontWeight: FontWeight.bold,
              color: AppColors.textDark,
            ),
          ),
          SR.vSpace(context, 16),

          Row(
            children: [
              // Icon container
              Container(
                width: SR.w(context, 60),
                height: SR.h(context, 60),
                decoration: BoxDecoration(
                  color: AppColors.info,
                  borderRadius: BorderRadius.circular(SR.r(context, 12)),
                ),
                child: Icon(
                  Icons.home,
                  size: SR.w(context, 32),
                  color: Colors.white,
                ),
              ),

              SR.hSpace(context, 16), // Horizontal spacing
              // Text content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Home Screen',
                      style: TextStyle(
                        fontSize: SR.sp(context, 16),
                        fontWeight: FontWeight.bold,
                        color: AppColors.textDark,
                      ),
                    ),
                    SR.vSpace(context, 4),
                    Text(
                      'Navigate to the main dashboard with all your important information.',
                      style: TextStyle(
                        fontSize: SR.sp(context, 14),
                        color: AppColors.textGray,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
