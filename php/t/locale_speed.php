<?php

include_once('../Plurr.php');

$p = new Plurr();
$x = 100000;

$start = microtime(true);

for ($i = 0; $i < $x; $i++) {
  $dummy = $p->locale('ru');
}

$end = microtime(true);
$time = $end - $start;

print("Execution time ($x calls): $time sec (" . ($time * 1000 / $x) . ' ms per call)');

?>
