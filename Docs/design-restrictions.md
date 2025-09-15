# Design Restrictions - ABC Budgeting

## Overview
This document outlines specific design restrictions and guidelines that must be followed throughout the ABC Budgeting application to maintain design consistency and user experience standards.

## Critical Design Restrictions

### NO DROP SHADOWS
**Restriction**: Drop shadows are strictly prohibited throughout the entire application.

**Rationale**: 
- Maintains flat design principles
- Ensures consistent visual hierarchy
- Reduces visual clutter
- Aligns with modern iOS design trends
- Improves accessibility and readability

**Implementation Guidelines**:
- Use subtle borders instead of shadows for card separation
- Implement elevation through color contrast and spacing
- Use flat design principles for all UI elements
- Apply consistent visual hierarchy without depth effects

**What NOT to Use**:
- `shadow()` modifier in SwiftUI
- `dropShadow()` effects
- Any shadow-related styling
- Depth-based visual effects

**What TO Use Instead**:
- Subtle borders with appropriate colors
- Color contrast for visual separation
- Proper spacing and padding
- Typography hierarchy for emphasis

## Design System Compliance

### Visual Identity
- **Style**: Professional flat design with banking-app-quality aesthetics
- **Shadows**: NONE - Use flat design principles exclusively
- **Depth**: Achieve visual hierarchy through color, typography, and spacing
- **Consistency**: Maintain uniform visual treatment across all components

### Component Guidelines

#### AppCard Component
- **NO shadows** - Use subtle borders instead
- Border radius: 12pt
- Use color contrast for visual separation
- Maintain flat design principles

#### AppButton Component
- **NO shadows** - Use flat design with color states
- Use color changes for pressed states
- Implement haptic feedback for interaction
- Maintain consistent sizing and spacing

#### All UI Elements
- Follow flat design principles
- Use color and typography for hierarchy
- Implement consistent spacing (4pt grid system)
- Ensure accessibility compliance

## Technical Implementation

### SwiftUI Guidelines
```swift
// ❌ DO NOT USE
.shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)

// ✅ USE INSTEAD
.overlay(
    RoundedRectangle(cornerRadius: 12)
        .stroke(Color.gray.opacity(0.2), lineWidth: 1)
)
```

### Alternative Visual Techniques
1. **Color Contrast**: Use different background colors for visual separation
2. **Typography**: Use font weight and size for hierarchy
3. **Spacing**: Use consistent padding and margins
4. **Borders**: Use subtle borders for component separation
5. **Color States**: Use different colors for different states

## Quality Assurance

### Design Review Checklist
- [ ] No drop shadows used anywhere in the design
- [ ] Flat design principles followed consistently
- [ ] Visual hierarchy achieved through color and typography
- [ ] Consistent spacing and padding applied
- [ ] Accessibility requirements met
- [ ] Apple HIG compliance maintained

### Code Review Checklist
- [ ] No `.shadow()` modifiers in SwiftUI code
- [ ] No shadow-related styling in any UI components
- [ ] Alternative visual techniques used appropriately
- [ ] Consistent design patterns applied
- [ ] Performance impact considered

## Examples

### Card Design
```swift
// ❌ WRONG - Using shadows
Card {
    // content
}
.shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)

// ✅ CORRECT - Using flat design
Card {
    // content
}
.overlay(
    RoundedRectangle(cornerRadius: 12)
        .stroke(Color.gray.opacity(0.2), lineWidth: 1)
)
.background(Color.white)
```

### Button Design
```swift
// ❌ WRONG - Using shadows
Button("Action") {
    // action
}
.shadow(color: .black.opacity(0.1), radius: 1, x: 0, y: 1)

// ✅ CORRECT - Using flat design
Button("Action") {
    // action
}
.background(Color.blue)
.foregroundColor(.white)
.cornerRadius(8)
```

## Enforcement

### Development Phase
- Code reviews must check for shadow usage
- Design reviews must verify flat design compliance
- Automated linting rules should flag shadow usage

### Testing Phase
- Visual regression testing should verify no shadows
- Accessibility testing should confirm flat design compliance
- User testing should validate visual hierarchy effectiveness

## Related Documents
- [Front-End Specification](./front-end-spec.md)
- [Branding & Style Guide](./front-end-spec/branding-style-guide.md)
- [Component Library](./front-end-spec/component-library-design-system.md)
- [Apple HIG Compliance](./front-end-spec/apple-hig-compliance-requirements.md)

---

**Document Version**: 1.0  
**Last Updated**: 2025-01-09  
**Status**: Active Design Restriction
