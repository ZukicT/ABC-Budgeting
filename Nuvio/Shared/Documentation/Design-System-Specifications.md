# iOS Design System Specifications
## Nuvio & Expense Tracking App

### Overview
This document outlines the comprehensive design system for the Nuvio app, implementing the 8pt grid system, typography hierarchy, and spacing rules to ensure consistent, scalable design across all screen sizes while maintaining the clean, professional fintech aesthetic.

---

## 📏 Spacing Scale (8pt Grid System)

### Base Grid System
| Size | Points | Rem | Usage |
|------|--------|-----|-------|
| **Micro** | 4pt | 0.25rem | Micro spacing, fine adjustments |
| **Base** | 8pt | 0.5rem | Base unit, fundamental spacing |
| **Small** | 12pt | 0.75rem | Small spacing, tight layouts |
| **Medium** | 16pt | 1rem | Medium spacing, standard padding |
| **Large** | 24pt | 1.5rem | Large spacing, section separation |
| **XL** | 32pt | 2rem | XL spacing, major sections |
| **XXL** | 48pt | 3rem | XXL spacing, page sections |
| **Section** | 64pt | 4rem | Section spacing, major page breaks |

### SwiftUI Usage
```swift
// Spacing Scale
Constants.UI.Spacing.micro      // 4pt
Constants.UI.Spacing.base       // 8pt
Constants.UI.Spacing.small      // 12pt
Constants.UI.Spacing.medium     // 16pt
Constants.UI.Spacing.large      // 24pt
Constants.UI.Spacing.xl         // 32pt
Constants.UI.Spacing.xxl        // 48pt
Constants.UI.Spacing.section    // 64pt
```

---

## 📦 Padding System

### Cards/Components
| Element | Vertical | Horizontal | Usage |
|---------|----------|------------|-------|
| **Card Internal** | 16pt | 16pt | All card content padding |
| **Button** | 12pt | 24pt | Primary action buttons |
| **Input Field** | 16pt | 16pt | Text input fields |
| **Navigation** | 12pt | 16pt | Navigation bar padding |

### Screen Edges
| Element | Spacing | Usage |
|---------|---------|-------|
| **Main Content Margins** | 16pt | Distance from screen edges |
| **Section Spacing** | 24pt | Between major sections |
| **List Item Padding** | 16pt | Vertical and horizontal list padding |

### SwiftUI Usage
```swift
// Padding System
Constants.UI.Padding.cardInternal        // 16pt all sides
Constants.UI.Padding.buttonVertical      // 12pt vertical
Constants.UI.Padding.buttonHorizontal    // 24pt horizontal
Constants.UI.Padding.inputVertical       // 16pt vertical
Constants.UI.Padding.inputHorizontal     // 16pt horizontal
Constants.UI.Padding.screenMargin        // 16pt from screen edges
Constants.UI.Padding.sectionSpacing      // 24pt between sections
```

---

## 🔤 Typography Hierarchy & Weights

### H1 - Screen Titles
- **Size**: 32pt (2rem)
- **Weight**: 700 (Bold)
- **Line Height**: 38pt
- **Usage**: Main screen headers, account balance
- **SwiftUI**: `Constants.Typography.H1.font`

### H2 - Section Headers
- **Size**: 24pt (1.5rem)
- **Weight**: 600 (Semi-bold)
- **Line Height**: 30pt
- **Usage**: Category titles, card headers
- **SwiftUI**: `Constants.Typography.H2.font`

### H3 - Subsection Headers
- **Size**: 18pt (1.125rem)
- **Weight**: 600 (Semi-bold)
- **Line Height**: 24pt
- **Usage**: Transaction categories, settings sections
- **SwiftUI**: `Constants.Typography.H3.font`

### Body - Primary Text
- **Size**: 16pt (1rem)
- **Weight**: 400 (Regular)
- **Line Height**: 22pt
- **Usage**: Transaction descriptions, main content
- **SwiftUI**: `Constants.Typography.Body.font`

### Body Small - Secondary Text
- **Size**: 14pt (0.875rem)
- **Weight**: 400 (Regular)
- **Line Height**: 20pt
- **Usage**: Dates, helper text, descriptions
- **SwiftUI**: `Constants.Typography.BodySmall.font`

### Caption - Meta Information
- **Size**: 12pt (0.75rem)
- **Weight**: 400 (Regular)
- **Line Height**: 16pt
- **Usage**: Timestamps, fine print, labels
- **SwiftUI**: `Constants.Typography.Caption.font`

### Button Text
- **Size**: 16pt (1rem)
- **Weight**: 600 (Semi-bold)
- **Line Height**: 20pt
- **Usage**: All button labels
- **SwiftUI**: `Constants.Typography.Button.font`

---

## 🎯 Visual Hierarchy Rules

