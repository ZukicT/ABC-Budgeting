import SwiftUI

// MARK: - Loan Data Model
struct LoanItem: Identifiable, Hashable {
    let id: UUID
    let name: String
    let lender: String
    let originalAmount: Double
    let currentBalance: Double
    let interestRate: Double
    let monthlyPayment: Double
    let startDate: Date
    let endDate: Date
    let loanType: LoanType
    let status: LoanStatus
    let notes: String?
    let iconName: String
    let iconColorName: String
    let iconBackgroundName: String
    
    var iconColor: Color { Color.fromName(iconColorName) }
    var iconBackground: Color { Color.fromName(iconBackgroundName) }
    
    // Computed properties
    var totalPaid: Double {
        originalAmount - currentBalance
    }
    
    var progressPercentage: Double {
        guard originalAmount > 0 else { return 0 }
        return (totalPaid / originalAmount) * 100
    }
    
    var remainingPayments: Int {
        let calendar = Calendar.current
        let monthsRemaining = calendar.dateComponents([.month], from: Date(), to: endDate).month ?? 0
        return max(0, monthsRemaining)
    }
    
    var nextPaymentDate: Date {
        let calendar = Calendar.current
        let now = Date()
        let currentMonth = calendar.component(.month, from: now)
        let currentYear = calendar.component(.year, from: now)
        
        // Find the day of the month when the loan started
        let startDay = calendar.component(.day, from: startDate)
        
        // Calculate next payment date
        var nextPayment = calendar.date(from: DateComponents(year: currentYear, month: currentMonth, day: startDay)) ?? now
        
        // If the day has passed this month, move to next month
        if nextPayment <= now {
            nextPayment = calendar.date(byAdding: .month, value: 1, to: nextPayment) ?? now
        }
        
        return nextPayment
    }
    
    var isOverdue: Bool {
        nextPaymentDate < Date()
    }
    
    var daysUntilNextPayment: Int {
        let calendar = Calendar.current
        return calendar.dateComponents([.day], from: Date(), to: nextPaymentDate).day ?? 0
    }
    
    static func makeMockData() -> [LoanItem] {
        let now = Date()
        let calendar = Calendar.current
        
        return [
            LoanItem(
                id: UUID(),
                name: "Student Loan",
                lender: "Federal Student Aid",
                originalAmount: 25000,
                currentBalance: 18500,
                interestRate: 4.5,
                monthlyPayment: 350,
                startDate: calendar.date(byAdding: .year, value: -2, to: now) ?? now,
                endDate: calendar.date(byAdding: .year, value: 3, to: now) ?? now,
                loanType: .student,
                status: .active,
                notes: "Federal student loan for undergraduate studies",
                iconName: "graduationcap",
                iconColorName: "blue",
                iconBackgroundName: "blue.opacity15"
            ),
            LoanItem(
                id: UUID(),
                name: "Car Loan",
                lender: "Auto Finance Co.",
                originalAmount: 18000,
                currentBalance: 12000,
                interestRate: 3.2,
                monthlyPayment: 280,
                startDate: calendar.date(byAdding: .month, value: -8, to: now) ?? now,
                endDate: calendar.date(byAdding: .year, value: 2, to: now) ?? now,
                loanType: .auto,
                status: .active,
                notes: "2022 Honda Civic",
                iconName: "car",
                iconColorName: "green",
                iconBackgroundName: "green.opacity15"
            ),
            LoanItem(
                id: UUID(),
                name: "Personal Loan",
                lender: "Community Bank",
                originalAmount: 5000,
                currentBalance: 0,
                interestRate: 6.8,
                monthlyPayment: 0,
                startDate: calendar.date(byAdding: .year, value: -1, to: now) ?? now,
                endDate: calendar.date(byAdding: .month, value: -2, to: now) ?? now,
                loanType: .personal,
                status: .paidOff,
                notes: "Emergency fund loan - paid off early",
                iconName: "checkmark.circle",
                iconColorName: "mint",
                iconBackgroundName: "mint.opacity15"
            ),
            LoanItem(
                id: UUID(),
                name: "Home Mortgage",
                lender: "First National Bank",
                originalAmount: 300000,
                currentBalance: 275000,
                interestRate: 3.8,
                monthlyPayment: 1800,
                startDate: calendar.date(byAdding: .year, value: -1, to: now) ?? now,
                endDate: calendar.date(byAdding: .year, value: 29, to: now) ?? now,
                loanType: .mortgage,
                status: .active,
                notes: "30-year fixed rate mortgage",
                iconName: "house",
                iconColorName: "purple",
                iconBackgroundName: "purple.opacity15"
            )
        ]
    }
}

