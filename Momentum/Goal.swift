// Goal.swift
import Foundation
import SwiftUI

enum GoalStatus: String, Codable {
    case pending, completed
}

struct Goal: Identifiable, Codable, Equatable {
    let id: UUID
    var title: String
    var notes: String?
    var scheduledAt: Date
    var status: GoalStatus
    var colorHex: String
    var progressCount: Int   // new property

    var color: Color {
        Color(hex: colorHex)
    }

    init(
        id: UUID = UUID(),
        title: String,
        notes: String? = nil,
        scheduledAt: Date,
        status: GoalStatus = .pending,
        color: Color = .momentumPalette.first ?? .gray,
        progressCount: Int = 0
    ) {
        self.id = id
        self.title = title
        self.notes = notes
        self.scheduledAt = scheduledAt
        self.status = status
        self.colorHex = color.toHex() ?? "#A8DADC"
        self.progressCount = progressCount
    }
}


