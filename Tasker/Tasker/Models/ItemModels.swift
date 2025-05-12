//
//  ItemModels.swift
//  Tasker
//
//  Created by Paris Phan on 5/12/25.
//

import SwiftData
import Foundation

// MARK: - Project -------------------------------------------------------------

@Model
final class Project {

    @Attribute(.unique) var id: UUID = UUID()      // fully-qualified
    var name: String
    var sortOrder: Int = 0                         // give it a default

    // NOTE: deleteRule comes *first*, inverse second
    @Relationship(deleteRule: .cascade,
                  inverse: \TaskItem.project)
    var tasks: [TaskItem] = []

    init(name: String, sortOrder: Int = 0) {
        self.name = name
        self.sortOrder = sortOrder
    }
}

// MARK: - TaskItem ------------------------------------------------------------

@Model
final class TaskItem {

    @Attribute(.unique) var id: UUID = UUID()
    var title: String
    var completed: Bool = false
    var dueDate: Date? = nil

    // No inverse here – already declared on Project.side
    @Relationship var project: Project? = nil

    init(title: String,
         completed: Bool = false,
         dueDate: Date? = nil,
         project: Project? = nil) {
        self.title = title
        self.completed = completed
        self.dueDate = dueDate
        self.project = project
    }
}
