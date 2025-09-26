import Foundation
import SwiftUI

@MainActor
class TransactionViewModel: ObservableObject {
    @Published var transactions: [Transaction] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    var hasDataLoaded = false
    
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
        
        // Simulate loading delay for better UX
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            // Start with empty state - no sample data
            self.transactions = []
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
    
    func addTransaction(_ transaction: Transaction) {
        transactions.append(transaction)
        // Sort transactions by date (newest first)
        transactions.sort { $0.date > $1.date }
    }
    
    func deleteTransaction(withId id: UUID) {
        transactions.removeAll { $0.id == id }
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
