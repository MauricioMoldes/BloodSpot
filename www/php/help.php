<?php 
  require_once "globals.php";
?>
<!DOCTYPE HTML>
<meta name="robots" content="noindex" />
<html xmlns="http://www.w3.org/1999/xhtml" lang="en">
  <head>
    <title>BloodSpot &#45; help</title>
    <meta name="language" content="en" />
    <meta http&#45;equiv="Content&#45;Type" 
          content="text/html; charset=iso&#45;8859&#45;1" />
    <link rel="stylesheet" type="text/css" href="../css/stylesheet.css" />
    <link rel="icon"  type="image/x&#45;icon" href="../images/icon.ico"/>
    
    <style type="text/css">
      table.altrowstable { font-family: verdana,arial,sans-serif;
                           font-size:11px;
                           color:#333333;
                           border-width: 1px;
                           border-color: #a9c6c9;
                           border-collapse: collapse; }
      table.altrowstable th { border-width: 1px;
                              padding: 8px;
                              border-style: solid;
                              border-color: #a9c6c9; }
      table.altrowstable td { border-width: 1px;
                              padding: 8px;
                              border-style: solid;
                              border-color: #a9c6c9; }
      .oddrowcolor{ background-color:white; }
      .evenrowcolor{ background-color:#2dabf9; }
    </style>

    <script type="text/javascript">
      function altRows(id){
        if(document.getElementsByTagName){  
          var table = document.getElementById(id);  
          var rows = table.getElementsByTagName("tr"); 
	  
	  for(i = 0; i < rows.length; i++){          
            if(i % 2 == 0){
              rows[i].className = "evenrowcolor";
            } else {
              rows[i].className = "oddrowcolor";
            }      
          }
        }
      }
      window.onload = function(){
        altRows('alternatecolor');
      }
    </script>
  </head>
 <body>
   <div id="wrappergrid5" class="wrapper fullwidth">
     <div id="contentGraphic">
       <img src="../images/logo_h_100.jpg" alt="BloodSpot" style="float:right">
       <h1>BloodSpot help and information page</h1>
       <p>
         <a href="../">Go back to webserver</a>
       <p>
   <video width="960" height="540" controls="controls">
     <source src="../media/BloodSpot_logo.mp4" type="video/mp4">
   </video>
     <h2>Introduction</h2>
     <p>
       BloodSpot is a database that provides gene expression profiles of genes 
       and gene signatures in healthy and malignant hematopoiesis and includes 
       data from both humans and mice. In addition to the default plot, that 
       displays an integrated expression plot, two additional levels of 
       visualization are available; an interactive tree showing the hierarchical 
       relationship between the samples, and a Kaplan&#45;Meier survival plot. 
       The database is sub&#45;divided into several datasets that are accessible 
       for browsing.
     </p>	
     <p>
       A short quick guide is available on the main page and can be expanded by 
       clicking &#34;Quick Guide&#34; under the main plot. Clicking on the three 
       plots above the main viewing area will enlarge the selected plot and 
       display it in the main viewing area.
     </p>
     <h2>Datasets</h2>
     <p>
       Datasets are organized by organism of origin and disease status, and 
       includes human healthy hematopoietic cells, human leukemia and healthy 
       mouse hematopoietic cells. All datasets available were generated using 
       oligonucleotide microarray chips, except for one mouse dataset that was 
       generated using RNA&#45;Seq.
     </p>
     <p>
       There are 23 different datasets to choose from:
     </p>
     <table>
       <tr>
         <td style="width:10%;">
           Normal human hematopoiesis with AMLs     <br>
           Normal human hematopoiesis (Normal human hematopoiesis (DMAP)) <br>
           Normal human hematopoiesis (HemaExplorer)<br>
           BloodPool: AML samples with normal cells <br>
           BloodPool: AML samples vs. normal cells  <br> 
           Leukemia MILE study                      <br>
           AML TCGA dataset                         <br>
           AML TCGA dataset vs. normal              <br>
           AML Normal Karyotype                     <br>
           AML Normal Karyotype vs. normal          <br>
           AML vs. normal                           <br>
           Mouse normal hematopoietic system        <br>
         </td>
         <td style="width:10%;">
           Mouse immgen abT cells                   <br>
           Mouse immgen Activated T cells           <br>
           Mouse immgen B cells                     <br>
           Mouse immgen Dentritic cells             <br>
           Mouse immgen gdT cells                   <br>
           Mouse immgen Key populations             <br>
           Mouse immgen MFs Monocytes_Neutrophiles  <br>
           Mouse immgen NK cells                    <br>
           Mouse immgen Stem and progenitor cells   <br>
           Mouse immgen Stromal cells               <br>
           Mouse normal (RNA-Seq)                   <br>
         </td>
       <tr>
     </table>
     <p>
       One feature of BloodSpot is BloodPool, an aggregated and integrated 
       dataset grouping the results of multiple studies focusing on AML. 
       By means of our batch batch correction methods this dataset can be 
       used to study gene expression in AML in comparison with healthy 
       corresponding cells. BloodPool can be selected as any of the other 
       available datasets.
     </p>
     <h2>Input</h2>
     <p>
       BloodSpot takes a single gene name (or unambiguous gene alias) or gene 
       signature name from MsigDB as query. CCL5 is the default gene displayed 
       in the input field. Furthermore, the queries are not case sensitive and 
       therefore the default gene CCL5 will also give an output in the mouse 
       datasets where the name of the equivalent gene is Ccl5. A list of the 
       datasets is available via the &#34;Select dataset&#34; drop&#45;down 
       menu. The default dataset is: &#34;Normal human hematopoiesis with 
       AMLs&#34;It is possible to select which probe to display from the list in 
       the upper right corner of the main plot. By default the probe with the 
       overall highest intensity is at the top of the list. The option &#34;Max 
       probe&#34; will use the one probe with the highest intensity within each 
       population.
     </p>
     <p>
       Three concomitant levels of visualization are available to the user: 
       Expression plot (default view), tree plot and survival plot. For each of 
       these plots, information about explorative and investigative features are 
       discussed below.
     </p>
     <h2>Default plot</h2>
     <p>
       The center plot (default view) is a novel improved jitter strip chart of 
       gene expression, a swift novel visualization plot that draws from bar 
       plots and violin plots, where the jitter is controlled by the density of 
       samples and normalized over the all columns in the chart. Thus, the width 
       of the data cloud shows how many samples have similar values.
     </p>
     <h2>Tree plot</h2>
     <p>
       The plot shown to the right is an interactive hierarchical tree that 
       shows the relationship between the samples displayed and allows changing 
       the focus of the display. Expression level is visualized by size and
       color of the nodes, as indicated by the color legend. Mouse over the 
       nodes to get the full name of cell type abbreviations. Click nodes to 
       collapse a branch of the tree &#45; this will also update the default 
       scatter, removing the same populations.
     </p>
     <h2>Survival plot</h2>
     <p>
       The chart shown to the left is a survival plot based on a high quality 
       AML dataset from 
       <a href="https://tcga&#45;data.nci.nih.gov/tcga/tcgaHome2.jsp" 
          target="_blank">The Cancer Genome Atlas (TCGA)</a>. 
       It visually displays a full Kaplan&#45;Meier analysis of survival, 
       based on gene expression above or below median for a given gene query. 
       The survival plots are only available for human datasets, sharing probes 
       with the microarray platform used by the TCGA (Affymetrix U133 Plus 2).
     </p>
     <h2>Correlations of genes and signatures</h2>
     <p>
       For each gene and signature in every dataset, the top correlating genes 
       or signatures can be explored from the drop&#45;down menu using the 
       &#34;Gene Correlations&#34; button. This feature allows for investigation 
       of associations between putative co&#45;regulated genes or signatures 
       that exhibit similar or inverse expression patterns over the course of 
       hematopoiesis. Correlation coefficients are given along with the genes or 
       signatures.
     </p>
     <h2>Other built-in tools</h2>
     <p>
       Cell populations may be removed from the graphs using the &#34;Select 
       population&#34; button. The current plot displayed can be exported as PDF 
       using the &#34;Print as PDF&#34; button. The &#34;T-Test&#34; button can 
       be used to add the results from a students t-test for significance 
       between pairs of populations in the default expression plot.
     </p>
     <h2>Upload sample</h2>
     <p>
       By clicking the &#34;Upload sample&#34; it is possible to analyze 
       user&#45;supplied samples on the Affymetrix U133 plus 2 platform. 
       Significantly, doing so allows for the comparison of any myeloid sample 
       microarray data to normal human hematopoiesis. The resulting analysis is 
       then displayed in a private session in the framework of BloodSpot, 
       together with a principal component analysis that shows the location of 
       the uploaded sample in the hematopoietic sample space. The analysis is 
       anonymous and requires no login. The resulting dataset, including the 
       uploaded sample, can then be queried along with the default datasets, in 
       a private session. All names and array information are stripped from the 
       uploaded file before creating the database for the user session. Hence, 
       the uploaded sample in the private session will appear simply as S_1 in 
       all charts. The private sessions and uploaded data will be deleted every 
       day at GMT 1.30 pm.
     </p>
     <h2>Data processing method</h2>
     <p>
       For some datasets (see <a href="#data">Data</a>) several Affymetrix chips
       platforms from different laboratories were used to generate the dataset, 
       which calls for some sort of batch correction. To this end, the CEL files 
       were partitioned into batches (platform and origin) prior to RMA 
       normalization. When several platforms are represented in the dataset, 
       only the overlapping probesets are retained for further data processing. 
       Afterwards, we used ComBat, an empirical bayes method implemented in the 
       R language to correct for batch effect. Fold changes for AML samples vs. 
       nl. are compared to their nearest normal counterpart, as described by 
       <a href="http://www.bloodjournal.org/content/123/6/894.short?sso&#45;checked=true" 
          target="_blank">Rapin et al. <i>Blood</i>, 2014</a>. 
       User-supplied uploaded samples obtain batch correction covariates from a 
       majority vote among the nearest normals in a subspace of probes that are 
       highly varying throughout the course of hematopoiesis. Hereafter the 
       entire dataset including the uploaded patient sample is normalized and 
       batch corrected using ComBat for full integrity of the dataset. PCA 
       analysis and gene signature values are then calculated.
     </p>
     <h2>Available genes</h2> 
     <p>
       The server is restricted to genes found in our database of Affymetrix 
       Human 133U plus 2 , Affymetrix Human 133UA and Affymetrix Human 133UB, 
       chips for human, and GeneChip Mouse Genome 430 2.0 and Affymetrix Mouse 
       Gene 1.0 ST Arrays for mouse. </p>
     <h2>Abbreviations</h2>
     <p>
       Abbreviations can be found below the plot by clicking 
       &#34;Abbreviations&#34;. Here information about the source of the data 
       is also displayed for the current dataset.
     </p>
     <a id="data"><h2>Data</h2></a>
     <table>
       <tr>
         <td style="width:30%;"><b>Dataset</b></td>
         <td style="width:10%;"><b>Features</b></td>
         <td style="width:70%;"><b>Samples</b> </td>
       </tr>
       <tr>
	       <td>Leukemia MILE study</td>
         <td>67191</td>
         <td>2095</td>
       </tr>
       <tr>
         <td>Normal human hematopoiesis with AMLs</td>
         <td>67191</td>
         <td>296</td>
       </tr>
       <tr>
         <td>Mouse immgen Key populations</td>
         <td>47273</td>
         <td>256</td>
       </tr>
       <tr>
         <td>AML vs. normal</td>
         <td>67191</td>
         <td>252</td>
       </tr>
       <tr>
         <td>AML TCGA dataset</td>
         <td>67191</td>
         <td>244</td>
       </tr>
       <tr>
         <td>AML TCGA dataset_vs_nl</td>
         <td>67191</td>
         <td>244</td>
       </tr>
       <tr>
	       <td>AML Normal Karyotype</td>
         <td>54675</td>
         <td>234</td>
       </tr>
       <tr>
         <td>AML Normal Karyotype_vs_nl</td>
         <td>67191</td>
         <td>234</td>
       </tr>
       <tr>
         <td>Normal human hematopoiesis (DMAP)</td>
         <td>35459</td>
         <td>211</td>
       </tr>
       <tr>
	       <td>Mouse immgen abT cells</td>
         <td>47273</td>
         <td>190</td>
       </tr>
       <tr>
         <td>Mouse immgen Dentritic cells</td>
         <td>47273</td>
         <td>151</td>
       </tr>
       <tr>
         <td>Mouse immgen MFs Monocytes_Neutrophiles</td>
         <td>47273</td>
         <td>114</td></tr>
       <tr>
         <td>Mouse immgen B cells</td>
         <td>47273</td>
         <td>103</td>
       </tr>
       <tr>
         <td>Normal human hematopoiesis (HemaExplorer)</td>
         <td>57270</td>
         <td>77</td>
       </tr>
       <tr>
         <td>Mouse immgen gdT cells</td>
         <td>47273</td>
         <td>76</td>
       </tr>
       <tr>
         <td>Mouse immgen Stem and progenitor cells</td>
         <td>47273</td>
         <td>76</td>
       </tr>
       <tr>
         <td>Mouse normal hematopoietic system</td>
         <td>57613</td>
         <td>67</td>
       </tr>
       <tr>
         <td>Mouse immgen Activated T cells</td>
         <td>47273</td>
         <td>55</td>
       </tr>
       <tr>
         <td>Mouse immgen NK cells</td>
         <td>47273</td>
         <td>47</td>
       </tr>
       <tr>
         <td>Mouse immgen Stromal cells</td>
         <td>47273</td>
         <td>39</td>
       </tr>
     </table>
     <br>
     <br>
     <table class="altrowstable" id="alternatecolor">
       <tr>
         <td><b>Dataset</b></td>
         <td><b>Organism</b></td>
         <td><b>Source</b></td>
         <td><center><b>Sample numbers</b></center></td>
         <td><b>Cell types</b></td><td><b>Reference</b></td>
       </tr>
       <tr>
         <td>Normal human hematopoiesis with AMLs</td>
         <td>Human</td><td>GSE42519</td><td><center>34</center></td>
         <td>HSC, MPP, CMP, MEP, GMP, early PM, late PM, MY, MM, BC, PMN</td>
         <td>Rapin et al. (1)    </td>
       </tr>
       <tr>
         <td>HemaExplorer</td>
         <td>Human</td>
         <td>GSE17054</td>
         <td><center>2</center></td>
         <td>HSC</td>
         <td>Majeti et al. (2)</td>
       </tr>
       <tr>
         <td>HemaExplorer</td>
         <td>Human</td>
         <td>GSE19599</td>
         <td><center>4</center></td>
         <td>GMP, MEP</td>
         <td>Andersson et al. (3)</td>
       </tr>
       <tr>
         <td>HemaExplorer</td>
         <td>Human</td>
         <td>GSE11864</td>
         <td><center>2</center></td>
         <td>Monocytes</td>
         <td>Hu et al. (4) </td>
       </tr>
       <tr>
         <td>HemaExplorer</td>
         <td>Human</td>
         <td>E&#45;MEXP&#45;1242</td>
         <td><center>2</center></td>
         <td>Monocytes</td>
         <td>Wildenberg et al. (5)</td>
       </tr>
       <tr>
         <td>DMAP</td>
         <td>Human</td>
         <td>GSE24759</td>
         <td><center>211</center></td>
         <td>Normal Hematopoiesis</td>
         <td>Novershtern et al. (6)</td>
       </tr>
       <tr>
         <td>Normal mouse hematopoiesis</td>
         <td>Mouse</td>
         <td>GSE14833, GSE6506</td>
         <td><center>67</center></td>
         <td>Normal Hematopoiesis</td>
         <td>Di Tullio et al.13,  Chambers et al.(7)</td>
       </tr>
       <tr>
         <td>Immgen datasets</td>
         <td>Mouse</td>
         <td>GSE15907</td>
         <td><center>700</center></td>
         <td>Normal Hematopoiesis</td>
         <td>(8&#45;14)</td>
       </tr>
       <tr>
         <td>AML Normal Karyotype , AML Normal Karyotype vs. normal</td>
         <td>Human AML</td>
	       <td>GSE15434</td>
         <td><center>251</center></td>
         <td>NK&#45;AML, WBM</td>
         <td>Kohlman et al. (15, 16) </td>
       </tr>
       <tr>
         <td>MILE study</td>
         <td>Human AML, ALL, CML, CLL  and MDS </td>
         <td>GSE13159</td>
         <td><center>2096</center></td>
         <td>AML, ALL and preleukemic stages.</td>
         <td>Haferlach et al. (17, 18)</td>
       </tr>
       <tr>
         <td>Normal human hematopoiesis with AMLs, AML vs. normal</td>
         <td>Human AML</td>
         <td>GSE6891</td>
         <td><center>91</center></td>
         <td>NK&#45;AML, WBM </td>
         <td>de Jonge et al.(19,20)</td>
       </tr>
       <tr>
         <td>TCGA, TCGA vs. normal </td>
         <td>Human AML</td>
         <td>TCGA </td>
         <td><center>183</center></td>
	       <td>Various genetic aberrations, including t(8;21), inv(16), t(15;17), 
             t(11q23), complex karyotype, WBM</td>
	       <td>TCGA (20)</td>
       </tr>
     </table>
     <h2>Data References</h2>
     <table>
       <tr>
         <td>1.</td>
         <td>Rapin, N. et al. Comparing cancer vs normal gene expression 
             profiles identifies new disease entities and common transcriptional 
             programs in AML patients. Blood 123,     894&#45;904 (2014).</td>
       </tr>
       <tr>
         <td>2.</td>
         <td>Majeti, R. et al. Dysregulated gene expression networks in human 
             acute myelogenous leukemia stem cells. Proceedings of the National 
             Academy of Sciences 106,     3396&#45;3401 (2009).</td>
       </tr>
       <tr>
         <td>3.</td>
         <td>Andersson, A., Ed&#233;n, P., Olofsson, T. and Fioretos, T. Gene 
             expression signatures in childhood acute leukemias are largely 
             unique and distinct from those of normal tissues and other 
             malignancies. BMC Medical Genomics 3, 6 (2010).</td>
       </tr>
       <tr>
         <td>4.</td>
         <td>Hu, X. et al. Integrated Regulation of Toll&#45;like Receptor 
             Responses by Notch and Interferon&#45;gamma Pathways. Immunity 29, 
             691&#45;703 (2008).</td>
       </tr>
       <tr>
         <td>5.</td>
         <td>Wildenberg, M. E., van Helden&#45;Meeuwsen, C. G., van de Merwe, 
             J.P., Drexhage, H. A. and Versnel, M. A. Systemic increase in type 
             I interferon activity in Sj&#246;gren's syndrome: A putative role 
             for plasmacytoid dendritic cells. European Journal of Immunology 38, 
             2024&#45;2033 (2008).</td>
       </tr>
       <tr>
         <td>7.</td>
         <td>Novershtern, N. et al. Densely interconnected transcriptional 
             circuits control cell states in human hematopoiesis. Cell 144, 
             296&#45;309 (2011).</td>
       </tr>
       <tr>
         <td>8.</td>
         <td>Di Tullio, A. et al. CCAAT/enhancer binding protein alpha 
             (C/EBP(alpha))&#45;induced transdifferentiation of pre&#45;B 
             cells into macrophages involves no overt retrodifferentiation. 
             Proceedings of the National Academy of Sciences 108, 
             17016&#45;17021 (2011).</td>
         </tr>
	       <tr>
           <td>9.</td>
           <td>Chambers, S. M. et al. Hematopoietic fingerprints: an 
               expression database of stem cells and their progeny. Cell Stem 
               Cell 1, 578&#45;591 (2007).</td>
         </tr>
	       <tr>
           <td>10.</td>
           <td>Painter, M. W. et al. Transcriptomes of the B and T lineages 
               compared by multiplatform microarray profiling. Journal of 
               immunology (Baltimore, Md. : 1950) 186, 3047&#45;3057 (2011).
               </td>
           </tr>
           <tr>
             <td>11.</td>
             <td>Desch, A. N. et al. CD103+ pulmonary dendritic cells 
                 preferentially acquire and present apoptotic 
                 cell&#45;associated antigen. The Journal of experimental 
                 medicine 208, 1789&#45;1797 (2011).</td>
           </tr>
           <tr>
             <td>12.</td>
             <td>Malhotra, D. et al. Transcriptional profiling of stroma from 
                 inflamed and resting lymph nodes defines immunological 
                 hallmarks. Nature immunology 13, 499&#45;510 (2012).</td>
           </tr>
           <tr>
             <td>13.</td>
             <td>Narayan, K. et al. Intrathymic programming of effector fates 
                 in three molecularly distinct [gamma][delta] T cell subtypes. 
                 Nature immunology 13, 511&#45;518 (2012).</td>
           </tr>
	         <tr>
             <td>14.</td>
	           <td>Miller, J. C. et al. Deciphering the transcriptional network 
                 of the dendritic cell lineage. Nature immunology 13, 
                 888&#45;899 (2012).</td>
           </tr>
	         <tr>
             <td>15.</td>
	           <td>Kohlmann, A. et al. Gene expression profiling in AML with 
                 normal karyotype can predict mutations for molecular markers 
                 and allows novel insights into perturbed biological pathways. 
                 Leukemia 24, 1216&#45;1220 (2010).</td>
           </tr>
	         <tr>
             <td>16.</td>
	           <td>Kohlmann, A. et al. An international standardization programme 
                 towards the application of gene expression profiling in 
                 routine leukaemia diagnostics: the Microarray Innovations in 
                 Leukemia study prephase. British Journal of Haematology 142, 
                 802&#45;807 (2008).</td>
           </tr>
	         <tr>
             <td>17.</td>
	           <td>Haferlach, T. et al. Clinical utility of microarray&#45;based 
                 gene expression profiling in the diagnosis and 
                 subclassification of leukemia: report from the International 
                 Microarray Innovations in Leukemia Study Group. Journal of 
                 Clinical Oncology 28, 2529&#45;2537 (2010).</td>
           </tr>
	         <tr>
             <td>18.</td>
	           <td>Verhaak, R. G. W. et al. Prediction of molecular subtypes in 
                 acute myeloid leukemia based on gene expression profiling. 
                 Haematologica 94, 131&#45;134 (2009).</td>
           </tr>
	         <tr>
             <td>19.</td>
	           <td>de Jonge, H. J. M. et al. High VEGFC expression is associated 
                 with unique gene expression profiles and predicts adverse 
                 prognosis in pediatric and adult acute myeloid leukemia. Blood 
                 116, 1747&#45;1754 (2010).</td></tr>
	         <tr>
             <td>20.</td>
	           <td>Network, C. G. A. R. Genomic and epigenomic landscapes of adult 
                 de novo acute myeloid leukemia. 368, 2059&#45;2074 (2013).</td>
           </tr>
         </table>
         <h2>Funding</h2>
	       <p>
           This work was funded by the Danish Research Council for Strategic 
	         Research and by the NovoNordisk Foundation.
         </p>
         <h2>Contact</h2>
         <p>
           For technical questions contact: frederik [at] binf.ku.dk
         </p>
         <p>
           For scientific questions contact: bo.porse [at] finsenlab.dk or 
           nicolas.rapin [at] binf.ku.dk
         </p>
         <h2> Citation: </h2> 
         <p>
           <a href="http://nar.oxfordjournals.org/content/early/2015/10/26/nar.gkv1101.abstract" 
              target="_blank">BloodSpot: a database of gene expression profiles 
	            and transcriptional programs for healthy and malignant 
              haematopoiesis <br> Nucl. Acids Res. (2015) <br> 
              doi: 10.1093/nar/gkv1101</a>  
         </p>
       </div>
     </div>
     <br>
   </div>
   <? include $FOOTER_TEMPLATE_PATH; ?>
</body>

