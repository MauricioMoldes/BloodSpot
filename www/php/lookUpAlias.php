<?php
  require_once "globals.php";
  require_once $DB_LIBRARY_PATH;

  $alias = $_GET["alias"];

  if (!isset($_GET["alias"])) {
    echo json_encode(array());
    exit;
  }

  $dbhandle = db_connect();

  echo json_encode(db_get_alias($dbhandle, $alias));

  db_close($dbhandle);
?>
