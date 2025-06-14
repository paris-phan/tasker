# TaskPlanner for macOS – **Unified Project Specification**

*This document merges, deduplicates, and reconciles the earlier **Software Description** and **SRS v1.0** into a single authoritative reference for all stakeholders.*

---

## 1  Purpose & Vision

A native **macOS‑only** productivity app that fuses **task management** and **calendar‑style time‑blocking** into one fast, keyboard‑centric experience for Apple‑ecosystem users. The app stores everything locally with **SwiftData** and syncs transparently via **CloudKit**—no external servers or trackers.

---

## 2  Platform Targets & Experience Goals

| Area              | Decision                                                                       | Rationale                               |
| ----------------- | ------------------------------------------------------------------------------ | --------------------------------------- |
| **Minimum macOS** | **macOS 14 Sonoma+** (Apple‑silicon‑first; Rosetta‑based Intel build allowed)  | SwiftData availability & modern APIs    |
| **UI**            | 100 % SwiftUI + modern concurrency; **NavigationSplitView** three‑pane pattern | Native look, consistent with Mail/Notes |
| **Performance**   | Cold start < 2 s; 60 fps scrolling with 10 k tasks                             | Meet pro‑user expectations              |
| **Privacy**       | Data remains in user’s private CloudKit zone; **no analytics by default**      | App Store “No tracking” compliance      |
| **Accessibility** | VoiceOver, Dynamic Type, High‑Contrast, full keyboard control                  | First‑class citizen for all users       |

---

## 3  High‑Level Architecture

```text
TaskPlanner/
│
├─ App/                  @main entry, Scene/Window/Commands
├─ Core/
│   ├─ Models/           SwiftData entity definitions
│   ├─ Services/
│   │   ├─ Persistence/  SwiftData + CloudKit stack
│   │   ├─ CalendarKit/  EventKit wrapper (read‑only overlay)
│   │   └─ Notifications/Local notifications
│   └─ Utils/
├─ Features/
│   ├─ Tasks/            Inbox, List, Kanban, Detail, QuickAdd
│   ├─ Calendar/         Day/Week time‑blocking board
│   ├─ Projects/Areas/   Sidebar hierarchy & Smart Filters
│   └─ Settings/
├─ SharedUI/             Re‑usable SwiftUI components & modifiers
└─ Tests/                Unit (XCTest) & UI (XCUITest)
```

*Patterns*: MVVM‑ish (`Observable` ViewModels), dependency injection via environment, modular target structure for CI.

---

## 4  Data Model (SwiftData ↔ DBML excerpt)

```
Table project  { id uuid [pk]; parent_id uuid [ref: > project.id]; name varchar; … }
Table task     { id uuid [pk]; project_id uuid [ref: > project.id]; parent_id uuid […]; title varchar; notes_md text; due_at datetime; scheduled_start/end datetime; priority int; estimate_min int; recurrence_rule text; is_done bool; … }
Table tag      { id uuid [pk]; name varchar; color varchar }
Table task_tag { task_id uuid [ref: > task.id]; tag_id uuid [ref: > tag.id]; [primary] task_id, tag_id }
```

All IDs are `@Attribute(.unique)`. A **recurrence\_rule** column (RFC 5545‑style) supports repeating tasks—added from SRS.

---

## 5  Functional Requirements (v 1.0)

