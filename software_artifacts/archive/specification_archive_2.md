Below is a **software\_description.md** document that consolidates everything we have discussed so far about the “Task Planner macOS App”.
You could copy-paste this into a new `software_description.md` file and have every detail needed to recreate the project from scratch.

---

# Task Planner macOS App – Software Description

## 1  Purpose & Vision

A native macOS productivity application that unifies **task management** (à-la Todoist) and **time-blocking / calendar scheduling** (à-la Akiflow) in one streamlined interface.
The app targets users who live entirely inside the Apple ecosystem and want a **fast, keyboard-friendly, no-compromise** alternative to web-centric tools.

---

## 2  Goals

| Area               | Goal                                                                                                                                                                                                                                                                                                                                                |
| ------------------ | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| **Platform**       | Ship **macOS-only** (first release macOS 13 Ventura+, Apple-silicon-first).                                                                                                                                                                                                                                                                         |
| **Experience**     | • Instant local DB performance<br>• Two-pane & three-pane navigation familiar to macOS apps (Mail, Notes).<br>• Deep macOS integration: system-wide Quick Add, Notification Center, drag-&-drop from Calendar/Reminders.                                                                                                                            |
| **Data**           | • Rich offline store using **SwiftData**.<br>• Seamless sync via **CloudKit**.<br>• Future gateway for iOS companion.                                                                                                                                                                                                                               |
| **Feature set v1** | • Projects / Areas with arbitrary hierarchy.<br>• Tasks with subtasks, rich notes (Markdown), attachments, tags, priority, estimate.<br>• Kanban & list views.<br>• Calendar view & “Time-block” drag-to-schedule.<br>• Natural-language Quick Add (“tomorrow 4-6pm pay rent”).<br>• Inbox & Smart Filters (Today, Upcoming, Overdue, Tag filters). |
| **Quality**        | • 100 % SwiftUI, modern C-style concurrency.<br>• Unit + UI tests (XCTest & XCUITest).<br>• Modular, MVVM-ish architecture (= View ⭢ ViewModel ⭢ Model).                                                                                                                                                                                            |

---

## 3  High-Level Architecture

```text
TaskPlannerApp/
│
├─ App/                         ← @main entry, Scene/Window configuration
│
├─ Core/                        ← Non-UI modules
│   ├─ Models/                  ← SwiftData model files
│   ├─ Services/
│   │   ├─ Persistence/         ← SwiftData + CloudKit stack
│   │   ├─ CalendarBridge/      ← EventKit wrapper
│   │   └─ NotificationCenter/  ← Local notifications
│   └─ Utilities/
│
├─ Features/
│   ├─ Tasks/                   ← List, Detail, QuickAdd
│   ├─ Calendar/                ← Time-blocking board
│   ├─ Projects/                ← Sidebar hierarchy
│   └─ Settings/
│
├─ SharedUI/                    ← Re-usable SwiftUI components
│
├─ Resources/
│   └─ Assets, Localization, Launch Screen
│
└─ Tests/
    ├─ Unit/
    └─ UI/
```

Key patterns:

* **NavigationSplitView** (Sidebar → Task list → Detail).
* **Observable** ViewModels feeding SwiftUI views.
* **Dependency Injection** via Environment or static builders for testability.

---

## 4  Data Model (SwiftData ↔ DBML)

```dbml
Table project {
  id              uuid        [pk]
  parent_id       uuid        [ref: > project.id]
  name            varchar
  color           varchar
  sort_order      int
  is_archived     bool
  created_at      datetime
  updated_at      datetime
}

Table task {
  id              uuid        [pk]
  project_id      uuid        [ref: > project.id]
  parent_id       uuid        [ref: - task.id]     // subtasks
  title           varchar
  notes_md        text
  due_at          datetime
  scheduled_start datetime
  scheduled_end   datetime
  priority        int         // 1-4
  estimate_min    int
  is_done         bool
  created_at      datetime
  updated_at      datetime
}

Table tag {
  id              uuid        [pk]
  name            varchar
  color           varchar
}

Table task_tag {                 // m:n pivot
  task_id         uuid           [ref: > task.id]
  tag_id          uuid           [ref: > tag.id]
  [primary] task_id, tag_id
}
```

SwiftData annotations mirror the above; all `id` fields are declared `@Attribute(.unique)`.

---

## 5  Key Functional Requirements

### 5.1  Core Task Flow

