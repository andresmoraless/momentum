// Date+Extensions.swift
import Foundation

extension Calendar {
    func startOfWeek(for date: Date) -> Date {
        dateComponents([.yearForWeekOfYear, .weekOfYear], from: date).date ?? date
    }

    func startOfMonth(for date: Date) -> Date {
        dateComponents([.year, .month], from: date).date ?? date
    }
}


