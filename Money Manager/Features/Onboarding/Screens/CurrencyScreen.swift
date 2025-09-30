//
//  CurrencyScreen.swift
//  Money Manager
//
//  Created by Development Team
//  Copyright © 2025 Money Manager. All rights reserved.
//
//  Code Summary:
//  Comprehensive currency selection screen for onboarding with organized
//  currency groups, visual selection indicators, and accessibility support.
//  Features back navigation and proper state management for currency selection.
//
//  Review Date: September 29, 2025
//

import SwiftUI

struct CurrencyScreen: View {
    @ObservedObject var viewModel: OnboardingViewModel
    @ObservedObject private var contentManager = MultilingualContentManager.shared
    @State private var selectedCurrency: CurrencyUtility.Currency = .usd
    
    struct CurrencySection: Identifiable {
        let id = UUID()
        let region: String
        let currencies: [CurrencyUtility.Currency]
    }
    
    private static let currencySections: [CurrencySection] = {
        let majorCurrencies = [CurrencyUtility.Currency.usd, .eur, .gbp, .jpy, .chf, .cad, .aud, .nzd]
        let europeanCurrencies = [CurrencyUtility.Currency.sek, .nok, .dkk, .pln, .czk, .huf, .ron, .bgn, .hrk]
        let asianCurrencies = [CurrencyUtility.Currency.cny, .krw, .sgd, .hkd, .twd, .thb, .myr, .idr, .php, .inr]
        let middleEastAfrica = [CurrencyUtility.Currency.aed, .sar, .qar, .ils, .egp, .zar, .ngn, .kes]
        let americas = [CurrencyUtility.Currency.mxn, .brl, .ars, .clp, .cop, .pen]
        
        return [
            CurrencySection(region: "Major Currencies", currencies: majorCurrencies),
            CurrencySection(region: "European Currencies", currencies: europeanCurrencies),
            CurrencySection(region: "Asian Currencies", currencies: asianCurrencies),
            CurrencySection(region: "Middle East & Africa", currencies: middleEastAfrica),
            CurrencySection(region: "Americas", currencies: americas)
        ]
    }()
    
    var body: some View {
        ZStack {
            Color.white
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Back button - positioned at top of safe area
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
                        .frame(height: Constants.Currency.backButtonHeight)
                        .padding(.horizontal, Constants.Currency.backButtonHorizontalPadding)
                        .background(Constants.Colors.textPrimary)
                        .cornerRadius(Constants.Currency.backButtonCornerRadius)
                    }
                    
                    Spacer()
                }
                .padding(.horizontal, Constants.Currency.headerHorizontalPadding)
                .padding(.top, Constants.Currency.backButtonTopPadding)
                
                // Header section
                VStack(spacing: Constants.Currency.headerSpacing) {
                    Text(contentManager.localizedString("onboarding.choose_currency"))
                        .font(Constants.Typography.H1.font)
                        .foregroundColor(Constants.Onboarding.primaryBlueHex)
                        .multilineTextAlignment(.leading)
                        .lineLimit(nil)
                        .lineSpacing(4)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .fixedSize(horizontal: false, vertical: true)
                    
                    Text(contentManager.localizedString("onboarding.currency_description"))
                        .font(Constants.Typography.Body.font)
                        .foregroundColor(Constants.Colors.textPrimary)
                        .multilineTextAlignment(.leading)
                        .lineLimit(nil)
                        .lineSpacing(6)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .fixedSize(horizontal: false, vertical: true)
                        
                }
                .padding(.horizontal, Constants.Currency.headerHorizontalPadding)
                .padding(.top, Constants.Currency.headerTopPadding)
                .padding(.bottom, Constants.Currency.headerBottomPadding)
                
                // Currency list - fixed height for better visibility
                CurrencyListView(
                    currencySections: Self.currencySections,
                    selectedCurrency: $selectedCurrency
                )
                .frame(height: Constants.Currency.listHeight)
                
                Spacer()
                
