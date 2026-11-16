var arrayValuesTree = Array();
var jsonLength = 0;
var AMLsIncluded = false;
var max_median_possible = 15;
var min_median_possible = 3;
var max_median;
var min_median;

var m = [40, 120, 20, 120],
	w = 1024 - m[0] - m[03],
	h = 600 - m[0] - m[02],
	i = 0,
	root;

var tree = d3.layout.tree()
	.size([h, w]);

var x = d3.scale.ordinal()
    .rangeRoundBands([0, width], .1, .3);

var diagonal = d3.svg.diagonal()
	.projection(function(d) { return [d.y, d.x]; });



var vis = d3.selectAll(".treeSVG")
	.attr("width", w + m[1] + m[3])
	.attr("height", h + m[0] + m[2])
  .append("svg:g")
	.attr("transform", "translate(" + m[3] + "," + m[0] + ")");

var gradient = vis.append("svg:defs")
  .append("svg:linearGradient")
    .attr("id", "gradient")
    .attr("x1", "100%")
    .attr("y1", "0%")
    .attr("x2", "100%")
    .attr("y2", "100%")
    .attr("spreadMethod", "pad");

gradient.append("svg:stop")
    .attr("offset", "0%")
    .attr("stop-color", "#d12E20")
    .attr("stop-opacity", 1);

gradient.append("svg:stop")
    .attr("offset", "50%")
    .attr("stop-color", "#fff")
    .attr("stop-opacity", 1);

gradient.append("svg:stop")
    .attr("offset", "100%")
    .attr("stop-color", "#2980B9")
    .attr("stop-opacity", 1);

//Create background. The mouse must be over an object on the graph for the zoom to work. The rectangle will cover the entire graph.
rect = vis.append("rect")
	.attr("width", 20)
    .attr("height", 80)
    .attr("rx", 5)
    .attr("ry", 5)
    .attr("x", 0)
    .attr("y", 0)
    .style("fill", "url(#gradient)")
    .style("stroke", "#bbb");

 vis.append("text")
 	.attr("class", "minMedianVal")
 	.attr("x", 22)
 	.attr("y", 81)
 	.style("text-anchor", "left")
	.style("font-size", "11")
  	.style("font-family", "helvetica, Georgia, 'Times New Roman', serif")
  	.text("");

 vis.append("text")
  	.attr("class", "maxMedianVal")
 	.attr("x", 22)
 	.attr("y", 7)
 	.style("text-anchor", "left")
	.style("font-size", "11")
  	.style("font-family", "helvetica, Georgia, 'Times New Roman', serif")
  	.text("");

 vis.append("text")
  	.attr("class", "RectLegend")
 	.attr("x", -70) //-75 if bold
 	.attr("y", 45)
 	.style("text-anchor", "left")
	.style("font-size", "13")
  	.style("font-family", "helvetica, Georgia, 'Times New Roman', serif")
  	//.style("font-weight", "bold")
  	.text("Expression");

vis.append("text")
  .attr("class", "graphTitle")
  .attr("x", w/2-100)
  .attr("y", 0)
  .style("text-anchor", "middle")
  .style("font-size", "16")
  .style("font-family", "helvetica, Georgia, 'Times New Roman', serif")
  .style("font-weight", "bold")
  .text(currentGene);

var nodeColor = d3.scale.linear()
	.domain([3, 9, 15])
	.range(["#2980B9", "#fff", "#d12E20"]);
var fontSize = d3.scale.linear()
	.domain([7, 40])
	.range([11, 2]);

var div2 = d3.select("body").append("div")   
	.attr("class", "tooltip2")               
	.style("opacity", 0)
	.style("min-width", "10px");


