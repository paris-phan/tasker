//
//  ContentView.swift
//  TaskItemer
//
//  Created by Paris Phan on 5/12/25.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var tasks: [TaskItem]

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
                .onDelete(perform: deleteTaskItems)
            }
            .navigationSplitViewColumnWidth(min: 180, ideal: 200)
            .toolbar {
                ToolbarItem {
                    Button(action: addTaskItem) {
                        Label("Add TaskItem", systemImage: "plus")
                    }
                }
            }
        } detail: {
            Text("easdf")
        }
    }

    private func addTaskItem() {
//        withAnimation {
//            let newTaskItem = TaskItem(title: "New TaskItem")
//            modelContext.insert(newTaskItem)
//        }
    }

    private func deleteTaskItems(offsets: IndexSet) {
        withAnimation {
            for index in offsets {
                modelContext.delete(tasks[index])
            }
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: TaskItem.self, inMemory: true)
}
