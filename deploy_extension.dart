import 'dart:io';

void main() async {
  print("🚀 Building Flutter Web with CSP and local resources...");
  // Run flutter build web
  final buildResult = await Process.run('flutter', [
    'build', 'web',
    '--release',
    '--base-href', '/',
    '--csp',
    '--no-web-resources-cdn'
  ], runInShell: true);
  
  if (buildResult.exitCode != 0) {
    print("❌ Flutter build failed:");
    print(buildResult.stderr);
    print(buildResult.stdout);
    exit(buildResult.exitCode);
  }
  print(buildResult.stdout);

  print("📂 Syncing to /extension folder...");
  final extensionDir = Directory('extension');
  if (await extensionDir.exists()) {
    await extensionDir.delete(recursive: true);
  }
  await extensionDir.create(recursive: true);

  final buildWebDir = Directory('build/web');
  if (!await buildWebDir.exists()) {
    print("❌ Build output directory build/web does not exist!");
    exit(1);
  }

  // Copy files
  await copyDirectory(buildWebDir, extensionDir);

  // Ensure bridge.js is present
  final bridgeSrc = File('web/bridge.js');
  if (await bridgeSrc.exists()) {
    await bridgeSrc.copy('extension/bridge.js');
  }

  // Ensure background.js is present
  final backgroundSrc = File('web/background.js');
  if (await backgroundSrc.exists()) {
    await backgroundSrc.copy('extension/background.js');
  }

  // Copy custom icon if present
  final customIconSrc = File('assets/icon/icon.png');
  final customIconDestDir = Directory('extension/assets/icon');
  if (await customIconSrc.exists()) {
    if (!await customIconDestDir.exists()) {
      await customIconDestDir.create(recursive: true);
    }
    await customIconSrc.copy('extension/assets/icon/icon.png');
    print("🎨 Custom icon copied into the extension bundle.");
  }

  // Fix base-href in index.html
  final indexFile = File('extension/index.html');
  if (await indexFile.exists()) {
    var content = await indexFile.readAsString();
    content = content.replaceAll('<base href="/">', '<base href="./">');
    content = content.replaceAll('<base href="\$FLUTTER_BASE_HREF">', '<base href="./">');

    // Inject the style block for popup dimensions via a separate file
    final popupCss = File('extension/popup.css');
    await popupCss.writeAsString(
      "html, body { width: 400px; height: 550px; margin: 0; padding: 0; background-color: #121212; overflow: hidden; }"
    );

    content = content.replaceAll('</head>', '<link rel="stylesheet" href="popup.css"></head>');

    // Force the HTML renderer to avoid WASM/CanvasKit issues in the extension
    final configJs = File('extension/config.js');
    await configJs.writeAsString("window.flutterConfiguration = { renderer: 'html' };");

    content = content.replaceAll('<body>', '<body><script src="config.js"></script>');

    await indexFile.writeAsString(content);
  }

  // Write manifest.json
  final manifestJson = File('extension/manifest.json');
  final manifestContent = '''{
  "manifest_version": 3,
  "name": "WorkSpaceX",
  "description": "Developer-focused workspace manager for Chrome.",
  "version": "1.0.0",
  "icons": {
    "16": "assets/icon/icon.png",
    "32": "assets/icon/icon.png",
    "48": "assets/icon/icon.png",
    "128": "assets/icon/icon.png"
  },
  "action": {
    "default_popup": "index.html",
    "default_icon": {
      "16": "assets/icon/icon.png",
      "32": "assets/icon/icon.png",
      "48": "assets/icon/icon.png",
      "128": "assets/icon/icon.png"
    }
  },
  "background": {
    "service_worker": "background.js"
  },
  "permissions": [
    "tabs",
    "storage",
    "tabGroups",
    "alarms"
  ],
  "host_permissions": [
    "<all_urls>"
  ],
  "content_security_policy": {
    "extension_pages": "script-src 'self' 'wasm-unsafe-eval'; object-src 'self'"
  }
}''';
  await manifestJson.writeAsString(manifestContent);

  print("✅ Done!");
  print("1. Go to chrome://extensions");
  print("2. Enable 'Developer mode' in the top-right corner");
  print("3. Click 'Load unpacked' and select this folder:");
  print("   \${Directory.current.path}\\extension");
}

Future<void> copyDirectory(Directory source, Directory destination) async {
  await for (var entity in source.list(recursive: false)) {
    final name = entity.path.split(RegExp(r'[/\\]')).last;
    if (entity is Directory) {
      final newDir = Directory('${destination.path}/$name');
      await newDir.create(recursive: true);
      await copyDirectory(entity, newDir);
    } else if (entity is File) {
      await entity.copy('${destination.path}/$name');
    }
  }
}
