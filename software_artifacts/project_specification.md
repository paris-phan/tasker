# TaskPlanner for macOS – **Unified Project Specification**

*This document serves as the single authoritative reference for all TaskPlanner stakeholders.*

---

## 1  Purpose & Vision

A native **macOS-only** productivity app that fuses **task management** and **calendar-style time-blocking** into one fast, keyboard-centric experience for Apple-ecosystem users. The app stores everything locally with **SwiftData** and syncs transparently via **CloudKit**—no external servers or trackers.

---

## 2  Platform Targets & Experience Goals

| Area              | Decision                                                                       | Rationale                               |
| ----------------- | ------------------------------------------------------------------------------ | --------------------------------------- |
| **Minimum macOS** | **macOS 14 Sonoma+** (Apple-silicon-first; Rosetta-based Intel build allowed) | SwiftData availability & modern APIs    |
| **UI**            | 100% SwiftUI + @Observable; **NavigationSplitView** three-pane pattern        | Native look, consistent with Mail/Notes |
| **Performance**   | Cold start < 2s; 60 fps scrolling with 10k tasks; < 100MB memory baseline     | Meet pro-user expectations              |
| **Privacy**       | Data remains in user's private CloudKit zone; **no analytics by default**     | App Store "No tracking" compliance      |
| **Accessibility** | VoiceOver, Dynamic Type, High-Contrast, full keyboard control                 | First-class citizen for all users       |

---

## 3  High-Level Architecture

```text
TaskPlanner/
│
├─ App/                     @main entry, Scene/Window/Commands
│   └─ MenuBarExtra/        Status bar quick-add component
├─ Core/
│   ├─ Models/              SwiftData entity definitions (@Model)
│   ├─ Services/
│   │   ├─ DataStore/       SwiftData ModelContainer & ModelContext
│   │   ├─ CloudSync/       CloudKit integration & conflict resolution
│   │   ├─ CalendarKit/     EventKit wrapper (read-only overlay)
│   │   └─ Notifications/   UNUserNotificationCenter wrapper
│   └─ Utils/
│       └─ NetworkMonitor/  NWPathMonitor for sync status
├─ Features/
│   ├─ Tasks/               Inbox, List, Kanban, Detail, QuickAdd
│   ├─ Calendar/            Day/Week time-blocking board
│   ├─ Projects/Areas/      Sidebar hierarchy & Smart Filters
│   └─ Settings/            Preferences & sync status
├─ SharedUI/                Reusable SwiftUI components & modifiers
├─ Widgets/                 WidgetKit extension target
└─ Tests/
    ├─ Unit/                Model & ViewModel tests (XCTest)
    ├─ Integration/         CloudKit sync tests
    └─ UI/                  End-to-end flows (XCUITest)
```

*Patterns*: 
- MVVM with `@Observable` macro for ViewModels
- Dependency injection via SwiftUI `@Environment` custom values
- Protocol-oriented services for testability

---

## 4  Data Model (SwiftData Schema)

```swift
// Conceptual representation - actual implementation uses @Model classes

@Model class Project {
    @Attribute(.unique) let id: UUID
    var parent: Project?
    var name: String
    var color: String
    var children: [Project]
    var tasks: [Task]
}

@Model class Task {
    @Attribute(.unique) let id: UUID
    var project: Project?
    var parent: Task?
    var title: String
    var notesMarkdown: String?
    var dueDate: Date?
    var scheduledStart: Date?
    var scheduledEnd: Date?
    var priority: TaskPriority
    var estimatedMinutes: Int?
    var recurrenceRule: String? // RFC 5545
    var isCompleted: Bool
    var completedAt: Date?
    var tags: [Tag]
    var subtasks: [Task]
}

@Model class Tag {
    @Attribute(.unique) let id: UUID
    var name: String
    var color: String
    var tasks: [Task]
}
```

---

## 5  Functional Requirements (v1.0)

| ID       | Title                             | Description & Notes                                                                           |
| -------- | --------------------------------- | --------------------------------------------------------------------------------------------- |
| **F-1**  | **Quick Add Task**                | `⌥Space` global hotkey or Menu Bar Extra; natural-language parsing ("Tue 2-4pm review PR")   |
| **F-2**  | **Edit / Delete / Complete Task** | Full CRUD; visual completion state; cascade completion prompt for subtasks                    |
| **F-3**  | **Recurring Tasks**               | Daily/weekly/monthly/custom; skip/reschedule/edit single occurrence                           |
| **F-4**  | **Projects & Areas Sidebar**      | Unlimited nesting; drag-drop reorganization; distinct Area vs Project semantics               |
| **F-5**  | **Drag-&-Drop Time-Blocking**     | Bidirectional: Task ↔ Calendar; live duration preview; snap-to-grid (15min)                  |
| **F-6**  | **Auto-Schedule (Fill My Day)**   | ML-based prioritization placing tasks in gaps; respects focus hours & energy levels           |
| **F-7**  | **Search & Smart Filters**        | FTS5-powered search; saved filters; natural language ("overdue high priority")                |
| **F-8**  | **Notifications**                 | Configurable: due date, block start, persistent reminders; DND respect                        |
| **F-9**  | **iCloud Sync**                   | Real-time CloudKit; field-level conflict resolution; offline queue                            |
| **F-10** | **Widgets (WidgetKit)**           | Timeline-based refresh; deep-linking to tasks; multiple sizes                                |
| **F-11** | **Siri Shortcuts / App Intents**  | Parameter-driven intents: Add task with details, Show specific project                        |
| **F-12** | **Import / Export**               | Lossless JSON; CSV with field mapping; calendar .ics bidirectional                            |
| **F-13** | **Multiple Views**                | Kanban board, hierarchical list, calendar, Gantt (future consideration)                       |

