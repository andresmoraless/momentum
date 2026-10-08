import SwiftUI

struct TimeBlock: Identifiable, Equatable {
    let id = UUID()
    var title: String
    var startHour: Double
    var endHour: Double
    var color: Color
    var date: Date
    var repeatOption: RepeatOption = .never
    var durationHours: Double { endHour - startHour }
}


