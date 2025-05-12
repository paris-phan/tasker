//
//  TaskListView.swift
//  Tasker
//
//  Created by Paris Phan on 5/12/25.
//

import SwiftUI
import SwiftData

struct TaskToolbar: ToolbarContent {
    let project: Project?
    var body: some ToolbarContent {
        ToolbarItem { Button { addTask() } label: { Image(systemName: "plus") } }
    }
    private func addTask() {
        // TODO: Insert a blank TaskItem into SwiftData
    }
}


struct TaskListView: View {
    @Environment(\.modelContext) private var ctx

    let project: Project?
    let primarySelection: PrimaryItem?

    // ------------------------------------------------------------------
    // 1️⃣ SwiftData query – will be assigned in init(…)
    // ------------------------------------------------------------------
    @Query private var tasks: [TaskItem]

    // ------------------------------------------------------------------
    // 2️⃣ Custom initialiser decides which query to run
    // ------------------------------------------------------------------
    init(project: Project?, primarySelection: PrimaryItem?) {
        self.project          = project
        self.primarySelection = primarySelection

        switch primarySelection {
        case .today:
            _tasks = Query(
                filter: #Predicate { $0.dueDate?.isInToday ?? false },
                sort:   \TaskItem.dueDate
            )

        case .next7:
            _tasks = Query(
                filter: #Predicate { $0.dueDate?.isInNext7Days ?? false },
                sort:   \TaskItem.dueDate
            )

        default: _tasks = Query(sort: \TaskItem.dueDate)
//            if let p = project {
//                let filterProject: Project? = p        // ← no global functions
//                _tasks = Query(
//                    filter: #Predicate { $0.project == filterProject },
//                    sort:   \TaskItem.dueDate
//                )
//            } else {
//                _tasks = Query(sort: \TaskItem.dueDate)
//            }
        }
    }

    // ------------------------------------------------------------------
    // 3️⃣ UI
    // ------------------------------------------------------------------
    var body: some View {
        Table(tasks, selection: .constant(nil)) {

            TableColumn(" ", content: { task in
                Image(systemName: task.completed
                                 ? "checkmark.circle.fill"
                                 : "circle")
                    .foregroundStyle(.secondary)
                    .onTapGesture { task.completed.toggle() }
            })
            .width(20)

            TableColumn("Title") { task in Text(task.title) }

            TableColumn("Due")   { task in
                Text(task.dueDate ?? Date(), style: .date)
            }
        }
        .navigationTitle(titleText)
        .toolbar { TaskToolbar(project: project) }
    }

    private var titleText: String {
        switch primarySelection {
        case .today: "Today"
        case .next7: "Next 7 Days"
        default:     project?.name ?? "Tasks"
        }
    }
}
