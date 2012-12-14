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
t('e.5', $p, '{N_PLURAL}', {'N' => 'NaN'}, undef, '', "Value of 'N' is not a number");

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
