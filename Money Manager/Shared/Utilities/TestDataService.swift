import Foundation
import SwiftUI

/// Service for adding temporary test data to help with testing and development
@MainActor
class TestDataService: ObservableObject {
    
    /// Add temporary test data to all ViewModels
    static func addTestData(
        transactionViewModel: TransactionViewModel,
        budgetViewModel: BudgetViewModel,
        loanViewModel: LoanViewModel
    ) {
        addTestTransactions(to: transactionViewModel)
        addTestBudgets(to: budgetViewModel)
        addTestLoans(to: loanViewModel)
    }
    
    /// Add sample transactions
    private static func addTestTransactions(to viewModel: TransactionViewModel) {
        let testTransactions = [
            Transaction(title: "Salary Deposit", amount: 3500.00, date: Calendar.current.date(byAdding: .day, value: -5, to: Date()) ?? Date(), category: "Income"),
            Transaction(title: "Grocery Shopping", amount: -125.50, date: Calendar.current.date(byAdding: .day, value: -4, to: Date()) ?? Date(), category: "Food & Dining"),
            Transaction(title: "Gas Station", amount: -45.00, date: Calendar.current.date(byAdding: .day, value: -3, to: Date()) ?? Date(), category: "Transportation"),
            Transaction(title: "Netflix Subscription", amount: -15.99, date: Calendar.current.date(byAdding: .day, value: -2, to: Date()) ?? Date(), category: "Entertainment"),
            Transaction(title: "Coffee Shop", amount: -8.50, date: Calendar.current.date(byAdding: .day, value: -1, to: Date()) ?? Date(), category: "Food & Dining"),
            Transaction(title: "Freelance Work", amount: 500.00, date: Calendar.current.date(byAdding: .day, value: -7, to: Date()) ?? Date(), category: "Income"),
            Transaction(title: "Electric Bill", amount: -85.25, date: Calendar.current.date(byAdding: .day, value: -6, to: Date()) ?? Date(), category: "Utilities"),
            Transaction(title: "Restaurant Dinner", amount: -67.80, date: Calendar.current.date(byAdding: .day, value: -5, to: Date()) ?? Date(), category: "Food & Dining"),
            Transaction(title: "Uber Ride", amount: -12.50, date: Calendar.current.date(byAdding: .day, value: -4, to: Date()) ?? Date(), category: "Transportation"),
            Transaction(title: "Amazon Purchase", amount: -89.99, date: Calendar.current.date(byAdding: .day, value: -3, to: Date()) ?? Date(), category: "Shopping"),
            Transaction(title: "Gym Membership", amount: -29.99, date: Calendar.current.date(byAdding: .day, value: -2, to: Date()) ?? Date(), category: "Health & Fitness"),
            Transaction(title: "Bank Transfer", amount: 200.00, date: Calendar.current.date(byAdding: .day, value: -1, to: Date()) ?? Date(), category: "Income"),
            Transaction(title: "Pharmacy", amount: -35.75, date: Calendar.current.date(byAdding: .day, value: -8, to: Date()) ?? Date(), category: "Health & Fitness"),
            Transaction(title: "Movie Tickets", amount: -24.00, date: Calendar.current.date(byAdding: .day, value: -7, to: Date()) ?? Date(), category: "Entertainment"),
            Transaction(title: "Parking Fee", amount: -15.00, date: Calendar.current.date(byAdding: .day, value: -6, to: Date()) ?? Date(), category: "Transportation")
        ]
        
        for transaction in testTransactions {
            viewModel.addTransaction(transaction)
        }
    }
    
    /// Add sample budgets
    private static func addTestBudgets(to viewModel: BudgetViewModel) {
        let testBudgets = [
            Budget(category: "Food & Dining", allocatedAmount: 500.00, spentAmount: 201.80, remainingAmount: 298.20),
            Budget(category: "Transportation", allocatedAmount: 200.00, spentAmount: 72.50, remainingAmount: 127.50),
            Budget(category: "Entertainment", allocatedAmount: 150.00, spentAmount: 39.99, remainingAmount: 110.01),
            Budget(category: "Utilities", allocatedAmount: 300.00, spentAmount: 85.25, remainingAmount: 214.75),
            Budget(category: "Shopping", allocatedAmount: 200.00, spentAmount: 89.99, remainingAmount: 110.01),
            Budget(category: "Health & Fitness", allocatedAmount: 100.00, spentAmount: 65.74, remainingAmount: 34.26),
            Budget(category: "Income", allocatedAmount: 4000.00, spentAmount: 0.00, remainingAmount: 4000.00),
            Budget(category: "Savings", allocatedAmount: 800.00, spentAmount: 0.00, remainingAmount: 800.00)
        ]
        
        for budget in testBudgets {
            viewModel.addBudget(budget)
        }
    }
    
