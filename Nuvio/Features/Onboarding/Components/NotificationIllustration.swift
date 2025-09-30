//
//  NotificationIllustration.swift
//  Nuvio
//
//  Created by Development Team
//  Copyright © 2025 Nuvio. All rights reserved.
//
//  Code Summary:
//  Animated notification illustration component for onboarding featuring
//  floating notification bells, central notification icon, and decorative
//  elements. Provides engaging visual representation of notification concepts.
//
//  Review Date: September 29, 2025
//

import SwiftUI

struct NotificationIllustration: View {
    @State private var animateElements = false
    
    var body: some View {
        ZStack {
            LightBlueBackground()
                .frame(height: 300)
            
            ZStack {
                FloatingNotificationBell(offset: CGPoint(x: -80, y: -20), delay: 0.1)
                FloatingNotificationBell(offset: CGPoint(x: 80, y: -30), delay: 0.2)
                FloatingNotificationBell(offset: CGPoint(x: -60, y: 20), delay: 0.3)
                FloatingNotificationBell(offset: CGPoint(x: 70, y: 10), delay: 0.4)
                
                CentralNotificationIcon()
                CentralNotificationIcon()
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

struct FloatingNotificationBell: View {
    let offset: CGPoint
    let delay: Double
    @State private var animate = false
    
    var body: some View {
        ZStack {
            // Bell body
            Circle()
                .fill(Constants.Colors.primaryOrange)
                .frame(width: 20, height: 20)
            
            // Bell clapper
            Circle()
                .fill(Constants.Colors.textPrimary)
                .frame(width: 6, height: 6)
                .offset(y: 2)
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

struct CentralNotificationIcon: View {
    var body: some View {
        ZStack {
            // Main bell circle
            Circle()
                .stroke(Constants.Colors.textPrimary, lineWidth: 2)
                .frame(width: 40, height: 40)
            
            // Bell icon
                Image(systemName: "bell.fill")
                    .font(Constants.Typography.H3.font)
                    .foregroundColor(Constants.Colors.textPrimary)
            
            // Notification badge
            Circle()
                .fill(Constants.Colors.primaryOrange)
                .frame(width: 12, height: 12)
                .offset(x: 12, y: -12)
            
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
    NotificationIllustration()
        .frame(height: 300)
}
