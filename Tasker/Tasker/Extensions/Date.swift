//
//  Date.swift
//  Tasker
//
//  Created by Paris Phan on 5/12/25.
//

import Foundation

extension Date {
    var isInToday: Bool { Calendar.current.isDateInToday(self) }

    var isInNext7Days: Bool {
        guard let upper = Calendar.current.date(byAdding: .day, value: 7, to: .now) else { return false }
        return self >= .now && self <= upper
    }
}