function updateTree(filename){
  d3.json("D3/trees/" + filename +".json", function(json) {//"flare.json", function(json) {
    if (!json) {
      console.warn("No tree available for dataset: " + filename);
      clearTree();
      return;
    }
	var celltypesIncluded = getCellTypes();
	var medianSizes = getMedianArray();
	//console.log(JSON.stringify(json).split(','));
	function traverseAndRemoveNodes(target, median, jsonTree) {
		//Change median size
		if(celltypesIncluded.indexOf(jsonTree["name"]) > -1){
			for(var i = 0; i < target.length; i++){
				if(target[i] == jsonTree["name"]){
					jsonTree["size"] = median[i];
				}
				if(jsonTree["name"] == "AMLs" || jsonTree["name"] == "NormalCells"){
					jsonTree["size"] = 0;	
				}
			}
		}

		if(jsonTree["children"]){
			var children = jsonTree["children"];
			for(var i = 0; i < children.length; i++) {
				var node = children[i];
				//console.log(jsonTree["name"] + " - " + node["name"]);
				if(getDataset() == "immgen_Stem_and_progenitor_cells"){ <!-- this is a hack to make safari draw the tree -->
					var test = (node["name"] != "CMP" && node["name"] != "preT.ETP" && node["name"] != "GMP" && node["name"] != "CLP" && node["name"] != "MDP" && node["name"] != "CDP");
				}
				if(node["name"] != "AMLs" && node["name"] != "NormalCells" && node["name"] != " " && node["name"] != ""  && node["name"] != "CMP" && node["name"] != "preT.ETP" && node["name"] != "GMP" && node["name"] != "CLP" && node["name"] != "MDP" && node["name"] != "CDP"){
					if((!(celltypesIncluded.indexOf(node["name"]) > -1))) {
						//console.log("Matched");
						var grandChildren = node["children"];
						if(grandChildren){	
							children.splice.apply(children,[i,1].concat(node["children"]));
							//console.log("REMOVE");
						} else {
							children.splice(i,1);
							//console.log("REMOVE");
						}
						i--;
					}
				} else {
					if(node["name"] != " "){
						AMLsIncluded = true;
					}
				}
				traverseAndRemoveNodes(target, median, node);
			}
		}
	}

	function normalizeMedians(median){

		max_median = d3.max(median);
		min_median = d3.min(median);

		for(var i = 0; i < median.length; i++){
			median[i] = median[i] = min_median_possible + (median[i] - min_median) * (max_median_possible - min_median_possible) / (max_median - min_median)
		}
		//console.log(median);

		return median;
	}
	//console.log(celltypesIncluded);
	medianSizes = normalizeMedians(medianSizes);
	traverseAndRemoveNodes(celltypesIncluded, medianSizes, json);
	//console.log(json);

	root = json;
	root.x0 = h / 2;
	root.y0 = 0;

	function toggleAll(d) {
		if (d.children.length === 1) {
			//next will be the first node we find with more than one child
			var next = d.children[0];
			for (;;) {
				if (next.children.length === 1) {
					next = next.children[0];
				} else if (next.children.length > 1) {
					break;
				} else {
					//you'll have to handle nodes with no children
				}
			}

			d._children = d.children;
			d.children = [next];
		}
	}

	// Initialize the display to show a few nodes.
	//root.children.forEach(toggleAll);
	drawTree(root);
	updateLegend();
  });
}

