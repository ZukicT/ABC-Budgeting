//
//  StatusTag.swift
//  Money Manager
//
//  Created by Development Team
//  Copyright © 2025 Money Manager. All rights reserved.
//
//  Code Summary:
//  Reusable status tag component for displaying loan payment status and other
//  status indicators. Features consistent styling, accessibility support,
//  and interactive selection states with proper color coding.
//
//  Review Date: September 29, 2025
//

import SwiftUI

struct StatusTag: View {
    let status: LoanPaymentStatus
    let isSelected: Bool
    let action: (() -> Void)?
    
    init(status: LoanPaymentStatus, isSelected: Bool = false, action: (() -> Void)? = nil) {
        self.status = status
        self.isSelected = isSelected
        self.action = action
    }
    
    var body: some View {
        Button(action: action ?? {}) {
            Text(status.displayName)
                .font(Constants.Typography.Caption.font)
                .fontWeight(isSelected ? .semibold : .medium)
                .foregroundColor(isSelected ? Constants.Colors.backgroundPrimary : status.color)
                .padding(.horizontal, 6)
                .padding(.vertical, 2)
                .background(
                    RoundedRectangle(cornerRadius: Constants.UI.CornerRadius.tertiary)
                        .fill(isSelected ? status.color : status.color.opacity(0.1))
                )
        }
        .buttonStyle(PlainButtonStyle())
        .accessibilityLabel("\(status.displayName) status")
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }
}

#Preview {
    VStack(spacing: 16) {
        StatusTag(status: .paid)
        StatusTag(status: .overdue)
        StatusTag(status: .missed)
        StatusTag(status: .current)
        StatusTag(status: .paid, isSelected: true)
    }
    .padding()
}
