//
//  BalanceIllustration.swift
//  Nuvio
//
//  Created by Development Team
//  Copyright © 2025 Nuvio. All rights reserved.
//
//  Code Summary:
//  Animated balance illustration component for onboarding featuring floating
//  money bills, central balance display, and decorative elements. Provides
//  engaging visual representation of financial balance concepts.
//
//  Review Date: September 29, 2025
//

import SwiftUI

struct BalanceIllustration: View {
    @State private var animateElements = false
    
    var body: some View {
        ZStack {
            LightBlueBackground()
                .frame(height: 300)
            
            ZStack {
                FloatingMoneyBill(amount: "$100", offset: CGPoint(x: -70, y: -20), delay: 0.1)
                FloatingMoneyBill(amount: "$50", offset: CGPoint(x: 80, y: -30), delay: 0.2)
                FloatingMoneyBill(amount: "$20", offset: CGPoint(x: -60, y: 20), delay: 0.3)
                FloatingMoneyBill(amount: "$10", offset: CGPoint(x: 70, y: 10), delay: 0.4)
                
                CentralBalanceDisplay()
                    .offset(y: -10)
                    .scaleEffect(animateElements ? 1.0 : 0.8)
                    .opacity(animateElements ? 1.0 : 0.0)
                    .animation(.easeInOut(duration: 0.8).delay(0.5), value: animateElements)
                
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

struct FloatingMoneyBill: View {
    let amount: String
    let offset: CGPoint
    let delay: Double
    @State private var animate = false
    
    var body: some View {
        ZStack {
            // Bill background
            RoundedRectangle(cornerRadius: Constants.UI.CornerRadius.quaternary)
                .fill(Constants.Colors.primaryBlue)
                .frame(width: 40, height: 24)
            
            // Amount text
                Text(amount)
                    .font(Constants.Typography.Mono.Caption.font)
                    .foregroundColor(.white)
        }
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

struct CentralBalanceDisplay: View {
    var body: some View {
        ZStack {
            // Main circle
            Circle()
                .stroke(Constants.Colors.textPrimary, lineWidth: 2)
                .frame(width: 50, height: 50)
            
            // Dollar sign
                Text("$")
                    .font(Constants.Typography.Mono.H3.font)
                    .foregroundColor(Constants.Colors.textPrimary)
            
            // Plus sign
                Text("+")
                    .font(Constants.Typography.Mono.Body.font)
                    .foregroundColor(Constants.Colors.primaryOrange)
                .offset(x: 20, y: -20)
            
            // Radiating lines
            ForEach(0..<8, id: \.self) { index in
                Rectangle()
                    .fill(Color.white)
                    .frame(width: 1, height: 8)
                    .offset(y: -30)
                    .rotationEffect(.degrees(Double(index) * 45))
            }
        }
    }
}

#Preview {
    BalanceIllustration()
        .frame(height: 300)
}
