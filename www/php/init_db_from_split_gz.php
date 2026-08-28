<?php
header('Content-Encoding: none'); // Disable gzip compression
ob_end_flush(); // Stop buffer
ob_implicit_flush(1); // Implicit flush at each output command

$nl = " <br> \n";

function injest_file($dbhandle, $filepath) {
    global $nl;
    
    $fhandle = gzopen($filepath, "r");

    $count = 0;
    $line_skip = 26;
    $line_max = 100000000000000;
    
    $statement = "";
    
    $dbhandle->autocommit(FALSE);
    if ($fhandle) {
        while (!gzeof($fhandle)) {
            $line = gzgets($fhandle);
            
            
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
                $count += 1;
            }
            
            if ($count % 100 == 0) {
                echo $count.$nl ;
                $dbhandle -> commit();
            }
            
            if ($count > $line_max)
                break;
        }
    }
    echo $count.$nl;
    // Commit transaction
    $dbhandle -> commit();
}

$httpd_private = realpath($_SERVER["DOCUMENT_ROOT"]."/../httpd-private/");
$httpd_public = $_SERVER["DOCUMENT_ROOT"];

require_once "globals.php";
require_once $DB_LIBRARY_PATH;


$db_init_archive_dir = $httpd_private."/db-init/archive_split";

$dbhandle = db_connect();

$dbhandle->set_charset('utf8mb4');

$table_results = mysqli_query($dbhandle, "SHOW TABLES");

while ($tables_row = mysqli_fetch_array($table_results)) {
  $this_table = $tables_row["Tables_in_".$database];
  echo $this_table.$nl;
}

foreach(scandir($db_init_archive_dir) as $fp) {
    if (strlen($fp) < 8) {
        continue;
    }
    if ($fp == "processed") {
        continue;
    }
    $this_filepath = $db_init_archive_dir."/".$fp;
    echo "BEGINNING PROCESSING OF ".$this_filepath.$nl;
    injest_file($dbhandle, $this_filepath);
    echo "FINISHED PROCESSING ".$this_filepath.$nl;
    }

$dbhandle->close();

?>