import Foundation
import Combine
import SwiftUI
import UIKit

enum Haptic {
    static func impact(_ style: UIImpactFeedbackGenerator.FeedbackStyle = .light) {
        UIImpactFeedbackGenerator(style: style).impactOccurred()
    }

    static func success() {
        UINotificationFeedbackGenerator().notificationOccurred(.success)
    }

    static func warning() {
        UINotificationFeedbackGenerator().notificationOccurred(.warning)
    }
}

@MainActor
final class MomentumGoalStore: ObservableObject {
    // MARK: - Published Properties
    @Published var templates: [GoalTemplate] = GoalTemplate.all
    @Published var weeklyGoals: [WeeklyGoal] = []
    @Published var monthlyGoals: [MonthlyGoal] = []
    @Published var selectedTemplate: GoalTemplate?
    @Published var showSetGoalTarget = false
    @Published var completionMessage: String? = nil
    @Published var currentGoalColor: Color? = nil
    
    // MARK: - User Preferences
    @Published var preferences = UserPreferences()

    // MARK: - Initialization
    init() {
        loadSampleDataIfEmpty()
        resetWeeklyGoalsIfNeeded()
        generateMonthlyGoalsIfNeeded()
        resetMonthlyGoalsIfNeeded()
        updateMonthlyProgress()
    }

    // MARK: - CRUD Operations

    /// Create a new weekly goal based on a template and target
    func addWeeklyGoal(from template: GoalTemplate, target: Int, notes: String = "") {
        // Prevent duplicate weekly goals
        guard !weeklyGoals.contains(where: { $0.templateID == template.id }) else { return }

        // Create and add new weekly goal
        let newGoal = WeeklyGoal(templateID: template.id, target: target, notes: notes)
        weeklyGoals.append(newGoal)

        // Auto-create monthly goal if one doesn't already exist
        if !monthlyGoals.contains(where: { $0.templateID == template.id }) {
            let monthlyTarget = target * 4  // Simple assumption: 4 weeks per month
            let newMonthlyGoal = MonthlyGoal(templateID: template.id, target: monthlyTarget)
            monthlyGoals.append(newMonthlyGoal)
        }

        updateMonthlyProgress()
    }


    /// Increment a goal's progress
    func incrementProgress(for goalID: UUID) {
        guard let i = weeklyGoals.firstIndex(where: { $0.id == goalID }) else { return }

        // Allow overcap progress
        weeklyGoals[i].current += 1

        // Trigger haptics and completion once
        if !weeklyGoals[i].isCompleted && weeklyGoals[i].current >= weeklyGoals[i].target {
            weeklyGoals[i].isCompleted = true
            Haptic.success()
            currentGoalColor = templateColor(for: weeklyGoals[i])
            completionMessage = "\(templateTitle(for: weeklyGoals[i])) goal completed!"
        }
        // Beyond goal — lighter haptic to celebrate continuing effort
        else if weeklyGoals[i].current > weeklyGoals[i].target {
            Haptic.impact(.medium)
        }

        updateMonthlyProgress()
    }

    /// Decrement a goal's progress
    func decrementProgress(for goalID: UUID) {
        guard let i = weeklyGoals.firstIndex(where: { $0.id == goalID }) else { return }
        guard weeklyGoals[i].current > 0 else { return }
        weeklyGoals[i].current -= 1
        updateMonthlyProgress()
    }

    /// Update the goal target manually
    func updateTarget(for goalID: UUID, to newTarget: Int) {
        guard let index = weeklyGoals.firstIndex(where: { $0.id == goalID }) else { return }
        weeklyGoals[index].target = newTarget
    }

    /// Delete a goal
    func deleteGoal(_ goalID: UUID) {
        weeklyGoals.removeAll(where: { $0.id == goalID })
        Haptic.warning()
    }


