import 'package:flutter/material.dart';
import '../../../core/utils/auto_responsive.dart';
import '../../../config/theme/app_colors.dart';

/// Auto Responsive Example - No context needed!
/// System automatically detects device size and applies scaling
class AutoResponsiveExample extends StatelessWidget {
  const AutoResponsiveExample({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: AText(
          'Auto Responsive Example',
          fontSize: 18,
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: AR.p(16), // Auto-scaled padding
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Device Info Card
            _buildDeviceInfoCard(),

            AR.h(20), // Auto-scaled vertical spacing
            // Auto Container Example
            _buildAutoContainer(),

            AR.h(20),

            // Text Examples
            _buildTextExamples(),

            AR.h(20),

            // Button Examples
            _buildButtonExamples(),

            AR.h(20),

            // Layout Example
            _buildLayoutExample(),

            AR.h(20),

            // Extension Methods Example
            _buildExtensionExample(),
          ],
        ),
      ),
    );
  }

  Widget _buildDeviceInfoCard() {
    return AContainer(
      width: double.infinity,
      padding: AR.p(16),
      borderRadius: 12,
      color: AppColors.primary.withValues(alpha: 0.1),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AText(
            'Auto-Responsive System Status',
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.primary,
          ),
          AR.h(8),
          AText(
            AutoResponsive.deviceInfo,
            fontSize: 14,
            color: AppColors.textDark,
          ),
          AR.h(8),
          AText(
            'Formula: (widget_size / 360) * device_width',
            fontSize: 12,
            color: AppColors.textGray,
            style: const TextStyle(fontStyle: FontStyle.italic),
          ),
          AR.h(8),
          AText(
            '✅ No context needed - fully automatic!',
            fontSize: 12,
            color: AppColors.success,
            fontWeight: FontWeight.w600,
          ),
        ],
      ),
    );
  }

  Widget _buildAutoContainer() {
    return AContainer(
      width: 300, // 300px on reference device
      height: 120, // 120px on reference device
      padding: AR.p(20),
      borderRadius: 16,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.success, AppColors.info],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AText(
            'Auto-Scaled Container',
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
          AR.h(8),
          AText(
            'Actual width: ${300.aw.toStringAsFixed(1)}px\n'
            'Actual height: ${120.ah.toStringAsFixed(1)}px',
            fontSize: 12,
            color: Colors.white70,
          ),
        ],
      ),
    );
  }

  Widget _buildTextExamples() {
    return AContainer(
      width: double.infinity,
      padding: AR.p(16),
      borderRadius: 12,
      color: AppColors.background,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AText(
            'Auto Text Examples',
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.textDark,
          ),
          AR.h(12),

          AText(
            'Small Text (12sp) → ${12.asp.toStringAsFixed(1)}sp',
            fontSize: 12,
            color: AppColors.textGray,
          ),
          AR.h(4),

          AText(
            'Medium Text (14sp) → ${14.asp.toStringAsFixed(1)}sp',
            fontSize: 14,
            color: AppColors.textDark,
          ),
          AR.h(4),

          AText(
            'Large Text (16sp) → ${16.asp.toStringAsFixed(1)}sp',
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.textDark,
          ),
          AR.h(4),

          AText(
            'Title Text (20sp) → ${20.asp.toStringAsFixed(1)}sp',
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors.primary,
          ),
        ],
      ),
    );
  }

  Widget _buildButtonExamples() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AText(
          'Auto Button Examples',
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: AppColors.textDark,
        ),
        AR.h(12),

        // Small Button
        SizedBox(
          width: 120.aw, // Auto-scaled width
          height: 40.ah, // Auto-scaled height
          child: ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.success,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.ar), // Auto-scaled radius
              ),
            ),
            child: AText('Small', fontSize: 14, color: Colors.white),
          ),
        ),

        AR.h(8),

        // Medium Button
        SizedBox(
          width: 160.aw,
          height: 48.ah,
          child: ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.ar),
              ),
            ),
            child: AText('Medium', fontSize: 16, color: Colors.white),
          ),
        ),

        AR.h(8),

        // Large Button
        SizedBox(
          width: 200.aw,
          height: 56.ah,
          child: ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.warning,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16.ar),
              ),
            ),
            child: AText(
              'Large Button',
              fontSize: 18,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLayoutExample() {
    return AContainer(
      width: double.infinity,
      padding: AR.p(16),
      borderRadius: 12,
      color: AppColors.background,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AText(
            'Auto Layout Example',
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.textDark,
          ),
          AR.h(16),

          Row(
            children: [
              // Icon container
              AContainer(
                width: 60,
                height: 60,
                borderRadius: 12,
                color: AppColors.info,
                child: Icon(
                  Icons.auto_awesome,
                  size: 32.aw, // Auto-scaled icon
                  color: Colors.white,
                ),
              ),

              AR.w(16), // Auto-scaled horizontal spacing
              // Text content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AText(
                      'Auto-Responsive System',
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textDark,
                    ),
                    AR.h(4),
                    AText(
                      'Automatically detects device size and scales all elements proportionally. No manual configuration needed!',
                      fontSize: 14,
                      color: AppColors.textGray,
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

  Widget _buildExtensionExample() {
    return AContainer(
      width: double.infinity,
      padding: AR.p(16),
      borderRadius: 12,
      color: AppColors.warning.withValues(alpha: 0.1),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AText(
            'Extension Methods Example',
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.warning,
          ),
          AR.h(12),

          AText(
            'Super clean syntax with extensions:',
            fontSize: 14,
            color: AppColors.textDark,
            fontWeight: FontWeight.w600,
          ),
          AR.h(8),

          // Code examples
          Container(
            width: double.infinity,
            padding: AR.p(12),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(8.ar),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AText(
                  'width: 200.aw  // Auto width',
                  fontSize: 12,
                  color: Colors.grey.shade700,
                  style: const TextStyle(fontFamily: 'monospace'),
                ),
                AText(
                  'height: 100.ah  // Auto height',
                  fontSize: 12,
                  color: Colors.grey.shade700,
                  style: const TextStyle(fontFamily: 'monospace'),
                ),
                AText(
                  'fontSize: 16.asp  // Auto font size',
                  fontSize: 12,
                  color: Colors.grey.shade700,
                  style: const TextStyle(fontFamily: 'monospace'),
                ),
                AText(
                  'radius: 8.ar  // Auto radius',
                  fontSize: 12,
                  color: Colors.grey.shade700,
                  style: const TextStyle(fontFamily: 'monospace'),
                ),
              ],
            ),
          ),

          AR.h(8),

          AText(
            '✨ No context parameter needed anywhere!',
            fontSize: 12,
            color: AppColors.success,
            fontWeight: FontWeight.w600,
          ),
        ],
      ),
    );
  }
}
