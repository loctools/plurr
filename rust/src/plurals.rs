// Copyright (C) 2020 Julen Ruiz Aizpuru, https://github.com/julen

pub(crate) fn plural_func(locale: &str, n: usize) -> usize {
    match locale {
        "ach" => {
            // Acholi
            0
        }
        "af" => {
            // Afrikaans
            if n != 1 {
                1
            } else {
                0
            }
        }
        "ak" => {
            // Akhan
            if n > 1 {
                1
            } else {
                0
            }
        }
        "am" => {
            // Amharic
            if n > 1 {
                1
            } else {
                0
            }
        }
        "an" => {
            // Aragonese
            if n != 1 {
                1
            } else {
                0
            }
        }
        "ar" => {
            // Arabic
            if n == 0 {
                0
            } else if n == 1 {
                1
            } else if n == 2 {
                2
            } else if n % 100 >= 3 && n % 100 <= 10 {
                3
            } else if n % 100 >= 11 {
                4
            } else {
                5
            }
        }
        "arn" => {
            // Mapudungun
            if n > 1 {
                1
            } else {
                0
            }
        }
        "ast" => {
            // Asturian
            if n != 1 {
                1
            } else {
                0
            }
        }
        "ay" => {
            // Aymara
            0
        }
        "az" => {
            // Azerbaijani
            if n != 1 {
                1
            } else {
                0
            }
        }

        "be" => {
            // Belarusian
            if n % 10 == 1 && n % 100 != 11 {
                0
            } else if n % 10 >= 2 && n % 10 <= 4 && (n % 100 < 10 || n % 100 >= 20) {
                1
            } else {
                2
            }
        }
        "bg" => {
            // Bulgarian
            if n != 1 {
                1
            } else {
                0
            }
        }
        "bn" => {
            // Bengali
            if n != 1 {
                1
            } else {
                0
            }
        }
        "bo" => {
            // Tibetan
            0
        }
        "br" => {
            // Breton
            if n > 1 {
                1
            } else {
                0
            }
        }
        "bs" => {
            // Bosnian
            if n % 10 == 1 && n % 100 != 11 {
                0
            } else if n % 10 >= 2 && n % 10 <= 4 && (n % 100 < 10 || n % 100 >= 20) {
                1
            } else {
                2
            }
        }

        "ca" => {
            // Catalan
            if n != 1 {
                1
            } else {
                0
            }
        }
        "cgg" => {
            // Chiga
            0
        }
        "cs" => {
            // Czech
            if n == 1 {
                0
            } else if n >= 2 && n <= 4 {
                1
            } else {
                2
            }
        }
        "csb" => {
            // Kashubian
            if n == 1 {
                0
            } else if n % 10 >= 2 && n % 10 <= 4 && (n % 100 < 10 || n % 100 >= 20) {
                1
            } else {
                2
            }
        }
        "cy" => {
            // Welsh
            if n == 1 {
                0
            } else if n == 2 {
                1
            } else if n != 8 && n != 11 {
                2
            } else {
                3
            }
        }

        "da" => {
            // Danish
            if n != 1 {
                1
            } else {
                0
            }
        }
        "de" => {
            // German
            if n != 1 {
                1
            } else {
                0
            }
        }
        "dz" => {
            // Dzongkha
            0
        }

        "el" => {
            // Greek
            if n != 1 {
                1
            } else {
                0
            }
        }
        "en" => {
            // English
            if n != 1 {
                1
            } else {
                0
            }
        }
        "eo" => {
            // Esperanto
            if n != 1 {
                1
            } else {
                0
            }
        }
        "es" => {
            // Spanish
            if n != 1 {
                1
            } else {
                0
            }
        }
        "es-ar" => {
            // Argentinean Spanish
            if n != 1 {
                1
            } else {
                0
            }
        }
        "et" => {
            // Estonian
            if n != 1 {
                1
            } else {
                0
            }
        }
        "eu" => {
            // Basque
            if n != 1 {
                1
            } else {
                0
            }
        }

        "fa" => {
            // Persian
            0
        }
        "fi" => {
            // Finnish
            if n != 1 {
                1
            } else {
                0
            }
        }
        "fil" => {
            // Filipino
            if n > 1 {
                1
            } else {
                0
            }
        }
        "fo" => {
            // Faroese
            if n != 1 {
                1
            } else {
                0
            }
        }
        "fr" => {
            // French
            if n > 1 {
                1
            } else {
                0
            }
        }
        "fur" => {
            // Friulian
            if n != 1 {
                1
            } else {
                0
            }
        }
        "fy" => {
            // Frisian
            if n != 1 {
                1
            } else {
                0
            }
        }

        "ga" => {
            // Irish
            if n == 1 {
                0
            } else if n == 2 {
                1
            } else if n < 7 {
                2
            } else if n < 11 {
                3
            } else {
                4
            }
        }
        "gl" => {
            // Galician
            if n != 1 {
                1
            } else {
                0
            }
        }
        "gu" => {
            // Gujarati
            if n != 1 {
                1
            } else {
                0
            }
        }
        "gun" => {
            // Gun
            if n > 1 {
                1
            } else {
                0
            }
        }

        "ha" => {
            // Hausa
            if n != 1 {
                1
            } else {
                0
            }
        }
        "he" => {
            // Hebrew
            if n != 1 {
                1
            } else {
                0
            }
        }
        "hi" => {
            // Hindi
            if n != 1 {
                1
            } else {
                0
            }
        }
        "hy" => {
            // Armenian
            0
        }
        "hr" => {
            // Croatian
            if n % 10 == 1 && n % 100 != 11 {
                0
            } else if n % 10 >= 2 && n % 10 <= 4 && (n % 100 < 10 || n % 100 >= 20) {
                1
            } else {
                2
            }
        }
        "hu" => {
            // Hungarian
            if n != 1 {
                1
            } else {
                0
            }
        }

        "ia" => {
            // Interlingua
            if n != 1 {
                1
            } else {
                0
            }
        }
        "id" => {
            // Indonesian
            0
        }
        "is" => {
            // Icelandic
            if n % 10 != 1 || n % 100 == 1 {
                1
            } else {
                0
            }
        }
        "it" => {
            // Italian
            if n != 1 {
                1
            } else {
                0
            }
        }

        "ja" => {
            // Japanese
            0
        }
        "jv" => {
            // Javanese
            if n != 0 {
                1
            } else {
                0
            }
        }

        "ka" => {
            // Georgian
            0
        }
        "kk" => {
            // Kazakh
            0
        }
        "km" => {
            // Khmer
            0
        }
        "kn" => {
            // Kannada
            if n != 1 {
                1
            } else {
                0
            }
        }
        "ko" => {
            // Korean
            0
        }
        "ku" => {
            // Kurdish
            if n != 1 {
                1
            } else {
                0
            }
        }
        "kw" => {
            // Cornish
            if n == 1 {
                0
            } else if n == 2 {
                1
            } else if n == 3 {
                2
            } else {
                3
            }
        }
        "ky" => {
            // Kyrgyz
            0
        }

        "lb" => {
            // Letzeburgesch
            if n != 1 {
                1
            } else {
                0
            }
        }
        "ln" => {
            // Lingala
            if n > 1 {
                1
            } else {
                0
            }
        }
        "lo" => {
            // Lao
            0
        }
        "lt" => {
            // Lithuanian
            if n % 10 == 1 && n % 100 != 11 {
                0
            } else if n % 10 >= 2 && (n % 100 < 10 || n % 100 >= 20) {
                1
            } else {
                2
            }
        }
        "lv" => {
            // Latvian
            if n % 10 == 1 && n % 100 != 11 {
                0
            } else if n != 0 {
                1
            } else {
                2
            }
        }

        "mfe" => {
            // Mauritian Creole
            if n > 1 {
                1
            } else {
                0
            }
        }
        "mg" => {
            // Malagasy
            if n > 1 {
                1
            } else {
                0
            }
        }
        "mi" => {
            // Maori
            if n > 1 {
                1
            } else {
                0
            }
        }
        "mk" => {
            // Macedonian
            if n == 1 || n % 10 == 1 {
                0
            } else {
                1
            }
        }
        "ml" => {
            // Malayalam
            if n != 1 {
                1
            } else {
                0
            }
        }
        "mn" => {
            // Mongolian
            if n != 1 {
                1
            } else {
                0
            }
        }
        "mr" => {
            // Marathi
            if n != 1 {
                1
            } else {
                0
            }
        }
        "ms" => {
            // Malay
            0
        }
        "mt" => {
            // Maltese
            if n == 1 {
                0
            } else if n == 0 || (n % 100 > 1 && n % 100 < 11) {
                1
            } else if n % 100 > 10 && n % 100 < 20 {
                2
            } else {
                3
            }
        }

        "nah" => {
            // Nahuatl
            if n != 1 {
                1
            } else {
                0
            }
        }
        "nap" => {
            // Neapolitan
            if n != 1 {
                1
            } else {
                0
            }
        }
        "nb" => {
            // Norwegian Bokmal
            if n != 1 {
                1
            } else {
                0
            }
        }
        "ne" => {
            // Nepali
            if n != 1 {
                1
            } else {
                0
            }
        }
        "nl" => {
            // Dutch
            if n != 1 {
                1
            } else {
                0
            }
        }
        "se" => {
            // Northern Sami
            if n != 1 {
                1
            } else {
                0
            }
        }
        "nn" => {
            // Norwegian Nynorsk
            if n != 1 {
                1
            } else {
                0
            }
        }
        "no" => {
            // Norwegian (old code)
            if n != 1 {
                1
            } else {
                0
            }
        }
        "nso" => {
            // Northern Sotho
            if n != 1 {
                1
            } else {
                0
            }
        }

        "oc" => {
            // Occitan
            if n > 1 {
                1
            } else {
                0
            }
        }
        "or" => {
            // Oriya
            if n != 1 {
                1
            } else {
                0
            }
        }

        "ps" => {
            // Pashto
            if n != 1 {
                1
            } else {
                0
            }
        }
        "pa" => {
            // Punjabi
            if n != 1 {
                1
            } else {
                0
            }
        }
        "pap" => {
            // Papiamento
            if n != 1 {
                1
            } else {
                0
            }
        }
        "pl" => {
            // Polish
            if n == 0 {
                0
            } else if n % 10 >= 2 && n % 10 <= 4 && (n % 100 < 10 || n % 100 >= 20) {
                1
            } else {
                2
            }
        }
        "pms" => {
            // Piemontese
            if n != 1 {
                1
            } else {
                0
            }
        }
        "pt" => {
            // Portuguese
            if n != 1 {
                1
            } else {
                0
            }
        }
        "pt-br" => {
            // Brazilian Portuguese
            if n > 1 {
                1
            } else {
                0
            }
        }

        "rm" => {
            // Romansh
            if n != 1 {
                1
            } else {
                0
            }
        }
        "ro" => {
            // Romanian
            if n == 1 {
                0
            } else if n == 0 || (n % 100 > 0 && n % 100 < 20) {
                1
            } else {
                2
            }
        }
        "ru" => {
            // Russian
            if n % 10 == 1 && n % 100 != 11 {
                0
            } else if n % 10 >= 2 && n % 10 <= 4 && (n % 100 < 10 || n % 100 >= 20) {
                1
            } else {
                2
            }
        }

        "sco" => {
            // Scots
            if n != 1 {
                1
            } else {
                0
            }
        }
        "si" => {
            // Sinhala
            if n != 1 {
                1
            } else {
                0
            }
        }
        "sk" => {
            // Slovak
            if n == 1 {
                0
            } else if n >= 2 && n <= 4 {
                1
            } else {
                2
            }
        }
        "sl" => {
            // Slovenian
            if n % 100 == 1 {
                1
            } else if n % 100 == 2 {
                2
            } else if n % 100 == 3 || n % 100 == 4 {
                3
            } else {
                0
            }
        }
        "so" => {
            // Somali
            if n != 1 {
                1
            } else {
                0
            }
        }
        "son" => {
            // Songhay
            0
        }
        "sq" => {
            // Albanian
            if n != 1 {
                1
            } else {
                0
            }
        }
        "sr" => {
            // Serbian
            if n % 10 == 1 && n % 100 != 11 {
                0
            } else if n % 10 >= 2 && n % 10 <= 4 && (n % 100 < 10 || n % 100 >= 20) {
                1
            } else {
                2
            }
        }
        "su" => {
            // Sundanese
            0
        }
        "sw" => {
            // Swahili
            if n != 1 {
                1
            } else {
                0
            }
        }
        "sv" => {
            // Swedish
            if n != 1 {
                1
            } else {
                0
            }
        }

        "ta" => {
            // Tamil
            if n != 1 {
                1
            } else {
                0
            }
        }
        "te" => {
            // Telugu
            if n != 1 {
                1
            } else {
                0
            }
        }
        "tg" => {
            // Tajik
            if n != 1 {
                1
            } else {
                0
            }
        }
        "ti" => {
            // Tigrinya
            if n > 1 {
                1
            } else {
                0
            }
        }
        "th" => {
            // Thai
            0
        }
        "tk" => {
            // Turkmen
            if n != 1 {
                1
            } else {
                0
            }
        }
        "tr" => {
            // Turkish
            0
        }
        "tt" => {
            // Tatar
            0
        }

        "ug" => {
            // Uyghur
            0
        }
        "uk" => {
            // Ukrainian
            if n % 10 == 1 && n % 100 != 11 {
                0
            } else if n % 10 >= 2 && n % 10 <= 4 && (n % 100 < 10 || n % 100 >= 20) {
                1
            } else {
                2
            }
        }
        "ur" => {
            // Urdu
            if n != 1 {
                1
            } else {
                0
            }
        }
        "uz" => {
            // Uzbek
            0
        }

        "vi" => {
            // Vietnamese
            0
        }

        "wa" => {
            // Walloon
            if n > 1 {
                1
            } else {
                0
            }
        }

        "zh" => {
            // Chinese
            0
        }
        "zh-personal" => {
            // Chinese, used in special cases when dealing with personal pronoun
            if n > 1 {
                1
            } else {
                0
            }
        }
        _ => {
            if n != 1 {
                1
            } else {
                0
            }
        }
    }
}
