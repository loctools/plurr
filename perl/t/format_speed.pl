#!/usr/bin/perl

use strict;

BEGIN {
  use File::Spec::Functions qw(rel2abs);
  use File::Basename;
  unshift(@INC, dirname(rel2abs($0)).'/..');
}

use Time::HiRes qw(gettimeofday tv_interval);

use Plurr;

my $p = Plurr->new();
my $s = 'Do you want to delete {N_PLURAL:this {N} file|these {N} files} permanently?';
my $params = {'N' => 5};
my $x = 100000;

my $start = [gettimeofday];

for (my $i = 0; $i < $x; $i++) {
  my $dummy = $p->format($s, $params);
}

my $end = [gettimeofday];
my $time = tv_interval($start, $end);
print("Execution time ($x calls): $time sec (" . ($time * 1000 / $x) . ' ms per call)');
