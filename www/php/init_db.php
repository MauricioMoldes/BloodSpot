<?php

require_once "globals.php";
require_once $DB_LIBRARY_PATH;


$httpd_private = realpath($_SERVER["DOCUMENT_ROOT"]."/../httpd-private/");
$httpd_public = $_SERVER["DOCUMENT_ROOT"];



$nl = " <br> \n";

$db_init_dir = $httpd_private."/db-init";

foreach(scandir($db_init_dir) as $fp) {
    echo $db_init_dir."/".$fp.$nl;
}


$dbhandle = db_connect();
$dbhandle->set_charset('utf8mb4');
$dbhandle->autocommit(FALSE);

$table_results = mysqli_query($dbhandle, "SHOW TABLES");

while ($tables_row = mysqli_fetch_array($table_results)) {
  $this_table = $tables_row["Tables_in_".$database];
  echo $this_table.$nl;
}

$db_init_fp = $db_init_dir."/01-init-db.sql";

$fhandle = fopen($db_init_fp, "r");

$count = 0;
$line_skip = 26;
$line_max = 100000000000000;

$statement = "";

if ($fhandle) {
    while (!feof($fhandle)) {
        $line = fgets($fhandle);
        
        $count += 1;
        
        if ($count < $line_skip)
            continue;
        
        $line = Rtrim($line);
        if (strlen($line) == 0) 
            continue;
        $last_char = substr($line, -1);
        
        $line = $line."\n";
        
        $statement .= $line;
        
        if ($last_char == ';') {
             #echo $statement.$nl;
             $qry = $dbhandle->query($statement);
             
             $statement = "";
        }
        
        if ($count % 100 == 0) {
            echo $count.$nl;
        }
        
        if ($count > $line_max)
            break;
    }
}
// Commit transaction
if (!$dbhandle -> commit()) {
    echo "Commit transaction failed";
    exit();
}

$dbhandle->close();

?>