import SwiftUI

struct CreateOrEditGoalView: View {
    enum Mode { case create(Date), edit(Goal) }

    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var store: GoalStore

    let mode: Mode

    @State private var title = ""
    @State private var notes = ""
    @State private var when = Date()                    // date + time for simplicity
    @State private var status: GoalStatus = .pending
    @State private var colorHex = "#A8DADC"

    var body: some View {
        NavigationStack {
            Form {
                Section("Details") {
                    TextField("Title", text: $title)
                    TextField("Notes", text: $notes)
                }
                Section("Schedule") {
                    DatePicker("When", selection: $when,
                               displayedComponents: [.date, .hourAndMinute])
                }
                Section("Status") {
                    Picker("Status", selection: $status) {
                        Text("Pending").tag(GoalStatus.pending)
                        Text("Completed").tag(GoalStatus.completed)
                    }
                    .pickerStyle(.segmented)
                }
                Section("Color") {
                    ColorPaletteSelector(selectedColor: Binding(
                        get: { Color(hex: colorHex) },
                        set: { newColor in
                            colorHex = newColor.toHex() ?? "#A8DADC"
                        }
                    ))
                }

            }
            .navigationTitle(navigationTitle)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save", action: save)
                        .disabled(title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
            .onAppear(perform: bootstrap)
        }
    }

    private var navigationTitle: String {
        switch mode {
        case .create: return "New Goal"
        case .edit:   return "Edit Goal"
        }
    }

    private func bootstrap() {
        switch mode {
        case .create(let day):
            // default the picker to the day the user was viewing
            let cal = Calendar.current
            let timeParts = cal.dateComponents([.hour, .minute], from: Date())
            when = cal.date(bySettingHour: timeParts.hour ?? 9,
                            minute: timeParts.minute ?? 0,
                            second: 0, of: day) ?? day
        case .edit(let g):
            title = g.title
            notes = g.notes ?? ""
            when = g.scheduledAt
            status = g.status
            colorHex = g.colorHex
        }
    }

    private func save() {
        switch mode {
        case .create:
            let new = Goal(title: title,
                           notes: notes.isEmpty ? nil : notes,
                           scheduledAt: when,
                           status: status,
                           color: Color(hex: colorHex)
            )
            store.create(new)
        case .edit(let g):
            let updated = Goal(id: g.id,
                               title: title,
                               notes: notes.isEmpty ? nil : notes,
                               scheduledAt: when,
                               status: status,
                               color: Color(hex: colorHex)
            )
            store.update(updated)
        }
        dismiss()
    }
}