function drawTree(source) {
		vis.selectAll(".graphTitle")
			.transition().duration(800)
			.attr("x", w/2-100)
	  		.attr("y", -100)
			.style("text-anchor", "middle")
			.style("font-size", "16")
			.style("font-family", "helvetica, Georgia, 'Times New Roman', serif")
			.style("font-weight", "bold")
			.transition().duration(700)
			.attr("x", w/2-100)
	  		.attr("y", 0)
			.text(function(){
				var ds = getDataset();
				
				if(ds == "normal_human_v2_with_AMLs" ||  ds == "DMAP" || ds == "immgen_Key_populations" || ds == "immgen_Stem_and progenitor_cells" || ds == "nl_human_data_HemaExp_v_1" || ds == "nl_mouse_data"  ){
					if (ds ==  "nl_mouse_data"  || (ds.substring(0,6) == "immgen") ){
						return mousify(getCurrentGene()) + " (Hierarchical differentiation tree)";
					}else{
						return getCurrentGene() + " (Hierarchical differentiation tree)";
					}
				}else{
					if ( (ds.substring(0,6) == "immgen") ){
					return mousify(getCurrentGene()) + " (Correlation of samples)";
				}else{
					return getCurrentGene() + " (Correlation of samples)";
				}
			}
			});
	
  var duration = d3.event && d3.event.altKey ? 5000 : 500;

  // Compute the new tree layout.
  var nodes = tree.nodes(root).reverse();

  // Normalize for fixed-depth.
  nodes.forEach(function(d) { d.y = d.depth * 60; });

  // Update the nodesâ€¦
  var node = vis.selectAll("g.node")
	  .data(nodes, function(d) { return d.id || (d.id = ++i); });

  // Enter any new nodes at the parent's previous position.
  var nodeEnter = node.enter().append("svg:g")
	  .attr("class", "node")
	  .attr("transform", function(d) { return "translate(" + source.y0 + "," + source.x0 + ")"; })
	  .on("click", function(d) { toggle(d); drawTree(d); })
	  .on("mouseover", function(d){ 
            div2.transition()        
               .duration(300)      
                .style("opacity", .9);      
            div2.html(findAbbDescription(d.name) + "<br/>" )  
                .style("left", (d3.event.pageX) + "px")     
                .style("top", (d3.event.pageY - 15) + "px")
                .style("width", (findAbbDescription(d.name).length*8)+"px");


            })
	  .on("mouseout", function(d) {       
            div2.transition()        
                .duration(500)      
                .style("opacity", 0);   
        });   

  nodeEnter.append("svg:circle")
	  .attr("r", 1e-6)
	  .style("fill", function(d) { return "#fff"; });
	             

  

  nodeEnter.append("svg:text")
	  //.attr("x", function(d) { return 10; })
	  .attr("dy", ".35em")
	  .attr("text-anchor",function(d) { return d.children || d._children ? "middle" : "left"; })
	  .attr("text-anchor",function(d) { var ret = "" ; if ( d.children || !(d._children) ) { ret = "right";  } return ret ; })
	  .attr("x", function(d) { return d.children || d._children ? -0 : 0; })
	  .text( function(d) {  return d.name.substring(0, 10); })  //See line 296
	  .style("fill-opacity", 1e-6);


//////////////////////////////

  // Transition nodes to their new position.
  var nodeUpdate = node.transition()
	  .duration(duration)
	  .attr("transform", function(d) { return "translate(" + d.y + "," + d.x + ")"; });

  nodeUpdate.select("circle")
	  .attr("r", function(d, i) {return d.size;} )//14.5)
	  .style("fill", function(d, i) { 
	  	if(d.visualize == 0){
	  		return "white";
	  	}else{
	  		return nodeColor(d.size);
	  	}
	  })
	  .style("stroke", function(d, i){
	  	if(d.visualize == 0){
	  		return "#bbb";
	  	}
	  })
	  .style("opacity", function(d, i){
	  	if(d.visualize == 0){
	  		return 0;
	  	}
	  });

  nodeUpdate.select("text")
	  .text(function(d) {
	  		var ret = "";
	  		if (d.name.indexOf("AML") > -1 ||  d.name.indexOf("ALL") > -1){
	  			ret = d.name
	  		}else{
	  			if (d.name.length > 7 && (d.children || d._children)){
	  				ret = d.name.substring(0, 7) + "â€¦";	
	  			} else{
	  				ret = d.name
	  			}
	  		}
	  		return ret;
	   })
	  .style("font-family", "Verdana")
	  .style("fill-opacity", 1);
//	  .call(wrap2, 50);

  // Transition exiting nodes to the parent's new position.
  var nodeExit = node.exit().transition()
	  .duration(duration)
	  .attr("transform", function(d) { return "translate(" + source.y + "," + source.x + ")"; })
	  .remove();

  nodeExit.select("circle")
	  .attr("r", 1e-6);

  nodeExit.select("text")
	  .style("fill-opacity", 1e-6);

  // Update the linksâ€¦
  var link = vis.selectAll("path.link")
	  .data(tree.links(nodes), function(d) { return d.target.id; });

  // Enter any new links at the parent's previous position.
  link.enter().insert("svg:path", "g")
	  .attr("class", "link")
	  .attr("d", function(d) {
		var o = {x: source.x0, y: source.y0};
		return diagonal({source: o, target: o});
	  })
	.transition()
	  .duration(duration)
	  .attr("d", diagonal);

  // Transition links to their new position.
  link.transition()
	  .duration(duration)
	  .attr("d", diagonal);

  link.style("stroke", function(d, i){
  	//console.log(d.target.name);
  	//console.log(d.target.draw_parent_line);
  	if(d.target.draw_parent_line == 0){
  		return "white";
  	} else {
  		return "#ccc";
  	}
  });
  //console.log("all: " + ((link.size()/2)-2) + " - " + ((link.size()/2)-1));

  // Transition exiting nodes to the parent's new position.
  link.exit().transition()
	  .duration(duration)
	  .attr("d", function(d) {
		var o = {x: source.x, y: source.y};
		return diagonal({source: o, target: o});
	  })
	  .remove();

  // Stash the old positions for transition.
  nodes.forEach(function(d) {
	d.x0 = d.x;
	d.y0 = d.y;
  });

  AMLsIncluded = false;

    //CSS
$(".node circle").css({"cursor":"pointer", "fill":"#fff", "stroke-opacity":".51", "stroke":"steelblue", "stroke-width":"1.5px"});
$("path.link").css({"fill":"none", "stroke-width":"1.5px"});
$(".node text").css({"font-size":"11px"});
}

