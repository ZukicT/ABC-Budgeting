# Code Standards - ABC Budgeting

## Overview

This document defines the coding standards, conventions, and best practices for the ABC Budgeting iOS app development. These standards ensure code consistency, maintainability, and quality across the entire project.

## Swift Language Standards

### Swift Version
- **Target Version:** Swift 6
- **Minimum iOS:** iOS 18+
- **Xcode Version:** Xcode 15+

### Code Style Guidelines

#### Naming Conventions
- **PascalCase:** Types, protocols, enums, structs, classes
- **camelCase:** Variables, functions, methods, properties
- **UPPER_CASE:** Constants, static values
- **snake_case:** File names (when appropriate)

#### Examples
```swift
// Types
class TransactionRepository { }
protocol TransactionRepositoryProtocol { }
enum TransactionCategory { }
struct TransactionFormData { }

// Variables and Functions
var transactionAmount: Double = 0.0
func createTransaction() { }
let MAX_RETRY_ATTEMPTS = 3

// File Names
transaction_repository.swift
transaction_view_model.swift
```

### Code Organization

#### File Structure
```swift
// MARK: - Imports
import Foundation
import SwiftUI
import CoreData

// MARK: - Protocol Definition
protocol TransactionRepositoryProtocol {
    // Protocol methods
}

// MARK: - Implementation
class CoreDataTransactionRepository: TransactionRepositoryProtocol {
    // MARK: - Properties
    private let coreDataStack: CoreDataStack
    
    // MARK: - Initialization
    init(coreDataStack: CoreDataStack) {
        self.coreDataStack = coreDataStack
    }
    
    // MARK: - Public Methods
    func createTransaction(_ transaction: Transaction) -> Result<Transaction, Error> {
        // Implementation
    }
    
    // MARK: - Private Methods
    private func validateTransaction(_ transaction: Transaction) -> Bool {
        // Implementation
    }
}
```

#### MARK Comments
- **MARK: - Imports:** All import statements
- **MARK: - Protocol Definition:** Protocol definitions
- **MARK: - Implementation:** Class/struct implementations
- **MARK: - Properties:** All properties grouped together
- **MARK: - Initialization:** Initializers and setup methods
- **MARK: - Public Methods:** Public interface methods
- **MARK: - Private Methods:** Private helper methods
- **MARK: - Extensions:** Extension implementations

### SwiftUI Standards

#### View Structure
```swift
struct TransactionListView: View {
    // MARK: - Properties
    @StateObject private var viewModel = TransactionListViewModel()
    @State private var showingAddTransaction = false
    
    // MARK: - Body
    var body: some View {
        NavigationView {
            VStack {
                // View content
            }
            .navigationTitle("Transactions")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Add") {
                        showingAddTransaction = true
                    }
                }
            }
        }
        .sheet(isPresented: $showingAddTransaction) {
            AddTransactionView()
        }
    }
}
```

#### View Modifiers
- **Consistent Spacing:** Use 8pt grid system
- **Color Usage:** Use defined color constants
- **Typography:** Use SF Pro Rounded consistently
- **Animation:** Use consistent animation patterns

#### Example
```swift
VStack(spacing: 16) {
    Text("Transaction Amount")
        .font(.title2)
        .fontWeight(.semibold)
        .foregroundColor(.primary)
    
    TextField("Enter amount", text: $amount)
        .textFieldStyle(RoundedBorderTextFieldStyle())
        .keyboardType(.decimalPad)
}
.padding(.horizontal, 16)
.padding(.vertical, 8)
.background(Color(.systemBackground))
.cornerRadius(12)
.shadow(radius: 2)
```

### Core Data Standards

#### Entity Naming
- **Entities:** PascalCase (e.g., `Transaction`, `GoalFormData`)
- **Attributes:** camelCase (e.g., `transactionAmount`, `createdDate`)
- **Relationships:** camelCase (e.g., `transactions`, `category`)

