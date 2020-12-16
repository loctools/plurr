// Copyright (C) 2012-2020 Igor Afanasyev, https://github.com/iafan/Plurr
// Version: 1.0.3

(function (root, factory) {
  if (typeof define === 'function' && define.amd) {
    define([], factory);
  } else if (typeof module === 'object' && module.exports) {
    module.exports = factory();
  } else {
    root.Plurr = factory();
  }
}(this, function () {
  function addMissingOptions (opt, defaults) {
    for (prop in defaults) {
      if (!opt.hasOwnProperty(prop)) {
        opt[prop] = defaults[prop];
      }
    }
  }


  var _PLURAL = '_PLURAL';

  //
  // list of plural equations taken from
  // http://translate.sourceforge.net/wiki/l10n/pluralforms
  //
  var pluralEquations = {
    'ach': 'zero', // Acholi
    'af': 'en', // Afrikaans
    'ak': 'fr', // Akan
    'am': 'fr', // Amharic
    'an': 'en', // Aragonese
    'ar': function(n) { return n==0 ? 0 : n==1 ? 1 : n==2 ? 2 : n%100>=3 && n%100<=10 ? 3 : n%100>=11 ? 4 : 5; }, // Arabic
    'arn': 'fr', // Mapudungun
    'ast': 'en', // Asturian
    'ay': 'zero', // Aymara
    'az': 'en', // Azerbaijani

    'be': 'ru', // Belarusian
    'bg': 'en', // Bulgarian
    'bn': 'en', // Bengali
    'bo': 'zero', // Tibetan
    'br': 'fr', // Breton
    'bs': 'ru', // Bosnian

    'ca': 'en', // Catalan
    'cgg': 'zero', // Chiga
    'cs': function(n) { return (n==1) ? 0 : (n>=2 && n<=4) ? 1 : 2; }, // Czech
    'csb': function(n) { return n==1 ? 0 : n%10>=2 && n%10<=4 && (n%100<10 || n%100>=20) ? 1 : 2; }, // Kashubian
    'cy': function(n) { return (n==1) ? 0 : (n==2) ? 1 : (n!=8 && n!=11) ? 2 : 3; }, // Welsh

    'da': 'en', // Danish
    'de': 'en', // German
    'dz': 'zero', // Dzongkha

    'el': 'en', // Greek
    'en': 'en', // English
    'eo': 'en', // Esperanto
    'es': 'en', // Spanish
    'es-ar': 'en', // Argentinean Spanish
    'et': 'en', // Estonian
    'eu': 'en', // Basque

    'fa': 'zero', // Persian
    'fi': 'en', // Finnish
    'fil': 'fr', // Filipino
    'fo': 'en', // Faroese
    'fr': 'fr', // French
    'fur': 'en', // Friulian
    'fy': 'en', // Frisian

    'ga': function(n) { return n==1 ? 0 : n==2 ? 1 : n<7 ? 2 : n<11 ? 3 : 4; }, // Irish
    'gl': 'en', // Galician
    'gu': 'en', // Gujarati
    'gun': 'fr', // Gun

    'ha': 'en', // Hausa
    'he': 'en', // Hebrew
    'hi': 'en', // Hindi
    'hy': 'zero', // Armenian
    'hr': 'ru', // Croatian
    'hu': 'en', // Hungarian

    'ia': 'en', // Interlingua
    'id': 'zero', // Indonesian
    'is': function(n) { return (n%10!=1 || n%100==11); }, // Icelandic
    'it': 'en', // Italian

    'ja': 'zero', // Japanese
    'jv': function(n) { return (n!=0) ? 1 : 0; }, // Javanese

    'ka': 'zero', // Georgian
    'kk': 'zero', // Kazakh
    'km': 'zero', // Khmer
    'kn': 'en', // Kannada
    'ko': 'zero', // Korean
    'ku': 'en', // Kurdish
    'kw': function(n) { return (n==1) ? 0 : (n==2) ? 1 : (n==3) ? 2 : 3; }, // Cornish
    'ky': 'zero', // Kyrgyz

    'lb': function(n) { return (n!=1); }, // Letzeburgesch
    'ln': 'fr', // Lingala
    'lo': 'zero', // Lao
    'lt': function(n) { return (n%10==1 && n%100!=11 ? 0 : n%10>=2 && (n%100<10 || n%100>=20) ? 1 : 2); }, // Lithuanian
    'lv': function(n) { return (n%10==1 && n%100!=11 ? 0 : n!=0 ? 1 : 2); }, // Latvian

    'mfe': 'fr', // Mauritian Creole
    'mg': 'fr', // Malagasy
    'mi': 'fr', // Maori
    'mk': function(n) { return n==1 || n%10==1 ? 0 : 1; }, // Macedonian
    'ml': 'en', // Malayalam
    'mn': 'en', // Mongolian
    'mr': 'en', // Marathi
    'ms': 'zero', // Malay
    'mt': function(n) { return (n==1 ? 0 : n==0 || ( n%100>1 && n%100<11) ? 1 : (n%100>10 && n%100<20 ) ? 2 : 3); }, // Maltese

    'nah': 'en', // Nahuatl
    'nap': 'en', // Neapolitan
    'nb': 'en', // Norwegian Bokmal
    'ne': 'en', // Nepali
    'nl': 'en', // Dutch
    'se': 'en', // Northern Sami
    'nn': 'en', // Norwegian Nynorsk
    'no': 'en', // Norwegian (old code)
    'nso': 'en', // Northern Sotho

    'oc': 'fr', // Occitan
    'or': 'en', // Oriya

    'ps': 'en', // Pashto
    'pa': 'en', // Punjabi
    'pap': 'en', // Papiamento
    'pl': function(n) { return (n==1 ? 0 : n%10>=2 && n%10<=4 && (n%100<10 || n%100>=20) ? 1 : 2); }, // Polish
    'pms': 'en', // Piemontese
    'pt': 'en', // Portuguese
    'pt-br': 'fr', // Brazilian Portuguese

    'rm': function(n) { return (n!=1); }, // Romansh
    'ro': function(n) { return (n==1 ? 0 : (n==0 || (n%100>0 && n%100<20)) ? 1 : 2); }, // Romanian
    'ru': 'ru', // Russian

    'sco': 'en', // Scots
    'si': 'en', // Sinhala
    'sk': function(n) { return (n==1) ? 0 : (n>=2 && n<=4) ? 1 : 2; }, // Slovak
    'sl': function(n) { return (n%100==1 ? 1 : n%100==2 ? 2 : n%100==3 || n%100==4 ? 3 : 0); }, // Slovenian
    'so': 'en', // Somali
    'son': 'zero', // Songhay
    'sq': 'en', // Albanian
    'sr': 'ru', // Serbian
    'su': 'zero', // Sundanese
    'sw': 'en', // Swahili
    'sv': 'en', // Swedish

    'ta': 'en', // Tamil
    'te': 'en', // Telugu
    'tg': 'en', // Tajik
    'ti': 'fr', // Tigrinya
    'th': 'zero', // Thai
    'tk': 'en', // Turkmen
    'tr': 'zero', // Turkish
    'tt': 'zero', // Tatar

    'ug': 'zero', // Uyghur
    'uk': 'ru', // Ukrainian
    'ur': 'en', // Urdu
    'uz': 'zero', // Uzbek

    'vi': 'zero', // Vietnamese

    'wa': 'fr', // Walloon

    'zh': 'zero', // Chinese
    'zh-personal': 'fr'
  };

  //
  // list of grouped equations which are shared across multiple languages
  //
  var familyEquations = {
    zero: function(n) { return 0; },
    en: function(n) { return (n!=1) ? 1 : 0; },
    fr: function(n) { return (n>1) ? 1 : 0; },
    ru: function(n) { return (n%10==1 && n%100!=11 ? 0 : n%10>=2 && n%10<=4 && (n%100<10 || n%100>=20) ? 1 : 2); }
  };

  function getEquation(locale) {
    var equation = pluralEquations[locale];
    if (typeof equation === 'function') {
      return equation;
    }
    return familyEquations[equation] || familyEquations.en;
  }


  function Plurr(options) {
    //
    // Initialize object
    //

    var defaultOptions = options || {};
    addMissingOptions(defaultOptions, {
      locale: 'en',
      autoPlurals: true,
      strict: true
    });

    //
    // Choose the plural function based on locale name
    //
    this.setLocale = function(locale) {
      this.plural = getEquation(locale);
    }; // function locale

    this.format = function(s, params, options) {
      if (typeof params != 'object') {
        throw new TypeError("'params' is not a hash");
      }

      if ((typeof options != 'undefined') && (typeof options != 'object')) {
        throw new TypeError("'options' is not a hash");
      }

      options = options || {};

      var pluralFunc = 'locale' in options ? getEquation(options.locale) : this.plural;

      addMissingOptions(options, defaultOptions);

      var strict = !!options.strict;
      var autoPlurals = !!options.autoPlurals;
      var callback = options.callback;

      var chunks = s.split(/([\{\}])/);
      var blocks = [''];
      var bracketCount = 0;
      for (var i = 0, chLen = chunks.length; i < chLen; i++) {
        var chunk = chunks[i];

        if (chunk == '{') {
          bracketCount++;
          blocks.push('');
          continue;
        }

        if (chunk == '}') {
          bracketCount--;
          if (bracketCount < 0) {
            throw new SyntaxError('Unmatched } found');
          }
          var block = blocks.pop();
          var colonPos = block.indexOf(':');

          if (strict && (colonPos == 0)) {
            throw new TypeError('Empty placeholder name');
          }

          var name;

          if (colonPos == -1) { // simple placeholder
            name = block;
          } else { // multiple choices
            name = block.substr(0, colonPos);
          }

          if (!(name in params)) {
            var pPos = name.indexOf(_PLURAL);
            if (autoPlurals && (pPos != -1) && (pPos == (name.length - _PLURAL.length))) {
              var prefix = name.substr(0, pPos);
              if (!(prefix in params)) {
                if (callback) {
                  params[prefix] = callback(prefix);
                } else if (strict) {
                  throw new TypeError(
                    "Neither '" + name + "' nor '" + prefix + "' are defined"
                  );
                }
              }

              var prefixValue = parseInt(params[prefix]);
              if (prefixValue != params[prefix] || (prefixValue < 0)) {
                if (strict) {
                  throw new RangeError(
                    "Value of '" + prefix + "' is not a zero or positive integer number"
                  );
                }
                prefixValue = 0;
              }

              params[name] = pluralFunc(prefixValue);
            } else {
              if (callback) {
                params[name] = callback(name);
              } else if (strict) {
                throw new TypeError("'" + name + "' not defined");
              }
            }
          }

          var result;

          if (colonPos == -1) { // simple placeholder
            result = params[name];
          } else { // multiple choices
            var blockLen = block.length;

            if (strict && (colonPos == blockLen - 1)) {
              throw new TypeError('Empty list of variants');
            }

            var choiceIdx = parseInt(params[name]);
            if (choiceIdx != params[name] || (choiceIdx < 0)) {
              if (strict) {
                throw new RangeError(
                  "Value of '" + name + "' is not a zero or positive integer number"
                );
              }
              choiceIdx = 0;
            }
            var n = 0;
            var choiceStart = colonPos + 1;
            var choiceEnd = blockLen;
            var j = -1;

            while ((j = block.indexOf('|', j + 1)) != -1) {
              n++;
              if (n <= choiceIdx) {
                choiceStart = j + 1;
              } else if (n == choiceIdx + 1) {
                choiceEnd = j;
              }
            }
            result = block.substr(choiceStart, choiceEnd - choiceStart);
          }

          blocks[blocks.length - 1] += result;
          continue;
        }
        blocks[blocks.length - 1] += chunk;
      }

      if (bracketCount > 0) {
        throw new SyntaxError('Unmatched { found');
      }

      return blocks[0];
    }; // function format

    // initialize with the provided or default locale ('en')
    this.setLocale(defaultOptions.locale || 'en');
  }

  return Plurr;
}));
