//
//  Task.swift
//  Tasker
//
//  Created by Paris Phan on 6/8/25.
//

import Foundation
import SwiftData

@Model                      // the macro that makes this class a SwiftData-managed model
final class Task {
    // MARK: - Stored properties the framework persists
    var title: String
    var isCompleted: Bool
    var date: Date

    // MARK: - Designated initializer
    /// SwiftData requires an `init` so you can supply default values
    /// *and* so the macro can synthesise the dynamic members it needs.
    init(title: String,
         isCompleted: Bool = false,
         date: Date = .now) {
        self.title       = title
        self.isCompleted = isCompleted
        self.date        = date
    }

    // MARK: - Convenience / computed properties (not stored, so not persisted)
    var formattedDate: String {
        date.formatted(date: .long, time: .shortened)
    }
}