// Toggle children.
function toggle(d) {
arrayValuesTree = [];
jsonLength = 0;
  if (d.children) {
  	//Remove descendents and move the entire subtree to _children
	d._children = d.children;
	d.children = null;
	
	//Find names for all nodes in subtree
	traverse(d);
	jsonLength = jsonLength - 1;

	//Untick checkboxes that correspond to nodes removed.
	untickCheckboxes(arrayValuesTree);
  } else {
  	//Return subtree with all descendents back to children.
	d.children = d._children;
	d._children = null;
	
	//Find names for all nodes in subtree.
	traverse(d);
	jsonLength = jsonLength - 1;

	//Tick checkboxes that correspond to the nodes shown again.
	tickCheckboxes(arrayValuesTree);
  }

  setTreeChanged(true);
  selectPopulationChanged();	
}

function traverse(jsonObj) {
	if(jsonObj["children"]){
		var children = jsonObj["children"];
		for(var i = 0; i < children.length; i++) {
			var node = children[i];
			arrayValuesTree.push(node["name"]);
			jsonLength += 1;
			traverse(node);
		}
	} else if(jsonObj["_children"]){
		var children = jsonObj["_children"];
		for(var i = 0; i < children.length; i++) {
			var node = children[i];
			arrayValuesTree.push(node["name"]);
			jsonLength += 1;
			traverse(node);
		}
	}
}

function mousify(text){
	return text.substring(0,1) + text.substring(1,text.length).toLowerCase()
}


function updateLegend(){
	 vis.select(".minMedianVal")
	 	.transition().duration(500)
	 	.style("opacity", "0")
	 	.text(min_median.toFixed(1).toString())
	 	.transition().duration(500)
	 	.style("opacity", "0.8");

	 vis.select(".maxMedianVal")
	 	.transition().duration(500)
	 	.style("opacity", "0")
	 	.text(max_median.toFixed(1).toString())
	 	.transition().duration(500)
	 	.style("opacity", "0.8");
}


// Remove the tree that is currently drawn (used when a dataset has no tree JSON).
function clearTree() {
  vis.selectAll("g.node").remove();
  vis.selectAll("path.link").remove();
  vis.selectAll(".graphTitle").text("");
}
