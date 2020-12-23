// Copyright (C) 2020 Julen Ruiz Aizpuru, https://github.com/julen

/// Splits a string `s` upon the `start` and `end` delimiters.
/// Returns a vector of owned strings.
/// NOTE: this is needed because `regex::Regex::split()` doesn't capture groups
/// (cf. rust-lang/regex#285).
pub(crate) fn split_string(s: &str, start: &str, end: &str) -> Vec<String> {
    let mut delim = false;
    let mut accum = "".to_string();
    let mut out: Vec<String> = vec![];

    for _char in s.chars() {
        let ch = _char.to_string();
        if (ch == start || ch == end) == delim {
            if delim {
                if accum != "" {
                    out.push(accum);
                }
                accum = ch;
            } else {
                accum.push_str(&ch);
            }
        } else {
            out.push(accum);
            delim = !delim;
            accum = ch;
        }
    }

    if accum != "" {
        out.push(accum);
    }
    out
}
