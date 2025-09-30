//
//  LoanViewModel.swift
//  Money Manager
//
//  Created by Development Team
//  Copyright © 2025 Money Manager. All rights reserved.
//
//  Code Summary:
//  ViewModel for managing loan data, payment tracking, and debt analysis.
//  Handles loan CRUD operations, category filtering, payment calculations,
//  and financial metrics for debt management.
//
//  Review Date: September 29, 2025
//

import Foundation
import SwiftUI

@MainActor
class LoanViewModel: ObservableObject {
    @Published var loans: [Loan] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var selectedCategory: LoanCategory? = nil
    
    var hasDataLoaded = false
    
    var loanCount: Int {
        filteredLoans.count
    }
    
    var totalDebt: Double {
        filteredLoans.reduce(0) { $0 + $1.remainingAmount }
    }
    
    var formattedTotalDebt: String {
        totalDebt.formatted(.currency(code: "USD"))
    }
    
    var totalMonthlyPayment: Double {
        filteredLoans.reduce(0) { $0 + $1.monthlyPayment }
    }
    
    var formattedTotalMonthlyPayment: String {
        totalMonthlyPayment.formatted(.currency(code: "USD"))
    }
    
    var nextDueDate: Date? {
        filteredLoans.min { $0.dueDate < $1.dueDate }?.dueDate
    }
    
    var filteredLoans: [Loan] {
        if let selectedCategory = selectedCategory {
            return loans.filter { $0.category == selectedCategory }
        } else {
            return loans
        }
    }
    
    init() {}
    
    func loadLoans() {
        guard !hasDataLoaded else { return }
        
        isLoading = true
        errorMessage = nil
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.loans = []
            self.isLoading = false
            self.hasDataLoaded = true
        }
    }
    
    // MARK: - Loan Management Methods
    
    func addLoan(
        name: String,
        principalAmount: Double,
        interestRate: Double,
        monthlyPayment: Double,
        dueDay: Int,
        category: LoanCategory,
        paymentStatus: LoanPaymentStatus,
        lastPaymentDate: Date,
        nextPaymentDueDate: Date
    ) {
        let calendar = Calendar.current
        let now = Date()
        
        // Calculate the next due date based on the due day
        var nextDueDate = nextPaymentDueDate
        if nextDueDate <= now {
            // If the due date is in the past, calculate the next occurrence
            let currentMonth = calendar.component(.month, from: now)
            let currentYear = calendar.component(.year, from: now)
            
            var dueDateComponents = DateComponents(year: currentYear, month: currentMonth, day: dueDay)
            var calculatedDueDate = calendar.date(from: dueDateComponents) ?? now
            
            // If the due date has passed this month, move to next month
            if calculatedDueDate <= now {
                dueDateComponents.month = currentMonth + 1
                if dueDateComponents.month! > 12 {
                    dueDateComponents.month = 1
                    dueDateComponents.year = currentYear + 1
                }
                calculatedDueDate = calendar.date(from: dueDateComponents) ?? now
            }
            
            nextDueDate = calculatedDueDate
        }
        
        let newLoan = Loan(
            name: name,
            principalAmount: principalAmount,
            remainingAmount: principalAmount, // Initially, remaining amount equals principal
            interestRate: interestRate,
            monthlyPayment: monthlyPayment,
            dueDate: nextDueDate,
            paymentStatus: paymentStatus,
            lastPaymentDate: lastPaymentDate,
            nextPaymentDueDate: nextDueDate,
            category: category
        )
        
        // Add the new loan to the array
        loans.append(newLoan)
        
        // In a real app, this would save to persistent storage
        print("Added new loan: \(name) - \(principalAmount.formatted(.currency(code: "USD")))")
    }
    
    func markLoanAsPaid(_ loan: Loan) {
        // Find the loan in the array and update its status
        if let index = loans.firstIndex(where: { $0.id == loan.id }) {
            loans[index].paymentStatus = .paid
            loans[index].remainingAmount = 0.0
            loans[index].lastPaymentDate = Date()
            loans[index].nextPaymentDueDate = nil
            
            print("Marked loan as paid: \(loan.name)")
        }
    }
    
    func getUnpaidLoans() -> [Loan] {
        return loans.filter { $0.paymentStatus != .paid }
    }
    
    func updateLoan(_ updatedLoan: Loan) {
        if let index = loans.firstIndex(where: { $0.id == updatedLoan.id }) {
            loans[index] = updatedLoan
            print("Updated loan: \(updatedLoan.name)")
        }
    }
    
    func deleteLoan(_ loan: Loan) {
        loans.removeAll { $0.id == loan.id }
        print("Deleted loan: \(loan.name)")
    }
    
    func refreshLoans() {
        hasDataLoaded = false
        loadLoans()
    }
}

