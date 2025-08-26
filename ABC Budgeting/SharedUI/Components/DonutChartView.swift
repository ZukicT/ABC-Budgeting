import SwiftUI
import UIKit

/// A premium, banking-app-quality donut chart with interactive selection, segment gaps, gradients, and full accessibility.
public struct DonutChartView: View {
    @ObservedObject private var viewModel: DonutChartViewModel
    private let donutThickness: CGFloat = 38
    private let segmentGap: CGFloat = 6
    private let selectedScale: CGFloat = 1.1
    private let selectedOffset: CGFloat = 12
    private let shadowRadius: CGFloat = 8
    private let selectedShadowRadius: CGFloat = 18
    private let centerIconSize: CGFloat = 36
    private let centerValueFont: CGFloat = 26
    private let currencyCode: String
    @Namespace private var animation
    @State private var pop: Bool = false
    @State private var lastCategoryCount: Int = 0
    @State private var donutRotation: Double = 0 // in radians

    public init(viewModel: DonutChartViewModel, currencyCode: String = Locale.current.currency?.identifier ?? "USD") {
        self.viewModel = viewModel
        self.currencyCode = currencyCode
    }

    public var body: some View {
        GeometryReader { geo in
            let size = min(geo.size.width, geo.size.height)
            let outerRadius = size/2 - segmentGap
            let reduceMotion = UIAccessibility.isReduceMotionEnabled
            ZStack {
                // Rotating donut
                ZStack {
                    ForEach(Array(viewModel.categories.enumerated()), id: \ .1.id) { index, category in
                        DonutSegment(
                            category: category,
                            index: index,
                            categories: viewModel.categories,
                            total: viewModel.total,
                            isSelected: viewModel.selectedCategory == category,
                            thickness: donutThickness,
                            gap: segmentGap,
                            selectedScale: selectedScale,
                            shadowRadius: shadowRadius,
                            selectedShadowRadius: selectedShadowRadius,
                            animation: animation
                        )
                        .onTapGesture {
                            withAnimation(reduceMotion ? .linear(duration: 0.1) : .interpolatingSpring(stiffness: 180, damping: 28)) {
                                rotateDonutToSegment(index: index)
                                viewModel.select(category)
                            }
                            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                        }
                        .accessibilityElement(children: .ignore)
                        .accessibilityLabel(Text("\(category.name), \(category.value.formatted(.currency(code: currencyCode).precision(.fractionLength(0))))"))
                        .accessibilityAddTraits(viewModel.selectedCategory == category ? .isSelected : [])
                    }
                }
                .rotationEffect(.radians(donutRotation))
                .scaleEffect(pop ? 1.08 : 1.0)
                .animation(reduceMotion ? .linear(duration: 0.1) : .interpolatingSpring(stiffness: 70, damping: 6), value: pop)
                .onChange(of: viewModel.categories.count) { oldValue, newValue in
                    if newValue != lastCategoryCount {
                        pop = true
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.28) { pop = false }
                        lastCategoryCount = newValue
                    }
                }
                .onChange(of: viewModel.selectedCategory) { oldValue, newValue in
                    if let selected = newValue, let selectedIndex = viewModel.categories.firstIndex(of: selected) {
                        withAnimation(reduceMotion ? .linear(duration: 0.1) : .interpolatingSpring(stiffness: 180, damping: 28)) {
                            rotateDonutToSegment(index: selectedIndex)
                        }
                    }
                }
                // Center content (icon and value) is static and does not rotate
                CenterContent(
                    category: viewModel.selectedCategory ?? viewModel.categories.first!,
                    iconSize: centerIconSize,
                    valueFont: centerValueFont,
                    currencyCode: currencyCode,
                    animation: animation
                )
                .transition(.scale.combined(with: .opacity))
                .animation(reduceMotion ? .linear(duration: 0.1) : .interpolatingSpring(stiffness: 50, damping: 20), value: viewModel.selectedCategory)
                // Static arrow at the right (always on top)
                ArrowIndicatorStatic(radius: outerRadius + 18)
            }
            .frame(width: size, height: size)
        }
        .animation(UIAccessibility.isReduceMotionEnabled ? .linear(duration: 0.1) : .interpolatingSpring(stiffness: 120, damping: 8), value: viewModel.categories)
    }

    // Helper to compute the center angle for a segment
    private func centerAngle(for index: Int, in categories: [DonutChartCategory], total: Double) -> Double {
        let sum = categories.prefix(index).reduce(0) { sum, category in sum + category.value }
        let sweep = categories[index].value / total * 2 * .pi
        return (sum / total * 2 * .pi + sweep / 2) - .pi/2
    }

    // Rotate the donut so the selected segment is at the top (arrow)
    private func rotateDonutToSegment(index: Int) {
        let angle = centerAngle(for: index, in: viewModel.categories, total: viewModel.total)
        donutRotation = -angle // negative to bring the segment to the top
    }
}

