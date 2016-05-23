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
my $x = 1000000;

my $start = [gettimeofday];

for (my $i = 0; $i < $x; $i++) {
  my $dummy = $p->set_locale('ru');
}

my $end = [gettimeofday];
my $time = tv_interval($start, $end);
print("Execution time ($x calls): $time sec (" . ($time * 1000 / $x) . ' ms per call)');
