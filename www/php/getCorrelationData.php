<?php
  require_once "globals.php";
  require_once $DB_LIBRARY_PATH;

  if (!isset($_GET["gene"]) || !isset($_GET["dataset"]) || !isset($_GET["probe"])) {
    echo json_encode(array());
    exit;
  }

  $probe = $_GET["probe"];
  $dataset = $_GET["dataset"];
  $gene = $_GET["gene"];
  
  $dbhandle = db_connect();

  echo json_encode(db_get_correlation_data($dbhandle, $gene, $dataset, $probe));

  db_close($dbhandle);
?>
