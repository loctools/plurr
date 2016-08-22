// Copyright (C) 2012-2016 Igor Afanasyev, https://github.com/iafan/Plurr
// Version: 1.0.2

package plurr

import (
	"fmt"
	"testing"
)

func TestSplitString(t *testing.T) {
	s := fmt.Sprintf("%#v", SplitString("foo{X}bar{BAZ:a|b|{X}}", '{', '}'))
	if s != `[]string{"foo", "{", "X", "}", "bar", "{", "BAZ:a|b|", "{", "X", "}", "}"}` {
		t.Fail()
	}
}

func BenchmarkSplitString(b *testing.B) {
	for i := 0; i < b.N; i++ {
		_ = SplitString("foo{X}bar{BAZ:a|b|{X}}", '{', '}')
	}
}
