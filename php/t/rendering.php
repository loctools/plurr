<?php

include_once('../Plurr.php');

function t($n, $p, $s, $params, $options, $message, $exception = null) {
  $result;
  try {
    $result = $p->format($s, $params, $options);
  } catch (Exception $e) {
    $err = $e->getMessage();
    print("$n: " . ($err === $exception ? 'pass' : "fail: [$err] vs [$exception]") . "\n");
    return;
  }

  if ($exception) {
    print("$n: fail: should produce exception [$exception]\n");
  } else {
    print("$n: " . ($result === $message ? 'pass' : "fail: [$result] vs [$message]") . "\n");
  }
}

$p = new Plurr();

t('e.1', $p, '', null, null, '', "'params' is not a hash");
t('e.2', $p, 'err {', array(), null, '', "Unmatched { found");
t('e.3', $p, 'err }', array(), null, '', "Unmatched } found");
t('e.4', $p, '{foo}', array(), null, '', "'foo' not defined");
t('e.5', $p, '{N_PLURAL}', array('N' => 'NaN'), null, '', "Value of 'N' is not a number");

$s = 'Do you want to delete {N_PLURAL:this {N} file|these {N} files} permanently?';

t('1.1', $p, $s, array('N' => 1), null, 'Do you want to delete this 1 file permanently?');
t('1.2', $p, $s, array('N' => 5), null, 'Do you want to delete these 5 files permanently?');

$s = 'Do you want to drink {CHOICE:coffee|tea|juice}?';

t('2.1', $p, $s, array('CHOICE' => 0), null, 'Do you want to drink coffee?');
t('2.2', $p, $s, array('CHOICE' => 1), null, 'Do you want to drink tea?');
t('2.3', $p, $s, array('CHOICE' => 2), null, 'Do you want to drink juice?');

$s = 'Удалить {N_PLURAL:этот {N} файл|эти {N} файла|эти {N} файлов} навсегда?';

t('3.1', $p, $s, array('N' => 1), array('locale' => 'ru'), 'Удалить этот 1 файл навсегда?');
t('3.2', $p, $s, array('N' => 2), array('locale' => 'ru'), 'Удалить эти 2 файла навсегда?');
t('3.3', $p, $s, array('N' => 5), array('locale' => 'ru'), 'Удалить эти 5 файлов навсегда?');
t('3.4', $p, $s, array('N' => 5), null, 'Удалить эти 5 файла навсегда?');
