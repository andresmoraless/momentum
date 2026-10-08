import SwiftUI

struct SetGoalTargetView: View {
    @EnvironmentObject var store: MomentumGoalStore
    @Environment(\.dismiss) private var dismiss

    @State private var target: Int = 1
    @State private var notes: String = ""

    var body: some View {
        NavigationStack {
            Form {
                Section("Goal Target") {
                    Stepper(value: $target, in: 1...30) {
                        Text("Target: \(target)")
                    }
                }

                Section("Notes") {
                    TextEditor(text: $notes)
                        .frame(minHeight: 100)
                        .foregroundColor(.primary)
                }
            }
            .navigationTitle("Set Target")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Add") {
                        if let template = store.selectedTemplate {
                            store.addWeeklyGoal(from: template, target: target, notes: notes)
                            dismiss()
                        }
                    }
                }
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
        }
    }
}


