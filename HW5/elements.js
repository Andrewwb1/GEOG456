var map = L.map('map').setView([39.828175, -98.5795], 4);

var OSM = L.tileLayer('https://tile.openstreetmap.org/{z}/{x}/{y}.png', {
    maxZoom: 19,
    attribution: '&copy; <a href="http://www.openstreetmap.org/copyright">OpenStreetMap</a>'
}).addTo(map);

var selectedYear = '1850' // base year
function myStyle(feature) {
    return {
    "fillColor": getColor(feature.properties[selectedYear]),
     "color": "black",// notice that the selected year is the name of a property of the geojson
    "weight": 0.75,
    "opacity": 2.0,
    "fillOpacity": 0.7
    }
};
    
function getColor(codedCont) {
    return codedCont === 1 ? '#7fc97f'
    :codedCont === 2 ? '#beaed4'
    :codedCont === 3 ? '#fdc086'
    :codedCont === 4 ? '#ffff99'
    :codedCont == 5 ? '#386cb0'
    : 'grey';
};

var BPLs = L.geoJSON(data, {style: myStyle}).addTo(map);

function moveSlider(value) {
    selectedYear = value; // this changes the value of the selectedYear variable
    map.removeLayer(BPLs);// leaflet method to remove a layer / 
    BPLs = L.geoJSON(data, {style: myStyle});
    map.addLayer(BPLs); // add the new layer
    document.getElementById('theYear').innerHTML = 'Year: '+ value  
}

moveSlider('1850')

// create a leaflet legend
var legend = L.control({position: 'bottomright'});
legend.onAdd = function (map) {
    var div = L.DomUtil.create('div', 'info legend'),
        grades = [ 1, 2, 3, 4, 5, 6],
        labels = ["North America", "South America","Europe", "Asia", "Africa", "NA"];

    for (var i = 0; i < grades.length; i++) {
        div.innerHTML +=
            '<i style="background:' + getColor(grades[i]) + '"></i> ' +
            labels[i] +  '<br>';
    }
    return div;
};

legend.addTo(map);

var legendTitle = L.control({position: 'bottomright'});
    legendTitle.onAdd = function (map) {
        this._div = L.DomUtil.create('div', 'info');
        this.update();
        return this._div;
    };

    legendTitle.update = function (props) {
        this._div.innerHTML = '<h3>Continent of Birth</h3>';
    };
    legendTitle.addTo(map);