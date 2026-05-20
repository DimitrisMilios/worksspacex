# DevDock

DevDock is a Chrome extension built with Flutter Web that helps developers instantly launch their development environments.

Instead of manually reopening the same tabs every day, DevDock allows you to save project workspaces and launch everything with a single click.

---

# Features

## Workspace Launcher

Launch all project-related tabs instantly:

* localhost
* staging environments
* GitHub repositories
* Jira boards
* Firebase consoles
* Admin panels
* Documentation

---

## Environment Presets

Switch between environments quickly:

* Development
* Staging
* Production

---

## Tab Grouping

Automatically organize tabs into Chrome tab groups.

Example groups:

* Frontend
* Backend
* DevOps
* Docs
* Design

---

## Developer Focused

Built specifically for developers and technical teams.

Unlike generic tab managers, DevDock is optimized for:

* multi-project workflows
* development context restoration
* fast environment switching
* repetitive setup reduction

---

# Tech Stack

## Frontend

* Flutter Web
* Dart

## Browser Extension

* Chrome Extension Manifest V3
* Chrome Tabs API
* Chrome Storage API
* Chrome Tab Groups API

---

# Project Structure

```text
lib/
 ├── core/
 │    ├── chrome/
 │    ├── storage/
 │    └── theme/
 │
 ├── features/
 │    ├── launch/
 │    ├── settings/
 │    └── workspaces/
 │
 └── main.dart
```

---

# Getting Started

## 1. Clone Repository

```bash
git clone <your-repository-url>
cd devdock
```

---

## 2. Install Dependencies

```bash
flutter pub get
```

---

## 3. Enable Web Support

```bash
flutter config --enable-web
```

---

## 4. Run Flutter Web

```bash
flutter run -d chrome
```

---

# Build Extension

## Build Flutter Web

```bash
flutter build web
```

Flutter output:

```text
build/web/
```

---

## Create Extension Folder

```text
extension/
```

Copy everything from:

```text
build/web/
```

into:

```text
extension/
```

---

# Manifest Example

Create:

```text
extension/manifest.json
```

```json
{
  "manifest_version": 3,
  "name": "DevDock",
  "description": "Launch development workspaces instantly.",
  "version": "1.0.0",
  "action": {
    "default_popup": "index.html"
  },
  "permissions": [
    "tabs",
    "storage",
    "tabGroups"
  ]
}
```

---

# Load Extension in Chrome

Open:

```text
chrome://extensions
```

Enable:

```text
Developer mode
```

Click:

```text
Load unpacked
```

Select:

```text
extension/
```

---

# MVP Roadmap

## Version 1

* Create workspace
* Save URLs
* Launch all tabs
* Search workspaces
* Chrome tab grouping

---

## Future Features

* Auto-detect open dev tabs
* Save current session
* Cloud sync
* Keyboard shortcuts
* Team workspace sharing
* Import/export
* Workspace templates

---

# Example Workspace

```text
Workspace: Wine App

Frontend
- http://localhost:3000
- https://github.com/company/frontend

Backend
- http://localhost:8080
- https://github.com/company/backend

Tools
- https://firebase.google.com
- https://jira.company.com
- https://figma.com
```

---

# Development Goals

DevDock focuses on solving a single problem well:

```text
Restore development context instantly.
```

The extension is intentionally designed to stay lightweight, fast, and developer-focused.

---

# Contributing

Contributions, ideas, and improvements are welcome.

To contribute:

```bash
git checkout -b feature/my-feature
```

Then open a pull request.

---

# License

MIT
