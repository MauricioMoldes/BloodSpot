<?php

  require_once "globals.php";
  require_once $DB_LIBRARY_PATH;
  $dbhandle = db_connect();


  $result = db_get_all_datasets($dbhandle);
  
  $bulk = array();
  $single = array();
  
  while ($row = db_fetch_array($result)) {
    $value = $row["dataset_name"];
    $label = $row["list"];
    $description =$row["dataset_desription"];
    
    $description = str_replace('_', ' ', $description);
    $string_to_append = "$description";
    
    if($value=="human"){
      $string_to_append .= "<option name='dataset' value='$value' checked='checked'>" . $description  . "</option><br>";
    }
    else{
      $string_to_append .= "<option name='dataset' value='$value' >" . $description . "</option><br>";
    }
    
    if(strpos($value, '_sc') !== false){
      array_push($single, $string_to_append);
    }elseif($value=="normal_human_v2_with_AMLs"){
      $first = $string_to_append;
    }else{
      array_push($bulk, $string_to_append);
    }
  }
  echo $first;
  foreach($single as $itemsingle){
    echo $itemsingle;
  }
  foreach($bulk as $itembulk){
    echo $itembulk;
  }

  db_close($dbhandle);

?>
