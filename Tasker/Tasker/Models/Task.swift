//
//  ContentView.swift
//  Tasker
//
//  Created by Paris Phan on 5/12/25.
//

import Foundation
import SwiftData

@Model
final class Task {
    var title: String
    var taskDescription: String
    var createdAt: Date
    var dueDate: Date?
    var isCompleted: Bool
    var priority: Priority
    
    enum Priority: Int, Codable {
        case low = 0
        case medium = 1
        case high = 2
    }
    
    init(title: String, taskDescription: String = "", dueDate: Date? = nil, priority: Priority = .medium) {
        self.title = title
        self.taskDescription = taskDescription
        self.createdAt = Date()
        self.dueDate = dueDate
        self.isCompleted = false
        self.priority = priority
    }
}
