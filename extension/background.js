/**
 * WorkSpaceX Background Service Worker
 * Handles periodic stale tab memory cleanup (Tab Memory Diet)
 */

const DEFAULT_IDLE_MINUTES = 60;
const CHECK_INTERVAL_MINUTES = 15;

// Set up alarm on installation or startup
chrome.runtime.onInstalled.addListener(() => {
  setupAlarm();
});

chrome.runtime.onStartup.addListener(() => {
  setupAlarm();
});

function setupAlarm() {
  chrome.alarms.get("stale-tab-check", (alarm) => {
    if (!alarm) {
      chrome.alarms.create("stale-tab-check", { periodInMinutes: CHECK_INTERVAL_MINUTES });
    }
  });
}

// Listen to alarms
chrome.alarms.onAlarm.addListener((alarm) => {
  if (alarm.name === "stale-tab-check") {
    checkAndDiscardTabs();
  }
});

// Query tabs and freeze those that are inactive for too long
async function checkAndDiscardTabs() {
  const settings = await getSettings();
  if (!settings.enabled) {
    console.log("Memory Diet is disabled. Skipping check.");
    return;
  }

  const now = Date.now();
  const idleThresholdMs = settings.idleMinutes * 60 * 1000;

  chrome.tabs.query({}, (tabs) => {
    let discardedCount = 0;
    
    tabs.forEach((tab) => {
      // Do not discard:
      // - Currently active tab in its window
      // - Already discarded tabs
      // - Internal/System browser tabs (chrome://, chrome-extension://)
      if (tab.active || tab.discarded) return;
      if (tab.url && (tab.url.startsWith('chrome://') || tab.url.startsWith('chrome-extension://') || tab.url.startsWith('edge://') || tab.url.startsWith('about:'))) {
        return;
      }

      // Check if lastAccessed property exists (Chrome 121+) and tab is older than threshold
      if (tab.lastAccessed) {
        const inactiveTime = now - tab.lastAccessed;
        if (inactiveTime > idleThresholdMs) {
          console.log(`Discarding tab ${tab.id}: ${tab.title} (inactive for ${Math.round(inactiveTime / 60000)} mins)`);
          chrome.tabs.discard(tab.id);
          discardedCount++;
        }
      } else {
        // Fallback: If lastAccessed is somehow not present, we skip to avoid discarding active tab history
      }
    });
    
    console.log(`Memory Diet Check complete. Discarded ${discardedCount} tabs.`);
  });
}

// Helper to load settings from storage
function getSettings() {
  return new Promise((resolve) => {
    chrome.storage.local.get(["tab_diet_enabled", "tab_diet_idle_minutes"], (result) => {
      resolve({
        enabled: result.tab_diet_enabled !== false, // default true
        idleMinutes: result.tab_diet_idle_minutes || DEFAULT_IDLE_MINUTES
      });
    });
  });
}

// Listen for direct check requests from popup UI
chrome.runtime.onMessage.addListener((message, sender, sendResponse) => {
  if (message.action === "check_and_discard_now") {
    checkAndDiscardTabs()
      .then(() => sendResponse({ success: true }))
      .catch((err) => sendResponse({ success: false, error: err.message }));
    return true; // Keep message channel open for async response
  }
});
