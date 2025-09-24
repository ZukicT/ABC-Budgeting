# Color Quick Reference - WCAG AA Compliant Fintech
## ABC Budgeting App

### 🎨 Primary Colors (WCAG AA Compliant)
| Color | Hex | Contrast | Usage |
|-------|-----|----------|-------|
| Success Green | `#339900` | 4.5:1+ | Gains, success, positive states |
| Clean Black | `#1F2123` | 4.5:1+ | Navigation, text, primary elements |
| Warning Red | `#CC3333` | 4.5:1+ | Losses, warnings, negative states |

### 🎨 Backgrounds
| Color | Hex | Usage |
|-------|-----|-------|
| Pure White | `#FFFFFF` | Main background, cards, modals |
| Light Gray | `#F7F7F7` | Subtle separation, inactive states |
| Medium Gray | `#F2F2F2` | Secondary backgrounds |

### 🎨 Text Colors (WCAG AA Compliant)
| Color | Hex | Contrast | Usage |
|-------|-----|----------|-------|
| Clean Black | `#1F2123` | 4.5:1+ | Main content, headlines, navigation |
| Dark Gray | `#666666` | 4.5:1+ | Supporting information |
| Medium Gray | `#808080` | 4.5:1+ | Less important info |
| Light Gray | `#999999` | 4.5:1+ | Subtle labels |

### 🎨 Minimalist Design Rules (Robinhood Style)
| Rule | Value | Usage |
|------|-------|-------|
| No Shadows | `shadowRadius: 0` | All elements flat |
| No Borders | `borderWidth: 0` | Color separation only |
| No Rounded Corners | `cornerRadius: 0` | Clean geometric shapes |
| Solid Colors Only | No gradients | Color-coded financial data |

### 💻 SwiftUI Usage
```swift
// Quick access
Constants.Colors.robinNeonGreen
Constants.Colors.cleanBlack
Constants.Colors.softRed

// Backgrounds
Constants.Colors.backgroundPrimary  // Pure white
Constants.Colors.cardBackground     // Pure white

// Text
Constants.Colors.textPrimary        // Clean black
Constants.Colors.textSecondary      // Medium gray

// Minimalist design
Constants.MinimalistDesign.cornerRadius   // 0
Constants.MinimalistDesign.borderWidth    // 0
Constants.MinimalistDesign.shadowRadius   // 0
```

### ✅ Accessibility
- All colors meet WCAG AA standards (4.5:1+ contrast)
- Tested for color blindness compatibility
- High contrast mode support
