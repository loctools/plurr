#!/usr/bin/env python
# -*- coding: utf-8 -*-

import sys
sys.path.append("..")

import time

from Plurr import Plurr

p = Plurr()
x = 100000

start = time.clock()

for i in xrange(x):
  dummy = p.locale('ru')

end = time.clock()
time = end - start
print('Execution time ({0} calls): {1} sec ({2} ms per call)'.format(x, time, time * 1000 / x))