| ID       | Title                             | Description & Notes                                                                       |
| -------- | --------------------------------- | ----------------------------------------------------------------------------------------- |
| **F‑1**  | **Quick Add Task**                | `⌥Space` pop‑up or **Menu‑Bar Extra**; natural‑language parsing (“Tue 2‑4 pm review PR”). |
| **F‑2**  | **Edit / Delete / Complete Task** | Full CRUD; strikethrough & checkmark on completion; prompt to auto‑complete children.     |
| **F‑3**  | **Recurring Tasks**               | Daily/weekly/monthly with skip/modify instance.                                           |
| **F‑4**  | **Projects & Areas Sidebar**      | Arbitrary hierarchy; collapsible; color coding.                                           |
| **F‑5**  | **Drag‑&‑Drop Time‑Blocking**     | Task → Calendar converts to `scheduled_start/end`; resizing updates duration.             |
| **F‑6**  | **Auto‑Schedule (Fill My Day)**   | Optional heuristic placing overdue/high‑priority tasks into free calendar gaps.           |
| **F‑7**  | **Search & Smart Filters**        | Instant search, tag filters, Today / Upcoming / Overdue, completed toggle.                |
| **F‑8**  | **Notifications**                 | Local alerts: due date, pre‑block, recurring reminders.                                   |
| **F‑9**  | **iCloud Sync**                   | Background CloudKit sync; conflict policy “last‑writer‑wins with merged subtasks”.        |
| **F‑10** | **Widgets (WidgetKit)**           | “Next Task” & “Today’s Blocks” (small/medium).                                            |
| **F‑11** | **Siri Shortcuts / App Intents**  | “Add Task”, “Plan my day”, “Show Today”.                                                  |
| **F‑12** | **Import / Export**               | JSON & CSV export; `.ics` import as blocks.                                               |
| **F‑13** | **Kanban & List Views**           | Board with status columns + sortable list.                                                |

---

## 6  Non‑Functional Requirements

| Category            | Spec                                                                                    |
| ------------------- | --------------------------------------------------------------------------------------- |
| **Performance**     | See § 2.                                                                                |
| **Reliability**     | WAL journalling + CloudKit retries with exponential back‑off; zero‑data‑loss guarantee. |
| **Security**        | TLS 1.3 in transit; encrypted at rest in iCloud; no third‑party back‑end.               |
| **Usability**       | All primary actions have keyboard shortcuts; touch‑pad drag‑round‑trip < 100 ms.        |
| **Maintainability** | 80 % unit‑test coverage; DocC; Conventional Commits; CI on GitHub Actions.              |
| **Portability**     | Apple Silicon native; Intel via Rosetta (perf caveats).                                 |
| **Localization**    | English base; `.stringsdict` ready for community translation.                           |
| **Licensing**       | MIT (finalised).                                                                        |

---

## 7  Development Environment & Build

| Tool      | Minimum | Purpose              |
| --------- | ------- | -------------------- |
| Xcode     | 15      | Swift 5.9, SwiftData |
| SwiftLint | 0.55    | Linting              |
| Fastlane  | 2.220   | CI/CD, notarisation  |
| Mint      | latest  | Bootstrap CLI tools  |

**Build steps**

```bash
git clone https://github.com/your-org/taskplanner-macos.git
mint bootstrap
open TaskPlanner.xcodeproj
# Enable iCloud (CloudKit) in Signing & Capabilities before first run
```

---

## 8  Testing Strategy

| Layer     | Framework           | Focus                                                                    |
| --------- | ------------------- | ------------------------------------------------------------------------ |
| Model     | XCTest              | CRUD, merge policies, recurrence calculations                            |
| ViewModel | Combine‑await tests | Time‑travel scheduler, auto‑schedule algorithm                           |
| UI        | XCUITest            | Add‑schedule‑complete‑sync happy path; accessibility identifiers on rows |

A manual **QA‑Checklist.md** tracks regressions.

---

## 9  Roadmap Beyond v 1.0

* **Command Palette** (⇧⌘ P).
* **Focus / Pomodoro overlay**.
* **Obsidian‑style backlink graph**.
* **SharePlay for pair‑planning**.
* **iOS & visionOS ports** reusing Core layer.

---

## 10  Glossary

| Term           | Meaning                                          |
| -------------- | ------------------------------------------------ |
| **Area**       | Long‑term theme (e.g. “Health”).                 |
| **Project**    | Finite goal with deadline.                       |
| **Task**       | Actionable item, may have subtasks & recurrence. |
| **Time Block** | Calendar slot where a task is planned.           |

---

### Change‑Log (this merge)

* [placeholder data,,,]
* Aligned minimum OS from macOS 13 → **14** (SwiftData dependency).
* Added recurrence & auto‑schedule features from SRS.
* Confirmed menu‑bar quick‑add and widgets as v 1.0 goals.
* Replaced AGPL/MIT undecided → **MIT** per latest consensus.

*End of Unified Specification*