enum LoanCategory: String, CaseIterable {
    case mortgage = "Mortgage"
    case auto = "Auto Loan"
    case student = "Student Loan"
    case personal = "Personal Loan"
    case creditCard = "Credit Card"
    case other = "Other"
    
    var displayName: String {
        let contentManager = MultilingualContentManager.shared
        switch self {
        case .mortgage: return contentManager.localizedString("loan.mortgage")
        case .auto: return contentManager.localizedString("loan.auto")
        case .student: return contentManager.localizedString("loan.student")
        case .personal: return contentManager.localizedString("loan.personal")
        case .creditCard: return contentManager.localizedString("loan.credit_card")
        case .other: return contentManager.localizedString("loan.other")
        }
    }
    
    var color: Color {
        switch self {
        case .mortgage: return .blue
        case .auto: return .green
        case .student: return .orange
        case .personal: return .purple
        case .creditCard: return .red
        case .other: return .gray
        }
    }
}

enum LoanPaymentStatus: String, CaseIterable {
    case paid = "paid"
    case overdue = "overdue"
    case missed = "missed"
    case current = "current"
    
    var displayName: String {
        switch self {
        case .paid: return "Paid"
        case .overdue: return "Overdue"
        case .missed: return "Missed"
        case .current: return "Current"
        }
    }
    
    var localizedDisplayName: String {
        let contentManager = MultilingualContentManager.shared
        switch self {
        case .paid: return contentManager.localizedString("loan.status.paid")
        case .overdue: return contentManager.localizedString("loan.status.overdue")
        case .missed: return contentManager.localizedString("loan.status.missed")
        case .current: return contentManager.localizedString("loan.status.current")
        }
    }
    
    var color: Color {
        switch self {
        case .paid: return Constants.Colors.success
        case .overdue: return Constants.Colors.error
        case .missed: return Constants.Colors.warning
        case .current: return Constants.Colors.success
        }
    }
}

struct Loan: Identifiable {
    let id: UUID
    let name: String
    let principalAmount: Double
    var remainingAmount: Double
    let interestRate: Double
    let monthlyPayment: Double
    let dueDate: Date
    var paymentStatus: LoanPaymentStatus
    var lastPaymentDate: Date?
    var nextPaymentDueDate: Date?
    let category: LoanCategory
    
    // Default initializer with new UUID
    init(name: String, principalAmount: Double, remainingAmount: Double, interestRate: Double, monthlyPayment: Double, dueDate: Date, paymentStatus: LoanPaymentStatus, lastPaymentDate: Date?, nextPaymentDueDate: Date?, category: LoanCategory) {
        self.id = UUID()
        self.name = name
        self.principalAmount = principalAmount
        self.remainingAmount = remainingAmount
        self.interestRate = interestRate
        self.monthlyPayment = monthlyPayment
        self.dueDate = dueDate
        self.paymentStatus = paymentStatus
        self.lastPaymentDate = lastPaymentDate
        self.nextPaymentDueDate = nextPaymentDueDate
        self.category = category
    }
    
    // Initializer with existing ID (for updates)
    init(id: UUID, name: String, principalAmount: Double, remainingAmount: Double, interestRate: Double, monthlyPayment: Double, dueDate: Date, paymentStatus: LoanPaymentStatus, lastPaymentDate: Date?, nextPaymentDueDate: Date?, category: LoanCategory) {
        self.id = id
        self.name = name
        self.principalAmount = principalAmount
        self.remainingAmount = remainingAmount
        self.interestRate = interestRate
        self.monthlyPayment = monthlyPayment
        self.dueDate = dueDate
        self.paymentStatus = paymentStatus
        self.lastPaymentDate = lastPaymentDate
        self.nextPaymentDueDate = nextPaymentDueDate
        self.category = category
    }
    
    /// Calculates the current payment status based on dates
    var calculatedStatus: LoanPaymentStatus {
        let now = Date()
        let calendar = Calendar.current
        
        // If no due date, return current
        guard let dueDate = nextPaymentDueDate else { return .current }
        
        // If loan is fully paid, return paid
        if remainingAmount <= 0 {
            return .paid
        }
        
        // Calculate days overdue
        let daysOverdue = calendar.dateComponents([.day], from: dueDate, to: now).day ?? 0
        
        if daysOverdue > 2 {
            return .missed
        } else if daysOverdue > 0 {
            return .overdue
        } else {
            return .current
        }
    }
}
