<?php

$private_dir = realpath($_SERVER["DOCUMENT_ROOT"]."/../httpd-private/");
$public_dir = $_SERVER["DOCUMENT_ROOT"];

$file = $public_dir.'/surv/survplotsPNG.zip';

// get the absolute path to $file
$path = pathinfo(realpath($file), PATHINFO_DIRNAME);

$zip = new ZipArchive;
$res = $zip->open($file);
if ($res === TRUE) {
  // extract it to the path we determined above
  $zip->extractTo($path);
  $zip->close();
  echo "WOOT! $file extracted to $path";
} else {
  echo "Doh! I couldn't open $file";
}


#$filename = $private_dir."/archives/surv.tar.gz";

#$archive = gzopen($filename, "r");

#$tarchive = fopen($private_dir."/archives/surv.tar", "wb" );

#while($entry = gzread($archive, 10240)){
#  fwrite($tarchive, $entry); 
#}

#fclose($tarchive);


#$p = new PharData($private_dir."/archives/surv.tar.gz");
#$p->decompress();

#$pout = new PharData($private_dir."/archives/surv.tar");
#$pout->extractTo($public_dir."/surv");

#$zip = new ZipArchive;
#$res = $zip->open('/customers/9/6/1/fobinf.com/httpd.private/docker-compose.tar.gz');

# if ($res === TRUE) {
#  $zip->extractTo('/customers/9/6/1/fobinf.com/httpd.private/docker-compose');
#  $zip->close();
#  echo 'woot!';
#} else {
#  echo 'doh!';
#}

?>