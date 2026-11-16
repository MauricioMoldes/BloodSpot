
//Setting generic width and height values for our SVG.
var margin = {top: -50, right: 0, bottom: 100, left: 80};

var genWidth = 1024;
var genHeight = 768;

var width = genWidth - 70 - margin.left - margin.right;
var height = genHeight - 150 - margin.top - margin.bottom;

//Other variable declarations.
var animationNum = 0;
var ANIMATION_TIME_MODIFIER = 0.7; //Higher for slower animation
var AXIS_ROTATION = -30;
var AXIS_FONTSIZE = "13px"
var minAxisY = 999999;
var maxAxisY = 0;
var maxAxisY_backup = 0;
var NEIGHBOUR_LIMIT = 0.2;
var maxNeighbourCount = 0;
var MIN_NEIGHBOUR_COUNT = 4;
var MAX_SPREAD_VALUE = 40;
var graphDataFullArray = Array();
var graphDataSubValueY = Array();
var graphDataY = Array();
var graphDataX = Array();
var graphDataNeighbours = Array();
var graphDataProbes = Array();
var graphDataColors = Array();
var arrayValues = [];
var currentDataset = "noData";
var currentGene = "noGene";
var chosenProbe = "none";
var probeChanged = false;
var datasetChanged = false;
var selectPopulation = false;
var treeChanged = false;
var log2Data = false;
var sortedGraphData = Array();
var bigSpreadLowerLimit = MAX_SPREAD_VALUE/100*75;
var numberOfUnchecked = 0;
var currentNumberOfCircles = 0;
var medianArray = Array();
var ttestArray = Array();
var MEDIAN_LENGTH = 70;
var CIRCLE_OPACITY = 0.7;
var MEDIAN_OPACITY = 0.5;
var TTEST_OPACITY = 0.4;
var MAX_PROBE = "Max probe"
var animationNumMedian = 0;
var resetZoomBool = false;
var SHRINK_PERCENT = 5;
var highestRowCountInArray = 0;
var range = 0;
var grid = 0;
var arrayForGrid;


//Initial variables.
var xScale;
var yScale;
var xAxis;
var yAxis;
var zoom;
var color;
var SVG;
var SVGbody;
var rect;
var clip;
var median;

//Creating scales used to scale everything to the size of the SVG.
xScale = d3.scale.linear()
  .domain([0, genWidth])
  .range([0, width-margin.right]);

yScale = d3.scale.linear()
    .domain([0, genHeight])
    .range([height, margin.bottom]);

xAxis = d3.svg.axis()
  .scale(xScale)
  .orient("bottom")
  .innerTickSize(-height+100).ticks(0);

yAxis = d3.svg.axis()
  .scale(yScale)
  .orient("left")
  .innerTickSize(-width).ticks(0);

//Zoom command ...
zoom = d3.behavior.zoom()
    .x(xScale)
    .y(yScale)
    .scaleExtent([1,10])
    .on("zoom", zoomTargets);

color = d3.scale.linear()
  .domain([0, 1, 2, 3, 4])
  .range(["#5B7F4B", "#45B29D", "#EFC94C", "#E27A3F", "#DF5A49"]);

// The mark '#' indicates an ID. IF '#' isn't included argument expected is a tag such as "svg" or "p" etc..
SVG = d3.selectAll(".SVG")
  .attr("class", "SVG")
  .attr("width", width + margin.left + margin.right)
  .attr("height", height + margin.top + margin.bottom)
  .attr("pointer-events", "all")
  .append("g")
    .attr("transform", "translate(" + margin.left + "," + margin.top + ")");

//This creates a body with a clippath inside the svg where all element in the graph will be. This prevents elemnts on the graph to go past the axis.
SVGbody = SVG.append("g")
  .attr("class", "zoomClass")
  .attr("clip-path", "url(#clip)")
  .call(zoom);

//Create background. The mouse must be over an object on the graph for the zoom to work. The rectangle will cover the entire graph.
rect = SVGbody.append("rect")
    .attr("width", width)
    .attr("height", height)
    .style("fill", "#fff");

//Showing the axis that we created earlier in the script for both X and Y.
SVG.append("g")
  .attr("class", "x axis")
    .attr("transform", "translate(0," + height + ")")
    .call(xAxis)
      .selectAll("text")
      .style("text-anchor", "end")
      .style("font-size", AXIS_FONTSIZE)
        .attr("transform", function(d) {
            return "rotate(" + AXIS_ROTATION + ")"
            });

SVG.append("g")
    .append("text")
      .attr("class", "label")
      .attr("x", 450)
      .attr("y", 665)
      .style("text-anchor", "end")
      .style("font-weight", "bold")
      .style("font-size", "11px")
      .style("font-family", "helvetica")
      .text(""); //used to be "celltypes"

SVG.append("g")
    .append("text")
      .attr("class", "label")
      .attr("id", "y-label")
      .attr("x", -190)
      .attr("y", -85)
      .attr("transform", "translate(14, 105) rotate(-90)")
      .style("text-anchor", "end")
      .style("font-weight", "bold")
      .style("font-size", "11px")
      .style("font-family", "helvetica")
      .text("log2 expression");

SVG.append("g")
    .attr("class", "y axis")
    .call(yAxis)
      .selectAll("text")
        .style("font-size", AXIS_FONTSIZE)
        .style("font-family", "helvetica");

SVG.append("text")
      .attr("class", "graphTitle")
      .attr("x", width/2)
      .attr("y", 90)
      .style("text-anchor", "middle")
      .style("font-size", "16")
      .style("font-family", "helvetica")
      .style("font-weight", "bold")
      .text(currentGene);

SVG.append("text")
      .attr("class", "title")
      .attr("id", "siteTitle")
      .attr("x", 20)
      .attr("y", 400)
      .style("font-weight", "normal")
      .style("text-anchor", "center")
      .style("font-size", "130px")
      .style("font-family", "helvetica")
      .style("fill", "#ccc")
      .style("opacity", "0.4")
      .text("BloodSpot");

//Clipping is defined here used to prevent elements from the graph from going past the axis.
clip = SVG.append("defs").append("svg:clipPath")
    .attr("id", "clip")
    .append("svg:rect")
    .attr("id", "clip-rect")
    .attr("x", "0")
    .attr("y", "0")
    .attr("width", width)
    .attr("height", height);

SVGMedian = SVG.append("g")
  .attr("class", "zoomClass")
  .attr("clip-path", "url(#clip)")
  .call(zoom);

SVGTTest = SVG.append("g")
  .attr("class", "zoomClass")
  .attr("clip-path", "url(#clip)")
  .call(zoom);

//Mouseover
var div = d3.select("body").append("div")   
    .attr("class", "tooltip")               
    .style("opacity", 0);

//CSS for d3
$(".axis path, .axis line").css({"fill":"none","stroke":"#ddd"});
$(".axis text").css({"font-size":AXIS_FONTSIZE, "font-family":"helvetica"});
$("svg").css({"margin-top":"5px","padding-top":"20px", "font":"10px sans-serif"});

