import SwiftUI
import UIKit

struct IndicatorCard: View {
    let goal: WeeklyGoal
    let isEditing: Bool

    @EnvironmentObject var store: MomentumGoalStore
    @Environment(\.colorScheme) private var colorScheme

    // MARK: - States
    @State private var isPressed = false
    @State private var showDeleteAlert = false
    @State private var shakeAngle: Double = 0.0
    @State private var showOverflow = false
    @State private var overflowValue = 0
    @State private var showMilestone = false
    @State private var glowOpacity: Double = 0.0
    @State private var showPulse = false
    @State private var showDetailView = false

    private let haptic = UIImpactFeedbackGenerator(style: .light)

    // MARK: - Derived
    private var template: GoalTemplate? {
        goal.template(from: store.templates)
    }

    private var color: Color {
        template?.color ?? Color.gray.opacity(0.4)
    }

    private var trackColor: Color {
        Color(uiColor: .tertiarySystemFill)
    }

    private var shadowBaseOpacity: Double {
        colorScheme == .dark ? 0.18 : 0.25
    }

    private var glowScale: Double {
        colorScheme == .dark ? 0.6 : 1.0
    }

    // MARK: - Card Surface
    private var cardSurface: some View {
        RoundedRectangle(cornerRadius: 14)
            .fill(
                LinearGradient(
                    colors: [
                        color.opacity(colorScheme == .dark ? 0.10 : 0.18),
                        color.opacity(colorScheme == .dark ? 0.05 : 0.08)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .fill(
                        color.opacity((0.12 * glowScale) + (glowOpacity * 0.18 * glowScale))
                    )
            )
            .shadow(
                color: color.opacity(
                    (isPressed ? 0.42 : shadowBaseOpacity) * glowScale
                ),
                radius: isPressed ? 8 : 6,
                x: 0,
                y: isPressed ? 6 : 2
            )
    }

    // MARK: - Header Row
    private var headerRow: some View {
        HStack {
            Image(systemName: template?.icon ?? "questionmark")
                .font(.system(size: 40, weight: .medium))
                .foregroundColor(color)
                .frame(width: 60)
                .padding(.leading, 10)

            Spacer()

            VStack(alignment: .trailing, spacing: 6) {
                Text(template?.title ?? "Goal")
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.primary)

                Text("\(goal.current) / \(goal.target)")
                    .font(.title3.bold())
                    .foregroundColor(color)
            }
            .padding(.trailing, 12)
        }
    }

    // MARK: - Progress Bar
    private var progressBar: some View {
        GeometryReader { geo in
            ZStack(alignment: .leading) {

                // BASE TRACK
                RoundedRectangle(cornerRadius: 6)
                    .fill(trackColor)
                    .frame(height: 8)

                // FILLED PROGRESS
                RoundedRectangle(cornerRadius: 6)
                    .fill(color)
                    .frame(
                        width: min(
                            geo.size.width * CGFloat(Double(goal.current) / Double(goal.target)),
                            geo.size.width
                        ),
                        height: 8
                    )
                    .animation(.easeOut(duration: 0.35), value: goal.current)

                // SHIMMER WHEN OVERFLOWING
                if goal.current > goal.target {
                    RoundedRectangle(cornerRadius: 6)
                        .fill(
                            LinearGradient(
                                colors: [
                                    color.opacity(0.22 * glowScale),
                                    .white.opacity(colorScheme == .dark ? 0.05 : 0.12),
                                    color.opacity(0.22 * glowScale)
                                ],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .blendMode(colorScheme == .dark ? .plusLighter : .screen)
                        .frame(width: geo.size.width, height: 8)
                        .opacity(glowOpacity)
                }
            }
        }
        .frame(height: 8)
        .overlay(
            overflowCounter,
            alignment: .topTrailing
        )
    }

    private var overflowCounter: some View {
        Group {
            if showOverflow {
                Text("+\(overflowValue)")
                    .font(.caption.bold())
                    .foregroundColor(color)
                    .offset(y: -14)
                    .transition(.scale.combined(with: .opacity))
            }
        }
    }

    // MARK: - Body
    var body: some View {
        ZStack {
            cardSurface
                .animation(.easeInOut(duration: 0.6), value: glowOpacity)

            VStack(spacing: 12) {
                headerRow
                progressBar
            }
            .padding()
            .contentShape(Rectangle())

            if isEditing { deleteButton }

            if goal.current >= goal.target { completionOverlay }

            if showMilestone { milestoneLabel }
        }
        .frame(height: 120)
        .scaleEffect(isPressed ? 0.97 : 1.0)
        .rotationEffect(.degrees(isEditing ? shakeAngle : 0))
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isPressed)
        .scaleEffect(showPulse ? 1.05 : 1.0)
        .animation(.spring(response: 0.4, dampingFraction: 0.6), value: showPulse)
        .onChange(of: isEditing) { _, newVal in newVal ? startShaking() : stopShaking() }
        .onTapGesture { handleSingleTap() }
        .onTapGesture(count: 2) { handleDoubleTap() }
        .onLongPressGesture(minimumDuration: 0.5) { handleLongPress() }
        .alert("Delete Goal?", isPresented: $showDeleteAlert) {
            Button("Cancel", role: .cancel) {}
            Button("Delete", role: .destructive) {
                store.deleteGoal(goal.id)
            }
        } message: {
            Text("Are you sure you want to delete this goal? This action cannot be undone.")
        }
        .sheet(isPresented: $showDetailView) {
            NavigationStack {
                GoalDetailView(goal: goal)
                    .environmentObject(store)
            }
        }
    }

    // MARK: - Buttons / Overlays
    private var deleteButton: some View {
        VStack {
            HStack {
                Spacer()
                Button {
                    showDeleteAlert = true
                    haptic.impactOccurred()
                } label: {
                    Image(systemName: "trash.circle.fill")
                        .font(.system(size: 26))
                        .foregroundColor(.red.opacity(0.85))
                        .padding(8)
                }
            }
            Spacer()
        }
    }

    private var completionOverlay: some View {
        RoundedRectangle(cornerRadius: 14)
            .fill(Color.white.opacity(colorScheme == .dark ? 0.35 : 0.55))
            .overlay(
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(color)
                    .font(.system(size: 38))
            )
    }

    private var milestoneLabel: some View {
        Text("New Record!")
            .font(.headline)
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(color.opacity(0.9))
            .foregroundColor(.white)
            .cornerRadius(8)
            .transition(.move(edge: .top).combined(with: .opacity))
            .offset(y: -60)
    }

    // MARK: - Gesture Handlers
    private func handleSingleTap() {
        guard !isEditing else { return }
        showDetail()
    }

    private func handleDoubleTap() {
        guard !isEditing else { return }

        let wasOver = goal.current >= goal.target
        store.incrementProgress(for: goal.id)

        if wasOver {
            triggerOverflowVisuals()
            checkForMilestone()
        } else if goal.current + 1 == goal.target {
            triggerGlow()
        }

        tapBounce()
    }

    private func handleLongPress() {
        guard !isEditing, goal.current > 0 else { return }

        store.decrementProgress(for: goal.id)
        tapBounce(downward: true)
    }

    private func tapBounce(downward: Bool = false) {
        withAnimation(.spring(response: 0.25, dampingFraction: 0.7)) {
            isPressed = true
        }
        haptic.impactOccurred(intensity: downward ? 0.5 : 0.8)

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
            isPressed = false
        }
    }

    // MARK: - Detail
    private func showDetail() {
        showDetailView = true
    }

    // MARK: - Animations
    private func triggerGlow() {
        withAnimation(.easeInOut(duration: 0.8)) { glowOpacity = 1.0 }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
            withAnimation(.easeOut(duration: 1.0)) { glowOpacity = 0.0 }
        }
    }

    private func triggerOverflowVisuals() {
        if showOverflow { return }

        if let updated = store.weeklyGoals.first(where: { $0.id == goal.id }) {
            overflowValue = max(1, updated.current - updated.target)
        } else {
            overflowValue = 1
        }

        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
            showOverflow = true
        }

        triggerGlow()
        showPulse = true

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { showPulse = false }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
            withAnimation(.easeOut(duration: 0.4)) { showOverflow = false }
        }
    }

    private func checkForMilestone() {
        let ratio = Double(goal.current) / Double(goal.target)

        if ratio >= 1.5 &&
            Int(ratio * 100) % 50 == 0 {

            withAnimation(.spring()) { showMilestone = true }

            NotificationCenter.default.post(
                name: .showConfetti,
                object: template?.color
            )

            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                withAnimation(.easeOut(duration: 0.6)) { showMilestone = false }
            }
        }
    }

    private func startShaking() {
        let angle = Double.random(in: -1.5...1.5)
        withAnimation(Animation.easeInOut(duration: 0.15)
            .repeatForever(autoreverses: true)) {
            shakeAngle = angle
        }
    }

    private func stopShaking() {
        withAnimation(.easeOut(duration: 0.15)) {
            shakeAngle = 0
        }
    }
}















