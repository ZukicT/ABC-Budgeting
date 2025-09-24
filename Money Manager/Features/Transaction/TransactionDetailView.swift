import SwiftUI

struct TransactionDetailView: View {
    let transactionId: UUID
    @ObservedObject var transactionViewModel: TransactionViewModel
    @Environment(\.dismiss) var dismiss
    @State private var showingEditSheet = false
    @State private var showingDeleteAlert = false
    
    private var transaction: Transaction? {
        transactionViewModel.transactions.first { $0.id == transactionId }
    }
    
    private var transactionBinding: Binding<Transaction> {
        Binding(
            get: { transaction ?? Transaction(title: "Unknown", amount: 0, date: Date(), category: "Other") },
            set: { updatedTransaction in
                transactionViewModel.updateTransaction(updatedTransaction)
            }
        )
    }
    
    var body: some View {
        Group {
            if let transaction = transaction {
                NavigationStack {
                    ScrollView {
                        VStack(spacing: Constants.UI.Spacing.large) {
                            // Header Section
                            VStack(spacing: Constants.UI.Spacing.medium) {
                                // Category Icon
                                ZStack {
                                    Circle()
                                        .fill(categoryColor(for: transaction.category))
                                        .frame(width: 80, height: 80)
                                    
                                    Image(systemName: categoryIcon(for: transaction.category))
                                        .font(.system(size: 32, weight: .semibold))
                                        .foregroundColor(.white)
                                }
                                .accessibilityHidden(true)
                                
                                // Transaction Title
                                Text(transaction.title)
                                    .font(Constants.Typography.H1.font)
                                    .fontWeight(.bold)
                                    .foregroundColor(Constants.Colors.textPrimary)
                                    .multilineTextAlignment(.center)
                                    .lineLimit(3)
                                
                                // Amount
                                Text(transaction.amount, format: .currency(code: "USD"))
                                    .font(.system(size: 36, weight: .bold, design: .rounded))
                                    .foregroundColor(transaction.amount >= 0 ? Constants.Colors.success : Constants.Colors.error)
                                    .accessibilityLabel("Amount: \(transaction.amount, format: .currency(code: "USD"))")
                            }
                            .padding(.top, Constants.UI.Spacing.large)
                            
                            // Details Section
                            VStack(spacing: Constants.UI.Spacing.medium) {
                                // Category
                                DetailRow(
                                    title: "Category",
                                    value: transaction.category,
                                    icon: "tag.fill",
                                    iconColor: categoryColor(for: transaction.category)
                                )
                                
                                // Date
                                DetailRow(
                                    title: "Date",
                                    value: transaction.date.formatted(date: .complete, time: .omitted),
                                    icon: "calendar",
                                    iconColor: Constants.Colors.info
                                )
                                
                                // Time
                                DetailRow(
                                    title: "Time",
                                    value: transaction.date.formatted(date: .omitted, time: .shortened),
                                    icon: "clock",
                                    iconColor: Constants.Colors.info
                                )
                                
                                // Transaction Type
                                DetailRow(
                                    title: "Type",
                                    value: transaction.amount >= 0 ? "Income" : "Expense",
                                    icon: transaction.amount >= 0 ? "arrow.down.circle.fill" : "arrow.up.circle.fill",
                                    iconColor: transaction.amount >= 0 ? Constants.Colors.success : Constants.Colors.error
                                )
                                
                                // Amount in different formats
                                DetailRow(
                                    title: "Amount (Raw)",
                                    value: String(format: "%.2f", transaction.amount),
                                    icon: "number",
                                    iconColor: Constants.Colors.textSecondary
                                )
                            }
                            .padding(.horizontal, Constants.UI.Padding.screenMargin)
                            
                            // Action Buttons
                            VStack(spacing: Constants.UI.Spacing.medium) {
                                // Edit Button
                                Button(action: {
                                    showingEditSheet = true
                                }) {
                                    HStack {
                                        Image(systemName: "pencil")
                                        Text("Edit Transaction")
                                    }
                                    .font(Constants.Typography.Body.font)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, Constants.UI.Spacing.medium)
                                    .background(Constants.Colors.cleanBlack)
                                    .cornerRadius(Constants.UI.cardCornerRadius)
                                }
                                .accessibilityLabel("Edit transaction")
                                
                                // Delete Button
                                Button(action: {
                                    showingDeleteAlert = true
                                }) {
                                    HStack {
                                        Image(systemName: "trash")
                                        Text("Delete Transaction")
                                    }
                                    .font(Constants.Typography.Body.font)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, Constants.UI.Spacing.medium)
                                    .background(Constants.Colors.error)
                                    .cornerRadius(Constants.UI.cardCornerRadius)
                                }
                                .accessibilityLabel("Delete transaction")
                            }
                            .padding(.horizontal, Constants.UI.Padding.screenMargin)
                            .padding(.bottom, Constants.UI.Spacing.section)
                        }
                    }
                    .navigationTitle("Transaction Details")
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbar {
                        ToolbarItem(placement: .navigationBarTrailing) {
                            Button("Done") {
                                dismiss()
                            }
                            .font(Constants.Typography.Body.font)
                            .foregroundColor(Constants.Colors.textPrimary)
                        }
                    }
                    .sheet(isPresented: $showingEditSheet) {
                        TransactionEditView(transaction: transactionBinding)
                    }
                    .alert("Delete Transaction", isPresented: $showingDeleteAlert) {
                        Button("Cancel", role: .cancel) { }
                        Button("Delete", role: .destructive) {
                            // TODO: Implement delete functionality
                            dismiss()
                        }
                    } message: {
                        Text("Are you sure you want to delete this transaction? This action cannot be undone.")
                    }
                }
            } else {
                // Transaction not found
                VStack(spacing: Constants.UI.Spacing.large) {
                    Image(systemName: "exclamationmark.triangle")
                        .font(.system(size: 50))
                        .foregroundColor(Constants.Colors.warning)
                    
                    Text("Transaction Not Found")
                        .font(Constants.Typography.H2.font)
                        .foregroundColor(Constants.Colors.textPrimary)
                    
                    Text("This transaction may have been deleted.")
                        .font(Constants.Typography.Body.font)
                        .foregroundColor(Constants.Colors.textSecondary)
                        .multilineTextAlignment(.center)
                    
                    Button("Done") {
                        dismiss()
                    }
                    .font(Constants.Typography.Body.font)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .padding(.horizontal, Constants.UI.Spacing.large)
                    .padding(.vertical, Constants.UI.Spacing.medium)
                    .background(Constants.Colors.primaryBlue)
                    .cornerRadius(Constants.UI.cardCornerRadius)
                }
                .padding(Constants.UI.Padding.screenMargin)
            }
        }
    }
    
    // MARK: - Helper Functions
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

