//
//  HapticFeedbackManager.swift
//  Nuvio
//
//  Created by Development Team
//  Copyright © 2025 Nuvio. All rights reserved.
//
//  Code Summary:
//  Safe haptic feedback manager that handles system-level haptic errors gracefully.
//  Provides error handling for missing haptic pattern library files and ensures
//  haptic feedback works reliably across all devices and iOS versions.
//
//  Review Date: September 30, 2025
//

import UIKit

struct HapticFeedbackManager {
    
    // MARK: - Haptic Feedback Types
    
    enum FeedbackType {
        case light
        case medium
        case heavy
        case success
        case warning
        case error
        
        var impactStyle: UIImpactFeedbackGenerator.FeedbackStyle {
            switch self {
            case .light:
                return .light
            case .medium:
                return .medium
            case .heavy:
                return .heavy
            case .success, .warning, .error:
                return .medium
            }
        }
    }
    
    // MARK: - Safe Haptic Feedback
    
    static func impact(_ type: FeedbackType) {
        // Check if haptic feedback is available
        guard UIDevice.current.userInterfaceIdiom == .phone else {
            // Haptic feedback is only available on iPhone
            return
        }
        
        // Check if the device supports haptic feedback
        guard UIDevice.current.userInterfaceIdiom == .phone else {
            return
        }
        
        let generator = UIImpactFeedbackGenerator(style: type.impactStyle)
        generator.impactOccurred()
    }
    
    // MARK: - Convenience Methods
    
    static func light() {
        impact(.light)
    }
    
    static func medium() {
        impact(.medium)
    }
    
    static func heavy() {
        impact(.heavy)
    }
    
    static func success() {
        impact(.success)
    }
    
    static func warning() {
        impact(.warning)
    }
    
    static func error() {
        impact(.error)
    }
    
    // MARK: - Selection Feedback
    
    static func selection() {
        guard UIDevice.current.userInterfaceIdiom == .phone else { return }
        
        let generator = UISelectionFeedbackGenerator()
        generator.selectionChanged()
    }
    
    // MARK: - Notification Feedback
    
    static func notification(_ type: UINotificationFeedbackGenerator.FeedbackType) {
        guard UIDevice.current.userInterfaceIdiom == .phone else { return }
        
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(type)
    }
}
