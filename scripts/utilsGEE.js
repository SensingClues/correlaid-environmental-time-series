// Export useful functions

// Function to get country AoI from asset folder
exports.getAoI = function getAoI(aoiPath, countryName) {
    // Load the assets in the folder
    var assets = ee.data.listAssets(aoiPath);

    // Filter assets to find matches with the partial filename
    var matchedAssets = assets.assets.filter(function(asset) {
        return asset.name.includes(countryName);
    });

    // Return the absolute filename or a not found message
    if (matchedAssets.length > 0) {
        return ee.FeatureCollection(matchedAssets[0].name); // load the file
    } else {
        return "No asset matches the partial filename: " + countryName;
    }
}

// Function to get date range
exports.getDateRange = function getDateRange(startYear, endYear, startMonth, endMonth) {
    // Get start date
    var startDate = ee.Date.fromYMD(startYear, startMonth, 1);

    // Get end date
    if (endYear === null || endMonth === null) {
        var endDate = startDate.advance(1, 'month');
    } else {
        var endDate = ee.Date.fromYMD(endYear, endMonth, 1);
    }
    return {startDate:startDate,endDate:endDate}
}