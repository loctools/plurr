<?php

// Copyright (C) 2012 Igor Afanasyev, https://github.com/iafan/Plurr

class Plurr {
  private $plural;
  private $default_options;
  private $locale_sub;

  //
  // Initialize object
  //
  function __construct($options = null) {

    $options = isset($options) ? $options : array();

    $this->default_options = $options + array(
      'locale' => 'en',
      'auto_plurals' => true,
      'strict' => true,
    );

    //
    // list of plural equations taken from
    // http://translate.sourceforge.net/wiki/l10n/pluralforms
    //
    $this->plural_equations = array(
      'ach' => function ($n) { return 0; }, // Acholi
      'af' => function ($n) { return ($n!=1) ? 1 : 0; }, // Afrikaans
      'ak' => function ($n) { return ($n>1) ? 1 : 0; }, // Akan
      'am' => function ($n) { return ($n>1) ? 1 : 0; }, // Amharic
      'an' => function ($n) { return ($n!=1) ? 1 : 0; }, // Aragonese
      'ar' => function ($n) { return $n==0 ? 0 : ($n==1 ? 1 : ($n==2 ? 2 : ($n%100>=3 && $n%100<=10 ? 3 : ($n%100>=11 ? 4 : 5)))); }, // Arabic
      'arn' => function ($n) { return ($n>1) ? 1 : 0; }, // Mapudungun
      'ast' => function ($n) { return ($n!=1) ? 1 : 0; }, // Asturian
      'ay' => function ($n) { return 0; }, // Aymara
      'az' => function ($n) { return ($n!=1) ? 1 : 0; }, // Azerbaijani

      'be' => function ($n) { return ($n%10==1 && $n%100!=11 ? 0 : ($n%10>=2 && $n%10<=4 && ($n%100<10 || $n%100>=20) ? 1 : 2)); }, // Belarusian
      'bg' => function ($n) { return ($n!=1) ? 1 : 0; }, // Bulgarian
      'bn' => function ($n) { return ($n!=1) ? 1 : 0; }, // Bengali
      'bo' => function ($n) { return 0; }, // Tibetan
      'br' => function ($n) { return ($n>1) ? 1 : 0; }, // Breton
      'bs' => function ($n) { return ($n%10==1 && $n%100!=11 ? 0 : ($n%10>=2 && $n%10<=4 && ($n%100<10 || $n%100>=20) ? 1 : 2)); }, // Bosnian

      'ca' => function ($n) { return ($n!=1) ? 1 : 0; }, // Catalan
      'cgg' => function ($n) { return 0; }, // Chiga
      'cs' => function ($n) { return ($n==1) ? 0 : (($n>=2 && $n<=4) ? 1 : 2); }, // Czech
      'csb' => function ($n) { return $n==1 ? 0 : ($n%10>=2 && $n%10<=4 && ($n%100<10 || $n%100>=20) ? 1 : 2); }, // Kashubian
      'cy' => function ($n) { return ($n==1) ? 0 : (($n==2) ? 1 : (($n!=8 && $n!=11) ? 2 : 3)); }, // Welsh

      'da' => function ($n) { return ($n!=1) ? 1 : 0; }, // Danish
      'de' => function ($n) { return ($n!=1) ? 1 : 0; }, // German
      'dz' => function ($n) { return 0; }, // Dzongkha

      'el' => function ($n) { return ($n!=1) ? 1 : 0; }, // Greek
      'en' => function ($n) { return ($n!=1) ? 1 : 0; }, // English
      'eo' => function ($n) { return ($n!=1) ? 1 : 0; }, // Esperanto
      'es' => function ($n) { return ($n!=1) ? 1 : 0; }, // Spanish
      'es-ar' => function ($n) { return ($n!=1) ? 1 : 0; }, // Argentinean Spanish
      'et' => function ($n) { return ($n!=1) ? 1 : 0; }, // Estonian
      'eu' => function ($n) { return ($n!=1) ? 1 : 0; }, // Basque

      'fa' => function ($n) { return 0; }, // Persian
      'fi' => function ($n) { return ($n!=1) ? 1 : 0; }, // Finnish
      'fil' => function ($n) { return ($n>1) ? 1 : 0; }, // Filipino
      'fo' => function ($n) { return ($n!=1) ? 1 : 0; }, // Faroese
      'fr' => function ($n) { return ($n>1) ? 1 : 0; }, // French
      'fur' => function ($n) { return ($n!=1) ? 1 : 0; }, // Friulian
      'fy' => function ($n) { return ($n!=1) ? 1 : 0; }, // Frisian

      'ga' => function ($n) { return $n==1 ? 0 : ($n==2 ? 1 : ($n<7 ? 2 : $n<11 ? 3 : 4)); }, // Irish
      'gl' => function ($n) { return ($n!=1) ? 1 : 0; }, // Galician
      'gu' => function ($n) { return ($n!=1) ? 1 : 0; }, // Gujarati
      'gun' => function ($n) { return ($n>1) ? 1 : 0; }, // Gun

      'ha' => function ($n) { return ($n!=1) ? 1 : 0; }, // Hausa
      'he' => function ($n) { return ($n!=1) ? 1 : 0; }, // Hebrew
      'hi' => function ($n) { return ($n!=1) ? 1 : 0; }, // Hindi
      'hy' => function ($n) { return 0; }, // Armenian
      'hr' => function ($n) { return ($n%10==1 && $n%100!=11 ? 0 : ($n%10>=2 && $n%10<=4 && ($n%100<10 || $n%100>=20) ? 1 : 2)); }, // Croatian
      'hu' => function ($n) { return ($n!=1) ? 1 : 0; }, // Hungarian

      'ia' => function ($n) { return ($n!=1) ? 1 : 0; }, // Interlingua
      'id' => function ($n) { return 0; }, // Indonesian
      'is' => function ($n) { return ($n%10!=1 || $n%100==11); }, // Icelandic
      'it' => function ($n) { return ($n!=1) ? 1 : 0; }, // Italian

      'ja' => function ($n) { return 0; }, // Japanese
      'jv' => function ($n) { return ($n!=0) ? 1 : 0; }, // Javanese

      'ka' => function ($n) { return 0; }, // Georgian
      'kk' => function ($n) { return 0; }, // Kazakh
      'km' => function ($n) { return 0; }, // Khmer
      'kn' => function ($n) { return ($n!=1) ? 1 : 0; }, // Kannada
      'ko' => function ($n) { return 0; }, // Korean
      'ku' => function ($n) { return ($n!=1) ? 1 : 0; }, // Kurdish
      'kw' => function ($n) { return ($n==1) ? 0 : (($n==2) ? 1 : (($n==3) ? 2 : 3)); }, // Cornish
      'ky' => function ($n) { return 0; }, // Kyrgyz

      'lb' => function ($n) { return ($n!=1); }, // Letzeburgesch
      'ln' => function ($n) { return ($n>1) ? 1 : 0; }, // Lingala
      'lo' => function ($n) { return 0; }, // Lao
      'lt' => function ($n) { return ($n%10==1 && $n%100!=11 ? 0 : ($n%10>=2 && ($n%100<10 || $n%100>=20) ? 1 : 2)); }, // Lithuanian
      'lv' => function ($n) { return ($n%10==1 && $n%100!=11 ? 0 : ($n!=0 ? 1 : 2)); }, // Latvian

      'mfe' => function ($n) { return ($n>1) ? 1 : 0; }, // Mauritian Creole
      'mg' => function ($n) { return ($n>1) ? 1 : 0; }, // Malagasy
      'mi' => function ($n) { return ($n>1) ? 1 : 0; }, // Maori
      'mk' => function ($n) { return $n==1 || $n%10==1 ? 0 : 1; }, // Macedonian
      'ml' => function ($n) { return ($n!=1) ? 1 : 0; }, // Malayalam
      'mn' => function ($n) { return ($n!=1) ? 1 : 0; }, // Mongolian
      'mr' => function ($n) { return ($n!=1) ? 1 : 0; }, // Marathi
      'ms' => function ($n) { return 0; }, // Malay
      'mt' => function ($n) { return ($n==1 ? 0 : ($n==0 || ( $n%100>1 && $n%100<11) ? 1 : (($n%100>10 && $n%100<20 ) ? 2 : 3))); }, // Maltese

      'nah' => function ($n) { return ($n!=1) ? 1 : 0; }, // Nahuatl
      'nap' => function ($n) { return ($n!=1) ? 1 : 0; }, // Neapolitan
      'nb' => function ($n) { return ($n!=1) ? 1 : 0; }, // Norwegian Bokmal
      'ne' => function ($n) { return ($n!=1) ? 1 : 0; }, // Nepali
      'nl' => function ($n) { return ($n!=1) ? 1 : 0; }, // Dutch
      'se' => function ($n) { return ($n!=1) ? 1 : 0; }, // Northern Sami
      'nn' => function ($n) { return ($n!=1) ? 1 : 0; }, // Norwegian Nynorsk
      'no' => function ($n) { return ($n!=1) ? 1 : 0; }, // Norwegian (old code)
      'nso' => function ($n) { return ($n!=1) ? 1 : 0; }, // Northern Sotho

      'oc' => function ($n) { return ($n>1) ? 1 : 0; }, // Occitan
      'or' => function ($n) { return ($n!=1) ? 1 : 0; }, // Oriya

      'ps' => function ($n) { return ($n!=1) ? 1 : 0; }, // Pashto
      'pa' => function ($n) { return ($n!=1) ? 1 : 0; }, // Punjabi
      'pap' => function ($n) { return ($n!=1) ? 1 : 0; }, // Papiamento
      'pl' => function ($n) { return ($n==1 ? 0 : $n%10>=2 && $n%10<=4 && ($n%100<10 || $n%100>=20) ? 1 : 2); }, // Polish
      'pms' => function ($n) { return ($n!=1) ? 1 : 0; }, // Piemontese
      'pt' => function ($n) { return ($n!=1) ? 1 : 0; }, // Portuguese
      'pt-br' => function ($n) { return ($n>1) ? 1 : 0; }, // Brazilian Portuguese

      'rm' => function ($n) { return ($n!=1); }, // Romansh
      'ro' => function ($n) { return ($n==1 ? 0 : ($n==0 || ($n%100>0 && $n%100<20)) ? 1 : 2); }, // Romanian
      'ru' => function ($n) { return ($n%10==1 && $n%100!=11 ? 0 : ($n%10>=2 && $n%10<=4 && ($n%100<10 || $n%100>=20) ? 1 : 2)); }, // Russian

      'sco' => function ($n) { return ($n!=1) ? 1 : 0; }, // Scots
      'si' => function ($n) { return ($n!=1) ? 1 : 0; }, // Sinhala
      'sk' => function ($n) { return ($n==1) ? 0 : ($n>=2 && $n<=4) ? 1 : 2; }, // Slovak
      'sl' => function ($n) { return ($n%100==1 ? 1 : ($n%100==2 ? 2 : ($n%100==3 || $n%100==4 ? 3 : 0))); }, // Slovenian
      'so' => function ($n) { return ($n!=1) ? 1 : 0; }, // Somali
      'son' => function ($n) { return 0; }, // Songhay
      'sq' => function ($n) { return ($n!=1) ? 1 : 0; }, // Albanian
      'sr' => function ($n) { return ($n%10==1 && $n%100!=11 ? 0 : ($n%10>=2 && $n%10<=4 && ($n%100<10 || $n%100>=20) ? 1 : 2)); }, // Serbian
      'su' => function ($n) { return 0; }, // Sundanese
      'sw' => function ($n) { return ($n!=1) ? 1 : 0; }, // Swahili
      'sv' => function ($n) { return ($n!=1) ? 1 : 0; }, // Swedish

      'ta' => function ($n) { return ($n!=1) ? 1 : 0; }, // Tamil
      'te' => function ($n) { return ($n!=1) ? 1 : 0; }, // Telugu
      'tg' => function ($n) { return ($n!=1) ? 1 : 0; }, // Tajik
      'ti' => function ($n) { return ($n>1) ? 1 : 0; }, // Tigrinya
      'th' => function ($n) { return 0; }, // Thai
      'tk' => function ($n) { return ($n!=1) ? 1 : 0; }, // Turkmen
      'tr' => function ($n) { return 0; }, // Turkish
      'tt' => function ($n) { return 0; }, // Tatar

      'ug' => function ($n) { return 0; }, // Uyghur
      'uk' => function ($n) { return ($n%10==1 && $n%100!=11 ? 0 : ($n%10>=2 && $n%10<=4 && ($n%100<10 || $n%100>=20) ? 1 : 2)); }, // Ukrainian
      'ur' => function ($n) { return ($n!=1) ? 1 : 0; }, // Urdu
      'uz' => function ($n) { return 0; }, // Uzbek

      'vi' => function ($n) { return 0; }, // Vietnamese

      'wa' => function ($n) { return ($n>1) ? 1 : 0; }, // Walloon

      'zh' => function ($n) { return 0; }, // Chinese
      'zh-personal' => function ($n) { return ($n>1) ? 1 : 0; }, // Chinese, used in special cases when dealing with personal pronoun
    );

    // initialize with the provided or default locale ('en')
    $this->locale(defined($this->options['locale']) ? $this->options['locale'] : 'en');
  } // function __construct

