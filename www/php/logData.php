<?php
// Suppressed warnings from get_client_ip() - Emil Lagoni
// TODO: mysql is deprecated - use mysqli or pdo -> see php doc
// TODO: Duplicate variables?
    $hostname="localhost";
    $username="servers";
    $pw="tlethlaw";
    $dbname="servers";

    //Gets IP for client.
    $ip = @get_client_ip();
    //An email, format of string.
    $email = "test@test.dk";
    //An int, in this case 19.
    $prgm_name = $_GET["prgm"];
    //Piece of text, format of string of course.
    $prgm_options =$prgm_name;
    $prgm_options.= " - ";
    $prgm_options.=$_GET["gene"];
    $prgm_options.=" - ";
    $prgm_options.=$_GET["data"];
    //Datasize, int.
    $data_size = 0;
    //Timestamp.
    $now = "NOW()";

    //Table name.
    $STAT_TABLE = "stat";

    $dblink = mysql_connect($hostname, $username, $pw);

    if (!$dblink) {
        die('Not connected : ' . mysql_error());
    }
    mysql_select_db($dbname, $dblink);

    $prgm_name=19;
    $gene = $_GET["gene"];
    $data = $_GET["data"];
    $prgm_options.=$prgm_name;
    $prgm_options.= "- ";
    $prgm_options.=$gene;
    $prgm_options.="- ";
    $prgm_options.=$data;
    $email= "test@test.dk";

    $ip= @get_client_ip();
    $data_size= 0;
    $PRGM_TABLE= "prgm";
    $STAT_TABLE= "stat";

    $query = "INSERT INTO $STAT_TABLE(ip, email, prgm, options, datasize, date) VALUES ('$ip', '$email', $prgm_name, '$prgm_options', $data_size, $now)";

    mysql_query($query); 
	mysql_close();


    function quote_smart($value){
            // Stripslashes
            if (get_magic_quotes_gpc()) {
                    $value = stripslashes($value);
            }
            // Quote if not integerß
            if (!is_numeric($value)) {
                    $value = "'" . mysql_real_escape_string($value) . "'";
            }
            return $value;
    }
    function get_client_ip() {
         $ipaddress = '';
         if ($_SERVER['HTTP_CLIENT_IP'])
             $ipaddress = $_SERVER['HTTP_CLIENT_IP'];
         else if($_SERVER['HTTP_X_FORWARDED_FOR'])
             $ipaddress = $_SERVER['HTTP_X_FORWARDED_FOR'];
         else if($_SERVER['HTTP_X_FORWARDED'])
             $ipaddress = $_SERVER['HTTP_X_FORWARDED'];
         else if($_SERVER['HTTP_FORWARDED_FOR'])
             $ipaddress = $_SERVER['HTTP_FORWARDED_FOR'];
         else if($_SERVER['HTTP_FORWARDED'])
             $ipaddress = $_SERVER['HTTP_FORWARDED'];
         else if($_SERVER['REMOTE_ADDR'])
             $ipaddress = $_SERVER['REMOTE_ADDR'];
         else
             $ipaddress = 'UNKNOWN';
         return $ipaddress; 
    }
?>
