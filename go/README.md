Go Plurr Implementation
=======================

This is a [Go](https://golang.org) implementation
of [Plurr](https://github.com/iafan/Plurr) formatter.

Installation
------------

```shell
$ go get github.com/iafan/Plurr/go/plurr
```

Usage
-----

```go
import "github.com/iafan/Plurr/go/plurr"

p := plurr.New() // English locale is set by default

s := "{N_PLURAL:{N} file|{N} files}"
out, err := p.Format(s, plurr.Params{"N": 1}) // => "1 file"
out, err = p.Format(s, plurr.Params{"N": 2})  // => "2 files"
out, err = p.Format(s, plurr.Params{"N": 5})  // => "5 files"

p.SetLocale("ru") // switch to Russian locale

s = "{N_PLURAL:{N} файл|{N} файла|{N} файлов}"
out, err = p.Format(s, plurr.Params{"N": 1}) // => "1 файл"
out, err = p.Format(s, plurr.Params{"N": 2}) // => "2 файла"
out, err = p.Format(s, plurr.Params{"N": 5}) // => "5 файлов"
```
