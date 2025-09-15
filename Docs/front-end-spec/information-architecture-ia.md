# Information Architecture (IA)

## Site Map / Screen Inventory

```mermaid
graph TD
    A[App Launch] --> B{First Time?}
    B -->|Yes| C[Onboarding Flow]
    B -->|No| D[Main TabView]
    
    C --> C1[Welcome Screen]
    C --> C2[Feature Introduction]
    C --> C3[User Setup]
    C --> C4[Currency Selection]
    C --> C5[Starting Balance]
    C --> D
    
    D --> E[Overview Tab]
    D --> F[Transactions Tab]
    D --> G[Budget Tab]
    D --> H[Settings Tab]
    
    E --> E1[Balance Display]
    E --> E2[Quick Actions]
    E --> E3[Goals Preview]
    E --> E4[Recent Transactions]
    E --> E5[Charts Section]
    
    F --> F1[Transaction List]
    F --> F2[Category Filter]
    F --> F3[Search Interface]
    F --> F4[Add Transaction]
    F --> F5[Transaction Detail]
    
    G --> G1[Goals List]
    G --> G2[Goal Categories]
    G --> G3[Add Goal]
    G --> G4[Goal Detail]
    G --> G5[Progress Tracking]
    
    H --> H1[User Profile]
    H --> H2[Preferences]
    H --> H3[Data Management]
    H --> H4[About Section]
    H --> H5[Import/Export]
```

## Navigation Structure

**Primary Navigation:** Four-tab bottom navigation (Overview, Transactions, Budget, Settings) with consistent iconography and labels

**Secondary Navigation:** Contextual navigation within each tab using standard iOS navigation patterns (NavigationStack, sheets, alerts)

**Breadcrumb Strategy:** Not applicable for mobile app - use clear page titles and back navigation
