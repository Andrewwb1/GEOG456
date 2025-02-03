var OSM = L.tileLayer('https://tile.openstreetmap.org/{z}/{x}/{y}.png', {
    maxZoom: 19,
    attribution: '&copy; <a href="http://www.openstreetmap.org/copyright">OpenStreetMap</a>'
}).addTo(map);

// here I am adding the ESRI tileLayer
var Esri_WorldImagery = L.tileLayer('https://server.arcgisonline.com/ArcGIS/rest/services/World_Imagery/MapServer/tile/{z}/{y}/{x}', {
    attribution: 'Tiles &copy; Esri &mdash; Source: Esri, i-cubed, USDA, USGS, AEX, GeoEye, Getmapping, Aerogrid, IGN, IGP, UPR-EGP, and the GIS User Community'
    });


var park_icon = L.icon({    // notice the L.icon which is a Leaflet object with properties
    iconUrl: '../HW3/parkIcon.png',
    iconSize: [30,30], // size of the icon
    popupAnchor: [0,0] // where the icon is located relative to the lat lon of the point. 
    });

var pointz = L.geoJSON(parks, {
    pointToLayer: function (feature, latlng) {
    return L.marker(latlng, {icon: park_icon}).bindPopup(feature.properties.Park_Name); 
    }
    }).addTo(map);

    var baseLayers = {
    "OpenStreetMap": OSM,
    "ESRI": Esri_WorldImagery
    };

var overlayMaps = {
    "Parks": pointz,
    };
    
var layerControl = L.control.layers(baseLayers,overlayMaps).addTo(map);
