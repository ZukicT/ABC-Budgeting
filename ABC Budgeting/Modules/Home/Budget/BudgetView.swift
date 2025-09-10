import SwiftUI

struct BudgetView: View {
    @State private var showAddGoal = false
    @Binding var goals: [GoalFormData]
    @State private var selectedCategory: TransactionCategory? = nil
    @State private var selectedGoal: GoalFormData? = nil
    // In the future, this will be a list of goals
    // For now, always empty state
    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottomTrailing) {
                AppColors.background.ignoresSafeArea()
                ScrollView {
                    VStack(alignment: .leading, spacing: 0) {
                        Text("Savings & Goals")
                            .font(.title.bold())
                            .foregroundColor(.primary)
                            .padding(.top, 20)
                            .padding(.horizontal)
                        // Filter Chips Row (dynamic)
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 12) {
                                Button(action: { selectedCategory = nil }) {
                                    Text("All")
                                        .font(.subheadline.bold())
                                        .foregroundColor(selectedCategory == nil ? .white : AppColors.tagUnselected)
                                        .padding(.vertical, 8)
                                        .padding(.horizontal, 18)
                                        .background(
                                            RoundedRectangle(cornerRadius: 8)
                                                .fill(selectedCategory == nil ? AppColors.black : AppColors.tagUnselectedBackground)
                                        )
                                }
                                .accessibilityLabel("All")
                                .accessibilityAddTraits(selectedCategory == nil ? .isSelected : .isButton)
                                ForEach(TransactionCategory.allCases) { cat in
                                    Button(action: { selectedCategory = cat }) {
                                        HStack(spacing: 6) {
                                            ZStack {
                                                Circle()
                                                    .fill(cat.color.opacity(0.18))
                                                    .frame(width: 22, height: 22)
                                                Image(systemName: cat.symbol)
                                                    .font(.system(size: 13, weight: .semibold))
                                                    .foregroundColor(selectedCategory == cat ? .white : cat.color)
                                            }
                                            Text(cat.label)
                                                .font(.subheadline.weight(.semibold))
                                                .foregroundColor(selectedCategory == cat ? .white : AppColors.tagUnselected)
                                        }
                                        .padding(.vertical, 8)
                                        .padding(.horizontal, 18)
                                        .background(
                                            RoundedRectangle(cornerRadius: 8)
                                                .fill(selectedCategory == cat ? cat.color : AppColors.tagUnselectedBackground)
                                        )
                                    }
                                    .accessibilityLabel(cat.label)
                                    .accessibilityAddTraits(selectedCategory == cat ? .isSelected : .isButton)
                                }
                            }
                            .padding(.horizontal)
                            .padding(.top, 12)
                        }
                        let filteredGoals = selectedCategory == nil ? goals : goals.filter { goal in
                            selectedCategory?.icons.contains(goal.iconName) ?? true
                        }
                        if filteredGoals.isEmpty {
                            VStack {
                                Image("Saving Money")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(maxWidth: 220, maxHeight: 220)
                                    .accessibilityLabel("No savings goals yet")
                                Text("No savings goals yet")
                                    .font(.title3.weight(.semibold))
                                    .foregroundColor(.secondary)
                                    .padding(.top, AppPaddings.small)
                                Text("Tap the + button to add your first goal.")
                                    .font(.body)
                                    .foregroundColor(.secondary)
                                    .multilineTextAlignment(.center)
                                    .padding(.horizontal, AppPaddings.section)
                            }
                            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                            .padding(.bottom, 100) // For FAB spacing
                        } else {
                            VStack(spacing: AppPaddings.medium) {
                                ForEach(filteredGoals.indices, id: \ .self) { idx in
                                    let goal = filteredGoals[idx]
                                    Button(action: { selectedGoal = goal }) {
                                        GoalCard(
                                            iconName: goal.iconName,
                                            iconColorName: goal.iconColorName,
                                            title: goal.name,
                                            subtitle: goal.subtitle,
                                            savedAmount: goal.savedAmount,
                                            goalAmount: goal.targetAmount,
                                            progress: goal.targetAmount > 0 ? min(max(goal.savedAmount / goal.targetAmount, 0), 1) : 0
                                        )
                                    }
                                    .buttonStyle(.plain)
                                }
                            }
                            .padding(.horizontal, 16)
                            .padding(.top, AppPaddings.sectionTitleTop)
                            .padding(.bottom, 100)
                        }
                    }
                }
                FloatingActionButton(action: {
                    showAddGoal = true
                })
                .padding(.trailing, AppPaddings.fabTrailing)
                .padding(.bottom, AppPaddings.fabBottom)
                .sheet(isPresented: $showAddGoal) {
                    NewSavingGoalView { newGoal in
                        goals.append(newGoal)
                        print("DEBUG: Added new goal: \(newGoal.name), total goals: \(goals.count)")
                        showAddGoal = false
                    }
                    .presentationDetents([.large])
                    .presentationDragIndicator(.visible)
                }
            }
            .sheet(item: $selectedGoal) { goal in
                // Map GoalFormData to a Transaction-like struct for reuse
                let pseudoTransaction = Transaction(
                    id: UUID(),
                    title: goal.name,
                    subtitle: goal.notes ?? "",
                    amount: goal.savedAmount,
                    iconName: goal.iconName,
                    iconColorName: goal.iconColorName,
                    iconBackgroundName: goal.iconColorName + ".opacity15",
                    category: .savings,
                    isIncome: false,
                    linkedGoalName: nil,
                    date: Date()
                )
                TransactionDetailView(transaction: pseudoTransaction) { updated in
                    if let idx = goals.firstIndex(where: { $0.name == goal.name }) {
                        goals[idx] = GoalFormData(
                            name: updated.title,
                            subtitle: goal.subtitle,
                            targetAmount: goal.targetAmount,
                            savedAmount: updated.amount,
                            targetDate: goal.targetDate,
                            notes: updated.subtitle,
                            iconName: updated.iconName,
                            iconColorName: updated.iconColorName
                        )
                    }
                }
            }
        }
    }
}

struct GoalDetailView: View {
    let goal: GoalFormData
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(spacing: 16) {
                ZStack {
                    Circle()
                        .fill(goal.iconColor)
                        .frame(width: 48, height: 48)
                    Image(systemName: goal.iconName)
                        .font(.system(size: 28, weight: .semibold))
                        .foregroundColor(.white)
                }
                VStack(alignment: .leading) {
                    Text(goal.name)
                        .font(.title2.bold())
                    if let subtitle = goal.subtitle {
                        Text(subtitle)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                }
            }
            Text("Saved: $\(Int(goal.savedAmount))")
                .font(.title3.weight(.semibold))
            Text("Target: $\(Int(goal.targetAmount))")
            if let notes = goal.notes, !notes.isEmpty {
                Text("Notes: \(notes)")
            }
            Text("Target Date: \(goal.targetDate.formatted(date: .abbreviated, time: .omitted))")
            Spacer()
        }
        .padding()
        .navigationTitle("Goal Details")
        .navigationBarTitleDisplayMode(.inline)
    }
}