#### Model Extensions
```swift
// MARK: - Core Data Extensions
extension Transaction {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<Transaction> {
        return NSFetchRequest<Transaction>(entityName: "Transaction")
    }
    
    @NSManaged public var amount: Double
    @NSManaged public var category: String
    @NSManaged public var createdDate: Date
    @NSManaged public var id: UUID
}

// MARK: - Convenience Initializers
extension Transaction {
    convenience init(amount: Double, category: TransactionCategory, date: Date) {
        self.init(context: CoreDataStack.shared.viewContext)
        self.amount = amount
        self.category = category.rawValue
        self.createdDate = date
        self.id = UUID()
    }
}
```

### Error Handling Standards

#### Error Types
```swift
enum TransactionError: LocalizedError {
    case invalidAmount
    case invalidCategory
    case saveFailed
    case networkError(Error)
    
    var errorDescription: String? {
        switch self {
        case .invalidAmount:
            return "Amount must be greater than zero"
        case .invalidCategory:
            return "Please select a valid category"
        case .saveFailed:
            return "Failed to save transaction"
        case .networkError(let error):
            return "Network error: \(error.localizedDescription)"
        }
    }
}
```

#### Error Handling Patterns
```swift
func createTransaction(_ transaction: Transaction) -> Result<Transaction, TransactionError> {
    do {
        // Validation
        guard transaction.amount > 0 else {
            return .failure(.invalidAmount)
        }
        
        // Save operation
        try coreDataStack.save()
        return .success(transaction)
        
    } catch {
        return .failure(.saveFailed)
    }
}
```

### Documentation Standards

#### Code Comments
```swift
/// Creates a new transaction with the specified details
/// - Parameters:
///   - amount: The transaction amount (must be positive)
///   - category: The transaction category
///   - date: The transaction date (defaults to current date)
/// - Returns: A Result containing the created transaction or an error
/// - Throws: TransactionError if validation fails
func createTransaction(
    amount: Double,
    category: TransactionCategory,
    date: Date = Date()
) -> Result<Transaction, TransactionError> {
    // Implementation
}
```

#### README Documentation
- **File Purpose:** Clear description of file purpose
- **Usage Examples:** Code examples for complex functions
- **Dependencies:** List of dependencies and requirements
- **Known Issues:** Document any known limitations

### Testing Standards

#### Test Naming
```swift
func testCreateTransaction_WithValidData_ReturnsSuccess() { }
func testCreateTransaction_WithInvalidAmount_ReturnsError() { }
func testUpdateTransaction_WithValidData_UpdatesSuccessfully() { }
```

#### Test Structure
```swift
func testCreateTransaction_Success() {
    // Given
    let amount = 100.0
    let category = TransactionCategory.food
    let date = Date()
    
    // When
    let result = repository.createTransaction(amount: amount, category: category, date: date)
    
    // Then
    XCTAssertTrue(result.isSuccess)
    XCTAssertEqual(result.value?.amount, amount)
    XCTAssertEqual(result.value?.category, category.rawValue)
}
```

### Performance Standards

#### Memory Management
- **Weak References:** Use `weak` for delegate patterns
- **Unowned References:** Use `unowned` when appropriate
- **Memory Leaks:** Avoid retain cycles
- **Resource Cleanup:** Properly clean up resources

#### Performance Guidelines
- **Lazy Loading:** Use `@State` and `@StateObject` appropriately
- **Efficient Queries:** Optimize Core Data queries
- **Background Processing:** Use background contexts for heavy operations
- **UI Responsiveness:** Keep UI updates on main thread

### Security Standards

#### Data Protection
- **Sensitive Data:** Store in Keychain when appropriate
- **Data Encryption:** Use Core Data encryption
- **Input Validation:** Validate all user inputs
- **Error Messages:** Don't expose sensitive information

#### Example
```swift
// Store sensitive data in Keychain
func storeUserToken(_ token: String) {
    let data = token.data(using: .utf8)!
    let query: [String: Any] = [
        kSecClass as String: kSecClassGenericPassword,
        kSecAttrAccount as String: "user_token",
        kSecValueData as String: data
    ]
    
    SecItemDelete(query as CFDictionary)
    SecItemAdd(query as CFDictionary, nil)
}
```

