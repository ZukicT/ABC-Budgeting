# ABC Budgeting App Architecture

## Overview

The ABC Budgeting app is architected for long-term scalability, maintainability, and clean separation of concerns. It uses a modular MVVM + Coordinator pattern, with each feature encapsulated in its own module, and shared resources/components abstracted for reuse. The project is designed for Swift 6 and iOS 18+, leveraging SwiftUI for all UI.

---

## Directory Structure

```
App/                  // App entry point and global configuration
Core/
  Models/             // Domain models (User, Transaction, etc.)
  Services/           // Networking, business logic, and API clients
  Persistence/        // Data storage, Core Data/SwiftData, Keychain wrappers
Modules/
  Home/
    Overview/         // Dashboard & insights
    Transactions/     // List of income/expenses
    Budget/           // Visual breakdowns
  Onboarding/         // Onboarding flow
  Settings/           // User profile, preferences, etc.
SharedUI/
  Components/         // Reusable SwiftUI views, controls, and extensions
Resources/
  Localized/          // Localizable.strings and other localization files
  Colors.swift        // Centralized color definitions
  Fonts.swift         // Font definitions
  Paddings.swift      // Spacing constants
  Info.plist          // App configuration
Tests/                // Unit and UI tests, mirroring Modules/Core structure
Docs/                 // Documentation, architecture notes
```

---

## Architectural Principles

- **MVVM + Coordinator**: UI logic is in ViewModels, navigation in Coordinators, and business/data logic in Services. Views are declarative SwiftUI.
- **Modularization**: Each feature (e.g., Onboarding, Home/Overview) is a self-contained module with its own Views, ViewModels, and Coordinator.
- **Shared UI**: Common UI elements (e.g., LoadingBar, SpinningShapesBackground) are in SharedUI/Components for reuse.
- **Core Layer**: Contains all shared models, services, and persistence logic. No UI code here.
- **Resources**: All assets, colors, fonts, and localized strings are centralized for maintainability and localization.
- **Testing**: All business and presentation logic is unit tested. UI tests cover critical flows.

---

## Adding New Features

1. **Create a new module** under `Modules/FeatureName/`.
2. Add `FeatureView.swift`, `FeatureViewModel.swift`, and `FeatureCoordinator.swift`.
3. Register the coordinator in the main app flow (AppCoordinator).
4. Add any shared UI to `SharedUI/Components`.
5. Add new models/services to `Core` if shared across modules.
6. Add tests in `Tests/FeatureName/`.

---

## Rationale

- **Separation of Concerns**: Each layer/module has a single responsibility, making the codebase easier to maintain and extend.
- **Testability**: Decoupled logic and dependency injection make unit/UI testing straightforward.
- **Scalability**: New features can be added as modules without impacting existing code.
- **SwiftUI-First**: Modern, declarative UI with full support for accessibility, dynamic type, and theming.

---

For more details, see inline documentation in each module and the README.
