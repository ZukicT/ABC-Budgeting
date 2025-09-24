import Foundation
import SwiftUI

@MainActor
class TransactionViewModel: ObservableObject {
    @Published var transactions: [Transaction] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private var hasDataLoaded = false
    
    // Counter for tab display
    var transactionCount: Int {
        transactions.count
    }
    
    init() {
        // Initialize transaction data
    }
    
    func loadTransactions() {
        // Only load if data hasn't been loaded yet
        guard !hasDataLoaded else { return }
        
        isLoading = true
        errorMessage = nil
        
        // TODO: Implement transaction loading logic
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            // Sample data for demonstration with multiple months
            let calendar = Calendar.current
            let now = Date()
            
            self.transactions = [
                // Current month (September 2024)
                Transaction(title: "Coffee Shop", amount: -4.50, date: now, category: "Food"),
                Transaction(title: "Gas Station", amount: -35.20, date: now.addingTimeInterval(-86400), category: "Transport"),
                Transaction(title: "Grocery Store", amount: -87.45, date: now.addingTimeInterval(-172800), category: "Food"),
                Transaction(title: "Salary", amount: 2500.00, date: now.addingTimeInterval(-259200), category: "Income"),
                Transaction(title: "Movie Theater", amount: -12.00, date: now.addingTimeInterval(-345600), category: "Entertainment"),
                Transaction(title: "Electric Bill", amount: -89.30, date: now.addingTimeInterval(-432000), category: "Bills"),
                Transaction(title: "Online Shopping", amount: -156.78, date: now.addingTimeInterval(-518400), category: "Shopping"),
                Transaction(title: "Restaurant", amount: -42.15, date: now.addingTimeInterval(-604800), category: "Food"),
                
                // Previous month (August 2024)
                Transaction(title: "Gym Membership", amount: -49.99, date: calendar.date(byAdding: .month, value: -1, to: now) ?? now, category: "Bills"),
                Transaction(title: "Uber Ride", amount: -15.75, date: calendar.date(byAdding: .month, value: -1, to: now)?.addingTimeInterval(-86400) ?? now, category: "Transport"),
                Transaction(title: "Netflix", amount: -15.99, date: calendar.date(byAdding: .month, value: -1, to: now)?.addingTimeInterval(-172800) ?? now, category: "Entertainment"),
                Transaction(title: "Grocery Store", amount: -92.30, date: calendar.date(byAdding: .month, value: -1, to: now)?.addingTimeInterval(-259200) ?? now, category: "Food"),
                Transaction(title: "Freelance Work", amount: 800.00, date: calendar.date(byAdding: .month, value: -1, to: now)?.addingTimeInterval(-345600) ?? now, category: "Income"),
                Transaction(title: "Amazon Purchase", amount: -67.45, date: calendar.date(byAdding: .month, value: -1, to: now)?.addingTimeInterval(-432000) ?? now, category: "Shopping"),
                
                // Two months ago (July 2024)
                Transaction(title: "Phone Bill", amount: -85.00, date: calendar.date(byAdding: .month, value: -2, to: now) ?? now, category: "Bills"),
                Transaction(title: "Coffee Shop", amount: -5.25, date: calendar.date(byAdding: .month, value: -2, to: now)?.addingTimeInterval(-86400) ?? now, category: "Food"),
                Transaction(title: "Gas Station", amount: -42.80, date: calendar.date(byAdding: .month, value: -2, to: now)?.addingTimeInterval(-172800) ?? now, category: "Transport"),
                Transaction(title: "Concert Tickets", amount: -120.00, date: calendar.date(byAdding: .month, value: -2, to: now)?.addingTimeInterval(-259200) ?? now, category: "Entertainment"),
                Transaction(title: "Grocery Store", amount: -78.90, date: calendar.date(byAdding: .month, value: -2, to: now)?.addingTimeInterval(-345600) ?? now, category: "Food"),
                Transaction(title: "Investment Return", amount: 150.00, date: calendar.date(byAdding: .month, value: -2, to: now)?.addingTimeInterval(-432000) ?? now, category: "Income")
            ]
            self.isLoading = false
            self.hasDataLoaded = true
        }
    }
    
    func refreshTransactions() {
        hasDataLoaded = false
        loadTransactions()
    }
    
    func updateTransaction(_ updatedTransaction: Transaction) {
        if let index = transactions.firstIndex(where: { $0.id == updatedTransaction.id }) {
            transactions[index] = updatedTransaction
        }
    }
}

struct Transaction: Identifiable {
    let id: UUID
    let title: String
    let amount: Double
    let date: Date
    let category: String
    
    init(title: String, amount: Double, date: Date, category: String) {
        self.id = UUID()
        self.title = title
        self.amount = amount
        self.date = date
        self.category = category
    }
    
    init(id: UUID, title: String, amount: Double, date: Date, category: String) {
        self.id = id
        self.title = title
        self.amount = amount
        self.date = date
        self.category = category
    }
}
