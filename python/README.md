Python Plurr Implementation
===========================

Requirements
------------

Python 2.6 or above.

Usage
-----

```Python
from plurr import Plurr

p = Plurr() # English locale is set by default

s = "{N_PLURAL:{N} file|{N} files}"
out = p.format(s, {"N": 1}) # => "1 file"
out = p.format(s, {"N": 2}) # => "2 files"
out = p.format(s, {"N", 5}) # => "5 files"

p.set_locale("ru") # switch to Russian locale

s = "{N_PLURAL:{N} файл|{N} файла|{N} файлов}"
out = p.format(s, {"N": 1}) # => "1 файл"
out = p.format(s, {"N": 2}) # => "2 файла"
out = p.format(s, {"N": 5}) # => "5 файлов"
```