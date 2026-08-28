<?php
  require_once "php/globals.php";
?>
<!DOCTYPE HTML>

<html>
  <head>
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
    <meta http-equiv="X-UA-Compatible" content="IE=edge,chrome=1">
    <meta name="keywords" 
          content="BloodSpot, gene expression, hematopoietic, database, hematopoiesis, cells, microarray, leukemia, leukaemia, AML">
    <meta http-equiv="cleartype" content="on">
    <meta name="viewport" content="width=1000">

    <title>BloodSpot</title>
    <link rel="shortcut icon" href="images/icon.ico">
    <link rel="stylesheet" type="text/css" href="css/stylesheet.css">
    <link rel="icon"  type="image/x-icon" href="images/icon.ico"/>
    <!-- - - - - - - - - - - - - - - javascript  - - - - - - - - - - - - - - -->
    <script type="text/javascript" src="js/jquery-3.7.0.min.js"></script>
    <script type="text/javascript" src="js/jquery-ui-1.13.2.min.js"></script>
    <script type="text/javascript" src="js/d3.v3.min.js"></script>
    <script type="text/javascript" src="js/bootstrap-v5.3.1.min.js"></script>
    <script type="text/javascript" src="js/abbs.js"></script>
    <script type="text/javascript" src="js/HEScript.js" defer></script>
    <script type="text/javascript" src="js/data.js"></script>
    <script type="text/javascript" src="js/D3_celltree.js" defer></script>

    <script>
      /**************************** Initialization ****************************/
      var getSVG = 0;


      /****************************** Functions  ******************************/
      function getAbbList(dataset){
        d3.text("abbs/" + dataset + ".info", function(error, text) {
          if (error) return console.warn(error);
          //console.log(text);
          $('#dropdownContentAbbs').empty();
          var div = document.getElementById('dropdownContentAbbs');
          div.innerHTML = text;
          //console.log(text);
        });
      }

      function loadGraphData() {
        var txt = document.getElementById('gene_input').value;
        var x = document.getElementById('dataset').value;
        var e = document.getElementById("probeSelect");
        var probe = e.options[e.selectedIndex].value;
        
        const url_params = new URL(window.location).searchParams;
        const up_dataset = url_params.get('dataset');
        
        if (up_dataset && x!==up_dataset) {
            x = up_dataset;
        }
        
        
        loadGraph(txt, x, probe);
        getAbbList(x);
      }

      function transformAutocompleteSignatures(){
        // Overrides the default autocomplete filter function to search only 
        // from the beginning of the string
        $.ui.autocomplete.filter = function (array, term) {
          var matcher = new RegExp($.ui.autocomplete.escapeRegex(term), 'i');
          return $.grep(array, function (value) {
            return matcher.test(value.label || value.value || value);
          });
        };
      }

      function transformAutocompleteGenes(){
        // Overrides the default autocomplete filter function to search only 
        // from the beginning of the string
        $.ui.autocomplete.filter = function (array, term) {
          var matcher = new RegExp('(^| )' + $.ui.autocomplete.escapeRegex(term), 'i');
          return $.grep(array, function (value) {
            return matcher.test(value.label || value.value || value);
          });
        };
      }
      
      function printDiv(divName) {
        var printContents = document.getElementById(divName).innerHTML;
        //var originalContents = document.body.innerHTML;

        //document.body.innerHTML = printContents;

        var myWidnow = window.open();
        myWidnow.document.write(printContents)
        myWidnow.focus();
        myWidnow.print();

        //document.body.innerHTML = originalContents;
      }
      function download_survivalplot(){
        var e = document.getElementById("probeSelect");
        var probe = e.options[e.selectedIndex].value;
        var dataset = document.getElementById('dataset').value;
        if(~dataset.indexOf('_sc')){
          window.open("/surv/survplots/" + dataset + "/" + probe.trim() + ".pdf");
        }else{
          window.open("/surv/survplots/" + probe + ".pdf");
        }
      }

      function settingSVG(svg) {
        getSVG = svg;
      }

      function gettingSVG() {
        return getSVG;
      }
      
      function changeSelectedDataset(givenValue) {
        var dropdownlistbox = document.getElementById("dataset");
        for(var x=0;x < dropdownlistbox.length; x++) {
          if(givenValue == dropdownlistbox.options[x].value) {
            dropdownlistbox.selectedIndex = x;
            return;
          }
        }
        console.log('givenValue',givenValue);
        var new_option = document.createElement("option");
        new_option.text = givenValue;
        dropdownlistbox.add(new_option);
        dropdownlistbox.selectedIndex = dropdownlistbox.length - 1;
      }

      function getParams(url) {
        var paramsStart = url.indexOf('?');
        var params = null;
                
        //no params available
        if(paramsStart != -1) {
          var paramsString = url.substring(url.indexOf('?') + 1, url.length);
                    
          //only '?' available
          if(paramsString != "") {
            var paramsPairs = paramsString.split('&');
                        
            //preparing
            params = {};
            var empty = true;
            var index  = 0;
            var key = "";
            var val = "";
                       
            for(i = 0, len = paramsPairs.length; i < len; i++) {
              index = paramsPairs[i].indexOf('=');
                            
              //if assignment symbol found
              if(index != -1) {
                key = paramsPairs[i].substring(0, index);
                val = paramsPairs[i].substring(index + 1, paramsPairs[i].length);
                                
                if(key != "" && val != "") {
                                    
                  //extend here for decoding, integer parsing, whatever...
                                    
                  params[key] = val;
                                    
                  if(empty) {
                    empty = false;
                  }
                }                    
              }
            }
                        
            if(empty) {
              params = null;
            }
          }
        }
        return params;
      }

      function selectPopulationChanged(){
        setSelectPopulation(true);
        resetGraph();
      }
      
      function submitCorrelatingGene(probe){
          document.getElementById('gene_input').value = probe;
          resetGraph();
      }

      /******************************* Reactions ******************************/
      function toggleAbbs(){
        $('#dropdownContentAbbs').fadeToggle('500');
      }

      function toggleQuickGuide(){
        $('#dropdownContent').fadeToggle('500');
      }
      
      function resetGraph(){
        removeTTests();
        loadGraphData();
      }

      function submitGraph(){
        removeTTests();
        /*var urldata = window.location.href;
        var data = getParams(urldata);
        var gene = data["gene"];
        var dataset = data["dataset"];
        var e = document.getElementById("probeSelect");
        var probe = e.options[e.selectedIndex].value;
        loadGraph(gene, dataset, probe);*/
        loadGraphData();
      }

      function updateAutocomplete(ths){
        if(ths.length > 3){
          transformAutocompleteSignatures();
        } else {
          transformAutocompleteGenes();
        }
      }
      
      function showLog2Data(){
        var dataset = document.getElementById('dataset').value;
        changeAxisLabel(dataset);
        if(getCircleSelection()){
          setLog2Data(true);
          resetGraph();
        }
      }

      function showMedian(){
        if(getCircleSelection()){
          if($("#median").is(':checked')){
            setAnimationNumMedian(2);
            calculateMedian();
            drawMedians();
          } else {
            removeMedians();
          }
        }
      }

      function changeDataset(){
        var dataset = document.getElementById('dataset').value;
        var searchParams = new URLSearchParams(window.location.search);
        var this_href = new URL(window.location.href);
        this_href.searchParams.set("dataset", dataset);
        window.history.replaceState(null, null, this_href);
        setDatasetChanged(true);
        resetGraph();   
      }
      function resetZoom() {
        // Resets zoom. Is called when reset zoom button is pressed on the web
        // page.
        resetZoomBool = true;
        zoomTargets();
        resetZoomBool = false;
      }

      function resetZoomToNormal(){
        resetZoom();
      }

      function enableAndDiableZoom(){
        if($("#enableZoom").is(':checked')){
          resetZoom();
          alert_text  = "Zoom has been enabled.\nYou can now scroll on the "
          alert_text += "stripChart to zoom.\n\n(You can go back to the "
          alert_text += "original state of the stripChart by clicking \"Reset "
          alert_text += "Zoom\")"
          alert(alert_text);
          $("#resetZoom").css("display", "inline-block");
        } else {
          $("#resetZoom").css("display", "none");
        }
      }

      function toggleGridIndex(){
        toggleGrid();
      }

      function toggleCorrelations(){
        $("#popupCorrelation").toggle();
      }

      function hideCorrelations() {
        $("popupCorrelations").hide();
      }

      function addTTest(){
        var e = document.getElementById("ttestSelect1");
        var value1 = e.options[e.selectedIndex].value;

        var e = document.getElementById("ttestSelect2");
        var value2 = e.options[e.selectedIndex].value;

        if(value1 == value2){
          alert_text  = "You have selected two identical celltypes.\nT-Test can"
          alert_text += " only be performed for two different celltypes.\n"
          alert_text += "Please try again.";
          alert(alert_text);
        } else if(isDuplicateTTest(value1, value2)){
          alert_text  = "The selected T-Test is already shown on the plot.\n"
          alert_text += "Please try another set.";
          alert(alert_text);
        } else {
          var stars = calculatePValue(value1, value2);
          calculateTTestArray(value1, value2, stars);
          drawTTest();
        }
      }
      
      function downloadPlot() {
        if($("#mainSVG").is(":visible")) {
          printDiv("mainFrames");
          //download_SVG("mainSVG", "scatter");
        }

        if($("#svgMainTree").is(":visible")) {
          printDiv("mainFrames");
          //download_SVG("svgMainTree", "tree");
        }

        if($("#survImgMain").is(":visible")) {
          // printDiv("mainFrames");
          download_survivalplot();
        }
      }
      
      function exportDataAsText() {
         exportAsCSV();
      }

      function changeProbe(probe){
        setProbeChanged(true);
        resetGraph();
      }

      function showSurvivorPlot(){
        d3.selectAll("#mainSVG")
          .transition()
          .duration(800)
          .style("opacity", 0);
        
        d3.selectAll("#miniSVG")
          .style("box-shadow", "0px 0px 15px #888");

        d3.selectAll("#svgMainTree")
          .transition()
          .duration(600)
          .style("opacity", 0);
        
        d3.selectAll("#svgMiniTree")
          .style("box-shadow", "0px 0px 15px #888");

        d3.selectAll("#survImg")
          .style("box-shadow", "0px 0px 15px #048");

        d3.selectAll("#mainFrames")
          .transition()
          .duration(600)
          .style("min-height", "880px")
          .each("end", function(){
            d3.selectAll("#survImgMain")
              .style("margin-top", "50px")
              .transition()
              .duration(400)
              .style("opacity", 1);
            $("#survImgMain").css("display", "block");
            });
                
        $("#mainSVG").css("display", "none");
        $("#svgMainTree").css("display", "none");
      }

      function showStripChart(){

        d3.selectAll("#survImgMain")
          .transition()
          .duration(800)
          .style("opacity", 0);
        
        d3.selectAll("#survImg")
          .style("box-shadow", "0px 0px 15px #888");

        d3.selectAll("#svgMainTree")
          .transition()
          .duration(800)
          .style("opacity", 0);
        
        d3.selectAll("#svgMiniTree")
          .style("box-shadow", "0px 0px 15px #888");

        d3.selectAll("#miniSVG")
           .style("box-shadow", "0px 0px 15px #048");

        d3.selectAll("#mainFrames")
          .transition()
          .duration(600)
          .style("min-height", "642px")
          .each("end", function(){
            $("#mainSVG").css("display", "block");
            d3.selectAll("#mainSVG")
              .transition()
              .duration(400)
              .style("opacity", 1);
            });

        $("#svgMainTree").css("display", "none");
        $("#survImgMain").css("display", "none");          
      }

      function showTreePlot(){
        d3.selectAll("#mainSVG")
          .transition()
          .duration(800)
          .style("opacity", 0);

        d3.selectAll("#miniSVG")
          .style("box-shadow", "0px 0px 15px #888");

        d3.selectAll("#survImgMain")
          .transition()
          .duration(800)
          .style("opacity", 0);
 
        d3.selectAll("#survImg")
          .style("box-shadow", "0px 0px 15px #888");

        d3.selectAll("#svgMainTree")
          .transition()
          .duration(1200)
          .style("opacity", 1);
 
        d3.selectAll("#svgMiniTree")
          .style("box-shadow", "0px 0px 15px #048");

        d3.selectAll("#mainFrames")
          .transition()
          .duration(600)
          .style("min-height", "620px");

        $("#mainSVG").css("display", "none");
        $("#survImgMain").css("display", "none");
        $("#svgMainTree").css("display", "block");
      }

      $(".submitbutton").keyup( function (e) {
        if (e.keyCode == 13) {submitGraph();} 
      });

      $('.corr_tr').click( function() {
        window.location = $(this).find('a'); })
                   .hover( function() {
        $(this).toggleClass('hover'); 
      });

      /***************************** Finalization *****************************/
      $(document).ready( function() {

        //Get list of dataset.
        $("#dataset").load('<?php echo $GETDATASET_PAGE_URL;?>', function() {
          var getSVG;
          var urldata = window.location.href;
          var data = getParams(urldata);
          if(data != null){
            var gene = data["gene"];
            var dataset = data["dataset"];
            var exportSvg = data["exportsvg"];
            getSVG = data["SVG"];
            var e = document.getElementById("probeSelect");
            var probe = e.options[e.selectedIndex].value;
            settingSVG(getSVG);

            loadGraph(gene, dataset, probe);
            getAbbList(dataset);
            changeSelectedDataset(dataset);
                       
            //setTimeout(download_SVG("mainSVG", "scatter"),6000);
            //console.log(data["gene"]);
            //console.log(data["dataset"]);   
          }
        });
  
        //Initialize everything for D3.
        $('.dropdown-menu').on("click", function(e) {
           e.stopPropagation();
        });

        $(".dropdown").on("click",function (e) {
          $(this).toggleClass('open');
        });

        d3.selectAll("#survImgMain")
          .style("opacity", 0);
        d3.selectAll("#svgMainTree")
          .style("opacity", 0);
        d3.selectAll("#miniSVG")
          .style("box-shadow", "0px 0px 10px #048");
        
        var mainSVG = $('#mainSVG');
        mainSVG.height(mainSVG.height()*1.1);
        var miniSVG = $('#miniSVG');
        miniSVG.height(miniSVG.height()*1.1);
        
        //Disable zoom reset as default
        $("#resetZoom").css("display", "none");

        transformAutocompleteGenes();

        var minAcLength = 2;

        //Load autocomplete entries.
        $.ajax({
          type: "GET",
          url: "autocomplete_list.txt",
          dataType: "text",
          success: function(data) {
            var entries = data.split('\n');
            var availableTags = [];
            availableTags = entries;
            $("#gene_input").autocomplete({
              minLength: 2,
              select: function () {
                setTimeout(function(){document.getElementById("gene_input_button").click(); }, 10);
              },
              source: function(request, response) {
                if(request.term.length >= minAcLength){
                  request.term = request.term.replace(" ", "_");
                }
                var results = $.ui.autocomplete.filter(availableTags, request.term);
                response(results.slice(0, 15));
              }
            });
          }
        });
        
        $('#dropdownContentAbbs').hide();
        $('#dropdownContent').hide(); 
      });
    </script>
  </head>
  <body>
    <div id="pagewrap">
      <form id="svgform" onsubmit="resetGraph(); return false">
        <div id="wrappergrid3" class="wrapper fullwidth">
          <div id="contentGraphic"><!-- BloodSpot -->
            <table style="margin: 0px; width:92%;">
              <tr>
                <td style="width:27%;" 
                    title="Write the genename alias you want to look up. Only unique aliases will result in a plot">
                  <b>Type gene symbol or alias:</b>
                  <div class="ui-widget">
                    <input type="text" 
                           onkeyup="updateAutocomplete(this.value);" 
                           value="SOD1" 
                           id="gene_input" 
                           size="15" 
                           autocomplete="on" 
                           autofocus="autofocus" >
                    <input id="gene_input_button" 
                           class="submitButton" 
                           type="button" 
                           value="Submit" 
                           onclick="submitGraph()" >
                  </div>
                  <div>
                    <input type="checkbox" 
                           checked="check" 
                           id="Log2_scale" 
                           onChange="showLog2Data()" >Data in log2</input>
                    <input type="checkbox" 
                           checked="check" 
                           id="median" 
                           onChange="showMedian()" >Show median</input> 
                    <br>
                  </div>  
                  <div>
                    <a class="transition" 
                       onClick="scrollToId('quickguide')"> 
                       -- Help and Description of Data --</a>
                  </div>
                </td>
                <td style="width:27%;" title="Select dataset">
                  <b>Select dataset:</b>
                  <select id="dataset" 
                          onchange="changeDataset();" 
                          onkeypress="changeDataset();">
                  </select>
                  </br>
                  <input type="checkbox" 
                         id="enableZoom" 
                         onChange="enableAndDiableZoom()" >
                         Enable Zoom</input>
                  </br>
                  <input type="checkbox" 
                         id="toggleGrid" 
                         onChange="toggleGridIndex()" > 
                         Grid </input>
                </td>
                <td style="width:20%;" 
                    title="Welcome to BloodSpot">
                <img src="images/logo_h_xxx.png" 
                     alt="BloodSpot" 
                     style="float:right" 
                     height="60">
                </td>
              </tr>
            </table>
            <hr style="width:92%; margin: 5px 0 10px 0">
            <table style="margin: 0 0 0 17px; width:92%;">
              <tr>
                <td>
                  <div class="dropdown" style="display:inline">
                    <button data-toggle="dropdown" 
                            class="btn btn-success" 
                            type="button" 
                            id="pops" >
                            Select Populations</button>
                    <ul id="popupDropDown" 
                        class="dropdown-menu" 
                        role="menu" 
                        aria-labelledby="dLabel">
                      <b>-- No Gene Selected --</b>
                    </ul>
                  </div>
                  <div class="dropdown" style="display:inline">
                    <button data-toggle="dropdown" 
                            class="btn btn-success" 
                            type="button" 
                            id="pops" 
                            onclick="toggleCorrelations()">
                            Gene Correlations</button>
                    <ul id="popupCorrelation" 
                        class="dropdown-menu" 
                        role="menu" 
                        aria-labelledby="dLabel">
                      <b>-- No Gene Selected --</b>
                    </ul>
                  </div>
                  <div class="dropdown" style="display:inline">
                    <button data-toggle="dropdown" 
                            class="btn btn-success" 
                            type="button" 
                            id="pops" >
                            T-Test</button>
                    <ul id="popupTTest" 
                        class="dropdown-menu" 
                        role="menu" 
                        aria-labelledby="dLabel">
                      <b style="margin: 10px">
                        Select to celltypes for T-Test.
                      </b>
                      <table id="ttest_table" 
                             cellpadding="50" 
                             style="white-space: nowrap;">
                        <tr>
                          <td style="padding: 10px 10px 10px 10px;">
                            <select id="ttestSelect1" style="min-width: 75px;">
                              <option>No gene Selected</option>
                            </select>
                          </td>
                          <td style="padding: 10px 10px 10px 10px;">
                            <select id="ttestSelect2" style="min-width: 75px;">
                              <option>No gene Selected</option>
                            </select>
                          </td>
                        </tr>    
                      </table>
                      <hr style="width:100%; margin: 7px 0 2px 0"/>
                        <button type="button" 
                                style="min-width: 39%; margin: 5%; padding: 3px 2.5% 3px 2.5%;"  
                                onclick="addTTest()" >
                                Add to Plot</button>
                        <button type="button" 
                                style="min-width: 39%; margin: 5%; padding: 3px 2.5% 3px 2.5%;"
                                onclick="submitGraph()" >
                                Reset plot</button>
                    </ul>
                  </div>
                  <button class="btn btn-success" 
                          type="button" 
                          onClick="downloadPlot()">
                          Print as PDF</button>
                  <!--<button class="btn btn-success" 
                              type="button" 
                              onClick="download_PDF()">
                              Export stripChart (PDF)</button>-->
                  <button class="btn btn-success" 
                          id="export_text" 
                          type="button" 
                          OnClick="exportDataAsText()">
                          Export Data as Text</button>
                  <button id="resetZoom" 
                          class="btn btn-success" 
                          type="button" onclick="resetZoomToNormal()">
                          Reset zoom</button>
                </td>
                <td>
                  <select id="probeSelect" 
                          onchange="changeProbe(this.value);" 
                          onkeypress="changeProbe(this.value);">
                    <option>No gene selected</option>
                  </select>
                </td>
              </tr>
            </table>
            <div class="vignette">
              <table class="menuTable">
                <tr>
                  <td>
                    <img id="survImg" class="survPlot" onclick="showSurvivorPlot()"/>
                  </td>
                  <td>
                    <div id="scatterDiv" onclick="showStripChart()">
                      <svg id="miniSVG" 
                           class="SVG" 
                           viewBox="0 0 958 598" 
                           style="pointer-events: none;"></svg>
                    </div>
                  </td>
                  <td>
                    <div id="treeDiv" onclick="showTreePlot()">
                      <svg id="svgMiniTree" 
                           class="treeSVG" 
                           viewBox="0 0 1024 642" 
                           style="pointer-events: none;"></svg>
                    </div>
                  </td>
                </tr>
              </table>
            </div>
            <div id="mainFrames" style="min-height: 642px;">              
              <svg id="mainSVG" 
                   class="SVG" 
                   xmlns="https://www.w3.org/2000/svg" 
                  version="1.1"></svg>
              <svg id="svgMainTree" 
                   class="treeSVG" 
                   viewBox="0 0 1024 600" 
                   style="display: none"></svg>
              <img id="survImgMain" 
                   class="survPlot" 
                   style="display: none; width: 90%; height: 80%;"/>
            </div>
            <div id="tree">
            </div>
  
            <noscript>
              <p>
                JavaScript is required to view the contents of this page.
              </p>
            </noscript>
          </div> <!-- contentGraphic slut -->
        </div><!-- /wrapper -->
      </form>
      <p>
        <a id="abbreviations" onclick="toggleAbbs(); return false;">
           Description of the data (click to expand)  &nbsp;&#187;</a>
      </p>
      <div id="dropdownContentAbbs">
        No abbreviations found. Please submit a gene first.
      </div>
      <p>
        <a id="quickguide" onclick="toggleQuickGuide(); return false;">
           Quick Guide (click to expand) &nbsp;&#187;</a>
      </p>
      <div id="dropdownContent">
        <p>
          Bloodspot provides a plot of gene expression in hematopoietic cells at 
          different maturation stages based on curated microarray data. The 
          server accepts a unique gene name (gene alias) or a gene signature 
          name from the MSigDB  database (there is an auto-complete mechanism to 
          help finding the right names).
        </p>
        <p>
          Type a gene alias and press submit to display its expression pattern. 
          Click in any of the top 3 panels to magnify its content.
        </p>
        <p> 
          Three concomitant levels of visualisation are available:<br>
          - Improved jitter strip chart of gene expression, a swift novel 
          visualisation plot that draws from bar plots and violin plots.<br>
          - An interactive hierarchical tree that shows the relationship between 
          the samples displayed and allows changing the focus of the display.
          <br>
          - Survival plot based on a high quality AML dataset that displays 
          visually a full Kaplan-Meier analysis for any query gene or gene 
          signature.<br>
        </p>
        <p>
          The <kbd>Select Population</kbd> button allows to select which 
          populations to display.
        </p>
        <p>
          The <kbd>Gene Correlations</kbd> button shows in a table how much 
          other genes or gene signatures correlate with the displayed gene. It 
          is possible to click on the genes in the table to display their expression profile.
        </p>

        <p>
          The <kbd>Print as PDF</kbd> button allows you to export the current 
          plot in pdf format.
        </p>
        <p>
          The <kbd>T-Test</kbd> button allows you to perform significance test 
          between pairs of populations. Legend is as following: NS: non 
          sigificant; *: p&lt;0.05 ; ** p&lt;0.01; *** p&lt;0.001.
        </p>
        <p>
          The <kbd>Export Data as Text</kbd> button allows you to export the 
          raw data as text (CSV format).
        </p>
        <!--
        <p>
          The <kbdblue>Upload your own sample</kbdblue> button allows to 
          upload an Affymetrix HU133 plus 2.0 .CEL file and see it in the 
          context of normal hematopoiesis.
        </p>
        -->
        <p>
          Use the drop down menu in the upper right corner of the main plot 
          to select a probe representing your gene of interrest. By default 
          the probe with the highest intensity is chosen.
        </p>
        <p>
          At the bottom of the main plot, a list of abbreviation is availble.
        </p>
        <p></p>
        <p>
          A video tutorial is available bellow:
        </p>
        <video width="960" height="540" controls="controls">
          <source src="./media/BloodSpot_logo.mp4" type="video/mp4">
        </video>
        <p></p>
        <p>
    See our <a href="<?php echo $HELP_PAGE_URL;?>" 
                   class="transition">help section</a> 
          for further information on BloodSpot.
        </p>
      </div>
          <p>
      <a href="<?php echo $HELP_PAGE_URL;?>" class="transition">
               Help and Description of Data</a>
          </p>
          <br>
        </div><!-- /Pagewrapper -->
      </div>
    </div>
    <?php include $FOOTER_TEMPLATE_PATH; ?>
  </body>
</html>