---

## 6  Non-Functional Requirements

| Category            | Specification                                                                                        |
| ------------------- | ---------------------------------------------------------------------------------------------------- |
| **Performance**     | Launch < 2s; 60fps UI; < 100MB baseline memory; background sync < 5% CPU                            |
| **Reliability**     | Zero data loss via write-ahead logging; automatic CloudKit retry with exponential backoff            |
| **Security**        | CloudKit encryption in transit/rest; Keychain for tokens; no third-party analytics                  |
| **Usability**       | All actions keyboard-accessible; gesture consistency with macOS; undo/redo for all operations       |
| **Maintainability** | 80% test coverage; comprehensive DocC; modular architecture; SwiftLint enforcement                  |
| **Scalability**     | Handle 10k+ tasks; CloudKit quota monitoring with user warnings                                     |
| **Localization**    | Base English; String catalogs prepared; RTL-ready layouts                                           |
| **Licensing**       | MIT License                                                                                          |

---

## 7  Development Environment & Build

| Tool          | Version  | Purpose                          | Installation                      |
| ------------- | -------- | -------------------------------- | --------------------------------- |
| **Xcode**     | 15.0+    | IDE, Swift 5.9+, SwiftData      | Mac App Store                     |
| **SwiftLint** | 0.55.0+  | Code style enforcement           | Homebrew or SPM build plugin      |
| **Git**       | 2.39+    | Version control                  | Xcode Command Line Tools          |

### Build Process

```bash
# Clone repository
git clone https://github.com/your-org/taskplanner-macos.git
cd taskplanner-macos

# Install SwiftLint (if using Homebrew)
brew install swiftlint

# Open in Xcode
open TaskPlanner.xcodeproj

# Configure (one-time)
# 1. Select your development team in Signing & Capabilities
# 2. Enable CloudKit capability
# 3. Create CloudKit container (automatic)

# Build and run
# Use Xcode GUI or: xcodebuild -scheme TaskPlanner build
```

### CI/CD

- **GitHub Actions** for automated testing and building
- **xcodebuild** for command-line builds
- **notarytool** for direct notarization (no Fastlane needed)

---

## 8  Testing Strategy

| Type              | Scope                          | Tools & Approach                                                      |
| ----------------- | ------------------------------ | --------------------------------------------------------------------- |
| **Unit Tests**    | Models, ViewModels, Services   | XCTest; in-memory ModelContainer; dependency injection               |
| **Integration**   | CloudKit sync, EventKit        | XCTest with timeouts; mock CloudKit container for deterministic tests |
| **UI Tests**      | Critical user journeys         | XCUITest; accessibility identifiers; snapshot testing                |
| **Performance**   | Launch time, memory, scrolling | XCTest metrics; Instruments profiling                                |

### Key Test Scenarios
- Create → Schedule → Complete → Sync task flow
- Offline task creation → online sync reconciliation  
- Concurrent edit conflict resolution
- 10k task performance benchmarks

---

## 9  CloudKit Sync Details

### Conflict Resolution Strategy
1. **Field-level comparison** using CKRecord change tags
2. **Smart merging**:
   - Title/notes: interactive 3-way merge UI
   - Dates/times: most recent change wins
   - Completion: true state wins (prevents undoing completion)
   - Subtasks: union of changes
3. **User notification** for non-automatic resolutions

### Quota Management
- Monitor CKContainer quotas via CKDatabase
- Warn at 80% capacity
- Implement data archiving for completed tasks > 1 year

---

## 10  Future Roadmap (Post-v1.0)

| Feature                  | Priority | Notes                                          |
| ------------------------ | -------- | ---------------------------------------------- |
| Command Palette (⌘K)     | High     | Spotlight-like universal actions               |
| Focus Mode / Pomodoro    | High     | Time-boxing with break reminders               |
| Task Dependencies        | Medium   | Gantt view, critical path                      |
| Natural Language Dates   | Medium   | "next Tuesday", "in 2 weeks"                   |
| iOS Companion App        | Medium   | Shared Core module, SwiftUI                    |
| Team Collaboration       | Low      | SharePlay for planning sessions                |
| AI Task Suggestions      | Low      | Core ML for smarter auto-scheduling            |

---

## 11  Glossary

| Term              | Definition                                                      |
| ----------------- | --------------------------------------------------------------- |
| **Area**          | Ongoing responsibility without end date (e.g., "Health")        |
| **Project**       | Multi-task outcome with defined completion                      |
| **Task**          | Single actionable item; may have subtasks                      |
| **Time Block**    | Calendar slot with assigned task(s)                             |
| **Smart Filter**  | Saved search query with dynamic results                         |
| **Natural Parse** | Converting "tomorrow 3pm" → structured date/time                |

---

### Revision Notes

- **Removed Mint**: SwiftLint now installed directly via Homebrew or SPM
- **Removed Fastlane**: Simplified to native Apple tools (xcodebuild, notarytool)
- **Added CloudKit sync details**: Specific conflict resolution and quota handling
- **Enhanced architecture**: Explicit MenuBarExtra location and network monitoring
- **Clarified data model**: SwiftData @Model representation instead of SQL-like DBML
- **Added performance metrics**: Memory usage targets and sync CPU limits
- **Specified test categories**: Added integration and performance testing
- **Detailed build process**: Step-by-step without unnecessary tooling

*End of Revised Specification*