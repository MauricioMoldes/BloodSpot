<?php
  require_once "globals.php";
  require_once $DB_LIBRARY_PATH;

  if (!isset($_GET["gene"]) || !isset($_GET["data"])) {
    echo json_encode(array());
    exit;
  }

  $gene = $_GET["gene"];
  $data = $_GET["data"];
  
  $dbhandle = db_connect();

  echo json_encode(db_get_data($dbhandle, $data, $gene));

  db_close($dbhandle);  
?>