                // Footer with button and carousel indicators
                OnboardingFooter(
                    buttonTitle: "Continue",
                    buttonIcon: "arrow.right",
                    currentPage: 2,
                    totalPages: OnboardingStep.allCases.count,
                    buttonAction: {
                        CurrencyUtility.setCurrency(selectedCurrency)
                        print("✅ Currency selected: \(selectedCurrency.name) (\(selectedCurrency.rawValue))")
                        viewModel.nextStep()
                    }
                )
            }
        }
        .onAppear {
            selectedCurrency = CurrencyUtility.currentCurrency
        }
    }

    private struct CurrencyListView: View {
        let currencySections: [CurrencySection]
        @Binding var selectedCurrency: CurrencyUtility.Currency

        var body: some View {
            ScrollView {
                LazyVStack(spacing: 0) {
                    ForEach(currencySections) { section in
                        CurrencySectionView(
                            section: section,
                            selectedCurrency: $selectedCurrency
                        )
                    }
                }
                .padding(.horizontal, Constants.Currency.listHorizontalPadding)
                .padding(.top, Constants.Currency.listTopPadding)
            }
            .background(Color.white)
            .cornerRadius(Constants.UI.CornerRadius.secondary)
        }
    }
    
    private struct CurrencySectionView: View {
        let section: CurrencySection
        @Binding var selectedCurrency: CurrencyUtility.Currency
        
        var body: some View {
            VStack(alignment: .leading, spacing: 0) {
                Text(section.region)
                    .font(Constants.Typography.Caption.font)
                    .foregroundColor(Constants.Colors.textPrimary)
                    .padding(.horizontal, Constants.Currency.sectionHeaderHorizontalPadding)
                    .padding(.vertical, Constants.Currency.sectionHeaderPadding)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Constants.Colors.textPrimary.opacity(0.05))
                
                ForEach(section.currencies, id: \.self) { currency in
                    CurrencyListItem(
                        currency: currency,
                        isSelected: selectedCurrency == currency,
                        onTap: { selectedCurrency = currency }
                    )
                }
            }
            .background(Color.white)
            .cornerRadius(Constants.Currency.sectionCornerRadius)
            .overlay(
                RoundedRectangle(cornerRadius: Constants.Currency.sectionCornerRadius)
                    .stroke(Constants.Colors.textPrimary.opacity(0.1), lineWidth: Constants.Currency.sectionBorderWidth)
            )
            .padding(.bottom, Constants.Currency.sectionBottomPadding)
        }
    }

    private struct CurrencyListItem: View {
        let currency: CurrencyUtility.Currency
        let isSelected: Bool
        let onTap: () -> Void
        
        var body: some View {
            HStack(spacing: Constants.Currency.currencyItemSpacing) {
                Text(currency.symbol)
                    .font(Constants.Typography.Mono.H3.font)
                    .foregroundColor(Constants.Colors.textPrimary)
                    .frame(width: Constants.Currency.currencySymbolFrameSize, height: Constants.Currency.currencySymbolFrameSize)
                    .background(Constants.Colors.textPrimary.opacity(0.05))
                    .cornerRadius(Constants.Currency.currencySymbolCornerRadius)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(currency.name)
                        .font(Constants.Typography.Body.font)
                        .foregroundColor(Constants.Colors.textPrimary)
                    
                    Text(currency.rawValue)
                        .font(Constants.Typography.Caption.font)
                        .foregroundColor(Constants.Colors.textSecondary)
                }
                
                Spacer()
                
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .font(Constants.Typography.H3.font)
                        .foregroundColor(Constants.Colors.textPrimary)
                } else {
                    Image(systemName: "circle")
                        .font(Constants.Typography.H3.font)
                        .foregroundColor(Constants.Colors.textSecondary)
                }
            }
            .padding(.horizontal, Constants.Currency.currencyItemHorizontalPadding)
            .padding(.vertical, Constants.Currency.currencyItemVerticalPadding)
            .background(isSelected ? Constants.Colors.textPrimary.opacity(0.05) : Color.clear)
            .onTapGesture(perform: onTap)
            .accessibilityElement(children: .combine)
            .accessibilityAddTraits(isSelected ? .isSelected : [])
            .accessibilityLabel("Select \(currency.name)")
            .accessibilityHint(isSelected ? "Currently selected currency" : "Tap to select \(currency.name)")
        }
    }

}