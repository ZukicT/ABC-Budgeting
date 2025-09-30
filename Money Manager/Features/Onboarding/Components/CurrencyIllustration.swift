//
//  CurrencyIllustration.swift
//  Money Manager
//
//  Created by Development Team
//  Copyright © 2025 Money Manager. All rights reserved.
//
//  Code Summary:
//  Animated currency illustration component for onboarding featuring
//  floating currency symbols, central money icon, and decorative
//  elements. Provides engaging visual representation of currency concepts.
//
//  Review Date: September 29, 2025
//

import SwiftUI

struct CurrencyIllustration: View {
    @State private var animateElements = false
    
    var body: some View {
        ZStack {
            LightBlueBackground()
                .frame(height: 300)
            
            ZStack {
                FloatingCurrencySymbol(symbol: "$", offset: CGPoint(x: -80, y: -20), delay: 0.1)
                FloatingCurrencySymbol(symbol: "€", offset: CGPoint(x: 80, y: -30), delay: 0.2)
                FloatingCurrencySymbol(symbol: "£", offset: CGPoint(x: -60, y: 20), delay: 0.3)
                FloatingCurrencySymbol(symbol: "¥", offset: CGPoint(x: 70, y: 10), delay: 0.4)
                
                CentralMoneyIcon()
                CentralMoneyIcon()
                    .offset(y: -10)
                    .scaleEffect(animateElements ? 1.0 : 0.8)
                    .opacity(animateElements ? 1.0 : 0.0)
                    .animation(.easeInOut(duration: 0.8).delay(0.5), value: animateElements)
                
                // Decorative elements
                DecorativeElements()
                    .opacity(animateElements ? 1.0 : 0.0)
                    .animation(.easeInOut(duration: 0.6).delay(0.6), value: animateElements)
            }
        }
        .onAppear {
            withAnimation {
                animateElements = true
            }
        }
    }
}

struct FloatingCurrencySymbol: View {
    let symbol: String
    let offset: CGPoint
    let delay: Double
    @State private var animate = false
    
    var body: some View {
                Text(symbol)
                    .font(Constants.Typography.Mono.H3.font)
                    .foregroundColor(Constants.Colors.primaryBlue)
            .offset(x: offset.x, y: offset.y)
            .scaleEffect(animate ? 1.0 : 0.5)
            .opacity(animate ? 1.0 : 0.0)
            .animation(.easeInOut(duration: 0.6).delay(delay), value: animate)
            .onAppear {
                withAnimation {
                    animate = true
                }
            }
    }
}

struct CentralMoneyIcon: View {
    var body: some View {
        ZStack {
            // Main circle
            Circle()
                .stroke(Constants.Colors.textPrimary, lineWidth: 2)
                .frame(width: 40, height: 40)
            
            // Dollar sign
                Text("$")
                    .font(Constants.Typography.Mono.Body.font)
                    .foregroundColor(Constants.Colors.textPrimary)
            
            // Radiating lines
            ForEach(0..<8, id: \.self) { index in
                Rectangle()
                    .fill(Color.white)
                    .frame(width: 1, height: 8)
                    .offset(y: -26)
                    .rotationEffect(.degrees(Double(index) * 45))
            }
        }
    }
}

#Preview {
    CurrencyIllustration()
        .frame(height: 300)
}
