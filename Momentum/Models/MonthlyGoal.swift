import Foundation

struct MonthlyGoal: Identifiable, Codable, Equatable {
    let id: UUID
    let templateID: UUID
    var current: Int              // total progress (aggregated from weekly goals)
    var target: Int
    var monthStartDate: Date
    var notes: String
    var isCompleted: Bool = false

    // MARK: - Derived properties
    var progressRatio: Double {
        guard target > 0 else { return 0 }
        return Double(current) / Double(target)
    }

    // Dynamically look up the title using the template
    var title: String {
        GoalTemplate.all.first(where: { $0.id == templateID })?.title ?? "Goal"
    }

    // MARK: - Initialization
    init(templateID: UUID, target: Int, notes: String = "") {
        self.id = UUID()
        self.templateID = templateID
        self.current = 0
        self.target = target
        self.monthStartDate = Calendar.current.startOfMonth(for: Date())
        self.notes = notes
    }

    // MARK: - Helper
    func template(from templates: [GoalTemplate]) -> GoalTemplate? {
        templates.first(where: { $0.id == templateID })
    }
}