function initValues() {
  arrayValues = [];
  graphDataFullArray = [];
  graphDataSubValueY = [];
  graphDataX = [];
  graphDataY = [];
  graphDataNeighbours = [];
  medianArray = [];
  graphDataColors = [];
  minAxisY = 999999;
  maxAxisY = 0;
  maxNeighbourCount = 0;
  numberOfUnchecked = 0;
}

//The function handleling the zoom. Nothing is zoomed automatically, every elemnt must me defined here.
function zoomTargets() {
  if($("#enableZoom").is(':checked')){
    var translate = zoom.translate(),
    scale = zoom.scale();

    tx = Math.min(0, Math.max(width * (1 - scale), translate[0]));
      ty = Math.min(0, Math.max(height * (1 - scale), translate[1]));

    //This line applies the tx and ty which prevents the graphs from moving out of the limits. This means it can't be moved until zoomed in first.
      zoom.translate([tx, ty]);

      if(resetZoomBool){
        zoom.scale(1); 
      zoom.translate([0,0]);
      }

    SVG.select(".x.axis").call(xAxis)
      .selectAll("text")
        .style("text-anchor", "end")
        .style("font-size", AXIS_FONTSIZE)
        .style("font-family", "helvetica")
          .attr("transform", function(d) {
              return "rotate(-30)" 
              });

    SVG.select(".y.axis").call(yAxis)
      .selectAll("text")
        .style("font-size", AXIS_FONTSIZE)
        .style("font-family", "helvetica");

    SVG.selectAll("circle")
    .attr("cx", function(d, i){ return xScale(graphDataX[i]);})
    .attr("cy",function(d){return yScale(d);});

    SVGMedian.selectAll("ellipse")
      .attr("cx", function(d, i){ return xScale((i*100)+100);})
      .attr("cy", function(d){ return yScale(d-0.01);});

    SVGTTest.selectAll("rect")
      .attr("x", function(d, i){
          var startIndex = ((ttestArray[i][0]+1)*100)+5;
          return xScale(startIndex);
        })
        .attr("y", function(d, i){
            return yScale(ttestArray[i][3]);
        })
        .attr("width", function(d, i){
            var endIndex = ((ttestArray[i][1]-ttestArray[i][0])*100)-5;
            return xScale(endIndex);
        })
        .attr("height", 3);

    SVGTTest.selectAll("text")
      .attr("x", function(d, i) {
          var startIndex = ((((ttestArray[i][1]-ttestArray[i][0])/2)+ttestArray[i][0]+1-(ttestArray[i][4].length*0.08))*100);
          return xScale(startIndex);
        })
        .attr("y", function(d, i) {
          if(ttestArray[i][4] == "NS"){
            var heightOfText = ttestArray[i][3]+0.05;
          } else {
            var heightOfText = ttestArray[i][3]-0.05;
          }
            return yScale(heightOfText);
        })
  }
}

function toggleGrid(){
  if(grid == 1){
    grid = 0;
  } else if(grid == 0){  
      grid = 1;
  }
  updateAxisX(arrayForGrid);
  updateAxisY();
}

function setGrid(num){
  grid = num;
}

function updateAxisX(arr) {
  arrayForGrid = arr;
  var formatAxis = function(d, i) { return arr[i]; }

  xAxis = d3.svg.axis()
    .scale(xScale)
    .orient("bottom")
    .tickValues(createTickValuesArray(arr.length))
    .tickFormat(formatAxis)
    .innerTickSize(-height+100);

  if(grid == 0){
    xAxis = d3.svg.axis()
    .scale(xScale)
    .orient("bottom")
    .tickValues(createTickValuesArray(arr.length))
    .tickFormat(formatAxis);
  }

  if(datasetChanged || SVG.selectAll("circle").empty() || selectPopulation){
    SVG.select(".x.axis").transition().duration(ANIMATION_TIME_MODIFIER*1000)
    .call(xAxis)
    .selectAll("text")
      .style("text-anchor", "end")
      .style("font-size", AXIS_FONTSIZE)
      .style("font-family", "helvetica")
        .attr("transform", function(d) {
            return "rotate(" + AXIS_ROTATION + ")" 
            });
  } else {
    SVG.select(".x.axis")
    .call(xAxis)
    .selectAll("text")
      .style("text-anchor", "end")
      .style("font-size", AXIS_FONTSIZE)
      .style("font-family", "helvetica")
        .attr("transform", function(d) {
            return "rotate(" + AXIS_ROTATION + ")" 
            });
  }
}

function updateScaleX(newWidth){

  genWidth = (newWidth*100)+50;
  xScale = d3.scale.linear()
    .domain([0, (newWidth*100)+50])
    .range([0, width-margin.right]);

  zoom.x(xScale);
}

function updateAxisY(){
  yAxis = d3.svg.axis()
    .scale(yScale)
    .orient("left")
    .innerTickSize(-width+25);

  if(grid == 0){
    yAxis = d3.svg.axis()
    .scale(yScale)
    .orient("left");
  }

  SVG.select(".y.axis").transition().duration(ANIMATION_TIME_MODIFIER*1500).call(yAxis)
    .selectAll("text")
    .style("font-size", AXIS_FONTSIZE)
    .style("font-family", "helvetica");
}

function updateScaleY(minVal, maxVal){

  yScale = d3.scale.linear()
      .domain([minVal, maxVal])
      .range([height, margin.bottom]);

  zoom.y(yScale);
}

function createTickValuesArray(amountOfTicks){
  var tickValuesArr = [];
  for(var i = 1;i<=amountOfTicks;i++){
    tickValuesArr[i-1] = 100*i;
  }
  return tickValuesArr;
}

function getMinMaxValuesAxisY(coordinates){
  coordinates.forEach(function(coordinate) {
  var num = parseFloat(coordinate);
        if (num < minAxisY) {
            minAxisY = num-0.1;
        } else if (num > maxAxisY) {
            maxAxisY = num+0.1;
        }
    });
}

function getMaxProbe(coordinates){
  var highestNum = -999999;

  coordinates.forEach(function(coordinate) {
  var num = parseFloat(coordinate);
        if (num > highestNum) {
            highestNum = num;
        }

        return highestNum;
    });
}

 //Custom functions used for specific uses.
var removeDuplicatesInArray = function (arr) {
    var i, j, cur, found;
    for (i = arr.length - 1; i >= 0; i--) {
        cur = arr[i];
        found = false;
        for (j = i - 1; !found && j >= 0; j--) {
            if (cur === arr[j]) {
                if (i !== j) {
                    arr.splice(i, 1);
                }
                found = true;
            }
        }
    }
    return arr;
};

function randomIntFromInterval(min,max)
{
    return Math.floor(Math.random()*(max-min+1)+min);
}

