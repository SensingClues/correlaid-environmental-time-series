// Script to define the necessary parameters
// to load and save composite data from Google Earth Engine

// Country name
var countryName = 'Zambia';

// Specify the year to process
var startYear = 2020; 
var endYear = null; //2024 

// Specify the month to process
var startMonth = 2; 
var endMonth = null; //12 

// Resolution in meters
var resolution = 10; 

// CRS for projection 
var crs = 'EPSG:4326'; // Specify CRS as EPSG:4326

// Paths
var aoiPath = 'projects/ee-sensingclues-timeseries/assets/'; // path to get AoI mask
var outputFolder = 'GEE/' + countryName + '/' + resolution+'m_resolution'; // Output folder in Google Drive

// Preprocessing parameters
var filterCloud = true;

// Visualize the NDVI composite.
var ndviParams = {
    min: -1,
    max: 0.8,
    palette: ['brown', 'white', 'green']
  };



