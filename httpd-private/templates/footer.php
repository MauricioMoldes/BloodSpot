<div id="wrappergrid3" class="wrapper fullwidth">
  <div id="contentGraphic">
    <footer>
      <table bgcolor="#00FF00" style="margin: 4px; width:100%;">
        <tr>
          <td style="width:33%;" valign="top" title="Institutions">
            <p>
              BloodSpot is a collaboration between:<br>
              <a href="https://www.binf.ku.dk"
                 target="_blank">Bioinformatics Centre, UCPH</a>, <br>
              <a href="https://www.finsenlab.dk"
                 target="_blank">The Finsen Laboratory</a>, <br>
              <a href="https://www.bric.ku.dk"
		 target="_blank">Biotech Research and Innovation Centre (BRIC), 
		 UCPH</a>
              , <br>and
              <a href="https://www.rigshospitalet.dk/RHenglish/Menu/"
                 target="_blank">The Danish State Hospital</a>
            </p>
          </td>
          <td style="width:23%;" valign="top" title="Contact">
            <p>
	      For technical & scientific questions, please contact:<br>
              support [at] bloodspot.eu
            </p>
          </td>
          <td style="width:29%;" valign="top" title="Funding">
            <p>
              This work is funded by:<br>
              Danish Research Council for Strategic Research<br>
              Lunbeck Foundation and NovoNordisk Foundation.
            </p>
          </td>
          <td style="width:15%;" valign="top" title="Website build with D3">
            <p>
              The page is built with<br>
              <a href="https://d3js.org" 
                 title="Page is build with Javascrpt library D3" 
                 target="_blank">javascript library D3</a><br>
	    <?php
            if ($_SERVER['REQUEST_URI'] != $HELP_REQUEST_URI) {
                echo '
            Citation: <br>
              <a href="https://academic.oup.com/nar/article/52/D1/D1138/7337619?login=false" 
                 target="_blank">BloodSpot 3.0: a database of gene and protein expression data in normal and malignant haematopoiesis<br> Nucl. Acids Res. (2024) <br> 
                 doi: 10.1093/nar/gkad993</a>
            </p>
	    <br>
                <a href="'.$HELP_PAGE_URL.'" 
		    class="transition">Help and Description</a>';
	    } 
            ?>
          </td>
        </tr>
      </table>
    </footer>
  </div>
</div>
