import SwiftUI

// MARK: - BudgetView

struct BudgetView: View {
    // MARK: - Properties
    @Binding var goals: [GoalFormItem]
    @State private var showAddGoal = false
    @State private var selectedCategory: TransactionCategoryType? = nil
    @State private var selectedGoal: GoalFormItem? = nil
    @AppStorage("preferredCurrency") private var preferredCurrency: String = "USD"
    
    // MARK: - Computed Properties
    
    /// Currency code extracted from preferred currency string
    private var currencyCode: String {
        preferredCurrency.components(separatedBy: " ").first ?? "USD"
    }
    
    /// Goals filtered by selected category
    private var filteredGoals: [GoalFormItem] {
        guard let selectedCategory = selectedCategory else { return goals }
        return goals.filter { goal in
            selectedCategory.icons.contains(goal.iconName)
        }
    }
    
    /// Total saved amount across all goals
    private var totalSavedAmount: Double {
        goals.reduce(0) { $0 + $1.savedAmount }
    }
    
    /// Total target amount across all goals
    private var totalTargetAmount: Double {
        goals.reduce(0) { $0 + $1.targetAmount }
    }
    
    /// Overall progress percentage
    private var overallProgress: Double {
        guard totalTargetAmount > 0 else { return 0 }
        return min(totalSavedAmount / totalTargetAmount, 1.0)
    }
    
    // MARK: - Body
    
    var body: some View {
        VStack(spacing: 0) {
            // Static header section - fixed at top
            VStack(spacing: 0) {
                // Header with stats - Robinhood style
                headerSection
                    .padding(.top, -20)
                
                // Filter chips - Clean horizontal layout
                filterChipsSection
                    .padding(.top, 24)
            }
            .background(RobinhoodColors.background)
            .zIndex(1)
            
            // Scrollable content section
            ScrollView(.vertical, showsIndicators: false) {
                LazyVStack(spacing: 0) {
                    // Content section
                    contentSection
                        .padding(.top, 24)
                }
                .padding(.bottom, 100)
            }
            .background(RobinhoodColors.background)
        }
        .padding(.horizontal, 16)
        .background(RobinhoodColors.background)
        .accessibilityElement(children: .contain)
        .accessibilityLabel("Savings and goals dashboard with progress tracking")
        .sheet(isPresented: $showAddGoal) {
            addGoalSheet
                .presentationDetents([.medium, .large])
                .presentationDragIndicator(.visible)
                .presentationBackground(.regularMaterial)
                .presentationCornerRadius(16)
                .presentationCompactAdaptation(.sheet)
        }
        .sheet(item: $selectedGoal) { goal in
            goalDetailSheet(for: goal)
                .presentationDetents([.medium, .large])
                .presentationDragIndicator(.visible)
                .presentationBackground(.regularMaterial)
                .presentationCornerRadius(16)
                .presentationCompactAdaptation(.sheet)
        }
        .overlay(alignment: .bottomTrailing) {
            floatingActionButton
        }
    }
    
    // MARK: - View Components
    
