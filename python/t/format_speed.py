#!/usr/bin/env python
# -*- coding: utf-8 -*-

import sys
sys.path.append("..")

import time

from plurr import Plurr

p = Plurr()
s = 'Do you want to delete {N_PLURAL:this {N} file|these {N} files} permanently?';
params = {'N': 5};
x = 100000

start = time.clock()

for i in xrange(x):
  dummy = p.format(s, params)

end = time.clock()
time = end - start
print('Execution time ({0} calls): {1} sec ({2} ms per call)'.format(x, time, time * 1000 / x))
