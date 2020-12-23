## Plurr

A library for handling plurals/genders/conditionals.

### Installation

Add the `plurr` crate to your *Cargo.toml* file:

```toml
[dependencies]
plurr = "0.1.0"
```

### Usage

```rust
extern crate plurr;

use plurr::Plurr;

let mut p = Plurr::new();
let s = "Delete {N_PLURAL:{N} file|{N} files}?";
p.param("N", "5").format(s); // "Delete 5 files?"
```