    /// Header section with title and stats - Robinhood style
    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 24) {
            // Title and progress overview
            VStack(alignment: .leading, spacing: 12) {
                Text("Savings & Goals")
                    .font(RobinhoodTypography.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(RobinhoodColors.textPrimary)
                
                // Overall progress indicator
                HStack(spacing: 6) {
                    Text("Overall Progress")
                        .font(RobinhoodTypography.caption)
                        .foregroundColor(RobinhoodColors.textSecondary)
                    
                    HStack(spacing: 2) {
                        Text("\(Int(overallProgress * 100))%")
                            .font(RobinhoodTypography.caption2)
                            .fontWeight(.semibold)
                            .foregroundColor(RobinhoodColors.success)
                    }
                    .padding(.horizontal, 4)
                    .padding(.vertical, 2)
                    .background(
                        RoundedRectangle(cornerRadius: 4)
                            .fill(RobinhoodColors.success.opacity(0.15))
                    )
                }
            }
            
            // Total saved amount - matching balance style
            Text(totalSavedAmount.formatted(.currency(code: currencyCode).precision(.fractionLength(0))))
                .font(.system(size: 36, weight: .bold, design: .rounded))
                .foregroundColor(RobinhoodColors.success)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
            
            // Progress bar with goal indicators
            VStack(spacing: 8) {
                HStack {
                    Text("of \(totalTargetAmount.formatted(.currency(code: currencyCode).precision(.fractionLength(0)))) goal")
                        .font(RobinhoodTypography.caption)
                        .foregroundColor(RobinhoodColors.textSecondary)
                    
                    Spacer()
                    
                    Text("\(Int(overallProgress * 100))%")
                        .font(RobinhoodTypography.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(RobinhoodColors.success)
                }
                
                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        // Background progress bar
                        RoundedRectangle(cornerRadius: 4)
                            .fill(RobinhoodColors.border)
                            .frame(height: 8)
                        
                        // Overall progress fill
                        RoundedRectangle(cornerRadius: 4)
                            .fill(RobinhoodColors.success)
                            .frame(width: geometry.size.width * overallProgress, height: 8)
                            .animation(.easeInOut(duration: 0.3), value: overallProgress)
                        
                        // Goal indicator lines - positioned above the progress bar
                        ForEach(goals.indices, id: \.self) { index in
                            let goal = goals[index]
                            let goalProgress = goal.savedAmount / totalTargetAmount
                            
                            if goalProgress > 0 {
                                VStack(spacing: 4) {
                                    // Goal icon - positioned above the line
                                    Image(systemName: goal.iconName)
                                        .font(.system(size: 10, weight: .medium))
                                        .foregroundColor(RobinhoodColors.success)
                                    
                                    // Indicator line - extending down to the progress bar
                                    Rectangle()
                                        .fill(RobinhoodColors.success)
                                        .frame(width: 2, height: 16)
                                }
                                .offset(x: geometry.size.width * goalProgress - 1, y: -20)
                                .opacity(0.9)
                            }
                        }
                    }
                }
                .frame(height: 8)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 4)
    }
    
    /// Filter chips for category selection - Robinhood style
    private var filterChipsSection: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                // All button
                Button(action: { 
                    withAnimation(.easeInOut(duration: 0.2)) {
                        selectedCategory = nil 
                    }
                }) {
                    HStack(spacing: 6) {
                        Image(systemName: "circle.grid.2x2")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(selectedCategory == nil ? RobinhoodColors.background : RobinhoodColors.textSecondary)
                        
                        Text("All")
                            .font(RobinhoodTypography.callout)
                            .fontWeight(.medium)
                            .foregroundColor(selectedCategory == nil ? RobinhoodColors.background : RobinhoodColors.textSecondary)
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                            .fill(selectedCategory == nil ? RobinhoodColors.success : RobinhoodColors.cardBackground)
                    )
                }
                .accessibilityLabel("All")
                .accessibilityAddTraits(selectedCategory == nil ? .isSelected : .isButton)
                
                // Category buttons
                ForEach(TransactionCategoryType.allCases) { category in
                    categoryFilterButton(for: category)
                }
            }
            .padding(.horizontal, 4)
        }
    }
    
    /// Individual category filter button - Robinhood style
    private func categoryFilterButton(for category: TransactionCategoryType) -> some View {
        Button(action: { 
            withAnimation(.easeInOut(duration: 0.2)) {
                selectedCategory = category 
            }
        }) {
            HStack(spacing: 6) {
                Image(systemName: category.symbol)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(selectedCategory == category ? RobinhoodColors.background : RobinhoodColors.success)
                
                Text(category.label)
                    .font(RobinhoodTypography.callout)
                    .fontWeight(.medium)
                    .foregroundColor(selectedCategory == category ? RobinhoodColors.background : RobinhoodColors.textSecondary)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(selectedCategory == category ? RobinhoodColors.success : RobinhoodColors.cardBackground)
            )
        }
        .accessibilityLabel(category.label)
        .accessibilityAddTraits(selectedCategory == category ? .isSelected : .isButton)
    }
    
    /// Main content section
    private var contentSection: some View {
        Group {
            if filteredGoals.isEmpty {
                emptyStateView
            } else {
                goalsListView
            }
        }
    }
    
    /// Empty state when no goals are available - Robinhood style
    private var emptyStateView: some View {
        VStack(spacing: 32) {
            Spacer()
            
            VStack(spacing: 20) {
                // Icon with background
                ZStack {
                    Circle()
                        .fill(RobinhoodColors.success.opacity(0.1))
                        .frame(width: 120, height: 120)
                    
                    Image(systemName: "target")
                        .font(.system(size: 48, weight: .medium))
                        .foregroundColor(RobinhoodColors.success)
                }
                
                VStack(spacing: 12) {
                    Text("No Goals Yet")
                        .font(RobinhoodTypography.title2)
                        .fontWeight(.bold)
                        .foregroundColor(RobinhoodColors.textPrimary)
                    
                    Text("Start building your financial future by creating your first savings goal.")
                        .font(RobinhoodTypography.body)
                        .foregroundColor(RobinhoodColors.textSecondary)
                        .multilineTextAlignment(.center)
                        .lineLimit(3)
                }
                
                // Add goal button
                Button(action: { showAddGoal = true }) {
                    HStack(spacing: 8) {
                        Image(systemName: "plus.circle.fill")
                            .font(.system(size: 16, weight: .semibold))
                        
                        Text("Add Your First Goal")
                            .font(RobinhoodTypography.callout)
                            .fontWeight(.semibold)
                    }
                    .foregroundColor(RobinhoodColors.background)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 12)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(RobinhoodColors.success)
                    )
                }
                .buttonStyle(PlainButtonStyle())
            }
            
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(.horizontal, 32)
    }
    
    /// List view for displaying goals - Robinhood style
    private var goalsListView: some View {
        VStack(spacing: 16) {
            ForEach(filteredGoals.indices, id: \.self) { index in
                let goal = filteredGoals[index]
                Button(action: { selectedGoal = goal }) {
                    RobinhoodGoalCard(
                        goal: goal,
                        currencyCode: currencyCode
                    )
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
        .padding(.horizontal, 4)
    }
    
    /// Floating action button for adding new goals - Robinhood style
    private var floatingActionButton: some View {
        Button(action: { showAddGoal = true }) {
            ZStack {
                Circle()
                    .fill(RobinhoodColors.success)
                    .frame(width: 56, height: 56)
                    .shadow(color: RobinhoodColors.success.opacity(0.3), radius: 8, x: 0, y: 4)
                
                Image(systemName: "plus")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(RobinhoodColors.background)
            }
        }
        .buttonStyle(PlainButtonStyle())
        .padding(.trailing, 20)
        .padding(.bottom, 20)
        .accessibilityLabel("Add new goal")
        .accessibilityAddTraits(.isButton)
    }
    
    /// Sheet for adding new goals
    private var addGoalSheet: some View {
        NewSavingGoalView { newGoal in
            goals.append(newGoal)
            showAddGoal = false
        }
        .presentationDetents([.large])
        .presentationDragIndicator(.visible)
    }
    
    /// Sheet for displaying goal details
    private func goalDetailSheet(for goal: GoalFormItem) -> some View {
        GoalDetailView(goal: goal)
    }
    
    // MARK: - Helper Methods
    
    /// Calculates progress percentage for a goal
    private func calculateProgress(for goal: GoalFormItem) -> Double {
        guard goal.targetAmount > 0 else { return 0 }
        return min(max(goal.savedAmount / goal.targetAmount, 0), 1)
    }
}


// MARK: - GoalDetailView

struct GoalDetailView: View {
    // MARK: - Properties
    let goal: GoalFormItem
    @AppStorage("preferredCurrency") private var preferredCurrency: String = "USD"
    
    // MARK: - Computed Properties
    
    /// Currency code extracted from preferred currency string
    private var currencyCode: String {
        preferredCurrency.components(separatedBy: " ").first ?? "USD"
    }
    
    /// Progress percentage for the goal
    private var progressPercentage: Double {
        guard goal.targetAmount > 0 else { return 0 }
        return min(max(goal.savedAmount / goal.targetAmount, 0), 1)
    }
    
    /// Remaining amount to reach the goal
    private var remainingAmount: Double {
        max(goal.targetAmount - goal.savedAmount, 0)
    }
    
    /// Days remaining until target date
    private var daysRemaining: Int {
        let calendar = Calendar.current
        let now = Date()
        let components = calendar.dateComponents([.day], from: now, to: goal.targetDate)
        return max(components.day ?? 0, 0)
    }
    
    // MARK: - Body
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    headerSection
                    progressSection
                    financialDetailsSection
                    if let notes = goal.notes, !notes.isEmpty {
                        notesSection
                    }
                    Spacer(minLength: 20)
                }
                .padding()
            }
            .navigationTitle("Goal Details")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
    
    // MARK: - View Components
    
    /// Header with icon and basic info
    private var headerSection: some View {
        HStack(spacing: AppPaddings.lg) {
            ZStack {
                Circle()
                    .fill(goal.iconColor)
                    .frame(width: AppSizes.iconXXXLarge, height: AppSizes.iconXXXLarge)
                Image(systemName: goal.iconName)
                    .font(.system(size: 24, weight: .semibold))
                    .foregroundColor(AppColors.textInverse)
            }
            
            VStack(alignment: .leading, spacing: AppPaddings.xs) {
                Text(goal.name)
                    .font(.h2)
                    .foregroundColor(AppColors.textPrimary)
                
                if let subtitle = goal.subtitle, !subtitle.isEmpty {
                    Text(subtitle)
                        .font(.body)
                        .foregroundColor(AppColors.textSecondary)
                }
            }
            
            Spacer()
        }
    }
    
    /// Progress section with progress bar and percentage
    private var progressSection: some View {
        VStack(alignment: .leading, spacing: AppPaddings.md) {
            HStack {
                Text("Progress")
                    .font(.h4)
                    .foregroundColor(AppColors.textPrimary)
                
                Spacer()
                
                Text("\(Int(progressPercentage * 100))%")
                    .font(.h2)
                    .foregroundColor(goal.iconColor)
            }
            
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: AppRadius.sm)
                        .fill(AppColors.backgroundSecondary)
                        .frame(height: 10)
                    
                    RoundedRectangle(cornerRadius: AppRadius.sm)
                        .fill(goal.iconColor)
                        .frame(width: geometry.size.width * progressPercentage, height: 10)
                        .animation(AppAnimations.easeInOut, value: progressPercentage)
                }
            }
            .frame(height: 10)
        }
    }
    
    /// Financial details section
    private var financialDetailsSection: some View {
        VStack(alignment: .leading, spacing: AppPaddings.lg) {
            Text("Financial Details")
                .font(.h4)
                .foregroundColor(AppColors.textPrimary)
            
            VStack(spacing: AppPaddings.md) {
                financialDetailRow(
                    title: "Saved",
                    amount: goal.savedAmount,
                    color: AppColors.success
                )
                
                financialDetailRow(
                    title: "Target",
                    amount: goal.targetAmount,
                    color: AppColors.textPrimary
                )
                
                financialDetailRow(
                    title: "Remaining",
                    amount: remainingAmount,
                    color: AppColors.primary
                )
            }
        }
    }
    
    /// Individual financial detail row
    private func financialDetailRow(title: String, amount: Double, color: Color) -> some View {
        HStack {
            Text(title)
                .font(.label)
                .foregroundColor(AppColors.textSecondary)
            
            Spacer()
            
            Text(amount, format: .currency(code: currencyCode))
                .font(.label)
                .foregroundColor(color)
        }
        .padding(.vertical, AppPaddings.sm)
        .padding(.horizontal, AppPaddings.md)
        .background(
            RoundedRectangle(cornerRadius: AppRadius.md)
                .fill(AppColors.backgroundSecondary)
        )
    }
    
    /// Notes section
    private var notesSection: some View {
        VStack(alignment: .leading, spacing: AppPaddings.sm) {
            Text("Notes")
                .font(.h4)
                .foregroundColor(AppColors.textPrimary)
            
            Text(goal.notes ?? "")
                .font(.body)
                .foregroundColor(AppColors.textSecondary)
                .padding(AppPaddings.md)
                .background(
                    RoundedRectangle(cornerRadius: AppRadius.md)
                        .fill(AppColors.backgroundSecondary)
                )
        }
    }
}
