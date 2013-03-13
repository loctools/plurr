#!/usr/bin/perl

use strict;

BEGIN {
  use File::Spec::Functions qw(rel2abs);
  use File::Basename;
  unshift(@INC, dirname(rel2abs($0)).'/..');
}

sub t {
  my ($n, $p, $s, $params, $options, $message, $exception) = @_;

  my $result;
  eval {
    $result = $p->format($s, $params, $options);
  };

  if ($@) {
    my $err = chomp($@);
    print("$n: " . ($@ eq $exception ? 'pass' : "fail: [$@] vs [$exception]") . "\n");
    return;
  } else {
    if ($exception) {
      print("$n: fail: should produce exception [$exception]\n");
    } else {
      print("$n: " . ($result eq $message ? 'pass' : "fail: [$result] vs [$message]") . "\n");
    }
  }
}

use Plurr;

my $p = Plurr->new();
my $s;

t('e.1', $p, '', undef, undef, '', "'params' is not a hash");
t('e.2', $p, 'err {', {}, undef, '', "Unmatched { found");
t('e.3', $p, 'err }', {}, undef, '', "Unmatched } found");
t('e.4', $p, '{foo}', {}, undef, '', "'foo' not defined");
t('e.5', $p, '{N_PLURAL}', {'N' => 'NaN'}, undef, '', "Value of 'N' is not a zero or positive integer number");
t('e.6', $p, '{N_PLURAL}', {'N' => 1.5}, undef, '', "Value of 'N' is not a zero or positive integer number");

$s = 'Do you want to delete {N_PLURAL:this {N} file|these {N} files} permanently?';

t('1.1', $p, $s, {'N' => 1}, undef, 'Do you want to delete this 1 file permanently?');
t('1.2', $p, $s, {'N' => 5}, undef, 'Do you want to delete these 5 files permanently?');

$s = 'Do you want to drink {CHOICE:coffee|tea|juice}?';

t('2.1', $p, $s, {'CHOICE' => 0}, undef, 'Do you want to drink coffee?');
t('2.2', $p, $s, {'CHOICE' => 1}, undef, 'Do you want to drink tea?');
t('2.3', $p, $s, {'CHOICE' => 2}, undef, 'Do you want to drink juice?');

$s = 'Удалить {N_PLURAL:этот {N} файл|эти {N} файла|эти {N} файлов} навсегда?';

t('3.1', $p, $s, {'N' => 1}, {'locale' => 'ru'}, 'Удалить этот 1 файл навсегда?');
t('3.2', $p, $s, {'N' => 2}, {'locale' => 'ru'}, 'Удалить эти 2 файла навсегда?');
t('3.3', $p, $s, {'N' => 5}, {'locale' => 'ru'}, 'Удалить эти 5 файлов навсегда?');
t('3.4', $p, $s, {'N' => 5}, undef, 'Удалить эти 5 файла навсегда?');

$s = '{X_PLURAL:{X:|One|{X}} file|{X:No|{X}} files} found.';

t('4.1', $p, $s, {'X' => 0}, undef, 'No files found.');
t('4.2', $p, $s, {'X' => 1}, undef, 'One file found.');
t('4.3', $p, $s, {'X' => 2}, undef, '2 files found.');

t('4.4', $p, $s, {'X' => '0'}, undef, 'No files found.');
t('4.5', $p, $s, {'X' => '1'}, undef, 'One file found.');
t('4.6', $p, $s, {'X' => '2'}, undef, '2 files found.');

$s = '{X_PLURAL:Найден {X:|один|{X}} файл|Найдены {X} файла|{X:Не найдено|Найдено {X}} файлов}.';

t('5.1', $p, $s, {'X' => 0}, {'locale' => 'ru'}, 'Не найдено файлов.');
t('5.2', $p, $s, {'X' => 1}, {'locale' => 'ru'}, 'Найден один файл.');
t('5.3', $p, $s, {'X' => 2}, {'locale' => 'ru'}, 'Найдены 2 файла.');
t('5.4', $p, $s, {'X' => 5}, {'locale' => 'ru'}, 'Найдено 5 файлов.');

$s = '{FOO}';

t('6.1', $p, $s, {'FOO' => 1}, undef, '1');
t('6.2', $p, $s, {'FOO' => 5.5}, undef, '5.5');
t('6.3', $p, $s, {'FOO' => 'bar'}, undef, 'bar');