function loadGraph(gene, dataset, probe){
  currentDataset = dataset;
  console.log("Getting data: ", "php/getdata.php?gene=" + gene + "&data=" + dataset)
  d3.json("php/getdata.php?gene=" + gene + "&data=" + dataset, function(error, dataLookUp) {
    if(error){ return console.log(error); }
    if(typeof dataLookUp !== 'undefined' && dataLookUp.length > 0) {
      gene = dataLookUp[0].gene_name;
      processDatalol(gene, dataset, probe, dataLookUp);
      window.history.pushState("object or string", "Title", "/?gene="+ gene +"&dataset=" + dataset);
    } else{
      console.log("Looking up Alias: ", "/php/lookUpAlias.php?alias=" + gene)
      d3.json("/php/lookUpAlias.php?alias=" + gene, function(error, aliasLookUp) {
        if(error){ return console.log(error); }
        else if (typeof aliasLookUp == 'undefined' || aliasLookUp.length < 1) {
          if(gene == ""){
            alert("You must enter a gene name to view a visualization on the graph below.")
          } else {
            alert("Gene or signature is not expressed, or is not annotated in this dataset.");
          }
          return console.log("No gene or alias found.")
        }
        else if(typeof aliasLookUp !== 'undefined' && aliasLookUp.length > 0) {
          gene = aliasLookUp[0].name;
          console.log("Getting data after alias: ", "php/getdata.php?gene=" + gene + "&data=" + dataset)
          d3.json("php/getdata.php?gene=" + gene + "&data=" + dataset, function(error, data) {
            if(error){ return console.log(error); }
            else if (typeof data == 'undefined' || data.length < 1) {
              if(gene == ""){
                alert("You must enter a gene name to view a visualization on the graph below.")
              } else {
                alert("Gene or signature is not expressed, or is not annotated in this dataset.");
              }
              return console.log("Alias found, but no gene was found.")
            }
            processDatalol(gene, dataset, probe, data);
            window.history.pushState("object or string", "Title", "/?gene="+ gene +"&dataset=" + dataset);
          });
        }
      }); 
    }
    
  });
}

function logQueryToDatabase(gene, dataset, probe){
  // d3.text("php/logData.php?gene=" + gene + "&data=" + dataset + "&prgm=" + 19, function(error, logData) {
  //   if(error){ return console.log(error); }
  //   console.log(logData);
  // }); 
}

