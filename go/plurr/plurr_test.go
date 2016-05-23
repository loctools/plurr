// Copyright (C) 2016 Igor Afanasyev, https://github.com/iafan/Plurr

package plurr

import "testing"

const S1 = "Do you want to delete {N_PLURAL:this {N} file|these {N} files} permanently?"
const S2 = "Do you want to drink {CHOICE:coffee|tea|juice}?"
const S3 = "Удалить {N_PLURAL:этот {N} файл|эти {N} файла|эти {N} файлов} навсегда?"
const S4 = "{X_PLURAL:{X:|One|{X}} file|{X:No|{X}} files} found."
const S5 = "{X_PLURAL:Найден {X:|один|{X}} файл|Найдены {X} файла|{X:Не найдено|Найдено {X}} файлов}."
const S6 = "{FOO}"
const S7 = "Удалить {N_PLURAL:этот {N} файл|эти {N} файла|эти {N} файлов} навсегда?"

func BenchmarkFormat(b *testing.B) {
	p := New()
	s := "Do you want to delete {N_PLURAL:this {N} file|these {N} files} permanently?"
	params := Params{"N": 5}

	for i := 0; i < b.N; i++ {
		_, _ = p.Format(s, params)
	}
}

func BenchmarkSetLocale(b *testing.B) {
	p := New()
	for i := 0; i < b.N; i++ {
		p.SetLocale("ru")
	}
}

func TestFormatE2(t *testing.T) {
	p := New()
	_, err := p.Format("err {", nil)

	if err.Error() != "Unmatched { found" {
		t.Fail()
	}
}

func TestFormatE3(t *testing.T) {
	p := New()
	_, err := p.Format("err }", nil)

	if err.Error() != "Unmatched } found" {
		t.Fail()
	}
}

func TestFormatE4(t *testing.T) {
	p := New()
	_, err := p.Format("{foo}", nil)

	if err.Error() != "'foo' not defined" {
		t.Fail()
	}
}

func TestFormatE5(t *testing.T) {
	p := New()
	_, err := p.Format("{N_PLURAL}", Params{"N": "NaN"})

	if err.Error() != "Value of 'N' is not a zero or positive integer number" {
		t.Fail()
	}
}

func TestFormatE6(t *testing.T) {
	p := New()
	_, err := p.Format("{N_PLURAL}", Params{"N": 1.5})

	if err.Error() != "Value of 'N' is not a zero or positive integer number" {
		t.Fail()
	}
}

func TestFormat1_1(t *testing.T) {
	p := New()
	out, err := p.Format(S1, Params{"N": 1})

	if err != nil || out != "Do you want to delete this 1 file permanently?" {
		t.Fail()
	}
}

func TestFormat1_2(t *testing.T) {
	p := New()
	out, err := p.Format(S1, Params{"N": 5})

	if err != nil || out != "Do you want to delete these 5 files permanently?" {
		t.Fail()
	}
}

func TestFormat2_1(t *testing.T) {
	p := New()
	out, err := p.Format(S2, Params{"CHOICE": 0})

	if err != nil || out != "Do you want to drink coffee?" {
		t.Fail()
	}
}

func TestFormat2_2(t *testing.T) {
	p := New()
	out, err := p.Format(S2, Params{"CHOICE": 1})

	if err != nil || out != "Do you want to drink tea?" {
		t.Fail()
	}
}

func TestFormat2_3(t *testing.T) {
	p := New()
	out, err := p.Format(S2, Params{"CHOICE": 2})

	if err != nil || out != "Do you want to drink juice?" {
		t.Fail()
	}
}

func TestFormat3_1(t *testing.T) {
	p := New().SetLocale("ru")
	out, err := p.Format(S3, Params{"N": 1})

	if err != nil || out != "Удалить этот 1 файл навсегда?" {
		t.Fail()
	}
}

func TestFormat3_2(t *testing.T) {
	p := New().SetLocale("ru")
	out, err := p.Format(S3, Params{"N": 2})

	if err != nil || out != "Удалить эти 2 файла навсегда?" {
		t.Fail()
	}
}

