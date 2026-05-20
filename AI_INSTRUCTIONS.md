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


### 🎨 Brand Identity & UI Styling (WorkSpaceX Theme)
The extension must use a premium, ultra-modern dark UI inspired by frosted-glass aesthetics, utilizing the following strict color palette:
* **Background:** `Color(0xFF0A090D)` (Deep space black)
* **Surface/Cards:** `Color(0xFF18151F)` with subtle borders (`Color(0xFF2D2838)`)
* **Primary Interactive:** `Color(0xFFFF6B35)` (Vibrant Orange)
* **Secondary/Environment Badge:** `Color(0xFFB5179E)` (Neon Magenta) and `Color(0xFFF7A23B)` (Honey Gold)
* **Text Primary:** `Color(0xFFFFFFFF)` (Pure White) using a bold, wide sans-serif weight for major headers.
* **Text Secondary:** `Color(0xFF9E9AA7)` (Muted Silver) for URLs and logs.

#### UI Component Goals:
* Card elements should feature a slight `borderRadius: BorderRadius.circular(16)`.
* Incorporate soft gradients on background containers or call-to-action buttons using a `LinearGradient` blending the Orange and Neon Magenta colors.