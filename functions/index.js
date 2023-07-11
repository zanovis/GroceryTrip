const functions = require("firebase-functions");
const admin = require("firebase-admin");
const Fuse = require("fuse.js");

admin.initializeApp();

exports.fuzzySearch = functions.https.onCall(async (data, context) => {
  const searchTerms = data.itemNames;
  const selectedStore = data.selectedStore; // Add this line to get the selectedStore from the input data
  const ref = admin.database().ref(`stores/${selectedStore}`); // Use the selectedStore in the reference path

  const snapshot = await ref.once("value");
  const items = snapshot.val();
  
  const options = {
    keys: ["value"],
    threshold: 0.1, // Adjust the threshold for more or less strict fuzzy matching
    findAllMatches: false,
  };

  const fuse = new Fuse(Object.entries(items).map(([key, value]) => ({ key, value })), options);

  const results = {
    found: [],
    notFound: []
  };

  searchTerms.forEach(searchTerm => {
    const searchResult = fuse.search(searchTerm);
    const foundItems = searchResult.map((result) => result.item.key);

    if (foundItems.length > 0) {
      results.found.push(...foundItems);
    } else {
      results.notFound.push(searchTerm);
    }
  });

  return results;
});
