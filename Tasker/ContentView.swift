//
//  ContentView.swift
//  Tasker
//
//  Created by Paris Phan on 5/12/25.
//

import SwiftUI

struct ContentView: View {
    @State private var tasks: [Task] = []
    @State private var newTaskTitle: String = ""
    @State private var selection: String? = "Today"
    @State private var newTaskDate: Date = Date()
    
    // Add this computed property to filter tasks
    private var filteredTasks: [Task] {
        guard let selection = selection else { return tasks }
        
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        _ = calendar.date(byAdding: .day, value: 1, to: today)!
        
        switch selection {
        case "Today":
            return tasks.filter { task in
                calendar.isDate(task.date, inSameDayAs: today)
            }
        case "Upcoming":
            return tasks.filter { task in
                task.date > today
            }
        case "All":
            return tasks
        default:
            return tasks
        }
    }
    
    var body: some View {
        NavigationSplitView {
            // Sidebar
            List(selection: $selection) {
                Section("Tasks") {
                    NavigationLink(value: "Today") {
                        Label("Today", systemImage: "star")
                    }
                    NavigationLink(value: "Upcoming") {
                        Label("Upcoming", systemImage: "calendar")
                    }
                    NavigationLink(value: "All", label: {
                        Label("All", systemImage: "tray")
                    })
                }
            }
            .listStyle(.sidebar)
        } detail: {
            // Main content area
            VStack {
                List {
                    ForEach(filteredTasks) { task in
                        HStack {
                            Image(systemName: task.isCompleted ? "checkmark.circle.fill" : "circle")
                                .foregroundColor(task.isCompleted ? .blue : .gray)
                                .onTapGesture {
                                    if let index = tasks.firstIndex(where: { $0.id == task.id }) {
                                        tasks[index].isCompleted.toggle()
                                    }
                                }
                            Text(task.title)
                                .strikethrough(task.isCompleted)
                        }
                    }
                }
                
                // New task input
                HStack {
                    Image(systemName: "plus.circle")
                        .foregroundColor(.blue)
                        .onTapGesture {
                            if !newTaskTitle.isEmpty {
                                tasks.append(Task(title: newTaskTitle, isCompleted: false, date: newTaskDate))
                                newTaskTitle = ""
                                newTaskDate = Date()  // Reset date to current date
                            }
                        }
                    TextField("Add a task...", text: $newTaskTitle)
                        .textFieldStyle(.plain)
                    DatePicker("", selection: $newTaskDate, displayedComponents: .date)
                        .labelsHidden()
                }
                .padding()
            }
        }
    }
}

#Preview {
    ContentView()
}
