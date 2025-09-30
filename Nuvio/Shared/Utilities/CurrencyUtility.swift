//
//  CurrencyUtility.swift
//  Nuvio
//
//  Created by Development Team
//  Copyright © 2025 Nuvio. All rights reserved.
//
//  Code Summary:
//  Utility for managing currency selection, formatting, and conversion.
//  Provides comprehensive currency support, formatting functions, and
//  currency symbol mapping for international financial management.
//
//  Review Date: September 29, 2025
//

import Foundation
import SwiftUI

struct CurrencyUtility {
    
    enum Currency: String, CaseIterable {
        case usd = "USD"
        case eur = "EUR"
        case gbp = "GBP"
        case jpy = "JPY"
        case chf = "CHF"
        case cad = "CAD"
        case aud = "AUD"
        case nzd = "NZD"
        
        case sek = "SEK"
        case nok = "NOK"
        case dkk = "DKK"
        case pln = "PLN"
        case czk = "CZK"
        case huf = "HUF"
        case ron = "RON"
        case bgn = "BGN"
        case hrk = "HRK"
        
        case cny = "CNY"
        case krw = "KRW"
        case sgd = "SGD"
        case hkd = "HKD"
        case twd = "TWD"
        case thb = "THB"
        case myr = "MYR"
        case idr = "IDR"
        case php = "PHP"
        case inr = "INR"
        
        // Middle East & Africa
        case aed = "AED"
        case sar = "SAR"
        case qar = "QAR"
        case ils = "ILS"
        case egp = "EGP"
        case zar = "ZAR"
        case ngn = "NGN"
        case kes = "KES"
        
        // Americas
        case mxn = "MXN"
        case brl = "BRL"
        case ars = "ARS"
        case clp = "CLP"
        case cop = "COP"
        case pen = "PEN"
        
        var symbol: String {
            switch self {
            // Major Currencies
            case .usd: return "$"
            case .eur: return "€"
            case .gbp: return "£"
            case .jpy: return "¥"
            case .chf: return "CHF"
            case .cad: return "C$"
            case .aud: return "A$"
            case .nzd: return "NZ$"
            
            // European Currencies
            case .sek: return "kr"
            case .nok: return "kr"
            case .dkk: return "kr"
            case .pln: return "zł"
            case .czk: return "Kč"
            case .huf: return "Ft"
            case .ron: return "lei"
            case .bgn: return "лв"
            case .hrk: return "kn"
            
            // Asian Currencies
            case .cny: return "¥"
            case .krw: return "₩"
            case .sgd: return "S$"
            case .hkd: return "HK$"
            case .twd: return "NT$"
            case .thb: return "฿"
            case .myr: return "RM"
            case .idr: return "Rp"
            case .php: return "₱"
            case .inr: return "₹"
            
            // Middle East & Africa
            case .aed: return "د.إ"
            case .sar: return "ر.س"
            case .qar: return "ر.ق"
            case .ils: return "₪"
            case .egp: return "£"
            case .zar: return "R"
            case .ngn: return "₦"
            case .kes: return "KSh"
            
            // Americas
            case .mxn: return "$"
            case .brl: return "R$"
            case .ars: return "$"
            case .clp: return "$"
            case .cop: return "$"
            case .pen: return "S/"
            }
        }
        
        var name: String {
            switch self {
            // Major Currencies
            case .usd: return "US Dollar"
            case .eur: return "Euro"
            case .gbp: return "British Pound"
            case .jpy: return "Japanese Yen"
            case .chf: return "Swiss Franc"
            case .cad: return "Canadian Dollar"
            case .aud: return "Australian Dollar"
            case .nzd: return "New Zealand Dollar"
            
            // European Currencies
            case .sek: return "Swedish Krona"
            case .nok: return "Norwegian Krone"
            case .dkk: return "Danish Krone"
            case .pln: return "Polish Złoty"
            case .czk: return "Czech Koruna"
            case .huf: return "Hungarian Forint"
            case .ron: return "Romanian Leu"
            case .bgn: return "Bulgarian Lev"
            case .hrk: return "Croatian Kuna"
            
            // Asian Currencies
            case .cny: return "Chinese Yuan"
            case .krw: return "South Korean Won"
            case .sgd: return "Singapore Dollar"
            case .hkd: return "Hong Kong Dollar"
            case .twd: return "Taiwan Dollar"
            case .thb: return "Thai Baht"
            case .myr: return "Malaysian Ringgit"
            case .idr: return "Indonesian Rupiah"
            case .php: return "Philippine Peso"
            case .inr: return "Indian Rupee"
            
            // Middle East & Africa
            case .aed: return "UAE Dirham"
            case .sar: return "Saudi Riyal"
            case .qar: return "Qatari Riyal"
            case .ils: return "Israeli Shekel"
            case .egp: return "Egyptian Pound"
            case .zar: return "South African Rand"
            case .ngn: return "Nigerian Naira"
            case .kes: return "Kenyan Shilling"
            
            // Americas
            case .mxn: return "Mexican Peso"
            case .brl: return "Brazilian Real"
            case .ars: return "Argentine Peso"
            case .clp: return "Chilean Peso"
            case .cop: return "Colombian Peso"
            case .pen: return "Peruvian Sol"
            }
        }
    }
    
    // MARK: - Current Currency
    static var currentCurrency: Currency {
        let currencyCode = UserDefaults.standard.string(forKey: "selected_currency") ?? "USD"
        return Currency(rawValue: currencyCode) ?? .usd
    }
    
    // MARK: - Currency Symbol
    static var currentSymbol: String {
        return currentCurrency.symbol
    }
    
    // MARK: - Currency Code
    static var currentCode: String {
        return currentCurrency.rawValue
    }
    
    // MARK: - Currency Formatter
    static var formatter: NumberFormatter {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = currentCode
        formatter.currencySymbol = currentSymbol
        formatter.maximumFractionDigits = 2
        formatter.minimumFractionDigits = 0
        return formatter
    }
    
    // MARK: - Format Amount
    static func formatAmount(_ amount: Double) -> String {
        return formatter.string(from: NSNumber(value: amount)) ?? "\(currentSymbol)0.00"
    }
    
    // MARK: - Format Amount with Custom Fraction Digits
    static func formatAmount(_ amount: Double, fractionDigits: Int) -> String {
        let customFormatter = NumberFormatter()
        customFormatter.numberStyle = .currency
        customFormatter.currencyCode = currentCode
        customFormatter.currencySymbol = currentSymbol
        customFormatter.maximumFractionDigits = fractionDigits
        customFormatter.minimumFractionDigits = 0
        return customFormatter.string(from: NSNumber(value: amount)) ?? "\(currentSymbol)0.00"
    }
    
    // MARK: - Get Starting Balance
    static var startingBalance: Double {
        return UserDefaults.standard.double(forKey: "starting_balance")
    }
    
    // MARK: - Set Starting Balance
    static func setStartingBalance(_ balance: Double) {
        UserDefaults.standard.set(balance, forKey: "starting_balance")
    }
    
    // MARK: - Set Currency
    static func setCurrency(_ currency: Currency) {
        UserDefaults.standard.set(currency.rawValue, forKey: "selected_currency")
    }
}


















