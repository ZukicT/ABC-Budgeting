//
//  StartingBalanceScreen.swift
//  Money Manager
//
//  Created by Development Team
//  Copyright © 2025 Money Manager. All rights reserved.
//
//  Code Summary:
//  Starting balance input screen for onboarding with currency-aware input
//  validation, quick amount selection, and proper state management. Features
//  back navigation, accessibility compliance, and data persistence.
//
//  Review Date: September 29, 2025
//

import SwiftUI

struct StartingBalanceScreen: View {
    @ObservedObject var viewModel: OnboardingViewModel
    @ObservedObject private var contentManager = MultilingualContentManager.shared
    @State private var startingBalance: String = ""
    @State private var isValidInput: Bool = false
    @State private var showInvalidBalanceAlert: Bool = false
    
    private var currencySymbol: String {
        return CurrencyUtility.currentSymbol
    }

    var body: some View {
        ZStack {
            // Background that extends to edges
            Color.white
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Back button
                HStack {
                    Button(action: {
                        viewModel.previousStep()
                    }) {
                        HStack(spacing: 8) {
                            Image(systemName: "chevron.left")
                                .font(Constants.Typography.Caption.font)
                                .foregroundColor(.white)
                            
                            Text(contentManager.localizedString("onboarding.back"))
                                .font(Constants.Typography.Caption.font)
                                .foregroundColor(.white)
                        }
                               .frame(height: Constants.StartingBalance.backButtonHeight)
                               .padding(.horizontal, Constants.StartingBalance.backButtonHorizontalPadding)
                               .background(Constants.Colors.textPrimary)
                               .cornerRadius(Constants.StartingBalance.backButtonCornerRadius)
                    }
                    
                    Spacer()
                }
                .padding(.horizontal, Constants.StartingBalance.headerHorizontalPadding)
                .padding(.top, Constants.StartingBalance.backButtonTopPadding)
                
                // Header section
                VStack(spacing: Constants.StartingBalance.headerSpacing) {
                    Text(contentManager.localizedString("onboarding.starting_balance_title"))
                        .font(Constants.Typography.H1.font)
                        .foregroundColor(Constants.Onboarding.primaryBlueHex)
                        .multilineTextAlignment(.leading)
                        .lineLimit(nil)
                        .lineSpacing(4)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .fixedSize(horizontal: false, vertical: true)
                    
                    Text(contentManager.localizedString("onboarding.starting_balance_description"))
                        .font(Constants.Typography.Body.font)
                        .foregroundColor(Constants.Colors.textPrimary)
                        .multilineTextAlignment(.leading)
                        .lineLimit(nil)
                        .lineSpacing(6)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .padding(.horizontal, Constants.StartingBalance.headerHorizontalPadding)
                .padding(.top, Constants.StartingBalance.headerTopPadding)
                
                
                // Balance input section
                BalanceInputView(
                    startingBalance: $startingBalance,
                    isValidInput: $isValidInput,
                    currencySymbol: currencySymbol
                )
                .frame(height: Constants.StartingBalance.inputSectionHeight)
                .padding(.top, -100)
                
                Spacer()
                
                // Footer
                OnboardingFooter(
                    buttonTitle: "Continue",
                    buttonIcon: "arrow.right",
                    currentPage: 3,
                    totalPages: OnboardingStep.allCases.count,
                    buttonAction: {
                        if let balance = Double(startingBalance), balance >= 0 {
                            CurrencyUtility.setStartingBalance(balance)
                            print("✅ Starting balance saved: \(balance)")
                            viewModel.nextStep()
                        } else {
                            showInvalidBalanceAlert = true
                        }
                    }
                )
            }
        }
        .onAppear {
            let savedBalance = CurrencyUtility.startingBalance
            if savedBalance > 0 {
                startingBalance = String(format: "%.2f", savedBalance)
                isValidInput = true
            }
        }
        .alert("Starting Balance Required", isPresented: $showInvalidBalanceAlert) {
            Button(contentManager.localizedString("button.ok")) { }
        } message: {
            Text(contentManager.localizedString("onboarding.starting_balance_validation"))
        }
    }
    