    // MARK: - Reset Logic
    func resetWeeklyGoalsIfNeeded() {
        let currentWeekStart = Calendar.current.startOfWeek(for: Date())

        for index in weeklyGoals.indices {
            if weeklyGoals[index].weekStartDate < currentWeekStart {
                weeklyGoals[index].current = 0
                weeklyGoals[index].isCompleted = false
                weeklyGoals[index].weekStartDate = currentWeekStart
            }
        }
    }

    func resetMonthlyGoalsIfNeeded() {
        let currentMonthStart = Calendar.current.startOfMonth(for: Date())

        for index in monthlyGoals.indices {
            if monthlyGoals[index].monthStartDate < currentMonthStart {
                monthlyGoals[index].current = 0
                monthlyGoals[index].isCompleted = false
                monthlyGoals[index].monthStartDate = currentMonthStart
            }
        }
        updateMonthlyProgress() // ✅ keep this
    }


    /// Ensure monthly goals exist for each weekly goal template
    func generateMonthlyGoalsIfNeeded() {
        for weekly in weeklyGoals {
            if !monthlyGoals.contains(where: { $0.templateID == weekly.templateID }) {
                let newMonthlyGoal = MonthlyGoal(templateID: weekly.templateID, target: weekly.target * 4)
                monthlyGoals.append(newMonthlyGoal)
            }
        }
    }

    // MARK: - Data Linking

    /// Aggregate weekly totals into monthly progress
    func updateMonthlyProgress() {
        for index in monthlyGoals.indices {
            let templateID = monthlyGoals[index].templateID
            let totalFromWeeks = weeklyGoals
                .filter { $0.templateID == templateID }
                .reduce(0) { $0 + $1.current }

            let oldProgress = monthlyGoals[index].current
            monthlyGoals[index].current = totalFromWeeks

            // Trigger completion feedback if just reached target
            if !monthlyGoals[index].isCompleted &&
                oldProgress < monthlyGoals[index].target &&
                totalFromWeeks >= monthlyGoals[index].target {
                monthlyGoals[index].isCompleted = true
                Haptic.success()
                currentGoalColor = templateColor(for: monthlyGoals[index])
                completionMessage = "\(templateTitle(for: monthlyGoals[index])) monthly goal completed!"
            }
        }
    }
    
    func updateMonthlyTarget(for goalID: UUID, to newTarget: Int) {
        guard let index = monthlyGoals.firstIndex(where: { $0.id == goalID }) else { return }
        monthlyGoals[index].target = newTarget
    }
    
    func updateNotes(for goalID: UUID, notes: String) {
        guard let index = weeklyGoals.firstIndex(where: { $0.id == goalID }) else { return }
        weeklyGoals[index].notes = notes
    }

    // MARK: - Debug / Sample Data
    private func loadSampleDataIfEmpty() {
        guard weeklyGoals.isEmpty else { return }

        // These pull color + icon from your template library
        let samples = [
            WeeklyGoal(templateID: templates[0].id, target: 7),
            WeeklyGoal(templateID: templates[1].id, target: 5),
            WeeklyGoal(templateID: templates[2].id, target: 7)
        ]

        weeklyGoals.append(contentsOf: samples)
    }
    
    // MARK: - Preferences Struct
    struct UserPreferences {
        var showConfetti: Bool = true
        var showGlow: Bool = true
        var showEncouragements: Bool = true
    }
    
    // MARK: - Template Helpers

    private func templateColor(for goal: WeeklyGoal) -> Color? {
        templates.first(where: { $0.id == goal.templateID })?.color
    }

    private func templateColor(for goal: MonthlyGoal) -> Color? {
        templates.first(where: { $0.id == goal.templateID })?.color
    }

    private func templateTitle(for goal: WeeklyGoal) -> String {
        templates.first(where: { $0.id == goal.templateID })?.title ?? "Goal"
    }

    private func templateTitle(for goal: MonthlyGoal) -> String {
        templates.first(where: { $0.id == goal.templateID })?.title ?? "Goal"
    }

}


