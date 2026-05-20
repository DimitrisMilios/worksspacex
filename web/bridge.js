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
