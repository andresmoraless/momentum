import SwiftUI

struct MonthlyGoalsView: View {
    @EnvironmentObject var store: MomentumGoalStore
    @State private var isExpanded = true

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Single header row
            Button(action: {
                withAnimation(.easeInOut) {
                    isExpanded.toggle()
                }
            }) {
                HStack {
                    Text("Monthly Indicators")
                        .font(.title3.bold())
                        .foregroundColor(.primary)

                    Spacer()

                    Image(systemName: isExpanded ? "chevron.down" : "chevron.right")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.secondary)
                        .rotationEffect(.degrees(isExpanded ? 0 : 0))
                        .animation(.easeInOut(duration: 0.2), value: isExpanded)
                }
                .contentShape(Rectangle()) // makes whole row tappable
            }
            .buttonStyle(.plain)
            .padding(.bottom, 4)

            // Monthly goal list
            if isExpanded {
                ForEach(store.monthlyGoals) { goal in
                    MonthlyGoalCard(goal: goal)
                        .environmentObject(store)
                    Divider()
                }
            }
        }
        .padding(.horizontal)
    }
}




