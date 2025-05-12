//
//  SecondarySidebar.swift
//  Tasker
//
//  Created by Paris Phan on 5/12/25.
//

import SwiftUI
import SwiftData

struct SecondarySidebar: View {
    @Binding var selection: Project?
    let primarySelection: PrimaryItem?
    @Query(sort: \Project.sortOrder) private var projects: [Project]
    
    var body: some View {
        List(selection: $selection) {
            // Dynamically swap sections based on the leftmost icon
            switch primarySelection {
            case .today, .next7, .inbox:
                Section("Lists") {
                    ForEach(projects) { p in
                        Label(p.name, systemImage: "folder")
                    }
                }
            case .completed:
                Section("Completed Tasks") { /* … */ }
            case .trash:
                Section("Trash") { /* … */ }
            case .none:
                EmptyView()
            }
        }
        .listStyle(.sidebar)
        .toolbar {                      // + / edit buttons, etc.
            ToolbarItem { Button(action: addProject) { Image(systemName: "plus") } }
        }
    }
    
    private func addProject() { /* insert into SwiftData */ }
}