// MARK: - Detail Row Component
private struct DetailRow: View {
    let title: String
    let value: String
    let icon: String
    let iconColor: Color
    
    var body: some View {
        HStack(spacing: Constants.UI.Spacing.medium) {
            // Icon
            ZStack {
                RoundedRectangle(cornerRadius: 8)
                    .fill(iconColor.opacity(0.1))
                    .frame(width: 40, height: 40)
                
                Image(systemName: icon)
                    .font(.title3)
                    .fontWeight(.semibold)
                    .foregroundColor(iconColor)
            }
            .accessibilityHidden(true)
            
            // Content
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(Constants.Typography.Caption.font)
                    .fontWeight(.medium)
                    .foregroundColor(Constants.Colors.textSecondary)
                
                Text(value)
                    .font(Constants.Typography.Body.font)
                    .fontWeight(.semibold)
                    .foregroundColor(Constants.Colors.textPrimary)
            }
            
            Spacer()
        }
        .padding(.vertical, Constants.UI.Spacing.small)
        .padding(.horizontal, Constants.UI.Spacing.medium)
        .background(Constants.Colors.backgroundSecondary)
        .cornerRadius(Constants.UI.cardCornerRadius)
    }
}

#Preview {
    TransactionDetailView(
        transactionId: UUID(),
        transactionViewModel: TransactionViewModel()
    )
}
