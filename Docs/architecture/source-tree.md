# Source Tree

## Existing Project Structure
```
ABC Budgeting/
├── App/
│   ├── AppEntry.swift
│   ├── MainHeaderView.swift
│   ├── MainTabCoordinator.swift
│   └── MainView.swift
├── Core/
│   ├── Extensions/
│   ├── Models/
│   ├── Persistence/
│   └── Services/
├── Modules/
│   ├── Home/
│   ├── Onboarding/
│   └── Settings/
├── SharedUI/
│   └── Components/
└── Resources/
```

## New File Organization
```
ABC Budgeting/
├── App/
│   ├── AppEntry.swift
│   ├── MainHeaderView.swift
│   ├── MainTabCoordinator.swift
│   └── MainView.swift
├── Core/
│   ├── Extensions/
│   ├── Models/
│   │   ├── Transaction.swift
│   │   ├── GoalFormData.swift
│   │   ├── WidgetConfiguration.swift      # New
│   │   └── AnalyticsData.swift           # New
│   ├── Persistence/
│   └── Services/
│       ├── TransactionRepository.swift
│       ├── GoalRepository.swift
│       ├── WidgetManager.swift           # New
│       └── AnalyticsCalculator.swift     # New
├── Modules/
│   ├── Home/
│   ├── Onboarding/
│   ├── Settings/
│   └── Analytics/                        # New
│       ├── AnalyticsView.swift
│       ├── AnalyticsViewModel.swift
│       └── Components/
├── SharedUI/
│   └── Components/
├── Resources/
└── Widgets/                              # New
    ├── BalanceWidget.swift
    ├── TransactionsWidget.swift
    └── GoalsWidget.swift
```

## Integration Guidelines
- **File Naming:** Follow existing Swift naming conventions and file organization patterns
- **Folder Organization:** Maintain existing modular structure with new feature folders
- **Import/Export Patterns:** Use existing Core Data patterns for new data models
