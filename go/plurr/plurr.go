// Copyright (C) 2012-2016 Igor Afanasyev, https://github.com/iafan/Plurr
// Version: 1.0.2

package plurr

import (
	"fmt"
	"strconv"
	"strings"
	"unicode/utf8"
)

const suffixPLURAL = "_PLURAL"

// CallbackFunc defines a type of callback function
// that is called to dynamically get the value of placeholder
type CallbackFunc func(s string) (string, error)

type pluralFunc func(n int) int

// Plurr object
type Plurr struct {
	locale      string
	autoPlurals bool
	strict      bool
	callback    CallbackFunc
	pluralFunc  pluralFunc
}

// Params type is used to pass placeholder values
// to Format function
type Params map[string]interface{}

// New initializes Plurr object
func New() *Plurr {
	p := &Plurr{}

	// initialize with the default parameters
	p.SetLocale("en").SetAutoPlurals(true).SetStrict(true)

	return p
}

// SetLocale chooses the plural function based on locale name.
// Function returns the Plurr object so that calls can be chained.
func (p *Plurr) SetLocale(locale string) *Plurr {
	f, ok := pluralEquations[locale]
	if !ok {
		f = pluralEquations["en"]
	}
	p.pluralFunc = f

	return p
}

// SetAutoPlurals sets the 'auto-plurals' mode where the value of
// 'X_PLURAL' placeholder is calculated automatically by taking
// the value of 'X' placeholder and passing it through `pluralFunc()`.
// This mode is enabled by default.
// Function returns the Plurr object so that calls can be chained.
func (p *Plurr) SetAutoPlurals(value bool) *Plurr {
	p.autoPlurals = value
	return p
}

// SetStrict sets the 'strict' mode where missing placeholder values,
// as well as non-uint values of placeholders about to be passed
// through a plural function, are reported as errors.
// This mode is enabled by default.
// Function returns the Plurr object so that calls can be chained.
func (p *Plurr) SetStrict(value bool) *Plurr {
	p.strict = value
	return p
}

// SetCallback sets the callback function to be called by 'plurr.Format'
// to get placeholder values dynamically.
// Function returns the Plurr object so that calls can be chained.
func (p *Plurr) SetCallback(value CallbackFunc) *Plurr {
	p.callback = value
	return p
}

// Format renders the string based on the template
// and a list (map) of parameters
func (p *Plurr) Format(s string, params Params) (string, error) {
	chunks := SplitString(s, '{', '}')
	blocks := []string{""}
	bracketCount := 0

	for _, chunk := range chunks {
		if chunk == "{" {
			bracketCount++
			blocks = append(blocks, "")
			continue
		}

		if chunk == "}" {
			bracketCount--
			if bracketCount < 0 {
				return "", ErrUnmatchedClosingBrace
			}

			// pop last item from array
			block := ""
			block, blocks = blocks[len(blocks)-1], blocks[:len(blocks)-1]
			colonPos := strings.Index(block, ":")

			if p.strict && colonPos == 0 {
				return "", ErrEmptyPlaceholderName
			}

			var name string

			if colonPos == -1 { // simple placeholder
				name = block
			} else { // multiple choices
				name = block[:colonPos]
			}

			if _, ok := params[name]; !ok {
				pPos := strings.Index(name, suffixPLURAL)
				if p.autoPlurals && pPos != -1 && pPos == (utf8.RuneCountInString(name)-utf8.RuneCountInString(suffixPLURAL)) {
					prefix := name[:pPos]
					if _, ok = params[prefix]; !ok {
						if p.callback != nil {
							val, err := p.callback(prefix)
							if err != nil {
								return "", err
							}
							params[prefix] = val
						} else if p.strict {
							return "", &PlaceholderValueNotDefinedError{name, prefix}
						}
					}

					prefixValue, err := strconv.Atoi(fmt.Sprintf("%v", params[prefix]))
					if err != nil || prefixValue < 0 {
						if p.strict {
							return "", &ValueNotAnIntegerError{prefix}
						}
						prefixValue = 0
					}

					params[name] = p.pluralFunc(prefixValue)
				} else {
					if p.callback != nil {
						val, err := p.callback(name)
						if err != nil {
							return "", err
						}
						params[name] = val
					} else if p.strict {
						return "", &ValueNotDefinedError{name}
					}
				}
			}

			result := ""

			if colonPos == -1 { // simple placeholder
				result = fmt.Sprintf("%v", params[name])
			} else { // multiple choices
				blockLen := utf8.RuneCountInString(block)

				if p.strict && colonPos == blockLen-1 {
					return "", ErrEmptyListOfVariants
				}

				choiceIdx, err := strconv.Atoi(fmt.Sprintf("%v", params[name]))
				if err != nil || choiceIdx < 0 {
					if p.strict {
						return "", &ValueNotAnIntegerError{name}
					}
					choiceIdx = 0
				}

				choices := strings.Split(block[colonPos+1:], "|")
				if choiceIdx > len(choices)-1 {
					choiceIdx = len(choices) - 1
				}

				result = choices[choiceIdx]
			}

			blocks[len(blocks)-1] = blocks[len(blocks)-1] + result
			continue
		}
		blocks[len(blocks)-1] = blocks[len(blocks)-1] + chunk
	}

	if bracketCount > 0 {
		return "", ErrUnmatchedOpeningBrace
	}

	return blocks[0], nil
}
