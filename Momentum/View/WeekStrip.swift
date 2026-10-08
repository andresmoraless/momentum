//
//  WeekStrip.swift
//  Momentum
//
//  Created by andres morales on 8/10/25.
//

// Views/Week/WeekStrip.swift
import SwiftUI

struct WeekStrip: View {
    @Binding var selectedDay: Date

    private var days: [Date] {
        let start = selectedDay.startOfWeek
        return (0..<7).map { start.addingDays($0) }
    }

    var body: some View {
        HStack(spacing: 0) {
            Button { selectedDay = selectedDay.addingDays(-7) } label: {
                Image(systemName: "chevron.left")
            }
            Spacer(minLength: 0)

            ForEach(days, id: \.self) { day in
                VStack(spacing: 2) {
                    Text(weekdayLetter(day)).font(.caption2)
                    Button {
                        selectedDay = day
                    } label: {
                        Text(dayNumber(day))
                            .padding(8)
                            .background(
                                Calendar.current.isDate(day, inSameDayAs: selectedDay)
                                ? Circle().fill(.primary.opacity(0.15))
                                : nil
                            )
                    }
                }
                .frame(maxWidth: .infinity)
            }

            Spacer(minLength: 0)
            Button { selectedDay = selectedDay.addingDays(7) } label: {
                Image(systemName: "chevron.right")
            }
        }
        .padding(.horizontal)
        .padding(.vertical, 6)
    }

    private func weekdayLetter(_ d: Date) -> String {
        let f = DateFormatter(); f.dateFormat = "E"         // Mon, Tue, ...
        return String(f.string(from: d).prefix(1))          // M, T, W, ...
    }
    private func dayNumber(_ d: Date) -> String {
        let f = DateFormatter(); f.dateFormat = "d"         // 1..31
        return f.string(from: d)
    }
}