// MARK: - DonutSegment
private struct DonutSegment: View {
    let category: DonutChartCategory
    let index: Int
    let categories: [DonutChartCategory]
    let total: Double
    let isSelected: Bool
    let thickness: CGFloat
    let gap: CGFloat
    let selectedScale: CGFloat
    let shadowRadius: CGFloat
    let selectedShadowRadius: CGFloat
    var animation: Namespace.ID
    var body: some View {
        GeometryReader { geo in
            let rect = geo.frame(in: .local)
            let center = CGPoint(x: rect.midX, y: rect.midY)
            let baseRadius = min(rect.width, rect.height) / 2
            let effectiveThickness = isSelected ? thickness * 1.32 : thickness
            let radius = baseRadius - effectiveThickness / 2
            let startAngle = angle(for: index, in: categories, total: total, isStart: true)
            let endAngle = angle(for: index, in: categories, total: total, isStart: false)
            let scale = isSelected ? selectedScale : 1.0
            // Subtle angular gradient for each segment
            let gradient = AngularGradient(
                gradient: Gradient(colors: [category.color.opacity(0.85), category.color]),
                center: .center,
                startAngle: .radians(startAngle),
                endAngle: .radians(endAngle)
            )
            // No gap between segments
            let gapRadians: CGFloat = 0
            let adjustedStart = startAngle + gapRadians/2
            let adjustedEnd = endAngle - gapRadians/2
            Path { path in
                path.addArc(center: center, radius: radius + effectiveThickness / 2, startAngle: .radians(adjustedStart), endAngle: .radians(adjustedEnd), clockwise: false)
                path.addArc(center: center, radius: radius - effectiveThickness / 2, startAngle: .radians(adjustedEnd), endAngle: .radians(adjustedStart), clockwise: true)
                path.closeSubpath()
            }
            .fill(gradient)
            .shadow(color: category.color.opacity(isSelected ? 0.22 : 0.08), radius: isSelected ? selectedShadowRadius : shadowRadius, x: 0, y: 2)
            .scaleEffect(scale)
            .matchedGeometryEffect(id: category.id, in: animation)
        }
    }
    private func angle(for index: Int, in categories: [DonutChartCategory], total: Double, isStart: Bool) -> Double {
        let sum = categories.prefix(index).reduce(0) { sum, category in sum + category.value }
        let sweep = categories[index].value / total * 2 * .pi
        return isStart ? sum / total * 2 * .pi - .pi/2 : (sum / total * 2 * .pi + sweep) - .pi/2
    }
}

// MARK: - CenterContent
private struct CenterContent: View {
    let category: DonutChartCategory
    let iconSize: CGFloat
    let valueFont: CGFloat
    let currencyCode: String
    var animation: Namespace.ID
    var body: some View {
        VStack(spacing: 6) {
            Image(systemName: category.symbol)
                .font(.system(size: iconSize, weight: .bold))
                .foregroundColor(category.color)
                .matchedGeometryEffect(id: "centerIcon-\(category.id)", in: animation)
            Text(category.value.formatted(.currency(code: currencyCode).precision(.fractionLength(0))))
                .font(.system(size: valueFont, weight: .bold, design: .rounded))
                .foregroundColor(.primary)
                .matchedGeometryEffect(id: "centerValue-\(category.id)", in: animation)
        }
        .animation(.spring(response: 0.45, dampingFraction: 0.85), value: category.id)
        .accessibilityElement(children: .combine)
        .accessibilityLabel(Text("\(category.name) selected, \(category.value.formatted(.currency(code: currencyCode).precision(.fractionLength(0))))"))
    }
}

// MARK: - ArrowIndicatorStatic
private struct ArrowIndicatorStatic: View {
    let radius: CGFloat
    var body: some View {
        GeometryReader { geo in
            let center = CGPoint(x: geo.size.width/2, y: geo.size.height/2)
            let arrowLength: CGFloat = 22
            let arrowWidth: CGFloat = 16
            let x = center.x + radius + arrowLength/2 - 10
            let y = center.y
            Image(systemName: "arrowtriangle.left.fill")
                .resizable()
                .frame(width: arrowLength, height: arrowWidth)
                .foregroundColor(.white)
                .shadow(color: .black.opacity(0.32), radius: 4, x: 0, y: 2)
                .position(x: x, y: y)
                .opacity(0.98)
        }
    }
}

// MARK: - DonutChartCategory Model
public struct DonutChartCategory: Identifiable, Equatable {
    public let id: UUID
    public let name: String
    public let value: Double
    public let color: Color
    public let symbol: String // SF Symbol or asset name
    public init(id: UUID = UUID(), name: String, value: Double, color: Color, symbol: String) {
        self.id = id
        self.name = name
        self.value = value
        self.color = color
        self.symbol = symbol
    }
}

// MARK: - ViewModel
public final class DonutChartViewModel: ObservableObject {
    @Published public var categories: [DonutChartCategory]
    @Published public var selectedCategory: DonutChartCategory?
    public var total: Double { categories.reduce(0) { sum, category in sum + category.value } }
    public init(categories: [DonutChartCategory], selected: DonutChartCategory? = nil) {
        self.categories = categories
        self.selectedCategory = selected ?? categories.first
    }
    public func select(_ category: DonutChartCategory) {
        withAnimation(.spring(response: 0.45, dampingFraction: 0.85)) {
            selectedCategory = category
        }
    }
} 