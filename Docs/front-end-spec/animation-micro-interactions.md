# Animation & Micro-interactions

## Motion Principles
- **Purposeful Motion**: Every animation serves a functional purpose
- **Natural Physics**: Use spring animations that feel natural
- **Performance First**: Maintain 60fps, respect reduced motion preferences
- **Accessibility**: Honor UIAccessibility.isReduceMotionEnabled

## Key Animations
- **Button Press**: Scale to 0.95 with 0.15s duration, easeOut curve
- **Card Tap**: Scale to 0.98 with 0.1s duration, spring animation
- **Modal Present**: Slide up from bottom with 0.25s duration, easeOut curve
- **List Item Swipe**: Reveal actions with 0.2s duration, spring animation
- **Chart Animation**: Staggered reveal with 0.3s duration, easeInOut curve
- **Loading States**: Subtle pulse animation with 1s duration, infinite repeat
- **Success Feedback**: Scale bounce with 0.4s duration, spring animation
- **Error Shake**: Horizontal shake with 0.5s duration, easeInOut curve
