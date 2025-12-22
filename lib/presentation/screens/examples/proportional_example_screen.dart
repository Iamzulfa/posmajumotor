import 'package:flutter/material.dart';
import '../../../core/utils/proportional_responsive.dart';
import '../../../core/utils/proportional_extensions.dart';
import '../../../config/constants/proportional_constants.dart';
import '../../widgets/common/proportional_widgets.dart';

/// Example screen showing how to use the proportional responsive system
class ProportionalExampleScreen extends StatelessWidget {
  const ProportionalExampleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const PText.large('Proportional Responsive Example'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(
          ProportionalConstants.screenPaddingHorizontal.w(context),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Device Info Card
            _buildDeviceInfoCard(context),

            PSpacing.large,

            // Text Examples
            _buildTextExamples(context),

            PSpacing.large,

            // Button Examples
            _buildButtonExamples(context),

            PSpacing.large,

            // Card Examples
            _buildCardExamples(context),

            PSpacing.large,

            // Layout Examples
            _buildLayoutExamples(context),

            PSpacing.large,

            // Manual Scaling Examples
            _buildManualScalingExamples(context),
          ],
        ),
      ),
    );
  }

  Widget _buildDeviceInfoCard(BuildContext context) {
    final factors = ProportionalResponsive.getScalingFactors(context);

    return PCard(
      color: Colors.blue.shade50,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const PText.title('Device Information', fontWeight: FontWeight.bold),
          PSpacing.small,
          PText.medium(
            'Current Device: ${factors['deviceWidth']?.toInt()}x${factors['deviceHeight']?.toInt()}',
          ),
          PText.medium(
            'Reference Device: ${factors['referenceWidth']?.toInt()}x${factors['referenceHeight']?.toInt()}',
          ),
          PText.medium(
            'Width Scale: ${factors['widthScaleFactor']?.toStringAsFixed(2)}x',
          ),
          PText.medium(
            'Height Scale: ${factors['heightScaleFactor']?.toStringAsFixed(2)}x',
          ),
          PSpacing.small,
          PText.small(
            'Formula: (widget_size / reference_size) * device_size',
            color: Colors.grey.shade600,
          ),
        ],
      ),
    );
  }

  Widget _buildTextExamples(BuildContext context) {
    return PCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const PText.title('Text Examples', fontWeight: FontWeight.bold),
          PSpacing.medium,
          const PText.small('Small Text (12sp)'),
          const PText.medium('Medium Text (14sp)'),
          const PText.large('Large Text (16sp)'),
          const PText.title('Title Text (24sp)'),
          const PText.heading('Heading Text (28sp)'),
          PSpacing.small,
          PText(
            'Custom Size Text (20sp)',
            fontSize: 20,
            color: Colors.blue,
            fontWeight: FontWeight.w600,
          ),
        ],
      ),
    );
  }

  Widget _buildButtonExamples(BuildContext context) {
    return PCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const PText.title('Button Examples', fontWeight: FontWeight.bold),
          PSpacing.medium,

          // Predefined sizes
          PButton.small(
            text: 'Small Button',
            onPressed: () {},
            backgroundColor: Colors.green,
          ),
          PSpacing.small,

          PButton.medium(
            text: 'Medium Button',
            onPressed: () {},
            backgroundColor: Colors.blue,
            icon: Icons.check,
          ),
          PSpacing.small,

          PButton.large(
            text: 'Large Button',
            onPressed: () {},
            backgroundColor: Colors.orange,
          ),
          PSpacing.small,

          // Custom size
          PButton(
            text: 'Custom Button',
            onPressed: () {},
            width: 200,
            height: 60,
            backgroundColor: Colors.purple,
            borderRadius: 30,
          ),
        ],
      ),
    );
  }

  Widget _buildCardExamples(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const PText.title('Card Examples', fontWeight: FontWeight.bold),
        PSpacing.medium,

        Row(
          children: [
            Expanded(
              child: PCard(
                height: 100,
                color: Colors.red.shade50,
                child: const Center(
                  child: PText.medium('Card 1', fontWeight: FontWeight.bold),
                ),
              ),
            ),
            PSpacing.horizontal(context, 16),
            Expanded(
              child: PCard(
                height: 100,
                color: Colors.green.shade50,
                child: const Center(
                  child: PText.medium('Card 2', fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildLayoutExamples(BuildContext context) {
    return PCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const PText.title('Layout Examples', fontWeight: FontWeight.bold),
          PSpacing.medium,

          // Using extension methods
          Row(
            children: [
              PContainer(
                width: 60,
                height: 60,
                color: Colors.blue,
                borderRadius: 8,
                child: const Center(
                  child: PIcon.medium(Icons.home, color: Colors.white),
                ),
              ),

              SizedBox(width: 16.w(context)), // Using extension

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const PText.large(
                      'Home Screen',
                      fontWeight: FontWeight.bold,
                    ),
                    SizedBox(height: 4.h(context)), // Using extension
                    const PText.medium('Navigate to home screen'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildManualScalingExamples(BuildContext context) {
    return PCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const PText.title(
            'Manual Scaling Examples',
            fontWeight: FontWeight.bold,
          ),
          PSpacing.medium,

          // Manual width scaling
          Container(
            width: 200.w(context), // 200px on reference device
            height: 50.h(context), // 50px on reference device
            decoration: BoxDecoration(
              color: Colors.amber,
              borderRadius: BorderRadius.circular(8.r(context)),
            ),
            child: Center(
              child: PText(
                'Scaled Container',
                fontSize: 16.sp(context), // 16sp on reference device
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          PSpacing.medium,

          // Show actual scaled values
          PText.small(
            'Actual scaled width: ${200.w(context).toStringAsFixed(1)}px',
          ),
          PText.small(
            'Actual scaled height: ${50.h(context).toStringAsFixed(1)}px',
          ),
          PText.small(
            'Actual scaled font: ${16.sp(context).toStringAsFixed(1)}sp',
          ),
        ],
      ),
    );
  }
}
