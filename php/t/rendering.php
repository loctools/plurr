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
t('e.5', $p, '{N_PLURAL}', array('N' => 'NaN'), null, '', "Value of 'N' is not a zero or positive integer number");
t('e.6', $p, '{N_PLURAL}', array('N' => 1.5), null, '', "Value of 'N' is not a zero or positive integer number");

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

$s = '{X_PLURAL:{X:|One|{X}} file|{X:No|{X}} files} found.';

t('4.1', $p, $s, array('X' => 0), null, 'No files found.');
t('4.2', $p, $s, array('X' => 1), null, 'One file found.');
t('4.3', $p, $s, array('X' => 2), null, '2 files found.');

t('4.4', $p, $s, array('X' => '0'), null, 'No files found.');
t('4.5', $p, $s, array('X' => '1'), null, 'One file found.');
t('4.6', $p, $s, array('X' => '2'), null, '2 files found.');

$s = '{X_PLURAL:Найден {X:|один|{X}} файл|Найдены {X} файла|{X:Не найдено|Найдено {X}} файлов}.';

t('5.1', $p, $s, array('X' => 0), array('locale' => 'ru'), 'Не найдено файлов.');
t('5.2', $p, $s, array('X' => 1), array('locale' => 'ru'), 'Найден один файл.');
t('5.3', $p, $s, array('X' => 2), array('locale' => 'ru'), 'Найдены 2 файла.');
t('5.4', $p, $s, array('X' => 5), array('locale' => 'ru'), 'Найдено 5 файлов.');

$s = '{FOO}';

t('6.1', $p, $s, array('FOO' => 1), null, '1');
t('6.2', $p, $s, array('FOO' => 5.5), null, '5.5');
t('6.3', $p, $s, array('FOO' => 'bar'), null, 'bar');

$s = 'Удалить {N_PLURAL:этот {N} файл|эти {N} файла|эти {N} файлов} навсегда?';
$p->set_locale('ru');
t('7.1', $p, $s, array('N' => 5), null, 'Удалить эти 5 файлов навсегда?');
t('7.2', $p, $s, array('N' => 5), array('locale' => 'en'), 'Удалить эти 5 файла навсегда?');
t('7.3', $p, $s, array('N' => 5), null, 'Удалить эти 5 файлов навсегда?');
$p->set_locale('en');
t('7.4', $p, $s, array('N' => 5), null, 'Удалить эти 5 файла навсегда?');