// MARK: - Loan Types
enum LoanType: String, CaseIterable, Identifiable {
    case student = "Student"
    case auto = "Auto"
    case personal = "Personal"
    case mortgage = "Mortgage"
    case business = "Business"
    case creditCard = "Credit Card"
    case other = "Other"
    
    var id: String { rawValue }
    var label: String { rawValue }
    
    var iconName: String {
        switch self {
        case .student: return "graduationcap"
        case .auto: return "car"
        case .personal: return "person"
        case .mortgage: return "house"
        case .business: return "building.2"
        case .creditCard: return "creditcard"
        case .other: return "questionmark.circle"
        }
    }
    
    var color: Color {
        switch self {
        case .student: return .blue
        case .auto: return RobinhoodColors.primary
        case .personal: return .orange
        case .mortgage: return .purple
        case .business: return .indigo
        case .creditCard: return .red
        case .other: return .gray
        }
    }
}

// MARK: - Loan Status
enum LoanStatus: String, CaseIterable, Identifiable {
    case active = "Active"
    case paidOff = "Paid Off"
    case defaulted = "Defaulted"
    case deferred = "Deferred"
    case refinanced = "Refinanced"
    
    var id: String { rawValue }
    var label: String { rawValue }
    
    var color: Color {
        switch self {
        case .active: return RobinhoodColors.primary
        case .paidOff: return .mint
        case .defaulted: return .red
        case .deferred: return .orange
        case .refinanced: return .blue
        }
    }
    
    var iconName: String {
        switch self {
        case .active: return "clock"
        case .paidOff: return "checkmark.circle"
        case .defaulted: return "exclamationmark.triangle"
        case .deferred: return "pause.circle"
        case .refinanced: return "arrow.triangle.2.circlepath"
        }
    }
}

// MARK: - Loan Payment
struct LoanPayment: Identifiable, Hashable {
    let id: UUID
    let loanId: UUID
    let amount: Double
    let principalAmount: Double
    let interestAmount: Double
    let paymentDate: Date
    let isScheduled: Bool
    let notes: String?
    
    static func makeMockData(for loanId: UUID) -> [LoanPayment] {
        let now = Date()
        let calendar = Calendar.current
        
        return [
            LoanPayment(
                id: UUID(),
                loanId: loanId,
                amount: 350,
                principalAmount: 280,
                interestAmount: 70,
                paymentDate: calendar.date(byAdding: .month, value: -1, to: now) ?? now,
                isScheduled: false,
                notes: "Regular monthly payment"
            ),
            LoanPayment(
                id: UUID(),
                loanId: loanId,
                amount: 350,
                principalAmount: 285,
                interestAmount: 65,
                paymentDate: calendar.date(byAdding: .month, value: -2, to: now) ?? now,
                isScheduled: false,
                notes: "Regular monthly payment"
            ),
            LoanPayment(
                id: UUID(),
                loanId: loanId,
                amount: 350,
                principalAmount: 290,
                interestAmount: 60,
                paymentDate: calendar.date(byAdding: .month, value: -3, to: now) ?? now,
                isScheduled: false,
                notes: "Regular monthly payment"
            )
        ]
    }
}

// MARK: - Loan Summary
struct LoanSummary {
    let totalLoans: Int
    let activeLoans: Int
    let totalDebt: Double
    let totalMonthlyPayments: Double
    let averageInterestRate: Double
    let nextPaymentDate: Date?
    let totalPaidOff: Double
    
    static func calculate(from loans: [LoanItem]) -> LoanSummary {
        let activeLoans = loans.filter { $0.status == .active }
        let paidOffLoans = loans.filter { $0.status == .paidOff }
        
        let totalDebt = activeLoans.reduce(0) { $0 + $1.currentBalance }
        let totalMonthlyPayments = activeLoans.reduce(0) { $0 + $1.monthlyPayment }
        let totalPaidOff = paidOffLoans.reduce(0) { $0 + $1.originalAmount }
        
        let averageInterestRate = activeLoans.isEmpty ? 0 : 
            activeLoans.reduce(0) { $0 + $1.interestRate } / Double(activeLoans.count)
        
        let nextPaymentDate = activeLoans
            .map { $0.nextPaymentDate }
            .min()
        
        return LoanSummary(
            totalLoans: loans.count,
            activeLoans: activeLoans.count,
            totalDebt: totalDebt,
            totalMonthlyPayments: totalMonthlyPayments,
            averageInterestRate: averageInterestRate,
            nextPaymentDate: nextPaymentDate,
            totalPaidOff: totalPaidOff
        )
    }
}
