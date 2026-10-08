// GoalTemplate.swift
import SwiftUI

struct GoalTemplate: Identifiable, Codable, Equatable {
    let id: UUID
    let title: String
    let icon: String
    let colorHex: String
    let description: String

    var color: Color {
        Color(hex: colorHex)
    }

    init(title: String, icon: String, color: Color, description: String) {
        self.id = UUID()
        self.title = title
        self.icon = icon
        self.colorHex = color.toHex() ?? "#A8DADC"
        self.description = description
    }
}

// MARK: - Preset Goal Templates
extension GoalTemplate {
    static let all: [GoalTemplate] = [
        GoalTemplate(title: "Workout", icon: "figure.walk", color: Color(hex: "#A8DADC"), description: "Physical activity or exercise"),
        GoalTemplate(title: "Study", icon: "books.vertical", color: Color(hex: "#F4A261"), description: "Focused learning time"),
        GoalTemplate(title: "Sleep", icon: "moon.fill", color: Color(hex: "#E9C46A"), description: "Rest and recovery"),
        GoalTemplate(title: "Scripture Study", icon: "book", color: Color(hex: "#9B9ECE"), description: "Spiritual growth and reflection"),
        GoalTemplate(title: "Social Time", icon: "person.2.fill", color: Color(hex: "#84A59D"), description: "Connection with others"),
        GoalTemplate(title: "Journal", icon: "pencil.and.outline", color: Color(hex: "#F28482"), description: "Personal reflection and writing")
    ]
}

