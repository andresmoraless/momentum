// WeeklyGoal.swift
import Foundation
import SwiftUI

struct WeeklyGoal: Identifiable, Codable {
    let id: UUID
    let templateID: UUID
    var current: Int
    var target: Int
    var weekStartDate: Date
    var notes: String
    var isCompleted: Bool = false

    init(templateID: UUID, target: Int, notes: String = "") {
        self.id = UUID()
        self.templateID = templateID
        self.current = 0
        self.target = target
        self.weekStartDate = Calendar.current.startOfWeek(for: Date())
        self.notes = notes
    }
    
    func template(from templates: [GoalTemplate]) -> GoalTemplate? {
        templates.first(where: { $0.id == templateID })
    }
}


