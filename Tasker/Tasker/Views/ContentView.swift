//
//  ContentView.swift
//  Tasker
//
//  Created by Paris Phan on 5/12/25.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var tasks: [Task]

    var body: some View {
        NavigationSplitView {
            List {
                ForEach(tasks) { task in
                    NavigationLink {
                        Text(task.title)
                    } label: {
                        HStack {
                            Text(task.title)
                            Spacer()
                            if let dueDate = task.dueDate {
                                Text(dueDate, format: .dateTime)
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                }
                .onDelete(perform: deleteTasks)
            }
            .navigationSplitViewColumnWidth(min: 180, ideal: 200)
            .toolbar {
                ToolbarItem {
                    Button(action: addTask) {
                        Label("Add Task", systemImage: "plus")
                    }
                }
            }
        } detail: {
            Text("easdf")
        }
    }

    private func addTask() {
        withAnimation {
            let newTask = Task(title: "New Task")
            modelContext.insert(newTask)
        }
    }

    private func deleteTasks(offsets: IndexSet) {
        withAnimation {
            for index in offsets {
                modelContext.delete(tasks[index])
            }
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: Task.self, inMemory: true)
}
