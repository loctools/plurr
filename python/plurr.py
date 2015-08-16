#!/usr/bin/env python
# Copyright (C) 2015 Igor Afanasyev, https://github.com/iafan/Plurr

import re

class Plurr:
    VERSION = '1.0'

    plural = None

    #
    # Merge two arrays
    #
    def add_missing_options(self, opt, defaults):
        o = defaults.copy()
        o.update(opt)
        opt.update(o)

    #
    # Initialize object
    #
    def __init__(self, options=None):

        if not options:
            options = {}

        self.add_missing_options(options, {
            'locale': 'en',
            'auto_plurals': True,
            'strict': True
        })

        self._default_options = options

        # initialize with the provided or default locale ('en')
        self.locale(options['locale'] or 'en')

    #
    # list of plural equations taken from
    # http://translate.sourceforge.net/wiki/l10n/pluralforms
    #
    _plural_equations = {
        'ach': lambda n: 0, # Acholi
        'af': lambda n: 1 if (n!=1) else 0, # Afrikaans
        'ak': lambda n: 1 if (n>1) else 0, # Akan
        'am': lambda n: 1 if (n>1) else 0, # Amharic
        'an': lambda n: 1 if (n!=1) else 0, # Aragonese
        'ar': lambda n: 0 if n==0 else 1 if n==1 else 2 if n==2 else 3 if n%100>=3 and n%100<=10 else 4 if n%100>=11 else 5, # Arabic
        'arn': lambda n: 1 if (n>1) else 0, # Mapudungun
        'ast': lambda n: 1 if (n!=1) else 0, # Asturian
        'ay': lambda n: 0, # Aymara
        'az': lambda n: 1 if (n!=1) else 0, # Azerbaijani

        'be': lambda n: 0 if n%10==1 and n%100!=11 else 1 if n%10>=2 and n%10<=4 and (n%100<10 or n%100>=20) else 2, # Belarusian
        'bg': lambda n: 1 if (n!=1) else 0, # Bulgarian
        'bn': lambda n: 1 if (n!=1) else 0, # Bengali
        'bo': lambda n: 0, # Tibetan
        'br': lambda n: 1 if (n>1) else 0, # Breton
        'bs': lambda n: 0 if n%10==1 and n%100!=11 else 1 if n%10>=2 and n%10<=4 and (n%100<10 or n%100>=20) else 2, # Bosnian

        'ca': lambda n: 1 if (n!=1) else 0, # Catalan
        'cgg': lambda n: 0, # Chiga
        'cs': lambda n: 0 if (n==1) else 1 if (n>=2 and n<=4) else 2, # Czech
        'csb': lambda n: 0 if n==1 else 1 if n%10>=2 and n%10<=4 and (n%100<10 or n%100>=20) else 2, # Kashubian
        'cy': lambda n: 0 if (n==1) else 1 if (n==2) else 2 if (n!=8 and n!=11) else 3, # Welsh

        'da': lambda n: 1 if (n!=1) else 0, # Danish
        'de': lambda n: 1 if (n!=1) else 0, # German
        'dz': lambda n: 0, # Dzongkha

        'el': lambda n: 1 if (n!=1) else 0, # Greek
        'en': lambda n: 1 if (n!=1) else 0, # English
        'eo': lambda n: 1 if (n!=1) else 0, # Esperanto
        'es': lambda n: 1 if (n!=1) else 0, # Spanish
        'es-ar': lambda n: 1 if (n!=1) else 0, # Argentinean Spanish
        'et': lambda n: 1 if (n!=1) else 0, # Estonian
        'eu': lambda n: 1 if (n!=1) else 0, # Basque

        'fa': lambda n: 0, # Persian
        'fi': lambda n: 1 if (n!=1) else 0, # Finnish
        'fil': lambda n: 1 if (n>1) else 0, # Filipino
        'fo': lambda n: 1 if (n!=1) else 0, # Faroese
        'fr': lambda n: 1 if (n>1) else 0, # French
        'fur': lambda n: 1 if (n!=1) else 0, # Friulian
        'fy': lambda n: 1 if (n!=1) else 0, # Frisian

        'ga': lambda n: 0 if n==1 else 1 if n==2 else 2 if n<7 else 3 if n<11 else 4, # Irish
        'gl': lambda n: 1 if (n!=1) else 0, # Galician
        'gu': lambda n: 1 if (n!=1) else 0, # Gujarati
        'gun': lambda n: 1 if (n>1) else 0, # Gun

        'ha': lambda n: 1 if (n!=1) else 0, # Hausa
        'he': lambda n: 1 if (n!=1) else 0, # Hebrew
        'hi': lambda n: 1 if (n!=1) else 0, # Hindi
        'hy': lambda n: 0, # Armenian
        'hr': lambda n: 0 if n%10==1 and n%100!=11 else 1 if n%10>=2 and n%10<=4 and (n%100<10 or n%100>=20) else 2, # Croatian
        'hu': lambda n: 1 if (n!=1) else 0, # Hungarian

        'ia': lambda n: 1 if (n!=1) else 0, # Interlingua
        'id': lambda n: 0, # Indonesian
        'is': lambda n: (n%10!=1 or n%100==11), # Icelandic
        'it': lambda n: 1 if (n!=1) else 0, # Italian

        'ja': lambda n: 0, # Japanese
        'jv': lambda n: 1 if (n!=0) else 0, # Javanese

        'ka': lambda n: 0, # Georgian
        'kk': lambda n: 0, # Kazakh
        'km': lambda n: 0, # Khmer
        'kn': lambda n: 1 if (n!=1) else 0, # Kannada
        'ko': lambda n: 0, # Korean
        'ku': lambda n: 1 if (n!=1) else 0, # Kurdish
        'kw': lambda n: 0 if (n==1) else 1 if (n==2) else 2 if (n==3) else 3, # Cornish
        'ky': lambda n: 0, # Kyrgyz

        'lb': lambda n: (n!=1), # Letzeburgesch
        'ln': lambda n: 1 if (n>1) else 0, # Lingala
        'lo': lambda n: 0, # Lao
        'lt': lambda n: 0 if n%10==1 and n%100!=11 else 1 if n%10>=2 and (n%100<10 or n%100>=20) else 2, # Lithuanian
        'lv': lambda n: 0 if n%10==1 and n%100!=11 else 1 if n!=0 else 2, # Latvian

        'mfe': lambda n: 1 if (n>1) else 0, # Mauritian Creole
        'mg': lambda n: 1 if (n>1) else 0, # Malagasy
        'mi': lambda n: 1 if (n>1) else 0, # Maori
        'mk': lambda n: 0 if n==1 or n%10==1 else 1, # Macedonian
        'ml': lambda n: 1 if (n!=1) else 0, # Malayalam
        'mn': lambda n: 1 if (n!=1) else 0, # Mongolian
        'mr': lambda n: 1 if (n!=1) else 0, # Marathi
        'ms': lambda n: 0, # Malay
        'mt': lambda n: 0 if n==1 else 1 if n==0 or (n%100>1 and n%100<11) else 2 if (n%100>10 and n%100<20) else 3, # Maltese

        'nah': lambda n: 1 if (n!=1) else 0, # Nahuatl
        'nap': lambda n: 1 if (n!=1) else 0, # Neapolitan
        'nb': lambda n: 1 if (n!=1) else 0, # Norwegian Bokmal
        'ne': lambda n: 1 if (n!=1) else 0, # Nepali
        'nl': lambda n: 1 if (n!=1) else 0, # Dutch
        'se': lambda n: 1 if (n!=1) else 0, # Northern Sami
        'nn': lambda n: 1 if (n!=1) else 0, # Norwegian Nynorsk
        'no': lambda n: 1 if (n!=1) else 0, # Norwegian (old code)
        'nso': lambda n: 1 if (n!=1) else 0, # Northern Sotho

        'oc': lambda n: 1 if (n>1) else 0, # Occitan
        'or': lambda n: 1 if (n!=1) else 0, # Oriya

        'ps': lambda n: 1 if (n!=1) else 0, # Pashto
        'pa': lambda n: 1 if (n!=1) else 0, # Punjabi
        'pap': lambda n: 1 if (n!=1) else 0, # Papiamento
        'pl': lambda n: 0 if n==1 else 1 if n%10>=2 and n%10<=4 and (n%100<10 or n%100>=20) else 2, # Polish
        'pms': lambda n: 1 if (n!=1) else 0, # Piemontese
        'pt': lambda n: 1 if (n!=1) else 0, # Portuguese
        'pt-br': lambda n: 1 if (n>1) else 0, # Brazilian Portuguese

        'rm': lambda n: (n!=1), # Romansh
        'ro': lambda n: 0 if n==1 else 1 if (n==0 or (n%100>0 and n%100<20)) else 2, # Romanian
        'ru': lambda n: 0 if n%10==1 and n%100!=11 else 1 if n%10>=2 and n%10<=4 and (n%100<10 or n%100>=20) else 2, # Russian

        'sco': lambda n: 1 if (n!=1) else 0, # Scots
        'si': lambda n: 1 if (n!=1) else 0, # Sinhala
        'sk': lambda n: 0 if (n==1) else 1 if (n>=2 and n<=4) else 2, # Slovak
        'sl': lambda n: 1 if n%100==1 else 2 if n%100==2 else 3 if n%100==3 or n%100==4 else 0, # Slovenian
        'so': lambda n: 1 if (n!=1) else 0, # Somali
        'son': lambda n: 0, # Songhay
        'sq': lambda n: 1 if (n!=1) else 0, # Albanian
        'sr': lambda n: 0 if n%10==1 and n%100!=11 else 1 if n%10>=2 and n%10<=4 and (n%100<10 or n%100>=20) else 2, # Serbian
        'su': lambda n: 0, # Sundanese
        'sw': lambda n: 1 if (n!=1) else 0, # Swahili
        'sv': lambda n: 1 if (n!=1) else 0, # Swedish

        'ta': lambda n: 1 if (n!=1) else 0, # Tamil
        'te': lambda n: 1 if (n!=1) else 0, # Telugu
        'tg': lambda n: 1 if (n!=1) else 0, # Tajik
        'ti': lambda n: 1 if (n>1) else 0, # Tigrinya
        'th': lambda n: 0, # Thai
        'tk': lambda n: 1 if (n!=1) else 0, # Turkmen
        'tr': lambda n: 0, # Turkish
        'tt': lambda n: 0, # Tatar

        'ug': lambda n: 0, # Uyghur
        'uk': lambda n: 0 if n%10==1 and n%100!=11 else 1 if n%10>=2 and n%10<=4 and (n%100<10 or n%100>=20) else 2, # Ukrainian
        'ur': lambda n: 1 if (n!=1) else 0, # Urdu
        'uz': lambda n: 0, # Uzbek

        'vi': lambda n: 0, # Vietnamese

        'wa': lambda n: 1 if (n>1) else 0, # Walloon

        'zh': lambda n: 0, # Chinese
        'zh-personal': lambda n: 1 if (n>1) else 0, # Chinese, used in special cases when dealing with personal pronoun
    }

    #
    # Choose the plural function based on locale name
    #
    def locale (self, locale):
        self._plural = self._plural_equations[locale]
        # TODO: raise error on missing locale

    _PLURAL = '_PLURAL'

    def format (self, s, params, options=None):
        if not isinstance(params, dict):
            raise TypeError("'params' is not a dict")

        if options and not isinstance(options, dict):
            raise TypeError("'options' is not a dict")

        if not options:
            options = {}

        plural_func = self._plural
        if 'locale' in options:
            plural_func = self._plural_equations[options['locale']] or self._plural_equations['en']

        self.add_missing_options(options, self._default_options)

        strict = options['strict']
        auto_plurals = options['auto_plurals']
        callback = options['callback'] if 'callback' in options else None

        chunks = re.compile("([{}])").split(s)
        blocks = ['']
        bracket_count = 0
        for i in xrange(len(chunks)):
            chunk = chunks[i]

            if chunk == '{':
                bracket_count += 1
                blocks.append('')
                continue

            if chunk == '}':
                bracket_count -= 1
                if bracket_count < 0:
                    raise SyntaxError("Unmatched } found")

                block = blocks.pop()
                colon_pos = block.find(':')

                name = ''

                if strict and (colon_pos == 0):
                    raise SyntaxError("Empty placeholder name")
                if (colon_pos == -1): # simple placeholder
                    name = block
                else: # multiple choices
                    name = block[0:colon_pos]

                if not name in params:
                    p_pos = name.find(self._PLURAL)
                    if auto_plurals and (p_pos != -1) and (p_pos == (len(name) - len(self._PLURAL))):
                        prefix = name[0:p_pos]
                        if strict and not prefix in params:
                            raise LookupError("Neither '{0}' nor '{1}' are defined".format(name, prefix))

                        prefix_value = 0
                        try:
                            prefix_value = int(params[prefix])
                            if str(params[prefix]) != str(prefix_value) or prefix_value < 0:
                                raise ValueError()
                        except ValueError:
                            if strict:
                                raise ValueError("Value of '{0}' is not a zero or positive integer number".format(prefix))

                        params[name] = plural_func(prefix_value)
                    else:
                        if callback:
                            params[name] = callback(name)
                        elif strict:
                            raise LookupError("'{0}' not defined".format(name))

                result = ''

                if colon_pos == -1: # simple placeholder
                    result = params[name]
                else: # multiple choices
                    block_len = len(block)

                    if strict and (colon_pos == block_len - 1):
                        raise SyntaxError('Empty list of variants')

                    choice_idx = 0
                    try:
                        choice_idx = int(params[name])
                        if str(choice_idx) != str(params[name]) or choice_idx < 0:
                            raise ValueError()
                    except ValueError:
                        if strict:
                            raise ValueError("Value of '{0}' is not a zero or positive integer number".format(name))

                    n = 0
                    choice_start = colon_pos + 1
                    choice_end = block_len
                    j = -1

                    while True:
                        j = block.find('|', j + 1)
                        if j == -1:
                            break
                        n += 1
                        if n <= choice_idx:
                            choice_start = j + 1
                        elif n == choice_idx + 1:
                            choice_end = j
                    result = block[choice_start:choice_end]

                blocks[len(blocks)-1] += str(result)
                continue
            blocks[len(blocks)-1] += chunk

        if bracket_count > 0:
            raise SyntaxError("Unmatched { found")

        return blocks[0]
