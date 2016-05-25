// Copyright (C) 2016 Igor Afanasyev, https://github.com/iafan/Plurr

package plurr

// SplitString splits the string by the set of individual characters
// in `delimiters` string and returns an array of strings
// including the delimiters
func SplitString(s string, start, end rune) []string {
	var out []string
	delim := false
	accum := ""
	for _, char := range s {
		if (char == start || char == end) == delim {
			if delim {
				if accum != "" {
					out = append(out, accum)
				}
				accum = string(char)
			} else {
				accum = accum + string(char)
			}
		} else {
			out = append(out, accum)
			delim = !delim
			accum = string(char)
		}
	}
	if accum != "" {
		out = append(out, accum)
	}
	return out
}
