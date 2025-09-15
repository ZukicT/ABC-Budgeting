# Component Library / Design System

## Design System Approach
**Design System Approach:** Custom SwiftUI-based design system with mathematical precision, following Apple's Human Interface Guidelines with NO drop shadows allowed

## Core Components

### AppButton
**Purpose:** Primary and secondary action buttons throughout the app

**Variants:** Primary, Secondary, Destructive, Small, Large, Tiny

**States:** Normal, Pressed, Disabled, Loading

**Usage Guidelines:**
- Primary buttons for main actions (Add Transaction, Save Goal)
- Secondary buttons for alternative actions (Cancel, Edit)
- Destructive buttons for dangerous actions (Delete, Clear Data)
- Use consistent sizing: Height 44pt (standard), 52pt (large), 36pt (small), 28pt (tiny)

### AppCard
**Purpose:** Container for related content with consistent styling

**Variants:** Standard, Large, Small, Elevated

**States:** Normal, Pressed, Selected

**Usage Guidelines:**
- Use for goal cards, transaction items, and content sections
- Standard height: 120pt, padding: 16pt
- Border radius: 12pt
- **NO SHADOWS**: Use flat design with subtle borders instead of shadows

### AppInputField
**Purpose:** Text input with validation and consistent styling

**Variants:** Standard, Large, Small, Search

**States:** Normal, Focused, Error, Disabled

**Usage Guidelines:**
- Height: 44pt (standard), 52pt (large), 36pt (small)
- Padding: 12pt horizontal, 12pt vertical
- Border radius: 8pt

### DonutChartView
**Purpose:** Interactive circular chart for data visualization

**Variants:** Standard, Large, Small, Animated

**States:** Normal, Selected, Loading

**Usage Guidelines:**
- Use for spending category breakdowns
- Standard size: 200pt diameter
- Include accessibility labels and VoiceOver support
