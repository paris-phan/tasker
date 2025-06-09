# Software Requirements Specification

**Product:** *Task-Tracker & Time-Blocking macOS App*\
**Platform:** macOS 14 + (Apple Silicon-first)\
**UI Framework:** SwiftUI\
**Persistence:** SwiftData (+ CloudKit)\
**Document Version:** 1.0\
**Last Updated:** 12 May 2025

---

## 1  Introduction

### 1.1 Purpose

This document defines the complete software requirements for a native macOS application that combines task management with calendar-style time blocking. It is intended for product owners, developers, designers, testers, and other stakeholders.

### 1.2 Scope

The product lets users:

* Capture, organise, and complete tasks.
* Visually assign those tasks to time blocks on a daily/weekly planner.
* Sync daily/weekly planner calendar with external calender sources (Apple, Google)
* Sync data across their Apple devices via iCloud.

### 1.3 Definitions, Acronyms & Abbreviations

| Term           | Meaning                                                        |
| -------------- | -------------------------------------------------------------- |
| **Task**       | A to-do item with metadata (title, notes, due date, etc.).     |
| **Time Block** | A contiguous period scheduled for a Task.                      |
| **SwiftData**  | Apple’s object-graph persistence framework (WWDC 23).          |
| **CloudKit**   | Apple’s iCloud sync technology.                                |
| **Widget**     | Home-Screen / Notification-Center widget built with WidgetKit. |

---

## 2  Overall Description

### 2.1 Product Perspective

Standalone desktop application distributed through the Mac App Store. Uses macOS frameworks for storage, sync, notifications, and widgets—no external servers required.

### 2.2 User Classes & Characteristics

| User Class       | Description                       | Technical Skill    |
| ---------------- | --------------------------------- | ------------------ |
|**Regular User**|Individual planning personal tasks and study/work sessions.|Basic macOS usage.|
| **Power User**| Heavy keyboard-shortcut & automation user; relies on scripting and Siri Shortcuts.| Advanced.|

### 2.3 Operating Environment

* macOS 14 Sonoma or later (Apple Silicon, Sequoia Prio.).
* iCloud account for sync features (optional).
* Internet connection for CloudKit, App Store updates, TestFlight.

### 2.4 Design & Implementation Constraints

* SwiftUI & Swift Concurrency (async/await) only—no AppKit UI code except where required (e.g., NSToolbar customization).
* Local data stored in user’s App Group container; no third-party analytics.
* Must pass App Store privacy “No tracking” criteria.

### 2.5 Assumptions & Dependencies

* Users have at least macOS 14.0 installed.
* iCloud Drive enabled if they want sync.
* Apple Push Notification service reliably delivers notifications.

---

## 3  System Features (Functional Requirements)

Each requirement is tagged **\[F-ID]** for traceability.

| ID       | Title                     | Priority | Description                                                                               |
| -------- | ------------------------- | -------- | ----------------------------------------------------------------------------------------- |
| **F-1**  | Create Task               | Must     | User can add a task with title (required), notes, due date, priority, tags.               |
| **F-2**  | Edit/Delete Task          | Must     | User can modify or remove existing tasks.                                                 |
| **F-3**  | Task Completion           | Must     | User can mark a task complete; UI reflects status with strikethrough & checkmark.         |
| **F-4**  | Recurring Tasks           | Should   | Support daily/weekly/monthly repeats with “skip instance” handling.                       |
| **F-5**  | Drag-&-Drop Time Blocking | Must     | User drags a task onto a calendar grid to create a Time Block; block resizable & movable. |
| **F-6**  | Auto-Schedule             | Could    | “Fill my day” algorithm suggests blocks based on due dates & free time.                   |
| **F-7**  | Notifications             | Must     | Configurable alerts: at due date, 10 min before block start, etc.                         |
| **F-8**  | Search & Filters          | Must     | Instant search, tag filters, “Today”, “Next 7 days”, completed toggle.                    |
| **F-9**  | Sidebar Projects          | Should   | Group tasks under user-defined projects; collapsible in sidebar.                          |
| **F-10** | iCloud Sync               | Must     | Tasks & blocks sync seamlessly across user’s Macs.                                        |
| **F-11** | Menu-Bar Quick Add        | Should   | MenuBarExtra with “Add Task” field and upcoming block list.                               |
| **F-12** | Widgets                   | Could    | “Next Task” & “Today’s Blocks” widgets (small/medium sizes).                              |
| **F-13** | Siri / Shortcuts          | Could    | Intent: “Add Task”, “Plan my day”, returns confirmation.                                  |
| **F-14** | Import/Export             | Could    | JSON/CSV export; .ics calendar import of events as time blocks.                           |

