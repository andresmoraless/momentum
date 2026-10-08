import SwiftUI

struct AddEventView: View {
    @State private var isEditing: Bool = false
    @Environment(\.dismiss) private var dismiss

    // Fields for new event input
    @State private var title = ""
    @State private var startTime: Date = Date()
    @State private var endTime: Date = Calendar.current.date(byAdding: .hour, value: 1, to: Date())!
    @State private var color = Color.blue
    @State private var repeatOption: RepeatOption = .never

    // Callback to send new event back to ScheduleView
    var onSave: (TimeBlock) -> Void

    init(
        isEditing: Bool = false,
        startTime: Date = Date(),
        endTime: Date = Calendar.current.date(byAdding: .hour, value: 1, to: Date())!,
        color: Color = .blue,
        onSave: @escaping (TimeBlock) -> Void
    ) {
        _isEditing = State(initialValue: isEditing) 
        _startTime = State(initialValue: startTime)
        _endTime = State(initialValue: endTime)
        _color = State(initialValue: color)
        self.onSave = onSave
    }


    var body: some View {
        NavigationStack {
            Form {
                Section("Details") {
                    TextField("Title", text: $title)
                        .textInputAutocapitalization(.words)
                }

                Section("Time") {
                    DatePicker("Start Time", selection: $startTime, displayedComponents: .hourAndMinute)
                        .datePickerStyle(.wheel)
                        .environment(\.locale, Locale(identifier: "en_US_POSIX"))

                    DatePicker("End Time", selection: $endTime, displayedComponents: .hourAndMinute)
                        .datePickerStyle(.wheel)
                        .environment(\.locale, Locale(identifier: "en_US_POSIX"))
                }
                
                Section("Repeat") {
                    Picker("Repeat", selection: $repeatOption) {
                        ForEach(RepeatOption.allCases) { option in
                            Text(option.rawValue).tag(option)
                        }
                    }
                    .pickerStyle(.navigationLink)
                }

                Section("Color") {
                    ColorPicker("Event Color", selection: $color)
                }
            }
            .onChange(of: startTime) { oldValue, newValue in
                if endTime <= newValue {
                    endTime = Calendar.current.date(byAdding: .hour, value: 1, to: newValue)!
                }
            }
            .navigationTitle(isEditing ? "Edit Event" : "New Event")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button(isEditing ? "Update" : "Save") {
                        let startHour = Double(Calendar.current.component(.hour, from: startTime)) +
                                        Double(Calendar.current.component(.minute, from: startTime)) / 60.0
                        let endHour = Double(Calendar.current.component(.hour, from: endTime)) +
                                      Double(Calendar.current.component(.minute, from: endTime)) / 60.0

                        let newBlock = TimeBlock(
                            title: title,
                            startHour: startHour,
                            endHour: endHour,
                            color: color,
                            date: Date(),
                            repeatOption: repeatOption
                        )
                        onSave(newBlock)
                        dismiss()
                    }
                    .disabled(title.isEmpty || startTime >= endTime)
                }
            }
        }
    }
}

private func hourLabel(for hour: Double) -> String {
    let totalMinutes = Int(hour * 60)
    let hourInt = totalMinutes / 60
    let minuteInt = totalMinutes % 60
    
    let date = Calendar.current.date(bySettingHour: hourInt, minute: minuteInt, second: 0, of: Date())!
    let formatter = DateFormatter()
    formatter.dateFormat = "h:mm a" // e.g. 8:15 AM, 9:30 PM
    return formatter.string(from: date)
}

enum RepeatOption: String, CaseIterable, Identifiable {
    case never = "Never"
    case daily = "Every Day"
    case weekly = "Every Week"
    case biweekly = "Every 2 Weeks"
    case monthly = "Every Month"

    var id: String { self.rawValue }
}
