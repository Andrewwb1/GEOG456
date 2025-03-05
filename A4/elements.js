var map = L.map('map').setView([39.828175, -98.5795], 4);

var OSM = L.tileLayer('https://tile.openstreetmap.org/{z}/{x}/{y}.png', {
    maxZoom: 19,
    attribution: '&copy; <a href="http://www.openstreetmap.org/copyright">OpenStreetMap</a>'
}).addTo(map);


function style(feature) {
    return {
            fillColor: 'pink',
            weight: 2,
            opacity: 1,
            color: 'white',
            fillOpacity: 0.7
        };
    }

function onEachFeature(feature, layer) {
        layer.on({mouseover: addInformation})
    }
    
var myInfo = document.getElementById('info')


function myFeature2nArrayOfObj(aFeature){ 
    var north = {name: 'North America', value: aFeature.properties.count_1}
    var south = {name: 'South America', value: aFeature.properties.count_2}
    var euro = {name: 'Europe', value: aFeature.properties.count_3}
    var asia = {name: 'Asia', value: aFeature.properties.count_4}
    var africa =  {name: 'Africa', value: aFeature.properties.count_5}
    var myArray = [north,south,euro,asia,africa]  
    return myArray
}


var myGeojson = L.geoJson(data, {
    style: style,
    onEachFeature: onEachFeature
}).addTo(map);

function addColumn(obj){
            
    var columnDiv = document.createElement("div");
    columnDiv.className = "column";
    columnDiv.style.height = (obj.value/200) + 'px' //`${value}px`;
    columnDiv.innerHTML = obj.name + ' <br/>' + obj.value 
    myInfo.append(columnDiv);
        }

function addInformation(e) {
    myInfo.innerHTML = '';
    var myNewArray = myFeature2nArrayOfObj(e.target.feature)
   myNewArray.forEach(e =>addColumn(e)) 

}

    