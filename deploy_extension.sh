#!/bin/bash

# Exit on error
set -e

echo "🚀 Building Flutter Web with CSP and local resources..."
# --no-web-resources-cdn forces Flutter to download CanvasKit/WASM locally instead of using gstatic.com
# --csp ensures the output is compatible with strict Content Security Policies
flutter build web --release --base-href "/" --csp --no-web-resources-cdn

echo "📂 Syncing to /extension folder..."
mkdir -p extension
rm -rf extension/*
cp -r build/web/* extension/

# Ensure bridge.js is present
if [ -f "web/bridge.js" ]; then
  cp web/bridge.js extension/bridge.js
fi

# Fix base-href in index.html
sed -i '' 's|<base href="/">|<base href="./">|g' extension/index.html
sed -i '' 's|<base href="\$FLUTTER_BASE_HREF">|<base href="./">|g' extension/index.html

# Inject the style block for popup dimensions via a separate file
echo "html, body { width: 400px; height: 550px; margin: 0; padding: 0; background-color: #121212; overflow: hidden; }" > extension/popup.css
sed -i '' "s|</head>|<link rel=\"stylesheet\" href=\"popup.css\"></head>|g" extension/index.html

# Force the HTML renderer to avoid WASM/CanvasKit issues in the extension
# We create a config.js and load it before the bootstrap
echo "window.flutterConfiguration = { renderer: 'html' };" > extension/config.js
sed -i '' "s|<body>|<body><script src=\"config.js\"></script>|g" extension/index.html

# IMPORTANT: Extension Manifest with strict CSP
# We include 'wasm-unsafe-eval' which is required for the Flutter engine
cat <<EOF > extension/manifest.json
{
  "manifest_version": 3,
  "name": "WorkSpaceX",
  "description": "Developer-focused workspace manager for Chrome.",
  "version": "1.0.0",
  "action": {
    "default_popup": "index.html"
  },
  "permissions": [
    "tabs",
    "storage",
    "tabGroups"
  ],
  "host_permissions": [
    "<all_urls>"
  ],
  "content_security_policy": {
    "extension_pages": "script-src 'self' 'wasm-unsafe-eval'; object-src 'self'"
  }
}
EOF

echo "✅ Done!
1. Go to chrome://extensions
2. Remove the old WorkSpaceX extension
3. Click 'Load unpacked' and select the /extension folder"
