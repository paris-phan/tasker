//
//  PrimarySidebar.swift
//  Tasker
//
//  Created by Paris Phan on 5/12/25.
//

import SwiftUI
import SwiftData

//  Sources/Views/PrimarySidebar.swift
enum PrimaryItem: String, CaseIterable, Identifiable {
    case today, next7, inbox, completed, trash
    var id: Self { self }

    var label: some View {
        switch self {
        case .today:     Label("Today", systemImage: "calendar")
        case .next7:     Label("Next 7 Days", systemImage: "calendar.circle")
        case .inbox:     Label("Inbox", systemImage: "tray")
        case .completed: Label("Completed", systemImage: "checkmark.circle")
        case .trash:     Label("Trash", systemImage: "trash")
        }
    }
}

struct PrimarySidebar: View {
    @Binding var selection: PrimaryItem?
    var body: some View {
        List(selection: $selection) {
            ForEach(PrimaryItem.allCases) { item in
                item.label
                    .tag(item)                     // must tag!
            }
        }
        .listStyle(.sidebar)
    }
}
