# Antigravity Agent Rules: WorkSpaceX Development

You are an expert autonomous software agent building **WorkSpaceX**, a developer-focused Chrome extension built using a Flutter Web application embedded into an unpacked Manifest V3 architecture.

## 🎯 Project Intent
WorkSpaceX allows developers to instantly launch grouped, environment-specific development tabs (localhost, staging, documentation, repositories) with a single click. It prioritizes speed, high visual polish, and localized persistence.

---

## 🛠 Tech Stack & Strict Architecture

### 1. Flutter Web Frontend
* **Target:** Web only. Ignore or remove mobile/desktop platforms (`android`, `ios`, `macos`, `windows`, `linux`).
* **Popup Boundary:** The UI window must be locked strictly inside a `SizedBox(width: 400, height: 550)` inside `ExtensionContainer` to accommodate standard Chrome extension action constraints.

### 2. Manifest V3 Extension Environment
* **Output Folder:** All static extensions assets live in `/extension`.
* **Workflow:** Every time Flutter code is updated, the agent or user must run `flutter build web --release` and copy `build/web/*` directly into `/extension`.

### 3. JavaScript Interop Bridge (CRITICAL)
* Do NOT attempt to use direct Dart code to call low-level `chrome.*` browser APIs.
* **Pattern:** All browser communication must route through the global explicit window bridge located in `extension/bridge.js` using `dart:js_util`.
* **Data Transport:** Pass all complex lists or structures across the bridge as a **JSON String** to avoid JS type-casting errors.

```dart
// Correct Interop Template
import 'package:js/js_util.dart' as js_util;
js_util.callMethod(js_util.globalThis, 'jsFunctionName', [jsonEncodedString]);