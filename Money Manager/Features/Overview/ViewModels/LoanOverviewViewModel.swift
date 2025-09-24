import SwiftUI
import Foundation

@MainActor
class LoanOverviewViewModel: ObservableObject {
    @Published var loanOverviewItems: [LoanOverviewItem] = []
    @Published var totalRemainingBalance: Double = 0.0
    @Published var totalMonthlyPayments: Double = 0.0
    @Published var overdueCount: Int = 0
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    init() {
        generateSampleData()
    }
    
    func refreshData() {
        isLoading = true
        errorMessage = nil
        
        // Simulate data refresh
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.generateSampleData()
            self.isLoading = false
        }
    }
    
    private func generateSampleData() {
        // Sample loan data
        let now = Date()
        let calendar = Calendar.current
        
        let sampleLoans = [
            Loan(name: "Auto Loan", principalAmount: 25000.0, remainingAmount: 18500.0, interestRate: 4.5, monthlyPayment: 450.0, dueDate: Date().addingTimeInterval(86400 * 15), paymentStatus: .current, lastPaymentDate: calendar.date(byAdding: .month, value: -1, to: now), nextPaymentDueDate: Date().addingTimeInterval(86400 * 15), category: .auto),
            Loan(name: "Student Loan", principalAmount: 15000.0, remainingAmount: 12000.0, interestRate: 3.2, monthlyPayment: 280.0, dueDate: Date().addingTimeInterval(86400 * 5), paymentStatus: .overdue, lastPaymentDate: calendar.date(byAdding: .month, value: -1, to: now), nextPaymentDueDate: Date().addingTimeInterval(86400 * -2), category: .student),
            Loan(name: "Credit Card", principalAmount: 5000.0, remainingAmount: 3200.0, interestRate: 18.9, monthlyPayment: 150.0, dueDate: Date().addingTimeInterval(86400 * 3), paymentStatus: .missed, lastPaymentDate: calendar.date(byAdding: .month, value: -2, to: now), nextPaymentDueDate: Date().addingTimeInterval(86400 * -5), category: .creditCard),
            Loan(name: "Home Loan", principalAmount: 300000.0, remainingAmount: 245000.0, interestRate: 3.8, monthlyPayment: 1200.0, dueDate: Date().addingTimeInterval(86400 * 25), paymentStatus: .current, lastPaymentDate: calendar.date(byAdding: .month, value: -1, to: now), nextPaymentDueDate: Date().addingTimeInterval(86400 * 25), category: .mortgage),
            Loan(name: "Personal Loan", principalAmount: 8000.0, remainingAmount: 5200.0, interestRate: 6.5, monthlyPayment: 320.0, dueDate: Date().addingTimeInterval(-86400 * 2), paymentStatus: .overdue, lastPaymentDate: calendar.date(byAdding: .month, value: -1, to: now), nextPaymentDueDate: Date().addingTimeInterval(-86400 * 2), category: .personal) // Overdue
        ]
        
        // Convert to LoanOverviewItem
        self.loanOverviewItems = sampleLoans.map { loan in
            let progressPercentage = calculateProgressPercentage(loan)
            let isOverdue = isLoanOverdue(loan)
            let statusColor = getStatusColor(loan, isOverdue: isOverdue)
            
            return LoanOverviewItem(
                loan: loan,
                remainingBalance: loan.remainingAmount,
                monthlyPayment: loan.monthlyPayment,
                progressPercentage: progressPercentage,
                nextDueDate: loan.dueDate,
                isOverdue: isOverdue,
                statusColor: statusColor
            )
        }
        
        // Calculate summary data
        self.totalRemainingBalance = loanOverviewItems.reduce(0) { $0 + $1.remainingBalance }
        self.totalMonthlyPayments = loanOverviewItems.reduce(0) { $0 + $1.monthlyPayment }
        self.overdueCount = loanOverviewItems.filter { $0.isOverdue }.count
    }
    
    private func calculateProgressPercentage(_ loan: Loan) -> Double {
        let paidAmount = loan.principalAmount - loan.remainingAmount
        return (paidAmount / loan.principalAmount) * 100
    }
    
    private func isLoanOverdue(_ loan: Loan) -> Bool {
        return loan.dueDate < Date()
    }
    
    private func getStatusColor(_ loan: Loan, isOverdue: Bool) -> Color {
        if isOverdue {
            return Constants.Colors.error
        } else if loan.dueDate < Date().addingTimeInterval(86400 * 7) { // Due within 7 days
            return Constants.Colors.warning
        } else {
            return Constants.Colors.success
        }
    }
}

// MARK: - Data Models
struct LoanOverviewItem: Identifiable {
    let id = UUID()
    let loan: Loan
    let remainingBalance: Double
    let monthlyPayment: Double
    let progressPercentage: Double
    let nextDueDate: Date
    let isOverdue: Bool
    let statusColor: Color
}

struct LoanOverviewData {
    let loans: [LoanOverviewItem]
    let totalRemainingBalance: Double
    let totalMonthlyPayments: Double
    let overdueCount: Int
}
