/**
 * WorkSpaceX JS Bridge
 * Handles communication between Flutter Web and Chrome Extension APIs
 */

/**
 * Saves a string value to chrome.storage.sync (Google Account Sync)
 */
window.saveToStorage = function(key, value) {
    return new Promise((resolve, reject) => {
        const storage = (typeof chrome !== 'undefined' && chrome.storage)
            ? (chrome.storage.sync || chrome.storage.local)
            : null;

        if (storage) {
            storage.set({ [key]: value }, () => {
                if (chrome.runtime.lastError) {
                    console.error("Storage Save Error:", chrome.runtime.lastError);
                    reject(false);
                } else {
                    resolve(true);
                }
            });
        } else {
            localStorage.setItem(key, value);
            resolve(true);
        }
    });
};

/**
 * Retrieves a string value from chrome.storage.sync
 */
window.getFromStorage = function(key) {
    return new Promise((resolve) => {
        const storage = (typeof chrome !== 'undefined' && chrome.storage)
            ? (chrome.storage.sync || chrome.storage.local)
            : null;

        if (storage) {
            storage.get([key], (result) => {
                resolve(result[key] || null);
            });
        } else {
            resolve(localStorage.getItem(key));
        }
    });
};

/**
 * Launches a list of URLs and handles grouping/cleaning.
 */
window.launchUrls = async function(jsonUrls, groupName, groupColor, shouldCloseOthers = false) {
    const urls = JSON.parse(jsonUrls);

    if (typeof chrome !== 'undefined' && chrome.tabs) {
        const existingTabs = await new Promise(r => chrome.tabs.query({ currentWindow: true }, r));

        const tabIds = [];
        for (const url of urls) {
            const tab = await new Promise(r => chrome.tabs.create({ url, active: false }, r));
            tabIds.push(tab.id);
        }

        if (groupName && chrome.tabGroups) {
            const groupId = await new Promise(r => chrome.tabs.group({ tabIds: tabIds }, r));
            const updateOptions = { title: groupName };
            if (groupColor) updateOptions.color = groupColor;
            await new Promise(r => chrome.tabGroups.update(groupId, updateOptions, r));
        }

        if (shouldCloseOthers) {
            const oldTabIds = existingTabs.map(t => t.id);
            chrome.tabs.remove(oldTabIds);
        }

        chrome.tabs.update(tabIds[0], { active: true });
        return true;
    } else {
        urls.forEach(url => window.open(url, '_blank'));
        return true;
    }
};

/**
 * Gets all open tabs in the current window
 */
window.getCurrentTabs = function() {
    return new Promise((resolve) => {
        if (typeof chrome !== 'undefined' && chrome.tabs) {
            chrome.tabs.query({ currentWindow: true }, (tabs) => {
                const tabData = tabs
                    .filter(tab => tab.url && !tab.url.startsWith('chrome://'))
                    .map(tab => ({
                        url: tab.url,
                        title: tab.title
                    }));
                resolve(JSON.stringify(tabData));
            });
        } else {
            resolve(JSON.stringify([
                { url: 'https://github.com', title: 'GitHub' },
                { url: 'https://flutter.dev', title: 'Flutter' }
            ]));
        }
    });
};

/**
 * Triggers a download of a JSON file
 */
window.downloadJson = function(fileName, jsonString) {
    const blob = new Blob([jsonString], { type: 'application/json' });
    const url = URL.createObjectURL(blob);
    const link = document.createElement('a');
    link.href = url;
    link.download = fileName;
    document.body.appendChild(link);
    link.click();
    document.body.removeChild(link);
    URL.revokeObjectURL(url);
};

/**
 * Opens a file picker and returns the content of the selected JSON file
 */
window.pickJsonFile = function() {
    return new Promise((resolve) => {
        const input = document.createElement('input');
        input.type = 'file';
        input.accept = '.json';
        input.onchange = (e) => {
            const file = e.target.files[0];
            if (!file) {
                resolve(null);
                return;
            }
            const reader = new FileReader();
            reader.onload = (event) => {
                resolve(event.target.result);
            };
            reader.readAsText(file);
        };
        input.click();
    });
};

/**
 * ============================================================================
 * Tab Memory Diet (Stale Tab Auto-Discarder) JS APIs
 * ============================================================================
 */

/**
 * Gets Tab Diet settings. Returns JSON string of { enabled, idleMinutes }
 */
window.getTabDietSettings = function() {
    return new Promise((resolve) => {
        if (typeof chrome !== 'undefined' && chrome.storage) {
            chrome.storage.local.get(["tab_diet_enabled", "tab_diet_idle_minutes"], (result) => {
                resolve(JSON.stringify({
                    enabled: result.tab_diet_enabled !== false, // default true
                    idleMinutes: result.tab_diet_idle_minutes || 60 // default 1 hour (60 mins)
                }));
            });
        } else {
            // Mock data for local development/web preview
            resolve(JSON.stringify({
                enabled: localStorage.getItem('tab_diet_enabled') !== 'false',
                idleMinutes: parseInt(localStorage.getItem('tab_diet_idle_minutes') || '60', 10)
            }));
        }
    });
};

/**
 * Saves Tab Diet settings
 */
window.saveTabDietSettings = function(enabled, idleMinutes) {
    return new Promise((resolve) => {
        if (typeof chrome !== 'undefined' && chrome.storage) {
            chrome.storage.local.set({
                tab_diet_enabled: enabled,
                tab_diet_idle_minutes: idleMinutes
            }, () => {
                resolve(true);
            });
        } else {
            localStorage.setItem('tab_diet_enabled', enabled.toString());
            localStorage.setItem('tab_diet_idle_minutes', idleMinutes.toString());
            resolve(true);
        }
    });
};

/**
 * Gets Open and Discarded/Sleeping Tab statistics.
 * Returns JSON string: { total, sleeping, active, estimatedSavedMB }
 */
window.getTabStats = function() {
    return new Promise((resolve) => {
        if (typeof chrome !== 'undefined' && chrome.tabs) {
            chrome.tabs.query({}, (tabs) => {
                const total = tabs.length;
                const sleeping = tabs.filter(t => t.discarded).length;
                const active = total - sleeping;
                // Chrome tabs consume roughly ~100MB of RAM on average when active
                const estimatedSavedMB = sleeping * 100; 
                
                resolve(JSON.stringify({
                    total: total,
                    sleeping: sleeping,
                    active: active,
                    estimatedSavedMB: estimatedSavedMB
                }));
            });
        } else {
            // Mock stats for dev web preview
            resolve(JSON.stringify({
                total: 18,
                sleeping: 5,
                active: 13,
                estimatedSavedMB: 500
            }));
        }
    });
};

/**
 * Manually trigger stale tab discarding immediately
 */
window.discardStaleTabsNow = function() {
    return new Promise((resolve) => {
        if (typeof chrome !== 'undefined' && chrome.runtime) {
            chrome.runtime.sendMessage({ action: "check_and_discard_now" }, (response) => {
                if (response && response.success) {
                    resolve(response.count);
                } else {
                    resolve(-1);
                }
            });
        } else {
            // Mock behavior
            setTimeout(() => {
                resolve(3);
            }, 800);
        }
    });
};

