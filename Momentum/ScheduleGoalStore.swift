//
//  GoalStore.swift
//  Momentum
//
//  Created by andres morales on 2/10/25.
//

import Foundation
import Combine

@MainActor
final class GoalStore: ObservableObject {

    @Published private(set) var goals: [Goal] = []

    init(now: Date = Date()) {
        goals = [
            Goal(title: "Scripture Study", scheduledAt: now.setting(hour: 7, minute: 30)),
            Goal(title: "Plan weekly goals", scheduledAt: now.setting(hour: 9, minute: 0)),
            Goal(title: "Call mom", scheduledAt: now.setting(hour: 17, minute: 30))
        ]
    }

    // C
    func create(_ goal: Goal) {
        goals.append(goal)
    }

    // U
    func update(_ goal: Goal) {
        if let i = goals.firstIndex(where: { $0.id == goal.id }) {
            goals[i] = goal
        }
    }

    // D
    func delete(_ goal: Goal) {
        goals.removeAll { $0.id == goal.id }
    }

    // R (helpers for the UI)
    func goals(on day: Date) -> [Goal] {
        goals.filter { Calendar.current.isDate($0.scheduledAt, inSameDayAs: day) }
    }

    func goalsByHour(on day: Date) -> [(hour: Int, items: [Goal])] {
        let dayGoals = goals(on: day)

        let buckets = Dictionary(grouping: dayGoals) { goal in
            Calendar.current.component(.hour, from: goal.scheduledAt)
        }

        return buckets
            .map { key, value in
                (hour: key, items: value.sorted { $0.scheduledAt < $1.scheduledAt })
            }
            .sorted { $0.hour < $1.hour }
    }
}

