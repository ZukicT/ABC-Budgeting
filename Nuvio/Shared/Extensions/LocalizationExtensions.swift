//
//  LocalizationExtensions.swift
//  Nuvio
//
//  Created by Development Team
//  Copyright © 2025 Nuvio. All rights reserved.
//
//  Code Summary:
//  Extensions and utilities for localization providing convenient access to
//  localized strings and localized UI components. Includes String extensions
//  and custom localized view components.
//
//  Review Date: September 29, 2025
//

import SwiftUI

extension String {
    var localized: String {
        return MultilingualContentManager.shared.localizedString(self)
    }
}

struct LocalizedText: View {
    let key: String
    
    var body: some View {
        Text(key.localized)
    }
    
    init(_ key: String) {
        self.key = key
    }
}

struct LocalizedButton: View {
    let key: String
    let action: () -> Void
    
    var body: some View {
        Button(key.localized, action: action)
    }
    
    init(_ key: String, action: @escaping () -> Void) {
        self.key = key
        self.action = action
    }
}

// MARK: - Localized Navigation Title
extension View {
    func localizedNavigationTitle(_ key: String) -> some View {
        self.navigationTitle(key.localized)
    }
}
