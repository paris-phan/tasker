//
//  TaskerApp.swift
//  Tasker
//
//  Created by Paris Phan on 5/12/25.
//

import SwiftUI
import SwiftData

@main
struct TaskerApp: App {
    @State private var primarySelection: PrimaryItem?
    @State private var secondarySelection: Project?
    
    
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            TaskItem.self,
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            NavigationSplitView {
                PrimarySidebar(selection: $primarySelection)
                    .frame(minWidth: 56, idealWidth: 64, maxWidth: 72)   // skinny icon bar
            } content: {
                SecondarySidebar(selection: $secondarySelection,
                                 primarySelection: primarySelection)
                    .frame(minWidth: 200, idealWidth: 220)              // lists / filters
            } detail: {
                TaskListView(project: secondarySelection,
                             primarySelection: primarySelection)
            }
            .navigationSplitViewStyle(.balanced)
        }
        .modelContainer(sharedModelContainer)
    }
}
