import SwiftUI

// MARK: - Localization Extension
extension String {
    /// Returns the localized string for the current language
    var localized: String {
        return MultilingualContentManager.shared.localizedString(self)
    }
}

// MARK: - Localized Text View
struct LocalizedText: View {
    let key: String
    
    var body: some View {
        Text(key.localized)
    }
    
    init(_ key: String) {
        self.key = key
    }
}

// MARK: - Localized Button
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
