<?php

$private_dir = realpath($_SERVER["DOCUMENT_ROOT"]."/../httpd-private/");
$public_dir = $_SERVER["DOCUMENT_ROOT"];

system("tar -xzf ".$private_dir."/archives/surv.tar");

# $pout = new PharData($private_dir."/archives/surv.tar");
# $pout->extractTo($public_dir."/surv");


?>