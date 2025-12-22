# 📐 Proportional Responsive System - Usage Guide

## 🎯 Overview

Sistem responsif proporsional berdasarkan rumus yang diberikan dosen:
- **Width:** `(widget_width / reference_width) * device_width`
- **Height:** `(widget_height / reference_height) * device_height`
- **Reference Device:** Google Pixel 9 (360px x 800px)

## 🚀 Quick Start

### 1. Import Extensions
```dart
import '../../../core/utils/proportional_extensions.dart';
import '../../../config/constants/proportional_constants.dart';
```

### 2. Basic Usage with Extensions
```dart
// Width scaling
Container(width: 200.w(context)) // 200px on reference device

// Height scaling  
Container(height: 100.h(context)) // 100px on reference device

// Font size scaling
Text('Hello', style: TextStyle(fontSize: 16.sp(context)))

// Border radius scaling
BorderRadius.circular(8.r(context))
```

### 3. Using Proportional Widgets
```dart
// Proportional Text
PText.large('Hello World') // Auto-scaled large text
PText('Custom', fontSize: 18) // Custom size with auto-scaling

// Proportional Button
PButton.medium(
  text: 'Click Me',
  onPressed: () {},
)

// Proportional Container
PContainer(
  width: 200,
  height: 100,
  padding: EdgeInsets.all(16),
  child: Text('Content'),
)
```

## 📏 Scaling Methods

### Core Scaling Functions
```dart
// Manual scaling
double scaledWidth = ProportionalResponsive.scaleWidth(context, 200);
double scaledHeight = ProportionalResponsive.scaleHeight(context, 100);
double scaledFont = ProportionalResponsive.scaleFontSize(context, 16);
```

### Extension Methods (Recommended)
```dart
// Much cleaner syntax
double width = 200.w(context);
double height = 100.h(context);
double fontSize = 16.sp(context);
double radius = 8.r(context);
```

## 🎨 Predefined Constants

### Font Sizes
```dart
ProportionalConstants.fontSizeSmall    // 12px
ProportionalConstants.fontSizeMedium   // 14px
ProportionalConstants.fontSizeLarge    // 16px
ProportionalConstants.fontSizeTitle    // 24px
ProportionalConstants.fontSizeHeading  // 28px
```

### Spacing
```dart
ProportionalConstants.spacingSmall     // 8px
ProportionalConstants.spacingMedium    // 12px
ProportionalConstants.spacingLarge     // 16px
ProportionalConstants.spacingXLarge    // 20px
```

### Component Sizes
```dart
ProportionalConstants.buttonHeightMedium  // 44px
ProportionalConstants.iconSizeMedium      // 24px
ProportionalConstants.radiusMedium        // 8px
```

## 🧩 Widget Examples

### 1. Proportional Text
```dart
// Predefined sizes
PText.small('Small text')
PText.medium('Medium text')  
PText.large('Large text')
PText.title('Title text')
PText.heading('Heading text')

// Custom size
PText('Custom text', fontSize: 18, fontWeight: FontWeight.bold)
```

### 2. Proportional Buttons
```dart
// Predefined sizes
PButton.small(text: 'Small', onPressed: () {})
PButton.medium(text: 'Medium', onPressed: () {})
PButton.large(text: 'Large', onPressed: () {})

// Custom size
PButton(
  text: 'Custom',
  onPressed: () {},
  width: 200,
  height: 50,
  backgroundColor: Colors.blue,
)
```

### 3. Proportional Containers
```dart
PContainer(
  width: 300,
  height: 200,
  padding: EdgeInsets.all(16),
  borderRadius: 12,
  color: Colors.blue.shade50,
  child: PText.medium('Content'),
)
```

### 4. Proportional Cards
```dart
PCard(
  width: 280,
  height: 120,
  child: Column(
    children: [
      PText.title('Card Title'),
      PSpacing.medium,
      PText.medium('Card content here'),
    ],
  ),
)
```

## 📱 Spacing Utilities

### Using PSpacing Class
```dart
Column(
  children: [
    Text('Item 1'),
    PSpacing.small,    // Predefined small spacing
    Text('Item 2'),
    PSpacing.medium,   // Predefined medium spacing
    Text('Item 3'),
  ],
)
```

### Manual Spacing
```dart
Column(
  children: [
    Text('Item 1'),
    SizedBox(height: 16.h(context)), // Custom spacing
    Text('Item 2'),
  ],
)
```

## 🔧 Advanced Usage

### Scaling EdgeInsets
```dart
Container(
  padding: EdgeInsets.symmetric(
    horizontal: 16.w(context),
    vertical: 12.h(context),
  ),
  // OR using extension
  padding: EdgeInsets.all(16).scale(context),
)
```

### Scaling Complex Layouts
```dart
Row(
  children: [
    Container(
      width: 60.w(context),
      height: 60.h(context),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8.r(context)),
      ),
    ),
    SizedBox(width: 16.w(context)),
    Expanded(
      child: Column(
        children: [
          PText('Title', fontSize: 16.sp(context)),
          SizedBox(height: 4.h(context)),
          PText('Subtitle', fontSize: 14.sp(context)),
        ],
      ),
    ),
  ],
)
```

## 🐛 Debugging

### Check Scaling Factors
```dart
final factors = ProportionalResponsive.getScalingFactors(context);
print('Width scale: ${factors['widthScaleFactor']}');
print('Height scale: ${factors['heightScaleFactor']}');
```

### Device Information
```dart
final deviceInfo = ProportionalResponsive.getDeviceInfo(context);
print(deviceInfo);
```

## 📋 Best Practices

### ✅ DO
- Use extension methods (`.w()`, `.h()`, `.sp()`) for cleaner code
- Use predefined constants from `ProportionalConstants`
- Use proportional widgets (`PText`, `PButton`, etc.) when possible
- Test on different screen sizes

### ❌ DON'T
- Mix proportional and fixed sizes in the same component
- Use very large reference values (keep under 400px for width)
- Forget to scale all dimensions (width, height, padding, font size)

## 🎯 Migration from Existing Code

### Before (Fixed sizes)
```dart
Container(
  width: 200,
  height: 100,
  padding: EdgeInsets.all(16),
  child: Text(
    'Hello',
    style: TextStyle(fontSize: 16),
  ),
)
```

### After (Proportional)
```dart
PContainer(
  width: 200,
  height: 100,
  padding: EdgeInsets.all(16),
  child: PText('Hello', fontSize: 16),
)

// OR manual scaling
Container(
  width: 200.w(context),
  height: 100.h(context),
  padding: EdgeInsets.all(16.w(context)),
  child: Text(
    'Hello',
    style: TextStyle(fontSize: 16.sp(context)),
  ),
)
```

## 📊 Example Calculations

### Reference Device (Google Pixel 9): 360px x 800px
- Widget width: 200px
- Target device: iPhone 17 Pro Max (440px width)
- **Formula:** `(200 / 360) * 440 = 244.44px`

### Different Devices
| Device | Width | Scale Factor | 200px becomes |
|--------|-------|--------------|---------------|
| Pixel 9 | 360px | 1.0x | 200px |
| iPhone 17 Pro Max | 440px | 1.22x | 244px |
| iPad Mini | 768px | 2.13x | 427px |
| Small Phone | 320px | 0.89x | 178px |

## 🔗 File Structure
```
lib/
├── core/utils/
│   ├── proportional_responsive.dart      # Core scaling logic
│   └── proportional_extensions.dart      # Extension methods
├── config/constants/
│   └── proportional_constants.dart       # Design constants
└── presentation/widgets/common/
    └── proportional_widgets.dart         # Proportional widgets
```