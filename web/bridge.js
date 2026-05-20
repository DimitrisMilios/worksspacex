/**
 * WorkSpaceX JS Bridge
 * Handles communication between Flutter Web and Chrome Extension APIs
 */

/**
 * Saves a string value to chrome.storage.sync (Google Account Sync)
 */
window.saveToStorage = function(key, value) {
    return new Promise((resolve, reject) => {
        // Try chrome.storage.sync first for Google Account Sync
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
        // 1. Capture existing tabs to close them later if needed
        const existingTabs = await new Promise(r => chrome.tabs.query({ currentWindow: true }, r));

        // 2. Create new tabs (KEEP THEM IN BACKGROUND so popup stays open)
        const tabIds = [];
        for (const url of urls) {
            const tab = await new Promise(r => chrome.tabs.create({ url, active: false }, r));
            tabIds.add ? null : tabIds.push(tab.id);
        }

        // 3. Group the new tabs
        if (groupName && chrome.tabGroups) {
            const groupId = await new Promise(r => chrome.tabs.group({ tabIds: tabIds }, r));
            const updateOptions = { title: groupName };
            if (groupColor) updateOptions.color = groupColor;
            await new Promise(r => chrome.tabGroups.update(groupId, updateOptions, r));
        }

        // 4. Close old tabs if "Clean Switch" is on
        if (shouldCloseOthers) {
            const oldTabIds = existingTabs.map(t => t.id);
            chrome.tabs.remove(oldTabIds);
        }

        // 5. Finally, focus the first new tab (this will close the popup)
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