    /// Add sample loans
    private static func addTestLoans(to viewModel: LoanViewModel) {
        let testLoans = [
            Loan(
                name: "Student Loan",
                principalAmount: 25000.00,
                remainingAmount: 18500.00,
                interestRate: 4.5,
                monthlyPayment: 350.00,
                dueDate: Calendar.current.date(byAdding: .day, value: 15, to: Date()) ?? Date(),
                paymentStatus: .current,
                lastPaymentDate: Calendar.current.date(byAdding: .day, value: -30, to: Date()),
                nextPaymentDueDate: Calendar.current.date(byAdding: .day, value: 15, to: Date()),
                category: .student
            ),
            Loan(
                name: "Car Loan",
                principalAmount: 18000.00,
                remainingAmount: 12500.00,
                interestRate: 3.2,
                monthlyPayment: 425.00,
                dueDate: Calendar.current.date(byAdding: .day, value: 8, to: Date()) ?? Date(),
                paymentStatus: .current,
                lastPaymentDate: Calendar.current.date(byAdding: .day, value: -25, to: Date()),
                nextPaymentDueDate: Calendar.current.date(byAdding: .day, value: 8, to: Date()),
                category: .auto
            ),
            Loan(
                name: "Credit Card",
                principalAmount: 5000.00,
                remainingAmount: 3200.00,
                interestRate: 18.9,
                monthlyPayment: 150.00,
                dueDate: Calendar.current.date(byAdding: .day, value: -5, to: Date()) ?? Date(),
                paymentStatus: .overdue,
                lastPaymentDate: Calendar.current.date(byAdding: .day, value: -35, to: Date()),
                nextPaymentDueDate: Calendar.current.date(byAdding: .day, value: -5, to: Date()),
                category: .creditCard
            ),
            Loan(
                name: "Home Improvement",
                principalAmount: 12000.00,
                remainingAmount: 8500.00,
                interestRate: 6.8,
                monthlyPayment: 280.00,
                dueDate: Calendar.current.date(byAdding: .day, value: 22, to: Date()) ?? Date(),
                paymentStatus: .current,
                lastPaymentDate: Calendar.current.date(byAdding: .day, value: -28, to: Date()),
                nextPaymentDueDate: Calendar.current.date(byAdding: .day, value: 22, to: Date()),
                category: .mortgage
            ),
            Loan(
                name: "Personal Loan",
                principalAmount: 8000.00,
                remainingAmount: 0.00,
                interestRate: 7.5,
                monthlyPayment: 0.00,
                dueDate: Calendar.current.date(byAdding: .day, value: -10, to: Date()) ?? Date(),
                paymentStatus: .paid,
                lastPaymentDate: Calendar.current.date(byAdding: .day, value: -10, to: Date()),
                nextPaymentDueDate: nil,
                category: .personal
            )
        ]
        
        for loan in testLoans {
            let dueDay = Calendar.current.component(.day, from: loan.dueDate)
            viewModel.addLoan(
                name: loan.name,
                principalAmount: loan.principalAmount,
                interestRate: loan.interestRate,
                monthlyPayment: loan.monthlyPayment,
                dueDay: dueDay,
                category: loan.category,
                paymentStatus: loan.paymentStatus,
                lastPaymentDate: loan.lastPaymentDate ?? Date(),
                nextPaymentDueDate: loan.nextPaymentDueDate ?? loan.dueDate
            )
        }
    }
    
    /// Clear all test data
    static func clearTestData(
        transactionViewModel: TransactionViewModel,
        budgetViewModel: BudgetViewModel,
        loanViewModel: LoanViewModel
    ) {
        transactionViewModel.transactions.removeAll()
        budgetViewModel.budgets.removeAll()
        loanViewModel.loans.removeAll()
    }
}
