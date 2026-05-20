/**
 * WorkSpaceX JS Bridge
 * Handles communication between Flutter Web and Chrome Extension APIs
 */

/**
 * Saves a string value to chrome.storage.local
 * @param {string} key
 * @param {string} value
 * @returns {Promise<boolean>}
 */
window.saveToStorage = function(key, value) {
    return new Promise((resolve, reject) => {
        if (typeof chrome !== 'undefined' && chrome.storage && chrome.storage.local) {
            chrome.storage.local.set({ [key]: value }, () => {
                if (chrome.runtime.lastError) {
                    console.error("Storage Save Error:", chrome.runtime.lastError);
                    reject(false);
                } else {
                    resolve(true);
                }
            });
        } else {
            // Fallback for local development outside of extension context
            localStorage.setItem(key, value);
            resolve(true);
        }
    });
};

/**
 * Retrieves a string value from chrome.storage.local
 * @param {string} key
 * @returns {Promise<string|null>}
 */
window.getFromStorage = function(key) {
    return new Promise((resolve, reject) => {
        if (typeof chrome !== 'undefined' && chrome.storage && chrome.storage.local) {
            chrome.storage.local.get([key], (result) => {
                if (chrome.runtime.lastError) {
                    console.error("Storage Load Error:", chrome.runtime.lastError);
                    reject(null);
                } else {
                    resolve(result[key] || null);
                }
            });
        } else {
            // Fallback for local development outside of extension context
            resolve(localStorage.getItem(key));
        }
    });
};

/**
 * Launches a list of URLs in new tabs and optionally groups them
 * @param {string} jsonUrls - JSON string of URL list
 * @param {string} groupName - Name for the tab group
 * @param {string} groupColor - Chrome color for the group
 * @returns {Promise<boolean>}
 */
window.launchUrls = function(jsonUrls, groupName, groupColor) {
    return new Promise((resolve) => {
        const urls = JSON.parse(jsonUrls);

        if (typeof chrome !== 'undefined' && chrome.tabs) {
            const tabIds = [];
            let createdCount = 0;

            urls.forEach((url) => {
                chrome.tabs.create({ url, active: false }, (tab) => {
                    tabIds.push(tab.id);
                    createdCount++;

                    // Once all tabs are created, group them if name is provided
                    if (createdCount === urls.length) {
                        if (groupName && chrome.tabGroups) {
                            chrome.tabs.group({ tabIds: tabIds }, (groupId) => {
                                const updateOptions = { title: groupName };
                                if (groupColor) {
                                    updateOptions.color = groupColor;
                                }
                                chrome.tabGroups.update(groupId, updateOptions);
                                resolve(true);
                            });
                        } else {
                            resolve(true);
                        }
                    }
                });
            });
        } else {
            // Fallback: Just open in new windows/tabs
            urls.forEach(url => window.open(url, '_blank'));
            resolve(true);
        }
    });
};

/**
 * Gets all open tabs in the current window
 * @returns {Promise<string>} - JSON string of {url: string, title: string}[]
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
            // Fallback for local development
            resolve(JSON.stringify([
                { url: 'https://github.com', title: 'GitHub' },
                { url: 'https://flutter.dev', title: 'Flutter' }
            ]));
        }
    });
};
