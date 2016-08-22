// Copyright (C) 2012-2016 Igor Afanasyev, https://github.com/iafan/Plurr
// Version: 1.0.2

package plurr

import (
	"errors"
	"fmt"
)

// ErrUnmatchedOpeningBrace is returned by Format function
// when there's an unmateched opening curly brace
// in the template string
var ErrUnmatchedOpeningBrace = errors.New("Unmatched { found")

// ErrUnmatchedClosingBrace is returned by Format function
// when there's an unmateched closing curly brace
// in the template string
var ErrUnmatchedClosingBrace = errors.New("Unmatched } found")

// ErrEmptyPlaceholderName is returned by Format function
// in strict mode when placeholder name is empty
// in the template string ("{}")
var ErrEmptyPlaceholderName = errors.New("Empty placeholder name")

// ErrEmptyListOfVariants is returned by Format function
// in strict mode when choice block has no variants ("{X:}")
var ErrEmptyListOfVariants = errors.New("Empty list of variants")

// ErrPlaceholderValueNotDefined is returned by Format function
// when neither palaceholder not its prefix variant (sans '_PLURAL')
// is not defined
type PlaceholderValueNotDefinedError struct {
	name   string
	prefix string
}

func (e *PlaceholderValueNotDefinedError) Error() string {
	return fmt.Sprintf("Neither '%s' nor '%s' are defined", e.name, e.prefix)
}

// ErrValueNotAnInteger is returned by Format function
// in strict mode when placeholder value can't be evaluated
// to 0 or positive integer
type ValueNotAnIntegerError struct {
	name string
}

func (e *ValueNotAnIntegerError) Error() string {
	return fmt.Sprintf("Value of '%s' is not a zero or positive integer number", e.name)
}

// ErrValueNotDefined is returned by Format function
// in strict mode when placeholder value is not provided
// in the parameters map
type ValueNotDefinedError struct {
	name string
}

func (e *ValueNotDefinedError) Error() string {
	return fmt.Sprintf("'%s' not defined", e.name)
}