  //
  // Choose the plural function based on locale name
  // 
  public function locale($locale) {
    $this->plural = $this->plural_equations[$locale];
  } // function locale

  const _PLURAL = '_PLURAL';

  public function format($s, $params, $options = null) {
    if (gettype($params) != 'array') {
      throw new Exception("'params' is not a hash");
    }

    if (isset($options) && (gettype($options) != 'array')) {
      throw new Exception("'options' is not a hash");
    }

    $options = isset($options) ? $options : array();

    $plural_func = array_key_exists('locale', $options) ?
      $this->plural_equations[$options['locale']] :
      $this->plural;

    if (!isset($plural_func)) {
      $plural_func = $this->plural_equations['en'];
    }

    $options = $options + $this->default_options;

    $strict = !!$options['strict'];
    $auto_plurals = !!$options['auto_plurals'];
    $callback = isset($options['callback']) ? $options['callback'] : null;

    $chunks = preg_split('/([\{\}])/', $s, null, PREG_SPLIT_DELIM_CAPTURE);
    $blocks = array('');
    $bracket_count = 0;
    for ($i = 0, $ch_len = count($chunks); $i < $ch_len; $i++) {
      $chunk = $chunks[$i];

      if ($chunk == '{') {
        $bracket_count++;
        array_push($blocks, '');
        continue;
      }

      if ($chunk == '}') {
        $bracket_count--;
        if ($bracket_count < 0) {
          throw new Exception("Unmatched } found");
        }

        $block = array_pop($blocks);
        $colon_pos = strpos($block, ':');

        if ($strict && ($colon_pos === 0)) {
          throw new Exception("Empty placeholder name");
        }

        if ($colon_pos === false) { # simple placeholder
          $name = $block;
        } else { # multiple choices
          $name = substr($block, 0, $colon_pos);
        }

        if (!isset($params[$name])) {
          $p_pos = strpos($name, self::_PLURAL);
          if ($auto_plurals && ($p_pos === (strlen($name) - strlen(self::_PLURAL)))) {
            $prefix = substr($name, 0, $p_pos);
            if ($strict && !isset($params[$prefix])) {
              throw new Exception("Neither '$name' nor '$prefix' are defined");
            }

            $prefix_value = (int) $params[$prefix];
            if (((string) $prefix_value !== (string) $params[$prefix]) || ($prefix_value < 0)) {
              if ($strict) {
                throw new Exception("Value of '$prefix' is not a zero or positive integer number");
              }
              $prefix_value = 0;
            }

            $params[$name] = $plural_func($prefix_value);
          } else {
            if ($callback) {
              $params[$name] = $callback($name);
            } elseif ($strict) {
              throw new Exception("'$name' not defined");
            }
          }
        }

        if ($colon_pos === false) { # simple placeholder
          $result = $params[$name];
        } else { # multiple choices
          $block_len = strlen($block);

          if ($strict && ($colon_pos === $block_len - 1)) {
            throw new Exception('Empty list of variants');
          }

          $choice_idx = (int) $params[$name];
          if (((string) $choice_idx !== (string) $params[$name]) || ($choice_idx < 0)) {
            if ($strict) {
              throw new Exception("Value of '$name' is not a zero or positive integer number");
            }
            $choice_idx = 0;
          }
          $n = 0;
          $choice_start = $colon_pos + 1;
          $choice_end = $block_len;
          $j = -1;

          while (($j = strpos($block, '|', $j + 1)) !== false) {
            $n++;
            if ($n <= $choice_idx) {
              $choice_start = $j + 1;
            } elseif ($n == $choice_idx + 1) {
              $choice_end = $j;
            }
          }
          $result = substr($block, $choice_start, $choice_end - $choice_start);
        }

        $blocks[count($blocks) - 1] .= $result;
        continue;
      }
      $blocks[count($blocks) - 1] .= $chunk;
    }

    if ($bracket_count > 0) {
      throw new Exception("Unmatched { found");
    }

    return $blocks[0];
  } // function format

} // class

?>