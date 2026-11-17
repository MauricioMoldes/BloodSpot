<?php

  require_once __DIR__ . "/config.local.php";
  $database = $DB_CONFIG["database"];    

  function db_connect() {
    global $database, $DB_CONFIG;
    $hostname = $DB_CONFIG["host"];
    $username = $DB_CONFIG["user"];
    $password = $DB_CONFIG["password"];

    $port = $DB_CONFIG["port"];

    try {
      $dbhandle = mysqli_connect( $hostname, 
                                  $username, 
                                  $password, 
                                  $database, 
                                  $port);
      
      $dbhandle->set_charset('utf8mb4');

      return $dbhandle;
    } catch (mysqli_sql_exception $e) {
      error_log($e);
      exit;
    }

  }  

  function db_close($dbhandle) {
    try {
      $dbhandle->close();
    } catch (mysqli_sql_exception $e) {
      error_log($e);
      exit;
    }
  }

  function db_query($stmt) {
    try {
      $stmt->execute();

      return $stmt->get_result();
    
    } catch (mysqli_sql_exception $e) {
      error_log($e);
      exit;
    
    }
  }

  function db_fetch_array($result) {
    try {
      return mysqli_fetch_array($result);
    } catch (mysqli_sql_exception $e) {
      error_log($e);
      return null;
    }
  }

  function db_sanitize_table_name($table_name) {
    $ret_str = str_replace(" ", "", $table_name);
    $ret_str = str_replace("; ", "", $ret_str);
    $ret_str = str_replace("'", "", $ret_str);
    $ret_str = str_replace("\"", "", $ret_str);
    $ret_str = str_replace("\t", "", $ret_str);
    $ret_str = str_replace("\\", "", $ret_str);
    $ret_str = str_replace("-", "", $ret_str);
    $ret_str = str_replace("\n", "", $ret_str);

    return $ret_str;
  }

  function db_validate_table_name($dbhandle, $table_name) {
    global $database, $DB_CONFIG;
    $table_results = mysqli_query($dbhandle, "SHOW TABLES");
    
    while ($tables_row = db_fetch_array($table_results)) {
      $this_table = $tables_row["Tables_in_".$database];
      if ($this_table == $table_name) {
        return true;
      }
    }  
    return false;
  }

  function db_get_all_datasets($dbhandle) {
    $query = "SELECT * from dataset";
    
    $stmt = mysqli_prepare($dbhandle, $query);
    
    return db_query($stmt);
  }
  
  function db_get_data($dbhandle, $data, $gene) {

    $table_name = db_sanitize_table_name($data);
    $table_name_valid = db_validate_table_name($dbhandle, $table_name);

    if (!$table_name_valid) {
      return array(); 
    }

    $query  = "SELECT cell_data, gene_name, probe_name, cell_name, id ";
    $query .= "FROM ".$table_name." ";
    $query .= "WHERE (gene_name=? OR probe_name=?)";

    $stmt = mysqli_prepare($dbhandle, $query);

    $stmt->bind_param("ss", $gene, $gene);

    return db_query($stmt)->fetch_all(MYSQLI_ASSOC);

  }

  function db_get_alias($dbhandle, $alias) {
    $query = "SELECT name FROM alias WHERE alias=?";

    $stmt = mysqli_prepare($dbhandle, $query);

    $stmt->bind_param("s", $alias);

    return db_query($stmt)->fetch_all(MYSQLI_ASSOC);
  }

  function db_get_correlation_data($dbhandle, $gene, $dataset, $probe) {
    
    if (substr( $dataset, 0, 10 ) === "hemasample"){
      $query  = "SELECT * ";
      $query .= "FROM corr ";
      $query .= "WHERE dataset='nl_human_data_HemaExp_v_1' and probe_name1=? ";
      $query .= "ORDER BY value DESC";

      $stmt = mysqli_prepare($dbhandle, $query);
      $stmt->bind_param("s", $probe);
    } elseif($gene == 'NULL') {              
      // hack to make uploaded samples use the correlations from dataset
      // nl_human_data_HemaExp_v_1
      $query  = "SELECT * ";
      $query .= "FROM corr ";
      $query .= "WHERE dataset=? and probe_name1=? ";
      $query .= "ORDER BY value DESC";

      $stmt = mysqli_prepare($dbhandle, $query);
      $stmt->bind_param("ss", $dataset, $probe);
    } else { //when there is no probe use gene name instead         
      $query  = "SELECT * ";
      $query .= "FROM corr ";
      $query .= "WHERE dataset=? and gene_name=? ";
      $query .= "ORDER BY value DESC";
 
      $stmt = mysqli_prepare($dbhandle, $query);
      $stmt->bind_param("ss", $dataset, $gene);
    }
    
    return db_query($stmt)->fetch_all(MYSQLI_ASSOC);
  }

?>
