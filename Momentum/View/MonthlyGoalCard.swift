import SwiftUI

struct MonthlyGoalCard: View {
    @EnvironmentObject var store: MomentumGoalStore
    @Environment(\.colorScheme) private var colorScheme
    let goal: MonthlyGoal

    @State private var isEditingTarget = false
    @State private var newTargetText = ""
    @State private var isPressed = false

    // Template & color
    private var template: GoalTemplate? {
        store.templates.first(where: { $0.id == goal.templateID })
    }
    private var color: Color {
        template?.color ?? Color.gray.opacity(0.4)
    }

    // Adaptive surfaces
    private var cardBackground: Color {
        Color(uiColor: .secondarySystemBackground)
    }
    private var trackColor: Color {
        Color(uiColor: .tertiarySystemFill)
    }
    private var shadowOpacity: Double {
        colorScheme == .dark ? 0.18 : 0.25
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: template?.icon ?? "chart.bar.fill")
                    .foregroundColor(color)
                    .font(.system(size: 22))
                Text(template?.title ?? goal.title)
                    .font(.headline)

                Spacer()

                Button {
                    withAnimation {
                        isEditingTarget.toggle()
                        newTargetText = String(goal.target)
                    }
                } label: {
                    Image(systemName: "pencil.circle.fill")
                        .foregroundColor(.gray)
                        .font(.system(size: 20))
                        .opacity(0.7)
                        .scaleEffect(isPressed ? 1.15 : 1.0)
                        .animation(.easeInOut(duration: 0.15), value: isPressed)
                }
                .buttonStyle(.plain)
            }

            HStack {
                Text("\(goal.current) / \(goal.target)")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                Spacer()
            }

            // Progress bar (cap at 100%)
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 6)
                        .fill(trackColor)
                        .frame(height: 8)

                    RoundedRectangle(cornerRadius: 6)
                        .fill(color)
                        .frame(
                            width: geo.size.width * CGFloat(min(Double(goal.current) / Double(goal.target), 1.0)),
                            height: 8
                        )
                        .animation(.easeInOut(duration: 0.25), value: goal.current)
                }
            }
            .frame(height: 8)

            if isEditingTarget {
                HStack {
                    TextField("Set new target", text: $newTargetText)
                        .keyboardType(.numberPad)
                        .textFieldStyle(RoundedBorderTextFieldStyle())

                    Button("Save") {
                        if let newValue = Int(newTargetText), newValue > 0 {
                            store.updateMonthlyTarget(for: goal.id, to: newValue)
                        }
                        withAnimation { isEditingTarget = false }
                    }
                    .buttonStyle(.borderedProminent)
                }
                .transition(.opacity.combined(with: .slide))
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(cardBackground)
        )
        // TO HAVE MONTHLY GOAL BLOCKS HAVE COLOR, Just replace .fill part with below code
        // .fill(
        // colorScheme == .dark
        // ? Color(uiColor: .secondarySystemBackground)
        //: color.opacity(0.15)
    //)

        .shadow(color: color.opacity(shadowOpacity), radius: 3, x: 0, y: 1)
        .scaleEffect(isPressed ? 0.97 : 1.0)
        .animation(.spring(response: 0.25, dampingFraction: 0.7), value: isPressed)
        .gesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in
                    if !isPressed {
                        isPressed = true
                        Haptic.impact(.light)  // subtle tap
                    }
                }
                .onEnded { _ in
                    isPressed = false
                }
        )
    }
}







