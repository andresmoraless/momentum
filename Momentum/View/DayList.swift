//
//  DayList.swift
//  Momentum
//
//  Created by andres morales on 9/10/25.
//

// Views/Day/DayList.swift
import SwiftUI

struct DayList: View {
    @EnvironmentObject private var store: GoalStore
    let selectedDay: Date
    var onAdd: () -> Void

    var body: some View {
        List {
            ForEach(store.goalsByHour(on: selectedDay), id: \.hour) { group in
                Section(header: Text(hourLabel(group.hour))) {
                    ForEach(group.items) { goal in
                        GoalRow(goal: goal)
                            .swipeActions {
                                Button(role: .destructive) {
                                    store.delete(goal)
                                } label: {
                                    Label("Delete", systemImage: "trash")
                                }
                            }

                            // Left-to-right swipe (mark complete)
                            .swipeActions(edge: .leading, allowsFullSwipe: true) {
                                if goal.status == .pending {
                                    Button {
                                        var updated = goal
                                        updated.status = .completed
                                        store.update(updated)
                                    } label: {
                                        Label("Complete", systemImage: "checkmark.circle")
                                    }
                                    .tint(.green)
                                } else {
                                    Button {
                                        var updated = goal
                                        updated.status = .pending
                                        store.update(updated)
                                    } label: {
                                        Label("Mark Pending", systemImage: "arrow.uturn.backward.circle")
                                    }
                                    .tint(.orange)
                                }
                            }
                            .contextMenu {
                                Button("Mark Completed") {
                                    var updated = goal
                                    updated.status = .completed
                                    store.update(updated)
                                }
                                Button("Mark Pending") {
                                    var updated = goal
                                    updated.status = .pending
                                    store.update(updated)
                                }
                            }
                    }
                }
            }

            Button {
                onAdd()
            } label: { Label("Add goal", systemImage: "plus.circle") }
        }
        .listStyle(.insetGrouped)
    }

    private func hourLabel(_ hour: Int) -> String {
        var comps = DateComponents()
        comps.hour = hour
        let date = Calendar.current.date(from: comps) ?? Date()
        let f = DateFormatter(); f.dateFormat = "h a"  // "7 AM"
        return f.string(from: date)
    }
}