---

## 4  External Interface Requirements

### 4.1 User Interfaces

* **Main Window**

  * Sidebar (Projects, Smart Filters)
  * Split view: Task List ↔ Calendar/Grid
  * Toolbar buttons: ◀︎ Day | Week ▶︎, +Task, +Block, Search.
* **Menu-Bar Extra**

  * Compact pop-over: quick add, next block countdown.
* **Preferences (Settings)**

  * Tabs: General, Notifications, iCloud, Shortcuts.

### 4.2 Hardware Interfaces

None beyond Macs running macOS.

### 4.3 Software Interfaces

| Framework             | Purpose                   |
| --------------------- | ------------------------- |
| **SwiftData**         | Local persistence & undo. |
| **CloudKit**          | Record syncing.           |
| **UserNotifications** | Local alerts.             |
| **WidgetKit**         | Home-Screen widgets.      |
| **AppIntents**        | Siri Shortcuts support.   |

### 4.4 Communications Interfaces

All network traffic is via CloudKit over HTTPS/TLS; no custom ports.

---

## 5  Non-Functional Requirements

### 5.1 Performance

* App launch < 2 seconds on M1 MacBook Air.
* Scrolling & drag-drop at 60 fps on a 60 Hz display.

### 5.2 Reliability & Availability

* Zero-data-loss guarantee backed by CoreData WAL + CloudKit conflict resolution.
* Sync queue auto-retries with exponential back-off.

### 5.3 Security & Privacy

* All data stored in user’s iCloud container—no third-party servers.
* No analytics or tracking; complies with App Store “Privacy Nutrition Label”.
* Encryption in transit (TLS 1.3) and at rest (Apple’s server-side encryption).

### 5.4 Usability & Accessibility

* Full VoiceOver, Dynamic Type, and High-Contrast support.
* Keyboard shortcuts for all primary actions; touchpad gestures optional.

### 5.5 Maintainability

* MVVM architecture with Repository pattern.
* 80 % unit-test coverage for business logic.
* Code documented with DocC; public APIs marked `@_spi(Internal)`.

### 5.6 Portability

* Binary runs on Apple Silicon (arm64); Intel (x86-64) build produced via Rosetta with potential performance caveats.

---

## 6  System Models

### 6.1 Domain Model (UML-style text)

```
Task "1" <--> "*" TimeBlock
Task "*" <--> "1" Project
Project "1" <--> "*" Tag
```

### 6.2 Use-Case Diagram (textual)

* **UC-1 Add Task** – Actor: User
* **UC-2 Schedule Block** – Actor: User
* **UC-3 Sync Data** – Trigger: Background process
* **UC-4 Notify Upcoming Block** – Trigger: Time event

---

## 7  Appendix

### 7.1 Future Enhancements

* Cross-platform iPad & iPhone versions (codebase 90 % shared).
* Focus-mode integration (activates when a block starts).
* AI-assisted scheduling using on-device Core ML.

### 7.2 Open Issues

* Decide on algorithm for Auto-Schedule (F-6).
* Explore CalendarKit interoperability for importing user calendars without violating sandbox rules.

---

*End of SRS v1.0*