| Step       | Requirement                                                                                                                     |
| ---------- | ------------------------------------------------------------------------------------------------------------------------------- |
| *Create*   | Cmd-N or ⌥Space Quick-Add window; supports natural-language parsing of dates (“Mon 2 pm”).                                      |
| *Organize* | Drag tasks between Projects; multi-select; tags with autocompletion.                                                            |
| *Schedule* | Drag a task onto Calendar view → fills `scheduled_start/end`; resizes update duration.                                          |
| *Complete* | Cmd-✔ or swipe. When parent task complete, prompt to auto-complete children.                                                    |
| *Sync*     | All changes stored in SwiftData; CloudKit sync in background with conflict resolution “last-writer-wins + merge subtasks list”. |

### 5.2  Navigation & UI

* **Sidebar**

  * Hierarchical Projects (fold/unfold)
  * Smart Sections: Inbox, Upcoming, Today, Tag-based filters
* **Main Pane** (List / Kanban)

  * Sort, Group (tag/priority), Inline edit
* **Detail Inspector**

  * Rich-text Markdown editor, attachment drop-zone
  * Timeline of changes (CoreData history)
* **Calendar Pane**

  * Day / Week toggle, vertically scrolling hours
  * Overlay of macOS Calendar events (read-only), user setting to hide/show

### 5.3  System Integration

| macOS API                  | Usage                                                        |
| -------------------------- | ------------------------------------------------------------ |
| **EventKit**               | Read user calendars → show overlay, prevent double-booking   |
| **NotificationCenter**     | Schedule local notification at `due_at-notificationLeadTime` |
| **UserActivity / Handoff** | Resume editing on another Mac (future iOS)                   |
| **AppShortcuts**           | Siri: “Add task … to TaskPlanner”                            |

---

## 6  Non-Functional Requirements

| Category          | Spec                                                                 |
| ----------------- | -------------------------------------------------------------------- |
| **Performance**   | Cold start < 2 s on M-series. List scrolling 60 fps on 10k tasks.    |
| **Security**      | All data remains in user iCloud zone; no third-party backend.        |
| **Privacy**       | Zero analytics by default; optional opt-in.                          |
| **Accessibility** | VoiceOver labels, Dynamic Type, high-contrast asset variants.        |
| **Localization**  | English base; strings in `.stringsdict`; easy community translation. |
| **Licensing**     | AGPL or MIT (decide before launch; discussions pending).             |

---

## 7  Development Environment

| Tool               | Minimum Version  | Purpose                          |
| ------------------ | ---------------- | -------------------------------- |
| **Xcode**          | 15               | Swift 5.9, SwiftData             |
| **SwiftLint**      | 0.55             | Code-style enforcement           |
| **Mint**           | latest           | Bootstrap command-line tools     |
| **Fastlane**       | 2.220            | CI/CD (unit tests, notarization) |
| **GitHub Actions** | macOS-14 runners | CI matrix (Debug/Release)        |

### Repository Naming

* **Suggested repo**: `taskplanner-macos`

  * Main branch: `main`
  * Conventional Commits (`feat:`, `fix:`, `chore:`).

---

## 8  Build & Run

```bash
git clone https://github.com/your-org/taskplanner-macos.git
mint bootstrap           # installs swiftlint etc.
open TaskPlanner.xcodeproj
```

1. Ensure you are signed in to Xcode with a Developer ID & iCloud-capable team.
2. Select **My Mac (Designed for \[Your Mac])** scheme → Run.
3. For CloudKit, in Xcode > Signing & Capabilities, enable **iCloud (CloudKit)**.

---

## 9  Testing Strategy

| Layer     | Framework           | Notes                                                                          |
| --------- | ------------------- | ------------------------------------------------------------------------------ |
| Model     | XCTest              | CRUD round-trip, custom merge policies                                         |
| ViewModel | Combine-await tests | time-travel scheduler                                                          |
| UI        | XCUITest            | happy path: add-schedule-complete-sync; accessibility identifiers on list rows |

QA checklist lives in `/Tests/QA-Checklist.md`.

---

## 10  Future Roadmap (post-v1)

* **Keyboard-first “Command Palette”.**
* **Focus Mode** (Pomodoro overlay).
* **Obsidian-style back-links between tasks (“reference graph” view).**
* **SharePlay for pair planning.**
* **iOS & visionOS ports** reusing Core layer.

---

## 11  Appendices

### 11.1  Glossary

| Term           | Meaning                                            |
| -------------- | -------------------------------------------------- |
| **Area**       | Long-term bucket (e.g. “Health”, “Work”).          |
| **Project**    | Finite goal with deadline (e.g. “WWDC Talk Prep”). |
| **Task**       | Actionable item; may have subtasks.                |
| **Time-block** | Calendar slot where a Task is planned to occur.    |

### 11.2  Design Reference Links

* Apple Human Interface Guidelines – macOS
* WWDC 23: Architecting with SwiftData
* WWDC 24: Advanced NavigationSplitView Patterns

---

*End of software\_description.md*