function processDatalol(gene, dataset, probe, data){
  // console.log("processDatalol", gene, dataset, probe);
  logQueryToDatabase(gene, dataset, probe);
  initValues();
  // If a new gene or dataset is chosen, no probes have been chosen by default. If new probe has been chosen, we ignore this.
  console.log("Current gene: " + currentGene + ", New gene: " + gene);
  if(currentGene != gene || datasetChanged){
        chosenProbe = "none";
        gene = makeUpperCase(gene, dataset);
        currentGene = gene;
        graphDataProbes = Array();
        SVG.selectAll(".graphTitle")
          .transition().duration(ANIMATION_TIME_MODIFIER*800)
          .attr("x", width/2)
          .attr("y", 0)
          .style("text-anchor", "middle")
          .style("font-size", "16")
          .style("font-family", "helvetica")
          .style("font-weight", "bold")
          .transition().duration(ANIMATION_TIME_MODIFIER*700)
          .attr("x", width/2)
          .attr("y", 90)
          .text(function(){ 
            var ds = getDataset();
            if ((ds ==  "nl_mouse_data") ||(ds.substring(0,6) == "immgen") || (ds == "mouse_nl_rna_seq") ){
              return mousify(currentGene) ;
            }else{
              return currentGene ;
            }
           });

        SVG.selectAll(".title")
          .transition().duration(ANIMATION_TIME_MODIFIER*1500)
          .style("font-size", "500")
          .style("opacity", "0")
          .remove();
      }

      if(typeof data !== 'undefined' && data.length > 0) {

        //console.log(data);

        changeAxisLabel(dataset);

        data.forEach( function(d) {
          arrayValues.push(d.cell_name);
          var cell_data = JSON.stringify(d.cell_data);
          var probe_name = JSON.stringify(d.probe_name);
          //console.log(d);
          //console.log(probe_name);
          cell_data = cell_data.replace(/"/g,"");
          probe_name = probe_name.replace(/"/g,"");
          if(chosenProbe == "none"){
            chosenProbe = probe_name;
          }
          if(probeChanged == true){
            chosenProbe = probe;
          }
          
          if((chosenProbe == probe_name) || (probe == MAX_PROBE)){
              graphDataSubValueY.push(cell_data.split(" "));
          }
          graphDataProbes.push(probe_name);
          graphDataFullArray.push(cell_data.split(" "));
        });

        // console.log(graphDataFullArray);
        // console.log(graphDataSubValueY);

        

        if(!$("#Log2_scale").is(':checked')){
          graphDataSubValueY = convert2DArrayToLog2(graphDataSubValueY);
        }

        arrayValues = removeDuplicatesInArray(arrayValues);
        graphDataProbes = removeDuplicatesInArray(graphDataProbes);

        //console.log(arrayValues);
        //console.log(graphDataProbes);

        chooseSearchedProbe();

        calculateMedian();

        updateTreeGraph(dataset);
        
        //Open survival plot for probe
        if(~dataset.indexOf('_sc')){
          $(".survPlot").attr("src","/surv/survplotsPNG/" + dataset + "/" + gene.trim() + ".png");
          $(".survPlot").off("error").one("error", function () { 
              $(".survPlot").attr("src","/surv/survplotsPNG/not_available_umap.png");
          });
        }else{
          $(".survPlot").attr("src","/surv/survplotsPNG/" + chosenProbe + ".png");
          $(".survPlot").off("error").one("error", function () { 
              $(".survPlot").attr("src","/surv/survplotsPNG/No_Survival_Data.png");
          });
        }

        updateCheckboxes();

        findBiggestCelltype(probe);
        calculateMinMaxValues();
        calculateCoordinatesXY();
        if(arrayValues.length > 9){
              document.getElementById("toggleGrid").checked = true;
              setGrid(1);
            } else {
              document.getElementById("toggleGrid").checked = false;
              setGrid(0);
            }
        updateAllAxis();

        // Change probes and ttest lists avaliable to user.
        refreshProbeSelect(graphDataProbes);
        refreshTTestList(arrayValues);
        changeSelectedProbe(chosenProbe, gene);

        //Draw circles and possibly medians.
        drawCircles();
                if($("#median").is(':checked')){
                    drawMedians();
                }

                //Get correlations from database and create buttons that will link to them.
    if(~dataset.indexOf('_sc')){
      getCorrelations(dataset, 'NULL', gene)
    } else {
                  getCorrelations(dataset, chosenProbe, 'NULL');
    }

                //Update global booleans after process is done.
                setProbeChanged(false);
                setDatasetChanged(false);
                setSelectPopulation(false);
                setLog2Data(false);
                animationNum = 1;

                //Take a backup of maxAxisY.
        maxAxisY_backup = maxAxisY;

      }

}

function drawCircles(){
  //console.log(datasetChanged);
  //This selects 4 circles (non-existent, there requires data-binding) and appends them all below  enter.
  //The amount of numbers in data is the amount of circles to be appended in the enter() section.

  if(datasetChanged){
    SVG.selectAll("circle").remove();
  }
  if(SVG.selectAll("circle").empty() ){
    animationNum = 0;
    animationNumMedian = 0;
  } else if(selectPopulation){
    animationNum = 1;
    animationNumMedian = 2;
  } else if(probeChanged || log2Data){
    animationNum = 2;
    animationNumMedian = 1;
  } else {
    animationNum = 3;
    animationNumMedian = 0;
    //animationNum = randomIntFromInterval(1, 4);
  }
    
  var circle = SVGbody
    .selectAll("circle")
    .data(graphDataY);

  circle.exit()
    .style("opacity", CIRCLE_OPACITY)
        .transition()
        .duration(ANIMATION_TIME_MODIFIER*300)
        .style("opacity", 0)
        .remove();

    circle.enter()
      .append("circle")
      .on("mouseover", function(d) {      
            //alert(d.toString().substring(0,5));
            div.transition()        
                .duration(100)      
                .style("opacity", .9);
            div.html(d.toString().substring(0,4))  
                .style("left", (d3.event.pageX) + "px")     
                .style("top", (d3.event.pageY - 28) + "px");    
            })                  
        .on("mouseout", function() {       
            div.transition()        
                .duration(300)      
                .style("opacity", 0);   
        });

    var amountOfCircles = d3.selectAll("circle").size();
    
  var iOS = ( navigator.userAgent.match(/(iPad|iPhone|iPod)/g) ? true : false );
  if(d3.selectAll("circle").size() > 3000 || iOS){
    animationNum = 9;
  }

    switch(animationNum){
      case 0:
      //Executed on init and when dataset is changed.
      circle
        .attr("cx",xScale(0))
        .attr("cy", yScale(minAxisY))
        .attr("r",4)
        .style('opacity', 0)
        .style("fill", function(d, i){ return graphDataColors[i]; })
        .transition()
        .duration(ANIMATION_TIME_MODIFIER*1000)
        .attr("cx", function(d, i){ return xScale(graphDataX[i]);})
        //.attr("cy", function (d, i){ return yScale(i); })
        .style('opacity', CIRCLE_OPACITY)
        .transition()
        .duration(ANIMATION_TIME_MODIFIER*1000)
        .attr("cy", function(d){return yScale(parseFloat(d));} );
      break;
    case 1:
    //Executed when select population is changed. Remove all dots below the graph and pulls the new data back up.
    circle
      .attr("cx", function(d, i){ return xScale(graphDataX[i]);})
        .attr("cy", function(d){return yScale(parseFloat(d));} )
        .attr("r",4)
        .style('opacity', 0)
        .style("fill",  function(d, i){ return graphDataColors[i]; })
        .transition().duration(ANIMATION_TIME_MODIFIER*500)
        .style('opacity', CIRCLE_OPACITY);
    break;
    case 2:
    //Executed when probe is changed. Changes the position og circles to quickly update the graph.
    circle
      .transition()
        .duration(ANIMATION_TIME_MODIFIER*1000)
        .attr("cx", function(d, i){ return xScale(graphDataX[i]);})
        .attr("cy", function(d){return yScale(parseFloat(d));} )
        .attr("r",4)
        .style('opacity', CIRCLE_OPACITY)
        .style("fill",  function(d, i){ return graphDataColors[i]; });
    break;
    case 3:
    //Executed when gene is changed. Gathers all circles in the middles, spreads the out at the bottom, and lastly pulls them to their places.
    circle
      .transition().duration(ANIMATION_TIME_MODIFIER*750)
      .style("fill", function(d, i){ return graphDataColors[i]; })
      .attr("r",4)
      .style('opacity', CIRCLE_OPACITY)
      .attr("cx", width/2)
      .attr("cy", height/2)
      .transition()
      .attr("cx", function(d, i){ return xScale(graphDataX[i]);})
      .attr("cy", yScale(minAxisY))
      .transition()
          .attr("cy",function(d){return yScale(parseFloat(d));});
    break;
    case 9:
    circle
        .attr("cx", function(d, i){ return xScale(graphDataX[i]);})
        .attr("cy", function(d){return yScale(parseFloat(d));} )
        .attr("r",4)
        .style('opacity', 0)
        .style("fill",  function(d, i){ return graphDataColors[i]; })
        .transition().duration(ANIMATION_TIME_MODIFIER*1000)
        .style('opacity', CIRCLE_OPACITY);
    break;
    case 10:
    circle
      .attr("cx", function(d, i){ return xScale(graphDataX[i]);})
        .attr("cy", function(d){return yScale(parseFloat(d));} )
        .attr("r",4)
        .style("fill",  function(d, i){ return graphDataColors[i]; })
        .style('opacity', CIRCLE_OPACITY);
    break;
  }

  //console.log(d3.selectAll("circle").size());

  //CSS for circles
  $("circle").css({"stroke":"#404040","stroke-width":"1px"});
}

function updateAllAxis(){
  //Updates the Y axis to fit the values of the newly loaded data.
  updateScaleX(arrayValues.length);
  updateAxisX(arrayValues);
  updateScaleY(minAxisY-(maxAxisY/100), maxAxisY);
  updateAxisY();

}

function calculateCoordinatesXY(){
  //Find all coordinates and ready the arrays for X and Y.
  setNeighbourLimit();  
  graphDataY = graphDataSubValueY.toString().split(",");
  findNeighbourCount();
  findDisplacedValuesX();
  colorCircles();
}

function findBiggestCelltype(probe){
  //Find celltype with highest median out of all probes
        if(probe == MAX_PROBE){
          for(var i = 0; i < arrayValues.length; i++)
          {
            medianArray[i] = -9999999;
            for(var j = 0; j < graphDataProbes.length; j++){
              var tempVal = d3.median(graphDataSubValueY[i+(j*arrayValues.length)]);
              if(medianArray[i] < tempVal){
                medianArray[i] = tempVal;
                graphDataSubValueY[i] = graphDataSubValueY[i+(j*arrayValues.length)];
              }
            }
          }
          graphDataSubValueY.splice(arrayValues.length, (graphDataProbes.length-1)*arrayValues.length);
        }
}

function calculateMedian(){
  for(var i = 0; i<graphDataSubValueY.length; i++)
  {
    graphDataSubValueY[i].sort(function(a,b) { return a - b;});
    //D3 Median calculator gets different values from my personal calculation..
    //So I used my own. Mine is right. Mine is god. Seriously, don't use D3 for median, unless you find out why its data is wrong..
    //medianArray[i] = d3.median(graphDataSubValueY[i]);
    var medianTemp;
    if(graphDataSubValueY[i].length % 2 == 0){
      medianTemp = (parseFloat(graphDataSubValueY[i][graphDataSubValueY[i].length/2]) + parseFloat(graphDataSubValueY[i][graphDataSubValueY[i].length/2 - 1])) / 2;
    } else {
      medianTemp = parseFloat(graphDataSubValueY[i][(graphDataSubValueY[i].length - 1) / 2]);
    }
    medianArray[i] = medianTemp;
  }
}

function calculateMinMaxValues(){
  //Find minimum and maximum Y-values from array.
  for(var i = 0; i<graphDataSubValueY.length; i++)
  {
    graphDataSubValueY[i] = graphDataSubValueY[i].sort();
    getMinMaxValuesAxisY(graphDataSubValueY[i]);
  }
}

function updateCheckboxes(){
  if(selectPopulation || probeChanged || log2Data){
    removePopulationEntries();  
  } else {
    addCheckboxes();
  }
}

function drawMedians(){

  // Draw medians
  var median = SVGMedian
    .selectAll("ellipse")
      .data(medianArray/*, function(d){return d;}*/);

  median.exit()
    .style("opacity", MEDIAN_OPACITY)
        .transition()
        .duration(ANIMATION_TIME_MODIFIER*300)
        .style("opacity", 0)
        .remove();

    median.enter()
      .append("ellipse");

  if(animationNum != 10){
    median
      .attr("cx", function(d, i){ return xScale((i*100)+100);})
      .attr("cy", function(d){ return yScale(d-0.01);})
      .attr("rx", 23) //or xScale(40) for same size but scale when less celltypes.
      .attr("ry", 3)
      .style("opacity", 0)
      .transition().duration(function(){
        if(animationNumMedian == 2){
          return ANIMATION_TIME_MODIFIER*500;
        } else {
          return ANIMATION_TIME_MODIFIER*1000;
        }
      })
      .delay(function(){
        if(animationNumMedian == 1){
          return ANIMATION_TIME_MODIFIER*500;
        } else if(animationNumMedian == 2){
          return ANIMATION_TIME_MODIFIER*0;
        } else {
          return ANIMATION_TIME_MODIFIER*1500;
        }
      })
      .style("opacity", MEDIAN_OPACITY)
      .style("fill", "#000000");
  } else {
    median
      .attr("cx", function(d, i){ return xScale((i*100)+100);})
      .attr("cy", function(d){ return yScale(d-0.01);})
      .attr("rx", 23) //or xScale(40) for same size but scale when less celltypes.
      .attr("ry", 3)
      .style("opacity", MEDIAN_OPACITY)
      .style("fill", "#000000");
  }
}

function updateTreeGraph(dataset){
  if(treeChanged == false){
    //Create file for D3 tree.
    //d3.text("D3/create_tree_data.php?gene="+ currentGene +"&type=" + currentDataset +"&probe=" + chosenProbe + "&celltypes=" + arrayValues.toString() + "&median=" + getMedianArray().toString(), function(error, text) {
    //    if (error) return console.warn(error);
        //console.log(text);
        updateTree(dataset);
    //});
  }
  setTreeChanged(false);
}

function removeMedians(){
  //Remove medians
  SVGMedian
    .selectAll("ellipse")
    .style("opacity", MEDIAN_OPACITY)
        .transition()
        .duration(ANIMATION_TIME_MODIFIER*300)
        .style("opacity", 0)
        .remove();
}

function refreshTTestList(celltypeArr){

  var container = document.getElementById('popupCorrelation');

  removeSelectOptions(document.getElementById("ttestSelect1"))
  removeSelectOptions(document.getElementById("ttestSelect2"))
  var select1 = document.getElementById("ttestSelect1");
  var select2 = document.getElementById("ttestSelect2");
  var option1, option2;


  celltypeArr.forEach(function(celltype) {
    option1 = document.createElement("option");
    option1.text = celltype;
    select1.add(option1);

    option2 = document.createElement("option");
    option2.text = celltype;
    select2.add(option2);

  });
}

function calculatePValue(celltype1, celltype2){
  var stars = "";

  //Get arrays based on celltype name.
  var array1, array2;
  for(var i = 0; i < arrayValues.length; i++){
    if(arrayValues[i] == celltype1){
      array1 = graphDataFullArray[i];
    }
    if(arrayValues[i] == celltype2){
      array2 = graphDataFullArray[i];
    }
  }

  //Get means
  var array1mean = array1.avg();
  var array2mean = array2.avg();

  //Calculate sigma values for array1
  var sum = 0.0, squaredSum = 0.0;
  array1.forEach(function(value) {
    //Claculate sum of squared values
    squaredSum = squaredSum + Math.pow(value, 2);
    //Calculate sum
    sum = parseFloat(sum) + parseFloat(value);
    });
  var sumOfSquaredArray1Values = squaredSum;
  var sumOfArray1ValuesSquared = Math.pow(sum, 2);

  //Calculate sigma values for array2
  sum = 0, squaredSum = 0;
  array2.forEach(function(value) {
    //Claculate sum of squared values
    squaredSum = squaredSum += Math.pow(value, 2);
    //Calculate sum
    sum = parseFloat(sum) + parseFloat(value);
    });
  var sumOfSquaredArray2Values = squaredSum;
  var sumOfArray2ValuesSquared = Math.pow(sum, 2);

  //Calculate sigma sections of the formula and df for less complication. 
  var xTemp = sumOfSquaredArray1Values - (sumOfArray1ValuesSquared / array1.length);
  var yTemp = sumOfSquaredArray2Values - (sumOfArray2ValuesSquared / array2.length);
  var df = array1.length + array2.length - 2;

  //Calculate T-Value
  var tValue = (array1mean - array2mean)/(Math.sqrt( ((xTemp + yTemp) / df) * ((1/array1.length) + (1/array2.length)) ));
  var absoluteTValue = Math.abs(tValue);

  //Get P-value from table
  var critVT = getCritValueTable();

  for(var i = critVT.length-1; i >= 0; i--){
    if(df >= critVT[i][0]){
      if(absoluteTValue > 0.05 && absoluteTValue < critVT[i][1]){
        stars = "NS";
      }
      if(absoluteTValue >= critVT[i][3]){
        stars = stars + "*";
      }
      if(absoluteTValue >= critVT[i][2]){
        stars = stars + "*";  
      }
      if(absoluteTValue >= critVT[i][1]){
        stars = stars + "*";
      }
      //alert("T-value: " + absoluteTValue + "\nDF Row: " + critVT[i] + "\nStars: " + stars);
      break;
    }
  }

  return stars;

}

Array.prototype.avg = function() {
var av = 0;
var cnt = 0;
var len = this.length;
for (var i = 0; i < len; i++) {
var e = +this[i];
if(!e && this[i] !== 0 && this[i] !== '0') e--;
if (this[i] == e) {av += e; cnt++;}
}
return av/cnt;
}

function calculateTTestArray(celltype1, celltype2, stars){
  var plotLength = arrayValues.length;
  var index1, index2;
  var yAxisPosition;
  //alert(celltype1 + " vs " +celltype2)

  //Get numeric indexes
  for(var i = 0; i < arrayValues.length; i++){
    if(arrayValues[i] == celltype1){
      index1 = i;
    }
    if(arrayValues[i] == celltype2){
      index2 = i;
    }
  }

  //Set index1 to be smaller than index2 
  if(index2 < index1){
    var tempIndex = index1;
    index1 = index2;
    index2 = tempIndex;
  }

  var rowCount = 1;
  var highestRowCountInArrayTemp = highestRowCountInArray;
  for(var i = 0; i < ttestArray.length; i++){
    //Save highest rowCounts
    if(highestRowCountInArray < ttestArray[i][2]){
      highestRowCountInArray = ttestArray[i][2];
    }
    //If the element we are checking is on the CURRENT row, we check start and end indexes.
    //alert("Index: " + index1 + " --- " + index2 + "\n Array: " + ttestArray[i][0] + " --- " + ttestArray[i][1] + "\n Length & i: " + ttestArray.length + " --- " + i + "\n\nrowCount: " + rowCount + " --- " + ttestArray[i][2] + "\nmaxCount: " + highestRowCountInArrayTemp);
    if(rowCount == ttestArray[i][2]){
      //If it is colliding, do following
      if(!((index1 < ttestArray[i][0] && index2 < ttestArray[i][0]) || (index1 > ttestArray[i][1] && index2 > ttestArray[i][1]))){
        rowCount++;
        i = -1;
        highestRowCountInArrayTemp--;
      }
    }
  }

  //Set y-axis position to be above the plot by 5% of it's height.
  range = (maxAxisY_backup - minAxisY)/100*SHRINK_PERCENT;
  if(rowCount > highestRowCountInArray){
    if(rowCount == 1){
      range = range*2;
    }
    resizePlot(maxAxisY+range);
    highestRowCountInArray = rowCount;
    if(rowCount == 1){
      range = range/2;
    }
  }
  //alert(rowCount);

  yAxisPosition = (range*rowCount) + maxAxisY_backup;
  //Add element to array.
  ttestArray.push([index1, index2, rowCount, yAxisPosition, stars]);
}

function drawTTest(){
  //Draw TTest linesco

  var ttest = SVGTTest
    .selectAll("rect")
    .data(ttestArray);

  ttest.exit()
      .style("opacity", TTEST_OPACITY)
      .transition()
      .duration(ANIMATION_TIME_MODIFIER*300)
      .style("opacity", 0)
      .remove();

  ttest.enter()
      .append("rect");

  ttest
      .attr("x", function(d, i){
          var startIndex = ((ttestArray[i][0]+1)*100)+5;
          return xScale(startIndex);
      })
      .attr("y", function(d, i){
          return yScale(ttestArray[i][3]);
      })
      .attr("width", function(d, i){
          var endIndex = ((ttestArray[i][1]-ttestArray[i][0])*100)-5;
          return xScale(endIndex);
      })
      .attr("height", 3)
      .style("opacity", 0)
      .transition().duration(ANIMATION_TIME_MODIFIER*500)
      .style("opacity", TTEST_OPACITY)
      .style("fill", "#000000");

  var text = SVGTTest
    .selectAll("text")
    .data(ttestArray);

  text.exit()
      .style("opacity", TTEST_OPACITY)
      .transition()
      .duration(ANIMATION_TIME_MODIFIER*300)
      .style("opacity", 0)
      .remove();

  text.enter()
    .append("text");

  text
    .attr("x", function(d, i) {
        var startIndex = ((((ttestArray[i][1]-ttestArray[i][0])/2)+ttestArray[i][0]+1-(ttestArray[i][4].length*0.08))*100);
        return xScale(startIndex);
      })
      .attr("y", function(d, i) {
        if(ttestArray[i][4] == "NS"){
          var heightOfText = ttestArray[i][3]+0.05;
        } else {
          var heightOfText = ttestArray[i][3]-0.05;
        }
          return yScale(heightOfText);
      })
    .text( function(d, i) { return ttestArray[i][4]; })
    .attr("font-size", function(d, i){
      if(ttestArray[i][4] == "NS"){
        return "14px";
      }
      return "20px";
    })
    .attr("fill", function(d, i){
      if(ttestArray[i][4] == "NS"){
        return "black";
      }
      return "red";
    });


}

function removeTTests(){
  SVGTTest
    .selectAll("rect")
    .style("opacity", TTEST_OPACITY)
        .transition()
        .duration(ANIMATION_TIME_MODIFIER*300)
        .style("opacity", 0)
        .remove();

    SVGTTest
    .selectAll("text")
      .style("opacity", TTEST_OPACITY)
      .transition()
      .duration(ANIMATION_TIME_MODIFIER*300)
      .style("opacity", 0)
      .remove();

    ttestArray = [];
}

function resizePlot(num){
  maxAxisY = num;
  calculateMedian();
  updateAllAxis();
  setProbeChanged(true);
  drawCircles();
    drawMedians();
    setProbeChanged(false);
}

function isDuplicateTTest(celltype1, celltype2){
  //Get numeric indexes
  for(var i = 0; i < arrayValues.length; i++){
    if(arrayValues[i] == celltype1){
      index1 = i;
    }
    if(arrayValues[i] == celltype2){
      index2 = i;
    }
  }

  for(var i = 0; i < ttestArray.length; i++){
    if(ttestArray[i][0] == index1){
      if(ttestArray[i][1] == index2){
        return true;
      }
    }else if(ttestArray[i][0] == index2){
      if(ttestArray[i][1] == index1){
        return true;
      }
    }
  }
  return false;
}

function findDisplacedValuesX(){
  //Calculate X position values.
  var count = 0;
  var count2 = 0;
  for(var i = 0; i < graphDataNeighbours.length; i++){
    //Check counts and restart if end of sub-section has been reached.
    if(count2 == graphDataSubValueY[count].length){
      count2 = 0;
      count++;
    }
    count2++;
    var minNeighbourCount = graphDataSubValueY[count].length / 100 * 0.5;

    //If the amount of neighbours are less than the minimum count, line the circle in the middle.
    if(graphDataNeighbours[i] < MIN_NEIGHBOUR_COUNT){
      graphDataX[i] = (count*100)+100;
    } else {
      var estimatedPercent = graphDataNeighbours[i] / maxNeighbourCount * 100;
      var estimatedSpread = (MAX_SPREAD_VALUE / 100) * estimatedPercent;

      if(estimatedSpread > bigSpreadLowerLimit){
        var randomNum = randomIntFromInterval(1, 4)
        if(randomNum == 1){
          graphDataX[i] = (count*100)+100+randomIntFromInterval(10, estimatedSpread);
        } else if(randomNum == 2){
          graphDataX[i] = (count*100)+100+randomIntFromInterval(-estimatedSpread, -10);
        } else {
          graphDataX[i] = (count*100)+100+randomIntFromInterval(-estimatedSpread, estimatedSpread);
        }
      }else{
        graphDataX[i] = (count*100)+100+randomIntFromInterval(-estimatedSpread, estimatedSpread);
      }
    }
  }
}

function findNeighbourCount(){
  for(var i = 0; i < graphDataSubValueY.length; i++){
    for(var j = 0; j < graphDataSubValueY[i].length; j++){
      var count = 0;
      var currentVal = parseFloat(graphDataSubValueY[i][j]);
      for(var k = j; k >= 0; k--) {
        var neighbourVal = parseFloat(graphDataSubValueY[i][k]);
          if( Math.abs(currentVal - neighbourVal) > NEIGHBOUR_LIMIT ){
            break;
          }
          count++;
      }
      for(var k = j; k < graphDataSubValueY[i].length; k++) {
        var neighbourVal = parseFloat(graphDataSubValueY[i][k]);
        if( Math.abs(currentVal - neighbourVal) > NEIGHBOUR_LIMIT ){
            break;
          }
          count++;
      }
      graphDataNeighbours.push(count);
      if(count > maxNeighbourCount){
        maxNeighbourCount = count;
      }
    }
  }
}

function colorCircles() {
  var colorIndex = 0;
  var count = 0;
  var count2 = 0;

  for(var i = 0; i < graphDataY.length; i++){
    if(count2 == graphDataSubValueY[count].length){
      count2 = 0;
      count++;
      colorIndex += 0.25;
    }
    count2++;
    if(colorIndex > 4){
      colorIndex = 0;
    }
    graphDataColors[i] = color(colorIndex);
  }
}

function refreshProbeSelect(probeArr) {
  removeSelectOptions(document.getElementById("probeSelect"))
  var select = document.getElementById("probeSelect");;
  var option;

  option = document.createElement("option");
  option.text = MAX_PROBE;
  select.add(option);

  probeArr.forEach(function(probe) {
    option = document.createElement("option");
    option.text = probe;
    select.add(option);
  });
}

function removeSelectOptions(selectbox) {
    var i;
    for(i=selectbox.options.length-1;i>=0;i--)
    {
        selectbox.remove(i);
    }
}

function changeSelectedProbe(givenValue, gene) {
  var dropdownlistbox = document.getElementById("probeSelect")
  
  for(var x=0;x < dropdownlistbox.length; x++)
  {
     if(givenValue == dropdownlistbox.options[x].text)
        dropdownlistbox.selectedIndex = x;
  }

  document.getElementById('gene_input').value = gene;
}

function getCircleSelection(){
  if(SVG.selectAll("circle").empty()){
    return false;
  } else {
    return true;
  }
}

function removeCorrelationLinks(data){

}

function addCorrelationLinks(data) {
  $("#popupCorrelation").empty();
  console.log("adding correlation links.")
  // console.log(data)
  var corrValueArray = [];
  data.forEach( function(d) {
    corrValueArray.push(parseFloat(d.value));
  });

  var corrColor = d3.scale.linear()
    .domain([d3.min(corrValueArray), 0, d3.max(corrValueArray)])
    .range(["#2980B9", "#FFFFFF", "#d12E20"]);

  var container = document.getElementById('popupCorrelation');
  
  if(typeof data !== 'undefined' && data.length > 0){
    container.style.padding = "10px";
    var count = 0;
    var t = document.createElement('table');
    var tb = document.createElement("tbody");
    
    t.id = "corr_table";
    t.style.whiteSpace = "nowrap";
    t.cellpadding = "50";
    /*t.border = 1;
    t.frame = "hsides";
    t.rules = "rows";*/ 
    
    //Create table row and headers.
    var tr = document.createElement("tr");
    var th = document.createElement("th"),
      th2 = document.createElement("th"),
      th3 = document.createElement("th");

    var a = document.createElement("p");

    //Style table headers.
    th.style.width = "110px";
    th2.style.width = "140px";
    th3.style.width = "50px";
    th.style.padding = "3px 10px 3px 10px";
      th2.style.padding = "3px 10px 3px 10px";
      th3.style.padding = "3px 10px 3px 10px";
      th.align = "center";
      th2.align = "center";
      th3.align = "center";

      //Inout header value/title.
    th.innerHTML = "<b>Value</b>";
    th2.innerHTML = "<b>Gene</b>";
    th3.innerHTML = "<b>Probe</b>";

    //Append to table.
    a.appendChild(th);
    a.appendChild(th2);
    a.appendChild(th3);
    tr.appendChild(a);
    tb.appendChild(tr);
    t.appendChild(tb);


    data.forEach( function(d) {
      count += 1;
      //Create table elements.
      tr = document.createElement("tr");
      tr.class = "corr_tr";
      tr.style.borderTop = "1px solid black";
        var td = document.createElement("td"),
          td2 = document.createElement("td"),
          td3 = document.createElement("td");

        //Style table data.
        td.style.minWidth = "110px";
        td2.style.minWidth = "140px";
        td3.style.minWidth = "100px";
        td.style.padding = "3px 10px 3px 10px";
        td2.style.padding = "3px 10px 3px 10px";
        td3.style.padding = "3px 10px 3px 10px";

        //Create link element and give id.
        a = document.createElement("a");
        a.id = "corrlink" + count;
        a.class = "corrlinkClass";
        a.style.color = "#424245";

        //Perform action when link is clicked.
        a.onclick = function(){
        if(~d.dataset.indexOf('_sc')){
          submitCorrelatingGene(d.corr_gene);
        } else {
          submitCorrelatingGene(d.probe_name2);
        }
          $("#popupCorrelation").hide();
          return false;
        };

        //Fill in table data.
        //console.log(d);
        if(d.value < 0){
          td.innerHTML = d.value;
          td.style.color = corrColor(d.value);
        } else{
          td.innerHTML = "&nbsp;" + d.value;
          td.style.color = corrColor(d.value);
        }
        td2.innerHTML = d.corr_gene;
        td3.innerHTML = d.probe_name2;

        //Append data all data inside of link tag.
        a.appendChild(td);
        a.appendChild(td2);
        a.appendChild(td3);

        //Append link into table row.
        tr.appendChild(a);

        //Add everything to the table body, then the table itself.
        tb.appendChild(tr);
        t.appendChild(tb);
    });

    //Add table to the container.
    container.appendChild(t);

  } else {
    var b = document.createElement("b");
    b.innerHTML = "-- No Gene Selected --";

    container.appendChild(b);
  }
}

function addCheckboxes() {
  $("#popupDropDown").empty();
  for(i=0; i<arrayValues.length; i++)
  {
    var container = document.getElementById('popupDropDown');
    var label = document.createElement('label');
    label.className = "listDropDown";
    label.style.display = "block";
    label.style.whiteSpace = "nowrap";
    label.style.margin = "3px 10px 3px 10px";

    var input = document.createElement('input');
    input.id = "cb"+(i+1);
    input.type = "checkbox";
    input.className = "listDropDown";
    input.onchange = selectPopulationChanged;
    input.value = arrayValues[i];

    label.appendChild(input);
    label.appendChild(document.createTextNode(arrayValues[i]));

    container.appendChild(label);

    $('#cb'+(i+1)).prop('checked', true);
  }
}

function removePopulationEntries(){
  var container = $('#popupDropDown');
    var inputs = container.find('input');

    for(var i = 0; i < inputs.length; i++){
      if(!$("#cb"+(i+1)).is(':checked')){
        arrayValues.splice(i-numberOfUnchecked, 1);
        medianArray.splice(i-numberOfUnchecked, 1);
        graphDataSubValueY.splice(i-numberOfUnchecked, 1);
        // nico:
        graphDataFullArray.splice(i-numberOfUnchecked, 1);
        numberOfUnchecked++;
      }
    }
}

function tickCheckboxes(arr){
  var container = $('#popupDropDown');
    var inputs = container.find('input');

    for(var i = 0; i < inputs.length; i++){
      var checkboxName = $("#cb"+(i+1)).val();
      if(arr.indexOf(checkboxName) > -1){
        //console.log(checkboxName);
        $("#cb"+(i+1)).prop('checked', true);
      }
    }
}

function untickCheckboxes(arr){
  var container = $('#popupDropDown');
    var inputs = container.find('input');
    for(var i = 0; i < inputs.length; i++){
      var checkboxName = $("#cb"+(i+1)).val();
      if(arr.indexOf(checkboxName) > -1){
        //console.log(checkboxName);
        $("#cb"+(i+1)).prop('checked', false);
      }
    }
}

function convert2DArrayToLog2(arr){
  var log2var = Math.log(2);
  for(var i = 0; i < arr.length; i++){
    for(var j = 0; j < arr[i].length; j++){
      arr[i][j] = Math.pow(2,arr[i][j]);
    }
  }
  return arr;
}

function exportAsCSV() {  
  if(currentGene != "noGene"){
    var textArray = getDataInFormatCSV();
    downloadFile(currentGene + "_log2", textArray);
  }
}

function getDataInFormatCSV(){
  var arrayCSV = Array();
  var tempArray = Array();
  var stringHeadCSV = currentGene + " (log2)";
  var stringCSV = "";

  for(var i = 0; i < graphDataProbes.length; i++){
    stringCSV += graphDataProbes[i];
    for(var j = i*arrayValues.length; j < (i*arrayValues.length)+arrayValues.length; j++){
      for(var k = 0; k < graphDataFullArray[j].length; k++){
        if(i == 0){
          stringHeadCSV += "," + arrayValues[j];
        }
        stringCSV += "," + graphDataFullArray[j][k];
      }
    }
    if(i == 0){
      stringHeadCSV += "\n";
    }
    stringCSV += "\n";
  }
  arrayCSV.push(stringHeadCSV + stringCSV);
  //console.log(arrayCSV);
  return arrayCSV;
}

function downloadFile(filename, text) {

  if((getBrowser() == "IE")){
    var blob = new Blob([text],{
        type: "text/csv;charset=utf-8;"
    });
    navigator.msSaveBlob(blob, filename + ".csv")

  } else if(getBrowser() == "Safari"){
    var tabSeperatedText = text.toString().replace(/\n/g,"<br>");
    //console.log(tabSeperatedText);
    var w = window.open(); // popup, may be blocked though
    w.document.open("text/csv");
    w.document.write(tabSeperatedText); // the csv string from for example a jquery plugin
    w.document.close();
    w.focus();
    w.document.execCommand('SaveAs');

  } else {
      var uri = 'data:text/csv;charset=utf-8,' + escape(text);
      var link = document.createElement("a");
      link.href = uri;
      link.style = "visibility:hidden";
      link.download = filename + ".csv";
      //alert(link.download);
      document.body.appendChild(link);
      link.click();
      document.body.removeChild(link);
  }
    //location.reload();
}

function downloadSVG(filename, text){

  if((getBrowser() == "IE")){
    var blob = new Blob([text],{
        type: "data:image/svg+xml;charset=utf8;"
    });
    navigator.msSaveBlob(blob, filename + ".svg")

  } else if(getBrowser() == "Safari"){
    var w = window.open(); // popup, may be blocked though
    w.document.open("svg");
    w.document.write(text); // the csv string from for example a jquery plugin
    w.document.close();

  }else{
    var uri = 'data:image/svg+xml;charset=utf8,' + encodeURIComponent(text);
      var link = document.createElement("a");
      link.href = uri;
      link.style = "visibility:hidden";
      link.download = filename + ".svg";
      document.body.appendChild(link);
      link.click();
      document.body.removeChild(link);
  }
}

function getBrowser() {
  if( navigator.userAgent.indexOf("Chrome") != -1 ) {
    return "Chrome";
  } else if( navigator.userAgent.indexOf("Opera") != -1 ) {
    return "Opera";
  } else if( (navigator.userAgent.indexOf("MSIE") != -1) || (navigator.userAgent.indexOf(".NET") != -1) ) {
    return "IE";
  } else if( navigator.userAgent.indexOf("Firefox") != -1 ) {
    return "Firefox";
  } else if( navigator.userAgent.indexOf("Safari") != -1 ){
    return "Safari";
  } else {
    return "unknown";
  }
}

function getCorrelations(dataset, probe, gene){
  console.log("/php/getCorrelationData.php?dataset=" + dataset + "&probe=" + probe + "&gene=" + gene);
  d3.json("/php/getCorrelationData.php?dataset=" + dataset + "&probe=" + probe + "&gene=" + gene, function(error, data) {
    if(error){ return console.log(error); }
    addCorrelationLinks(data);

  });
}

function chooseSearchedProbe(){
  var probeTxt = document.getElementById('gene_input').value;
  if (graphDataProbes.indexOf(probeTxt) > -1) {
      chosenProbe = probeTxt;
  }
}

function makeUpperCase(gene, dataset){
  if(dataset == "mouse"){
    gene = gene.charAt(0).toUpperCase() + gene.slice(1).toLowerCase();
  } else {
    gene = gene.toUpperCase();
  }
  return gene;
}

function nlLabelChange(dataset){

  if(dataset.length < 6){
    return false;
  }

  var datasetSubstring = dataset.slice(-5).toLowerCase();
  if(datasetSubstring == "vs_nl"){
    return true;
  } else{
    return false;
  }
}

function changeAxisLabel(dataset){
  if(!$("#Log2_scale").is(':checked')){
        if(nlLabelChange(dataset)){
            SVG.selectAll("#y-label").transition().duration(ANIMATION_TIME_MODIFIER*500)
            .style("opacity", "0").transition().duration(ANIMATION_TIME_MODIFIER*500)
            .style("opacity", "1")
            .text("fold change");
        } else {
            SVG.selectAll("#y-label").transition().duration(ANIMATION_TIME_MODIFIER*500)
            .style("opacity", "0").transition().duration(ANIMATION_TIME_MODIFIER*500)
            .style("opacity", "1")
            .text("expression");
        }
    } else {
        if(nlLabelChange(dataset)){
            SVG.selectAll("#y-label").transition().duration(ANIMATION_TIME_MODIFIER*500)
            .style("opacity", "0").transition().duration(ANIMATION_TIME_MODIFIER*500)
            .style("opacity", "1")
            .text("log2 fold change");
        } else {
            SVG.selectAll("#y-label").transition().duration(ANIMATION_TIME_MODIFIER*500)
            .style("opacity", "0").transition().duration(ANIMATION_TIME_MODIFIER*500)
            .style("opacity", "1")
            .text("log2 expression");
        }
    }
}


//GETTERS and SETTERS !!!

function getminY(){
  return minAxisY;
}

function getmaxY(){
  return maxAxisY;
}

function getmaxYBackup(){
  return maxAxisY_backup;
}

function getCellTypes(){
  return arrayValues;
}

function getHeight(){
  return height;
}

function getMedianArray(){
  return medianArray;
}

function getDataset(){
  return currentDataset;
}

function getDatasetChanged(){
  return datasetChanged;
}

function getCurrentGene(){
  return currentGene;
}

function getRange(){
  return range;
}

function setRange(){
  range = 0;
}

function setNeighbourLimit(){
  NEIGHBOUR_LIMIT = (maxAxisY - minAxisY) / 100*2;
  //console.log(NEIGHBOUR_LIMIT);
}

function setProbeChanged(bool){
  probeChanged = bool;
}

function setDatasetChanged(bool){
  datasetChanged = bool;
}

function setSelectPopulation(bool){
  selectPopulation = bool;
}

function setLog2Data(bool){
  log2Data = bool;
}

function setAnimationNumMedian(num){
  animationNumMedian = num;
}
function setTreeChanged(bool){
  treeChanged = bool;
}