func TestFormat3_3(t *testing.T) {
	p := New().SetLocale("ru")
	out, err := p.Format(S3, Params{"N": 5})

	if err != nil || out != "Удалить эти 5 файлов навсегда?" {
		t.Fail()
	}
}

func TestFormat3_4(t *testing.T) {
	p := New() // keep English locale
	out, err := p.Format(S3, Params{"N": 5})

	if err != nil || out != "Удалить эти 5 файла навсегда?" {
		t.Fail()
	}
}

func TestFormat4_1(t *testing.T) {
	p := New()
	out, err := p.Format(S4, Params{"X": 0})

	if err != nil || out != "No files found." {
		t.Fail()
	}
}

func TestFormat4_2(t *testing.T) {
	p := New()
	out, err := p.Format(S4, Params{"X": 1})

	if err != nil || out != "One file found." {
		t.Fail()
	}
}

func TestFormat4_3(t *testing.T) {
	p := New()
	out, err := p.Format(S4, Params{"X": 2})

	if err != nil || out != "2 files found." {
		t.Fail()
	}
}

func TestFormat4_4(t *testing.T) {
	p := New()
	out, err := p.Format(S4, Params{"X": "0"})

	if err != nil || out != "No files found." {
		t.Fail()
	}
}

func TestFormat4_5(t *testing.T) {
	p := New()
	out, err := p.Format(S4, Params{"X": "1"})

	if err != nil || out != "One file found." {
		t.Fail()
	}
}

func TestFormat4_6(t *testing.T) {
	p := New()
	out, err := p.Format(S4, Params{"X": "2"})

	if err != nil || out != "2 files found." {
		t.Fail()
	}
}

func TestFormat5_1(t *testing.T) {
	p := New().SetLocale("ru")
	out, err := p.Format(S5, Params{"X": 0})

	if err != nil || out != "Не найдено файлов." {
		t.Fail()
	}
}

func TestFormat5_2(t *testing.T) {
	p := New().SetLocale("ru")
	out, err := p.Format(S5, Params{"X": 1})

	if err != nil || out != "Найден один файл." {
		t.Fail()
	}
}

func TestFormat5_3(t *testing.T) {
	p := New().SetLocale("ru")
	out, err := p.Format(S5, Params{"X": 2})

	if err != nil || out != "Найдены 2 файла." {
		t.Fail()
	}
}

func TestFormat5_4(t *testing.T) {
	p := New().SetLocale("ru")
	out, err := p.Format(S5, Params{"X": 5})

	if err != nil || out != "Найдено 5 файлов." {
		t.Fail()
	}
}

func TestFormat6_1(t *testing.T) {
	p := New()
	out, err := p.Format(S6, Params{"FOO": 1})

	if err != nil || out != "1" {
		t.Fail()
	}
}

func TestFormat6_2(t *testing.T) {
	p := New()
	out, err := p.Format(S6, Params{"FOO": 5.5})

	if err != nil || out != "5.5" {
		t.Fail()
	}
}

func TestFormat6_3(t *testing.T) {
	p := New()
	out, err := p.Format(S6, Params{"FOO": "bar"})

	if err != nil || out != "bar" {
		t.Fail()
	}
}

func TestFormat7_1__7_4(t *testing.T) {
	p := New()
	// 7.1
	out, err := p.SetLocale("ru").Format(S7, Params{"N": 5})

	if err != nil || out != "Удалить эти 5 файлов навсегда?" {
		t.Fail()
	}
	// 7.2
	out, err = p.SetLocale("en").Format(S7, Params{"N": 5})

	if err != nil || out != "Удалить эти 5 файла навсегда?" {
		t.Fail()
	}
	// 7.3
	out, err = p.SetLocale("ru").Format(S7, Params{"N": 5})

	if err != nil || out != "Удалить эти 5 файлов навсегда?" {
		t.Fail()
	}
	// 7.4
	out, err = p.SetLocale("en").Format(S7, Params{"N": 5})

	if err != nil || out != "Удалить эти 5 файла навсегда?" {
		t.Fail()
	}
}
