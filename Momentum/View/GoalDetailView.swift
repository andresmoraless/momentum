import SwiftUI

struct GoalDetailView: View {
    @EnvironmentObject var store: MomentumGoalStore
    let goal: WeeklyGoal

    @State private var editedTarget: String = ""
    @State private var editedNotes: String = ""

    private var template: GoalTemplate? {
        goal.template(from: store.templates)
    }

    var color: Color {
        template?.color ?? .accentColor
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {

                // MARK: - Icon + Title
                VStack(spacing: 8) {
                    Image(systemName: template?.icon ?? "target")
                        .font(.system(size: 64))
                        .foregroundColor(color)

                    Text(template?.title ?? "Goal")
                        .font(.largeTitle.bold())
                }

                // MARK: - Progress
                VStack(spacing: 4) {
                    Text("\(goal.current) / \(goal.target)")
                        .font(.title.bold())
                        .foregroundColor(color)

                    ProgressView(value: Double(goal.current), total: Double(goal.target))
                        .tint(color)
                        .padding(.horizontal)
                }

                Divider()

                // MARK: - Edit Target
                VStack(alignment: .leading, spacing: 12) {
                    Text("Target")
                        .font(.headline)

                    HStack {
                        TextField("Target", text: $editedTarget)
                            .keyboardType(.numberPad)
                            .textFieldStyle(.roundedBorder)

                        Button("Save") {
                            if let newValue = Int(editedTarget), newValue > 0 {
                                store.updateTarget(for: goal.id, to: newValue)
                            }
                        }
                        .buttonStyle(.borderedProminent)
                    }
                }
                .padding(.horizontal)

                // MARK: - Notes
                VStack(alignment: .leading, spacing: 12) {
                    Text("Notes")
                        .font(.headline)

                    TextEditor(text: $editedNotes)
                        .frame(height: 140)
                        .padding(8)
                        .background(Color(.systemGray6))
                        .cornerRadius(12)

                    Button("Save Notes") {
                        store.updateNotes(for: goal.id, notes: editedNotes)
                    }
                    .buttonStyle(.bordered)
                }
                .padding(.horizontal)

                Spacer()
            }
            .padding(.top, 30)
            .onAppear {
                editedTarget = String(goal.target)
                editedNotes = goal.notes
            }
        }
        .navigationTitle("Goal Details")
        .navigationBarTitleDisplayMode(.inline)
    }
}

