<?php

include_once('../Plurr.php');

$p = new Plurr();
$s = 'Do you want to delete {N_PLURAL:this {N} file|these {N} files} permanently?';
$params = array('N' => 5);
$x = 100000;

$start = microtime(true);

for ($i = 0; $i < $x; $i++) {
  $dummy = $p->format($s, $params);
}

$end = microtime(true);
$time = $end - $start;

print("Execution time ($x calls): $time sec (" . ($time * 1000 / $x) . ' ms per call)');

?>
