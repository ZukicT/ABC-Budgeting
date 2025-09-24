import SwiftUI

/// Shared TransactionCard component used across the app
/// Provides consistent transaction display with category icons and formatting
struct TransactionCard: View {
    let transaction: Transaction
    
    var body: some View {
        HStack(spacing: Constants.UI.Spacing.medium) {
            // Category Icon - Fixed Size
            ZStack {
                Rectangle()
                    .fill(categoryColor(for: transaction.category))
                    .frame(width: 40, height: 40)
                
                Image(systemName: categoryIcon(for: transaction.category))
                    .font(.title3)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
            }
            .accessibilityHidden(true)
            
            // Transaction Details - Fixed Layout
            VStack(alignment: .leading, spacing: 4) {
                // Transaction Title - Primary Information
                Text(transaction.title)
                    .font(Constants.Typography.Body.font)
                    .fontWeight(.semibold)
                    .foregroundColor(Constants.Colors.textPrimary)
                    .lineLimit(1)
                    .truncationMode(.tail)
                
                // Category and Date - Secondary Information
                HStack(spacing: 6) {
                    Text(transaction.category)
                        .font(Constants.Typography.Caption.font)
                        .fontWeight(.medium)
                        .foregroundColor(Constants.Colors.textSecondary)
                    
                    Text("•")
                        .font(Constants.Typography.Caption.font)
                        .foregroundColor(Constants.Colors.textTertiary)
                    
                    Text(transaction.date, format: .dateTime.month(.abbreviated).day().year(.twoDigits))
                        .font(Constants.Typography.Caption.font)
                        .foregroundColor(Constants.Colors.textSecondary)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            
            // Amount Section - Fixed Width
            VStack(alignment: .trailing, spacing: 2) {
                // Amount - Most Prominent
                Text(transaction.amount, format: .currency(code: "USD"))
                    .font(Constants.Typography.H3.font)
                    .fontWeight(.bold)
                    .foregroundColor(transaction.amount >= 0 ? Constants.Colors.success : Constants.Colors.error)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
                
                // Transaction Type Label
                Text(transaction.amount >= 0 ? "Income" : "Expense")
                    .font(.caption2)
                    .fontWeight(.medium)
                    .foregroundColor(transaction.amount >= 0 ? Constants.Colors.success : Constants.Colors.error)
            }
            .frame(width: 80, alignment: .trailing)
        }
        .padding(Constants.UI.Padding.cardInternal)
        .background(Constants.Colors.cardBackground)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(transaction.title), \(transaction.amount, format: .currency(code: "USD")), \(transaction.category)")
    }
    
    private func categoryIcon(for category: String) -> String {
        switch category.lowercased() {
        case "food": return "fork.knife"
        case "transport": return "car.fill"
        case "shopping": return "bag.fill"
        case "entertainment": return "tv.fill"
        case "bills": return "doc.text.fill"
        case "income": return "arrow.down.circle.fill"
        default: return "creditcard.fill"
        }
    }
    
    private func categoryColor(for category: String) -> Color {
        switch category.lowercased() {
        case "food": return .green
        case "transport": return .blue
        case "shopping": return .orange
        case "entertainment": return .purple
        case "bills": return .red
        case "income": return .green
        case "savings": return .green
        case "other": return .gray
        default: return .blue
        }
    }
}

#Preview {
    VStack(spacing: 16) {
        TransactionCard(transaction: Transaction(
            title: "Coffee Shop",
            amount: -4.50,
            date: Date(),
            category: "Food"
        ))
        
        TransactionCard(transaction: Transaction(
            title: "Salary",
            amount: 2500.00,
            date: Date(),
            category: "Income"
        ))
    }
    .padding()
}
