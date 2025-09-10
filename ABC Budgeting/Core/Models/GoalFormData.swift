import SwiftUI

struct GoalFormData: Hashable, Identifiable {
    var id: String { name }
    let name: String
    let subtitle: String?
    let targetAmount: Double
    let savedAmount: Double
    let targetDate: Date
    let notes: String?
    let iconName: String
    let iconColorName: String
    var iconColor: Color { Color.fromName(iconColorName) }
}

