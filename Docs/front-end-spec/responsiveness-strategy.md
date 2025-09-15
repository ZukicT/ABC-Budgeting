# Responsiveness Strategy

## Breakpoints
| Breakpoint | Min Width | Max Width | Target Devices |
|------------|-----------|-----------|----------------|
| iPhone SE | 320pt | 375pt | iPhone SE, iPhone 12 mini |
| iPhone Standard | 375pt | 414pt | iPhone 12, iPhone 13, iPhone 14 |
| iPhone Plus | 414pt | 428pt | iPhone 12 Pro Max, iPhone 13 Pro Max |
| iPhone Pro Max | 428pt | - | iPhone 14 Pro Max, iPhone 15 Pro Max |

## Adaptation Patterns

**Layout Changes:** 
- Single column layout maintained across all breakpoints
- Card widths adjust to screen width with consistent margins
- Chart sizes scale proportionally with screen size

**Navigation Changes:**
- Bottom tab navigation maintained across all breakpoints
- Tab bar height: 80pt with 48pt item height
- Icon size: 24pt, label size: 12pt

**Content Priority:**
- Essential information (balance, quick actions) always visible
- Secondary content (charts, detailed lists) scrollable
- Progressive disclosure for complex information

**Interaction Changes:**
- Touch targets maintain 44pt minimum size
- Swipe gestures work consistently across all sizes
- Modal presentations adapt to screen size
