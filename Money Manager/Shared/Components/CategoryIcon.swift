import SwiftUI

/**
 * CategoryIcon
 *
 * Reusable component for displaying category-based icons with consistent colors
 * and styling. Provides visual recognition for transaction categories following
 * market research best practices.
 *
 * Features:
 * - Category-specific SF Symbols icons
 * - Consistent color coding system
 * - Scalable sizing for different contexts
 * - Accessibility compliance
 * - Professional flat design aesthetic
 *
 * Usage:
 * - Transaction detail views
 * - Transaction lists
 * - Category filters
 * - Budget displays
 *
 * Architecture:
 * - Pure SwiftUI component
 * - No external dependencies
 * - Stateless design
 * - Performance optimized
 *
 * Last Review: 2025-01-26
 * Status: Production Ready
 */

struct CategoryIcon: View {
    let category: String
    let size: CGFloat
    
    // MARK: - Category Icon System
    private var iconInfo: (name: String, color: Color) {
        switch category.lowercased() {
        case "food", "restaurant", "dining", "groceries":
            return ("fork.knife", .orange)
        case "transportation", "gas", "uber", "lyft", "taxi", "parking":
            return ("car.fill", .blue)
        case "shopping", "retail", "amazon", "clothing", "electronics":
            return ("bag.fill", .purple)
        case "entertainment", "movies", "streaming", "games", "music":
            return ("tv.fill", .pink)
        case "healthcare", "medical", "pharmacy", "doctor", "hospital":
            return ("cross.fill", .red)
        case "utilities", "electric", "water", "internet", "phone", "cable":
            return ("bolt.fill", .yellow)
        case "income", "salary", "freelance", "bonus", "refund":
            return ("arrow.up.circle.fill", .green)
        case "transfer", "savings", "investment", "deposit":
            return ("arrow.left.arrow.right", .gray)
        case "education", "school", "books", "course":
            return ("book.fill", .indigo)
        case "travel", "hotel", "flight", "vacation":
            return ("airplane", .cyan)
        case "insurance", "car insurance", "health insurance":
            return ("shield.fill", .mint)
        case "subscription", "software", "app", "service":
            return ("creditcard.fill", .teal)
        case "gift", "donation", "charity":
            return ("gift.fill", .brown)
        case "home", "rent", "mortgage", "maintenance":
            return ("house.fill", .orange)
        default:
            return ("questionmark.circle", .gray)
        }
    }
    
    var body: some View {
        ZStack {
            // Background circle with category color
            Circle()
                .fill(iconInfo.color.opacity(0.1))
                .frame(width: size, height: size)
            
            // Category icon
            Image(systemName: iconInfo.name)
                .font(.system(size: size * 0.45, weight: .semibold))
                .foregroundColor(iconInfo.color)
        }
        .accessibilityLabel("Category: \(category)")
        .accessibilityAddTraits(.isStaticText)
    }
}

// MARK: - Preview
#Preview {
    VStack(spacing: 20) {
        // Different sizes
        HStack(spacing: 16) {
            CategoryIcon(category: "Food", size: 32)
            CategoryIcon(category: "Transportation", size: 40)
            CategoryIcon(category: "Shopping", size: 48)
            CategoryIcon(category: "Income", size: 56)
        }
        
        // Different categories
        HStack(spacing: 16) {
            CategoryIcon(category: "Restaurant", size: 40)
            CategoryIcon(category: "Gas", size: 40)
            CategoryIcon(category: "Amazon", size: 40)
            CategoryIcon(category: "Netflix", size: 40)
        }
        
        HStack(spacing: 16) {
            CategoryIcon(category: "Doctor", size: 40)
            CategoryIcon(category: "Electric", size: 40)
            CategoryIcon(category: "Salary", size: 40)
            CategoryIcon(category: "Transfer", size: 40)
        }
        
        // Unknown category
        CategoryIcon(category: "Unknown Category", size: 40)
    }
    .padding()
}
