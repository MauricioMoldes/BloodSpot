<?php

$private_dir = realpath($_SERVER["DOCUMENT_ROOT"]."/../httpd-private/");
$public_dir = $_SERVER["DOCUMENT_ROOT"];

$file = $public_dir.'/surv/survplots_base.zip';

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

?>