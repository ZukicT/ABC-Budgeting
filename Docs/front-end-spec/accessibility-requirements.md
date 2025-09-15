# Accessibility Requirements

## Compliance Target
**Standard:** WCAG 2.1 AA compliance with iOS accessibility best practices and Apple HIG requirements

## Key Requirements

**Visual:**
- Color contrast ratios: 4.5:1 for normal text, 3:1 for large text (Apple HIG minimum)
- Focus indicators: 2pt border with 2pt offset, high contrast colors
- Text sizing: Support Dynamic Type from 12pt to 34pt (Apple HIG range)
- Dark mode support: Full compatibility with iOS Dark Mode
- Color independence: Never rely on color alone to convey information

**Interaction:**
- Keyboard navigation: Full VoiceOver support with logical tab order
- Screen reader support: Complete VoiceOver labels, hints, and traits
- Touch targets: Minimum 44pt x 44pt for all interactive elements (Apple HIG requirement)
- Gesture alternatives: Provide alternative methods for all gesture-based actions
- Haptic feedback: Use UIImpactFeedbackGenerator for appropriate interactions

**Content:**
- Alternative text: All images and icons have descriptive labels
- Heading structure: Proper heading hierarchy (H1-H6) for screen readers
- Form labels: All form fields have associated labels and validation messages
- SF Symbols: Use system icons with proper accessibility labels
- Dynamic Type: All text must scale properly with user preferences

**Apple HIG Specific Requirements:**
- VoiceOver rotor: Customize rotor for app-specific navigation
- Switch Control: Support for switch-based navigation
- AssistiveTouch: Ensure all functions work with AssistiveTouch
- Reduce Motion: Honor UIAccessibility.isReduceMotionEnabled
- Reduce Transparency: Support UIAccessibility.isReduceTransparencyEnabled

## Testing Strategy
- VoiceOver testing on all screens with rotor navigation
- Dynamic Type testing at all supported sizes (12pt-34pt)
- Color contrast validation using automated tools
- Manual testing with accessibility features enabled
- Switch Control testing for alternative input methods
- Dark mode testing across all screens and components