### Screen Structure
| Element | Spacing | Usage |
|---------|---------|-------|
| **Screen Title** | 32pt from top safe area | H1 positioning |
| **Primary Content** | 24pt below title | Main content start |
| **Card Internal** | 16pt all sides | Card content padding |
| **Between Cards** | 12pt spacing | Card separation |
| **Bottom Safe Area** | 32pt margin | Bottom spacing |

### Transaction Lists
| Element | Typography | Alignment | Spacing |
|---------|------------|-----------|---------|
| **Amount** | H3 | Right-aligned | 16pt between items |
| **Description** | Body | Left-aligned | |
| **Date/Category** | Body Small | Left-aligned | Secondary color |

### Button Hierarchy
| Type | Weight | Contrast | Usage |
|------|--------|----------|-------|
| **Primary** | Bold | High | Main actions |
| **Secondary** | Regular | Medium | Secondary actions |
| **Tertiary** | Regular | Low | Subtle actions |

---

## 🧩 Component Spacing

### Budget Cards
| Element | Spacing | Usage |
|---------|---------|-------|
| **Card Padding** | 16pt all sides | Internal card content |
| **Progress Bar Margin** | 8pt top/bottom | Progress indicator spacing |
| **Icon to Text** | 12pt | Icon and text separation |
| **Card Corner Radius** | 12pt | Rounded corners |

### Navigation
| Element | Size | Usage |
|---------|------|-------|
| **Tab Bar Height** | 80pt | Including safe area |
| **Tab Icon Size** | 24pt × 24pt | Tab bar icons |
| **Tab Label Margin** | 4pt below icon | Label positioning |

### Form Elements
| Element | Size/Spacing | Usage |
|---------|--------------|-------|
| **Input Height** | 48pt minimum | Touch target compliance |
| **Label to Input** | 8pt spacing | Form field labels |
| **Between Form Fields** | 16pt | Field separation |
| **Submit Button Margin** | 24pt from last field | Form completion |

---

## 📱 Responsive Design Considerations

### Screen Size Adaptations
- **iPhone SE (375pt)**: Use micro and small spacing
- **iPhone Standard (390pt)**: Use base and medium spacing
- **iPhone Plus (428pt)**: Use medium and large spacing
- **iPad (768pt+)**: Use large and XL spacing

### Dynamic Type Support
- All typography scales with system font size preferences
- Line heights adjust proportionally
- Spacing remains consistent across font sizes

### Accessibility
- Minimum touch targets: 44pt × 44pt
- High contrast mode support
- VoiceOver compatibility
- Reduced motion support

---

## 🎨 Implementation Guidelines

### SwiftUI Best Practices
```swift
// Use design system constants
VStack(spacing: Constants.UI.Spacing.medium) {
    Text("Title")
        .font(Constants.Typography.H1.font)
    
    Text("Description")
        .font(Constants.Typography.Body.font)
}
.padding(Constants.UI.Padding.cardInternal)

// Button hierarchy
Button("Primary Action") {
    // Action
}
.font(Constants.ButtonHierarchy.primary)
.padding(.vertical, Constants.UI.Padding.buttonVertical)
.padding(.horizontal, Constants.UI.Padding.buttonHorizontal)
```

### Consistency Rules
1. **Always use design system constants** - Never hardcode spacing or typography
2. **Follow the 8pt grid** - All spacing should be multiples of 8pt
3. **Maintain hierarchy** - Use appropriate typography levels
4. **Test across devices** - Verify spacing works on all screen sizes
5. **Accessibility first** - Ensure all elements meet accessibility standards

---

## ✅ Quality Checklist

### Spacing
- [ ] All spacing follows 8pt grid system
- [ ] Consistent padding across similar components
- [ ] Proper margins from screen edges
- [ ] Adequate spacing between interactive elements

### Typography
- [ ] Correct hierarchy levels used
- [ ] Appropriate font weights applied
- [ ] Line heights optimized for readability
- [ ] Dynamic type support implemented

### Components
- [ ] Touch targets meet minimum 44pt requirement
- [ ] Corner radius consistent across similar elements
- [ ] Proper contrast ratios maintained
- [ ] Accessibility labels provided

### Responsive Design
- [ ] Layout works across all supported screen sizes
- [ ] Spacing scales appropriately
- [ ] Typography remains readable
- [ ] Interactive elements remain accessible

---

## 🚀 Future Considerations

- **Dark Mode**: Adapt spacing and typography for dark theme
- **iPad Optimization**: Enhanced spacing for larger screens
- **Accessibility**: Enhanced support for assistive technologies
- **Animation**: Spacing and typography for smooth transitions
- **Internationalization**: Typography adjustments for different languages

This design system ensures consistent, scalable, and accessible design across your entire Nuvio app while maintaining the clean, professional fintech aesthetic.
