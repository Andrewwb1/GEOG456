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
    var white = {name: 'White', value: aFeature.properties.White}
    var black = {name: 'Black', value: aFeature.properties.Blc_A_A}
    var americanIndian = {name: 'American Indian', value: aFeature.properties.Amr_Ind}
    var asian = {name: 'Asian', value: aFeature.properties.Asian}
    var pacific =  {name: 'Hawaii & Pacific Islands', value: aFeature.properties.Haw_Pcf}
    var other =  {name: 'Other', value: aFeature.properties.other}
    var twoOrMore = {name: 'Two or more', value: aFeature.properties.tw_r_mr}
    var myArray = [white,black,americanIndian,asian,pacific,other,twoOrMore]  
    return myArray
}


var myGeojson = L.geoJson(data, {
    style: style,
    onEachFeature: onEachFeature
}).addTo(map);




function selectColorByValue(value){
            if (value > 5000) {return 'pink'}
            if (value >0 ) {return 'yellow'}
        }



        function addColumn(obj){
            
            var columnDiv = document.createElement("div");
            columnDiv.className = "column";
            columnDiv.style.backgroundColor = selectColorByValue(obj.value);
            columnDiv.style.height = (obj.value/200) + 'px' //`${value}px`;
            columnDiv.innerHTML = obj.name + ' <br/>' + obj.value 
            myInfo.append(columnDiv);
        }

function addInformation(e) {
    myInfo.innerHTML = '';
    var myNewArray = myFeature2nArrayOfObj(e.target.feature)
   myNewArray.forEach(e =>addColumn(e)) 

}

    