    private func validateInput(_ newValue: String) {
        let (_, isValid) = InputValidationUtility.validateCurrencyInput(newValue, currentValue: &startingBalance)
        isValidInput = isValid
    }

    private struct BalanceInputView: View {
        @Binding var startingBalance: String
        @Binding var isValidInput: Bool
        let currencySymbol: String

        var body: some View {
            VStack(spacing: Constants.StartingBalance.inputSectionSpacing) {
                // Balance input field
                VStack(alignment: .leading, spacing: Constants.StartingBalance.inputFieldSpacing) {
                    Text("onboarding.starting_balance_label".localized)
                        .font(Constants.Typography.Caption.font)
                        .foregroundColor(Constants.Colors.textPrimary)
                        .frame(maxWidth: .infinity, alignment: .leading)

                    HStack {
                        Text(currencySymbol)
                            .font(Constants.Typography.Mono.H3.font)
                            .foregroundColor(Constants.Colors.textPrimary)
                            .frame(width: Constants.StartingBalance.currencySymbolWidth, alignment: .leading)

                        TextField("0.00", text: $startingBalance)
                            .font(Constants.Typography.Mono.H3.font)
                            .foregroundColor(Constants.Colors.textPrimary)
                            .keyboardType(.decimalPad)
                            .textFieldStyle(PlainTextFieldStyle())
                            .onChange(of: startingBalance) { _, newValue in
                                validateInput(newValue)
                            }
                    }
                    .padding(.horizontal, Constants.StartingBalance.inputFieldHorizontalPadding)
                    .padding(.vertical, Constants.StartingBalance.inputFieldVerticalPadding)
                    .background(
                        RoundedRectangle(cornerRadius: Constants.StartingBalance.inputFieldCornerRadius)
                            .fill(Color.white)
                            .overlay(
                                RoundedRectangle(cornerRadius: Constants.StartingBalance.inputFieldCornerRadius)
                                    .stroke(
                                        isValidInput ? Constants.Colors.textPrimary : Constants.Colors.textSecondary.opacity(0.3),
                                        lineWidth: Constants.StartingBalance.inputFieldBorderWidth
                                    )
                            )
                    )

                    if !isValidInput && !startingBalance.isEmpty {
                        Text("onboarding.starting_balance_error".localized)
                            .font(Constants.Typography.Caption.font)
                            .foregroundColor(Constants.Colors.error)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }

                // Quick amount buttons
                VStack(alignment: .leading, spacing: Constants.StartingBalance.quickAmountsSpacing) {
                    Text("onboarding.quick_amounts".localized)
                        .font(Constants.Typography.Caption.font)
                        .foregroundColor(Constants.Colors.textPrimary)
                        .frame(maxWidth: .infinity, alignment: .leading)

                    LazyVGrid(columns: [
                        GridItem(.flexible()),
                        GridItem(.flexible())
                    ], spacing: Constants.StartingBalance.quickAmountButtonSpacing) {
                        ForEach(Constants.StartingBalance.quickAmountValues, id: \.self) { amount in
                            Button(action: {
                                startingBalance = String(amount)
                                validateInput(String(amount))
                            }) {
                                Text("\(currencySymbol)\(amount)")
                                    .font(Constants.Typography.Mono.Body.font)
                                    .foregroundColor(Constants.Colors.textPrimary)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, Constants.StartingBalance.quickAmountButtonVerticalPadding)
                                    .background(
                                        RoundedRectangle(cornerRadius: Constants.StartingBalance.quickAmountButtonCornerRadius)
                                            .fill(Constants.Colors.textSecondary.opacity(0.1))
                                    )
                            }
                        }
                    }
                }
            }
            .padding(.horizontal, Constants.StartingBalance.sectionHorizontalPadding)
            .padding(.top, Constants.StartingBalance.sectionTopPadding)
            .background(Color.white)
            .cornerRadius(Constants.StartingBalance.sectionCornerRadius)
        }
        
        private func validateInput(_ newValue: String) {
            let (_, isValid) = InputValidationUtility.validateCurrencyInput(newValue, currentValue: &startingBalance)
            isValidInput = isValid
        }
    }
}
