//
//  GoalRow.swift
//  Momentum
//
//  Created by andres morales on 9/10/25.
//

// Views/Shared/GoalRow.swift
import SwiftUI

struct GoalRow: View {
    let goal: Goal

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: goal.status == .completed ? "checkmark.circle.fill" : "circle")
                .foregroundStyle(goal.status == .completed ? .green : .secondary)

            VStack(alignment: .leading, spacing: 2) {
                Text(goal.title).font(.headline)
                if let notes = goal.notes, !notes.isEmpty {
                    Text(notes).font(.caption).foregroundStyle(.secondary)
                }
            }
            Spacer()
            Text(timeOnly(goal.scheduledAt))
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }

    private func timeOnly(_ d: Date) -> String {
        let f = DateFormatter(); f.dateFormat = "h:mm a"
        return f.string(from: d)
    }
}

