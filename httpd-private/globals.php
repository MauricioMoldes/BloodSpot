<?php
  ## Derive protocol
  ## Source: https://stackoverflow.com/a/14270161
  if ( isset($_SERVER['HTTPS']) &&
       ( $_SERVER['HTTPS'] == 'on' || $_SERVER['HTTPS'] == 1) ||
         isset($_SERVER['HTTP_X_FORWARDED_PROTO'] ) &&
       $_SERVER['HTTP_X_FORWARDED_PROTO'] == 'https') {
    $PROTOCOL = 'https://';
  } else {
    $PROTOCOL = 'http://';
  }
  ## BASE PATHS
  $BASE_URL = $PROTOCOL.$_SERVER['HTTP_HOST'];
  $DOCUMENT_ROOT = $_SERVER["DOCUMENT_ROOT"];
  $RESOURCES_ROOT = realpath($_SERVER["DOCUMENT_ROOT"]."/../httpd-private");
  
  $LIBRARIES_PATH = $RESOURCES_ROOT."/libraries";
  $TEMPLATES_PATH =  $RESOURCES_ROOT."/templates";
  ## API PATHS
  $HELP_REQUEST_URI = "/php/help.php";
  $HELP_PAGE_URL = $BASE_URL.$HELP_REQUEST_URI;
  
  $GETDATASET_REQUEST_URI = "/php/getDataset.php";
  $GETDATASET_PAGE_URL = $BASE_URL.$GETDATASET_REQUEST_URI;  
  ## TEMPLATE PATHS
  $FOOTER_TEMPLATE_PATH = $TEMPLATES_PATH."/footer.php";
  ## LIBRARY PATHS
  $DB_LIBRARY_PATH = $LIBRARIES_PATH."/db.php";

?>
