// Copyright (C) 2012-2016 Igor Afanasyev, https://github.com/iafan/Plurr
// Version: 1.0.2

package plurr

//
// list of plural equations taken from
// http://translate.sourceforge.net/wiki/l10n/pluralforms
//
var pluralEquations = map[string]pluralFunc{
	"ach": func(n int) int { return 0 }, // Acholi
	"af": func(n int) int {
		if n != 1 {
			return 1
		}
		return 0
	}, // Afrikaans
	"ak": func(n int) int {
		if n > 1 {
			return 1
		}
		return 0
	}, // Akan
	"am": func(n int) int {
		if n > 1 {
			return 1
		}
		return 0
	}, // Amharic
	"an": func(n int) int {
		if n != 1 {
			return 1
		}
		return 0
	}, // Aragonese
	"ar": func(n int) int {
		if n == 0 {
			return 0
		} else if n == 1 {
			return 1
		} else if n == 2 {
			return 2
		} else if n%100 >= 3 && n%100 <= 10 {
			return 3
		} else if n%100 >= 11 {
			return 4
		}
		return 5
	}, // Arabic
	"arn": func(n int) int {
		if n > 1 {
			return 1
		}
		return 0
	}, // Mapudungun
	"ast": func(n int) int {
		if n != 1 {
			return 1
		}
		return 0
	}, // Asturian
	"ay": func(n int) int { return 0 }, // Aymara
	"az": func(n int) int {
		if n != 1 {
			return 1
		}
		return 0
	}, // Azerbaijani

	"be": func(n int) int {
		if n%10 == 1 && n%100 != 11 {
			return 0
		} else if n%10 >= 2 && n%10 <= 4 && (n%100 < 10 || n%100 >= 20) {
			return 1
		}
		return 2
	}, // Belarusian
	"bg": func(n int) int {
		if n != 1 {
			return 1
		}
		return 0
	}, // Bulgarian
	"bn": func(n int) int {
		if n != 1 {
			return 1
		}
		return 0
	}, // Bengali
	"bo": func(n int) int { return 0 }, // Tibetan
	"br": func(n int) int {
		if n > 1 {
			return 1
		}
		return 0
	}, // Breton
	"bs": func(n int) int {
		if n%10 == 1 && n%100 != 11 {
			return 0
		} else if n%10 >= 2 && n%10 <= 4 && (n%100 < 10 || n%100 >= 20) {
			return 1
		}
		return 2
	}, // Bosnian

	"ca": func(n int) int {
		if n != 1 {
			return 1
		}
		return 0
	}, // Catalan
	"cgg": func(n int) int { return 0 }, // Chiga
	"cs": func(n int) int {
		if n == 1 {
			return 0
		} else if n >= 2 && n <= 4 {
			return 1
		}
		return 2
	}, // Czech
	"csb": func(n int) int {
		if n == 1 {
			return 0
		} else if n%10 >= 2 && n%10 <= 4 && (n%100 < 10 || n%100 >= 20) {
			return 1
		}
		return 2
	}, // Kashubian
	"cy": func(n int) int {
		if n == 1 {
			return 0
		} else if n == 2 {
			return 1
		} else if n != 8 && n != 11 {
			return 2
		}
		return 3
	}, // Welsh

	"da": func(n int) int {
		if n != 1 {
			return 1
		}
		return 0
	}, // Danish
	"de": func(n int) int {
		if n != 1 {
			return 1
		}
		return 0
	}, // German
	"dz": func(n int) int { return 0 }, // Dzongkha

	"el": func(n int) int {
		if n != 1 {
			return 1
		}
		return 0
	}, // Greek
	"en": func(n int) int {
		if n != 1 {
			return 1
		}
		return 0
	}, // English
	"eo": func(n int) int {
		if n != 1 {
			return 1
		}
		return 0
	}, // Esperanto
	"es": func(n int) int {
		if n != 1 {
			return 1
		}
		return 0
	}, // Spanish
	"es-ar": func(n int) int {
		if n != 1 {
			return 1
		}
		return 0
	}, // Argentinean Spanish
	"et": func(n int) int {
		if n != 1 {
			return 1
		}
		return 0
	}, // Estonian
	"eu": func(n int) int {
		if n != 1 {
			return 1
		}
		return 0
	}, // Basque

	"fa": func(n int) int { return 0 }, // Persian
	"fi": func(n int) int {
		if n != 1 {
			return 1
		}
		return 0
	}, // Finnish
	"fil": func(n int) int {
		if n > 1 {
			return 1
		}
		return 0
	}, // Filipino
	"fo": func(n int) int {
		if n != 1 {
			return 1
		}
		return 0
	}, // Faroese
	"fr": func(n int) int {
		if n > 1 {
			return 1
		}
		return 0
	}, // French
	"fur": func(n int) int {
		if n != 1 {
			return 1
		}
		return 0
	}, // Friulian
	"fy": func(n int) int {
		if n != 1 {
			return 1
		}
		return 0
	}, // Frisian

	"ga": func(n int) int {
		if n == 1 {
			return 0
		} else if n == 2 {
			return 1
		} else if n < 7 {
			return 2
		} else if n < 11 {
			return 3
		}
		return 4
	}, // Irish
	"gl": func(n int) int {
		if n != 1 {
			return 1
		}
		return 0
	}, // Galician
	"gu": func(n int) int {
		if n != 1 {
			return 1
		}
		return 0
	}, // Gujarati
	"gun": func(n int) int {
		if n > 1 {
			return 1
		}
		return 0
	}, // Gun

	"ha": func(n int) int {
		if n != 1 {
			return 1
		}
		return 0
	}, // Hausa
	"he": func(n int) int {
		if n != 1 {
			return 1
		}
		return 0
	}, // Hebrew
	"hi": func(n int) int {
		if n != 1 {
			return 1
		}
		return 0
	}, // Hindi
	"hy": func(n int) int { return 0 }, // Armenian
	"hr": func(n int) int {
		if n%10 == 1 && n%100 != 11 {
			return 0
		} else if n%10 >= 2 && n%10 <= 4 && (n%100 < 10 || n%100 >= 20) {
			return 1
		}
		return 2
	}, // Croatian
	"hu": func(n int) int {
		if n != 1 {
			return 1
		}
		return 0
	}, // Hungarian

	"ia": func(n int) int {
		if n != 1 {
			return 1
		}
		return 0
	}, // Interlingua
	"id": func(n int) int { return 0 }, // Indonesian
	"is": func(n int) int {
		if n%10 != 1 || n%100 == 11 {
			return 1
		}
		return 0
	}, // Icelandic
	"it": func(n int) int {
		if n != 1 {
			return 1
		}
		return 0
	}, // Italian

	"ja": func(n int) int { return 0 }, // Japanese
	"jv": func(n int) int {
		if n != 0 {
			return 1
		}
		return 0
	}, // Javanese

	"ka": func(n int) int { return 0 }, // Georgian
	"kk": func(n int) int { return 0 }, // Kazakh
	"km": func(n int) int { return 0 }, // Khmer
	"kn": func(n int) int {
		if n != 1 {
			return 1
		}
		return 0
	}, // Kannada
	"ko": func(n int) int { return 0 }, // Korean
	"ku": func(n int) int {
		if n != 1 {
			return 1
		}
		return 0
	}, // Kurdish
	"kw": func(n int) int {
		if n == 1 {
			return 0
		} else if n == 2 {
			return 1
		} else if n == 3 {
			return 2
		}
		return 3
	}, // Cornish
	"ky": func(n int) int { return 0 }, // Kyrgyz

	"lb": func(n int) int {
		if n != 1 {
			return 1
		}
		return 0
	}, // Letzeburgesch
	"ln": func(n int) int {
		if n > 1 {
			return 1
		}
		return 0
	}, // Lingala
	"lo": func(n int) int { return 0 }, // Lao
	"lt": func(n int) int {
		if n%10 == 1 && n%100 != 11 {
			return 0
		} else if n%10 >= 2 && (n%100 < 10 || n%100 >= 20) {
			return 1
		}
		return 2
	}, // Lithuanian
	"lv": func(n int) int {
		if n%10 == 1 && n%100 != 11 {
			return 0
		} else if n != 0 {
			return 1
		}
		return 2
	}, // Latvian

	"mfe": func(n int) int {
		if n > 1 {
			return 1
		}
		return 0
	}, // Mauritian Creole
	"mg": func(n int) int {
		if n > 1 {
			return 1
		}
		return 0
	}, // Malagasy
	"mi": func(n int) int {
		if n > 1 {
			return 1
		}
		return 0
	}, // Maori
	"mk": func(n int) int {
		if n == 1 || n%10 == 1 {
			return 0
		}
		return 1
	}, // Macedonian
	"ml": func(n int) int {
		if n != 1 {
			return 1
		}
		return 0
	}, // Malayalam
	"mn": func(n int) int {
		if n != 1 {
			return 1
		}
		return 0
	}, // Mongolian
	"mr": func(n int) int {
		if n != 1 {
			return 1
		}
		return 0
	}, // Marathi
	"ms": func(n int) int { return 0 }, // Malay
	"mt": func(n int) int {
		if n == 1 {
			return 0
		} else if n == 0 || (n%100 > 1 && n%100 < 11) {
			return 1
		} else if n%100 > 10 && n%100 < 20 {
			return 2
		}
		return 3
	}, // Maltese

	"nah": func(n int) int {
		if n != 1 {
			return 1
		}
		return 0
	}, // Nahuatl
	"nap": func(n int) int {
		if n != 1 {
			return 1
		}
		return 0
	}, // Neapolitan
	"nb": func(n int) int {
		if n != 1 {
			return 1
		}
		return 0
	}, // Norwegian Bokmal
	"ne": func(n int) int {
		if n != 1 {
			return 1
		}
		return 0
	}, // Nepali
	"nl": func(n int) int {
		if n != 1 {
			return 1
		}
		return 0
	}, // Dutch
	"se": func(n int) int {
		if n != 1 {
			return 1
		}
		return 0
	}, // Northern Sami
	"nn": func(n int) int {
		if n != 1 {
			return 1
		}
		return 0
	}, // Norwegian Nynorsk
	"no": func(n int) int {
		if n != 1 {
			return 1
		}
		return 0
	}, // Norwegian (old code)
	"nso": func(n int) int {
		if n != 1 {
			return 1
		}
		return 0
	}, // Northern Sotho

	"oc": func(n int) int {
		if n > 1 {
			return 1
		}
		return 0
	}, // Occitan
	"or": func(n int) int {
		if n != 1 {
			return 1
		}
		return 0
	}, // Oriya

	"ps": func(n int) int {
		if n != 1 {
			return 1
		}
		return 0
	}, // Pashto
	"pa": func(n int) int {
		if n != 1 {
			return 1
		}
		return 0
	}, // Punjabi
	"pap": func(n int) int {
		if n != 1 {
			return 1
		}
		return 0
	}, // Papiamento
	"pl": func(n int) int {
		if n == 1 {
			return 0
		} else if n%10 >= 2 && n%10 <= 4 && (n%100 < 10 || n%100 >= 20) {
			return 1
		} else {
			return 2
		}
	}, // Polish
	"pms": func(n int) int {
		if n != 1 {
			return 1
		}
		return 0
	}, // Piemontese
	"pt": func(n int) int {
		if n != 1 {
			return 1
		}
		return 0
	}, // Portuguese
	"pt-br": func(n int) int {
		if n > 1 {
			return 1
		}
		return 0
	}, // Brazilian Portuguese

	"rm": func(n int) int {
		if n != 1 {
			return 1
		}
		return 0
	}, // Romansh
	"ro": func(n int) int {
		if n == 1 {
			return 0
		} else if n == 0 || (n%100 > 0 && n%100 < 20) {
			return 1
		}
		return 2
	}, // Romanian
	"ru": func(n int) int {
		if n%10 == 1 && n%100 != 11 {
			return 0
		} else if n%10 >= 2 && n%10 <= 4 && (n%100 < 10 || n%100 >= 20) {
			return 1
		}
		return 2
	}, // Russian

	"sco": func(n int) int {
		if n != 1 {
			return 1
		}
		return 0
	}, // Scots
	"si": func(n int) int {
		if n != 1 {
			return 1
		}
		return 0
	}, // Sinhala
	"sk": func(n int) int {
		if n == 1 {
			return 0
		} else if n >= 2 && n <= 4 {
			return 1
		}
		return 2
	}, // Slovak
	"sl": func(n int) int {
		if n%100 == 1 {
			return 1
		} else if n%100 == 2 {
			return 2
		} else if n%100 == 3 || n%100 == 4 {
			return 3
		}
		return 0
	}, // Slovenian
	"so": func(n int) int {
		if n != 1 {
			return 1
		}
		return 0
	}, // Somali
	"son": func(n int) int { return 0 }, // Songhay
	"sq": func(n int) int {
		if n != 1 {
			return 1
		}
		return 0
	}, // Albanian
	"sr": func(n int) int {
		if n%10 == 1 && n%100 != 11 {
			return 0
		} else if n%10 >= 2 && n%10 <= 4 && (n%100 < 10 || n%100 >= 20) {
			return 1
		}
		return 2
	}, // Serbian
	"su": func(n int) int { return 0 }, // Sundanese
	"sw": func(n int) int {
		if n != 1 {
			return 1
		}
		return 0
	}, // Swahili
	"sv": func(n int) int {
		if n != 1 {
			return 1
		}
		return 0
	}, // Swedish

	"ta": func(n int) int {
		if n != 1 {
			return 1
		}
		return 0
	}, // Tamil
	"te": func(n int) int {
		if n != 1 {
			return 1
		}
		return 0
	}, // Telugu
	"tg": func(n int) int {
		if n != 1 {
			return 1
		}
		return 0
	}, // Tajik
	"ti": func(n int) int {
		if n > 1 {
			return 1
		}
		return 0
	}, // Tigrinya
	"th": func(n int) int { return 0 }, // Thai
	"tk": func(n int) int {
		if n != 1 {
			return 1
		}
		return 0
	}, // Turkmen
	"tr": func(n int) int { return 0 }, // Turkish
	"tt": func(n int) int { return 0 }, // Tatar

	"ug": func(n int) int { return 0 }, // Uyghur
	"uk": func(n int) int {
		if n%10 == 1 && n%100 != 11 {
			return 0
		} else if n%10 >= 2 && n%10 <= 4 && (n%100 < 10 || n%100 >= 20) {
			return 1
		}
		return 2
	}, // Ukrainian
	"ur": func(n int) int {
		if n != 1 {
			return 1
		}
		return 0
	}, // Urdu
	"uz": func(n int) int { return 0 }, // Uzbek

	"vi": func(n int) int { return 0 }, // Vietnamese

	"wa": func(n int) int {
		if n > 1 {
			return 1
		}
		return 0
	}, // Walloon

	"zh": func(n int) int { return 0 }, // Chinese
	"zh-personal": func(n int) int {
		if n > 1 {
			return 1
		}
		return 0
	}, // Chinese, used in special cases when dealing with personal pronoun
}
