import SwiftUI

struct BudgetView: View {
    @State private var showAddGoal = false
    @Binding var goals: [GoalFormData]
    @State private var selectedCategory: TransactionCategory? = nil
    // In the future, this will be a list of goals
    // For now, always empty state
    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            AppColors.background.ignoresSafeArea()
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
                                        .fill(selectedCategory == nil ? AppColors.brandBlack : AppColors.tagUnselectedBackground)
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
                } else {
                    ScrollView {
                        VStack(spacing: AppPaddings.medium) {
                            ForEach(filteredGoals.indices, id: \ .self) { idx in
                                let goal = filteredGoals[idx]
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
                        }
                        .padding(.horizontal, AppPaddings.section)
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
                    showAddGoal = false
                }
                .presentationDetents([.large])
                .presentationDragIndicator(.visible)
            }
        }
    }
}
