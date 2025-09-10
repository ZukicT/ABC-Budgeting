import Foundation

struct ImportPreview {
    let transactions: [Transaction]
    let goals: [GoalFormData]
    let userSettings: UserSettingsImport
    
    struct UserSettingsImport {
        let displayName: String
        let preferredCurrency: String
        let baselineBalance: Double
        let notificationsEnabled: Bool
        let hapticsEnabled: Bool
    }
}

struct UserSettings {
    let displayName: String
    let preferredCurrency: String
    let baselineBalance: Double
    let notificationsEnabled: Bool
    let hapticsEnabled: Bool
}