## Code Quality Tools

### SwiftLint Configuration
```yaml
# .swiftlint.yml
disabled_rules:
  - trailing_whitespace
  - line_length

opt_in_rules:
  - empty_count
  - empty_string
  - force_unwrapping
  - implicitly_unwrapped_optional

included:
  - ABCBudgeting

excluded:
  - Pods
  - Tests

line_length:
  warning: 120
  error: 200

function_body_length:
  warning: 50
  error: 100

type_body_length:
  warning: 300
  error: 500
```

### Pre-commit Hooks
```bash
#!/bin/sh
# .git/hooks/pre-commit

# Run SwiftLint
if which swiftlint >/dev/null; then
  swiftlint
else
  echo "warning: SwiftLint not installed, download from https://github.com/realm/SwiftLint"
fi

# Run tests
xcodebuild test -scheme ABCBudgeting -destination 'platform=iOS Simulator,name=iPhone 15'
```

## Code Review Standards

### Review Checklist
- [ ] **Code Style:** Follows naming conventions and formatting
- [ ] **Documentation:** Adequate comments and documentation
- [ ] **Testing:** Appropriate test coverage
- [ ] **Performance:** No obvious performance issues
- [ ] **Security:** No security vulnerabilities
- [ ] **Error Handling:** Proper error handling
- [ ] **Memory Management:** No memory leaks
- [ ] **Accessibility:** Accessibility considerations

### Review Process
1. **Self Review:** Author reviews own code first
2. **Peer Review:** At least one peer review required
3. **Technical Review:** Technical lead review for complex changes
4. **Final Approval:** Merge only after all reviews approved

## Continuous Integration

### Automated Checks
- **SwiftLint:** Code style validation
- **Unit Tests:** All unit tests must pass
- **Integration Tests:** All integration tests must pass
- **UI Tests:** All UI tests must pass
- **Performance Tests:** Performance requirements met
- **Security Tests:** Security requirements met

### Quality Gates
- **Code Coverage:** Minimum 90% coverage
- **Test Success:** 100% test pass rate
- **Performance:** All performance requirements met
- **Security:** All security requirements met
- **Documentation:** All public APIs documented

## Best Practices

### General Principles
- **KISS (Keep It Simple, Stupid):** Write simple, clear code
- **DRY (Don't Repeat Yourself):** Avoid code duplication
- **SOLID Principles:** Follow SOLID design principles
- **YAGNI (You Aren't Gonna Need It):** Don't over-engineer
- **Clean Code:** Write readable, maintainable code

### Swift-Specific Best Practices
- **Optionals:** Use optionals appropriately, avoid force unwrapping
- **Protocols:** Use protocols for abstraction
- **Extensions:** Use extensions to organize code
- **Generics:** Use generics for reusable code
- **Closures:** Use closures appropriately, avoid retain cycles

### iOS-Specific Best Practices
- **Memory Management:** Follow iOS memory management patterns
- **Lifecycle:** Understand view and app lifecycle
- **Threading:** Use appropriate threading for operations
- **User Experience:** Prioritize user experience
- **Accessibility:** Make app accessible to all users

## Conclusion

These code standards ensure consistent, high-quality code across the ABC Budgeting project. Following these standards leads to:

- **Maintainability:** Easier to maintain and update code
- **Readability:** Clear, understandable code
- **Quality:** Fewer bugs and issues
- **Team Collaboration:** Consistent code style across team
- **Performance:** Optimized, efficient code

**Key Success Factors:**
- Consistent application of standards
- Regular code reviews
- Automated quality checks
- Continuous improvement
- Team training and education

**Next Steps:**
1. Implement SwiftLint configuration
2. Set up pre-commit hooks
3. Train team on standards
4. Establish code review process
5. Monitor and improve standards
