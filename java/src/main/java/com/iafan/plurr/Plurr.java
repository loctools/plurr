// Copyright (C) 2015 Igor Afanasyev, https://github.com/iafan/Plurr

package com.iafan.plurr;

import java.lang.reflect.InvocationTargetException;
import java.lang.reflect.Method;
import java.util.ArrayList;
import java.util.Map;
import java.util.HashMap;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

public class Plurr {
  private String locale = "en";
  private boolean autoPlurals = true;
  private boolean strict = true;

  private Method pluralMethod;
  private PlurrCallback callback;

  private static final String _PLURAL = "_PLURAL";

  //
  // list of plural equations taken from
  // http://translate.sourceforge.net/wiki/l10n/pluralforms
  //
  private int plural_ach (int n) { return 0; } // Acholi
  private int plural_af (int n) { return (n!=1) ? 1 : 0; } // Afrikaans
  private int plural_ak (int n) { return (n>1) ? 1 : 0; } // Akan
  private int plural_am (int n) { return (n>1) ? 1 : 0; } // Amharic
  private int plural_an (int n) { return (n!=1) ? 1 : 0; } // Aragonese
  private int plural_ar (int n) { return n==0 ? 0 : n==1 ? 1 : n==2 ? 2 : n%100>=3 && n%100<=10 ? 3 : n%100>=11 ? 4 : 5; } // Arabic
  private int plural_arn (int n) { return (n>1) ? 1 : 0; } // Mapudungun
  private int plural_ast (int n) { return (n!=1) ? 1 : 0; } // Asturian
  private int plural_ay (int n) { return 0; } // Aymara
  private int plural_az (int n) { return (n!=1) ? 1 : 0; } // Azerbaijani

  private int plural_be (int n) { return (n%10==1 && n%100!=11 ? 0 : n%10>=2 && n%10<=4 && (n%100<10 || n%100>=20) ? 1 : 2); } // Belarusian
  private int plural_bg (int n) { return (n!=1) ? 1 : 0; } // Bulgarian
  private int plural_bn (int n) { return (n!=1) ? 1 : 0; } // Bengali
  private int plural_bo (int n) { return 0; } // Tibetan
  private int plural_br (int n) { return (n>1) ? 1 : 0; } // Breton
  private int plural_bs (int n) { return (n%10==1 && n%100!=11 ? 0 : n%10>=2 && n%10<=4 && (n%100<10 || n%100>=20) ? 1 : 2); } // Bosnian

  private int plural_ca (int n) { return (n!=1) ? 1 : 0; } // Catalan
  private int plural_cgg (int n) { return 0; } // Chiga
  private int plural_cs (int n) { return (n==1) ? 0 : (n>=2 && n<=4) ? 1 : 2; } // Czech
  private int plural_csb (int n) { return n==1 ? 0 : n%10>=2 && n%10<=4 && (n%100<10 || n%100>=20) ? 1 : 2; } // Kashubian
  private int plural_cy (int n) { return (n==1) ? 0 : (n==2) ? 1 : (n!=8 && n!=11) ? 2 : 3; } // Welsh

  private int plural_da (int n) { return (n!=1) ? 1 : 0; } // Danish
  private int plural_de (int n) { return (n!=1) ? 1 : 0; } // German
  private int plural_dz (int n) { return 0; } // Dzongkha

  private int plural_el (int n) { return (n!=1) ? 1 : 0; } // Greek
  private int plural_en (int n) { return (n!=1) ? 1 : 0; } // English
  private int plural_eo (int n) { return (n!=1) ? 1 : 0; } // Esperanto
  private int plural_es (int n) { return (n!=1) ? 1 : 0; } // Spanish
  private int plural_es_ar (int n) { return (n!=1) ? 1 : 0; } // Argentinean Spanish
  private int plural_et (int n) { return (n!=1) ? 1 : 0; } // Estonian
  private int plural_eu (int n) { return (n!=1) ? 1 : 0; } // Basque

  private int plural_fa (int n) { return 0; } // Persian
  private int plural_fi (int n) { return (n!=1) ? 1 : 0; } // Finnish
  private int plural_fil (int n) { return (n>1) ? 1 : 0; } // Filipino
  private int plural_fo (int n) { return (n!=1) ? 1 : 0; } // Faroese
  private int plural_fr (int n) { return (n>1) ? 1 : 0; } // French
  private int plural_fur (int n) { return (n!=1) ? 1 : 0; } // Friulian
  private int plural_fy (int n) { return (n!=1) ? 1 : 0; } // Frisian

  private int plural_ga (int n) { return n==1 ? 0 : n==2 ? 1 : n<7 ? 2 : n<11 ? 3 : 4; } // Irish
  private int plural_gl (int n) { return (n!=1) ? 1 : 0; } // Galician
  private int plural_gu (int n) { return (n!=1) ? 1 : 0; } // Gujarati
  private int plural_gun (int n) { return (n>1) ? 1 : 0; } // Gun

  private int plural_ha (int n) { return (n!=1) ? 1 : 0; } // Hausa
  private int plural_he (int n) { return (n!=1) ? 1 : 0; } // Hebrew
  private int plural_hi (int n) { return (n!=1) ? 1 : 0; } // Hindi
  private int plural_hy (int n) { return 0; } // Armenian
  private int plural_hr (int n) { return (n%10==1 && n%100!=11 ? 0 : n%10>=2 && n%10<=4 && (n%100<10 || n%100>=20) ? 1 : 2); } // Croatian
  private int plural_hu (int n) { return (n!=1) ? 1 : 0; } // Hungarian

  private int plural_ia (int n) { return (n!=1) ? 1 : 0; } // Interlingua
  private int plural_id (int n) { return 0; } // Indonesian
  private int plural_is (int n) { return (n%10!=1 || n%100==11) ? 1 : 0; } // Icelandic
  private int plural_it (int n) { return (n!=1) ? 1 : 0; } // Italian

  private int plural_ja (int n) { return 0; } // Japanese
  private int plural_jv (int n) { return (n!=0) ? 1 : 0; } // Javanese

  private int plural_ka (int n) { return 0; } // Georgian
  private int plural_kk (int n) { return 0; } // Kazakh
  private int plural_km (int n) { return 0; } // Khmer
  private int plural_kn (int n) { return (n!=1) ? 1 : 0; } // Kannada
  private int plural_ko (int n) { return 0; } // Korean
  private int plural_ku (int n) { return (n!=1) ? 1 : 0; } // Kurdish
  private int plural_kw (int n) { return (n==1) ? 0 : (n==2) ? 1 : (n==3) ? 2 : 3; } // Cornish
  private int plural_ky (int n) { return 0; } // Kyrgyz

  private int plural_lb (int n) { return (n!=1) ? 1 : 0; } // Letzeburgesch
  private int plural_ln (int n) { return (n>1) ? 1 : 0; } // Lingala
  private int plural_lo (int n) { return 0; } // Lao
  private int plural_lt (int n) { return (n%10==1 && n%100!=11 ? 0 : n%10>=2 && (n%100<10 || n%100>=20) ? 1 : 2); } // Lithuanian
  private int plural_lv (int n) { return (n%10==1 && n%100!=11 ? 0 : n!=0 ? 1 : 2); } // Latvian

  private int plural_mfe (int n) { return (n>1) ? 1 : 0; } // Mauritian Creole
  private int plural_mg (int n) { return (n>1) ? 1 : 0; } // Malagasy
  private int plural_mi (int n) { return (n>1) ? 1 : 0; } // Maori
  private int plural_mk (int n) { return n==1 || n%10==1 ? 0 : 1; } // Macedonian
  private int plural_ml (int n) { return (n!=1) ? 1 : 0; } // Malayalam
  private int plural_mn (int n) { return (n!=1) ? 1 : 0; } // Mongolian
  private int plural_mr (int n) { return (n!=1) ? 1 : 0; } // Marathi
  private int plural_ms (int n) { return 0; } // Malay
  private int plural_mt (int n) { return (n==1 ? 0 : n==0 || ( n%100>1 && n%100<11) ? 1 : (n%100>10 && n%100<20 ) ? 2 : 3); } // Maltese

  private int plural_nah (int n) { return (n!=1) ? 1 : 0; } // Nahuatl
  private int plural_nap (int n) { return (n!=1) ? 1 : 0; } // Neapolitan
  private int plural_nb (int n) { return (n!=1) ? 1 : 0; } // Norwegian Bokmal
  private int plural_ne (int n) { return (n!=1) ? 1 : 0; } // Nepali
  private int plural_nl (int n) { return (n!=1) ? 1 : 0; } // Dutch
  private int plural_se (int n) { return (n!=1) ? 1 : 0; } // Northern Sami
  private int plural_nn (int n) { return (n!=1) ? 1 : 0; } // Norwegian Nynorsk
  private int plural_no (int n) { return (n!=1) ? 1 : 0; } // Norwegian (old code)
  private int plural_nso (int n) { return (n!=1) ? 1 : 0; } // Northern Sotho

  private int plural_oc (int n) { return (n>1) ? 1 : 0; } // Occitan
  private int plural_or (int n) { return (n!=1) ? 1 : 0; } // Oriya

  private int plural_ps (int n) { return (n!=1) ? 1 : 0; } // Pashto
  private int plural_pa (int n) { return (n!=1) ? 1 : 0; } // Punjabi
  private int plural_pap (int n) { return (n!=1) ? 1 : 0; } // Papiamento
  private int plural_pl (int n) { return (n==1 ? 0 : n%10>=2 && n%10<=4 && (n%100<10 || n%100>=20) ? 1 : 2); } // Polish
  private int plural_pm (int n)  { return (n!=1) ? 1 : 0; } // Piemontese
  private int plural_pt (int n) { return (n!=1) ? 1 : 0; } // Portuguese
  private int plural_pt_br (int n) { return (n>1) ? 1 : 0; } // Brazilian Portuguese

  private int plural_rm (int n) { return (n!=1) ? 1 : 0; } // Romansh
  private int plural_ro (int n) { return (n==1 ? 0 : (n==0 || (n%100>0 && n%100<20)) ? 1 : 2); } // Romanian
  private int plural_ru (int n) { return (n%10==1 && n%100!=11 ? 0 : n%10>=2 && n%10<=4 && (n%100<10 || n%100>=20) ? 1 : 2); } // Russian

  private int plural_sco (int n) { return (n!=1) ? 1 : 0; } // Scots
  private int plural_si (int n) { return (n!=1) ? 1 : 0; } // Sinhala
  private int plural_sk (int n) { return (n==1) ? 0 : (n>=2 && n<=4) ? 1 : 2; } // Slovak
  private int plural_sl (int n) { return (n%100==1 ? 1 : n%100==2 ? 2 : n%100==3 || n%100==4 ? 3 : 0); } // Slovenian
  private int plural_so (int n) { return (n!=1) ? 1 : 0; } // Somali
  private int plural_son (int n) { return 0; } // Songhay
  private int plural_sq (int n) { return (n!=1) ? 1 : 0; } // Albanian
  private int plural_sr (int n) { return (n%10==1 && n%100!=11 ? 0 : n%10>=2 && n%10<=4 && (n%100<10 || n%100>=20) ? 1 : 2); } // Serbian
  private int plural_su (int n) { return 0; } // Sundanese
  private int plural_sw (int n) { return (n!=1) ? 1 : 0; } // Swahili
  private int plural_sv (int n) { return (n!=1) ? 1 : 0; } // Swedish

  private int plural_ta (int n) { return (n!=1) ? 1 : 0; } // Tamil
  private int plural_te (int n) { return (n!=1) ? 1 : 0; } // Telugu
  private int plural_tg (int n) { return (n!=1) ? 1 : 0; } // Tajik
  private int plural_ti (int n) { return (n>1) ? 1 : 0; } // Tigrinya
  private int plural_th (int n) { return 0; } // Thai
  private int plural_tk (int n) { return (n!=1) ? 1 : 0; } // Turkmen
  private int plural_tr (int n) { return 0; } // Turkish
  private int plural_tt (int n) { return 0; } // Tatar

  private int plural_ug (int n) { return 0; } // Uyghur
  private int plural_uk (int n) { return (n%10==1 && n%100!=11 ? 0 : n%10>=2 && n%10<=4 && (n%100<10 || n%100>=20) ? 1 : 2); } // Ukrainian
  private int plural_ur (int n) { return (n!=1) ? 1 : 0; } // Urdu
  private int plural_uz (int n) { return 0; } // Uzbek

  private int plural_vi (int n) { return 0; } // Vietnamese

  private int plural_wa (int n) { return (n>1) ? 1 : 0; } // Walloon

  private int plural_zh (int n) { return 0; } // Chinese
  private int plural_zh_personal (int n) { return (n>1) ? 1 : 0; } // Chinese, used in special cases when dealing with personal pronoun

  public Plurr() throws PlurrLocaleNotFoundException {
    this.updatePluralMethod();
  }

  public Plurr(String value) throws PlurrLocaleNotFoundException {
    this.setLocale(value);
  }

  public String getLocale() {
    return this.locale;
  }

  public void setLocale(String value) throws PlurrLocaleNotFoundException {
    this.locale = value;
    this.updatePluralMethod();
  }

  public boolean getAutoPlurals() {
    return autoPlurals;
  }

  public void setAutoPlurals(boolean value) {
    this.autoPlurals = value;
  }

  public boolean getStrict() {
    return this.strict;
  }

  public void setStrict(boolean value) {
    this.strict = value;
  }

  public PlurrCallback getCallback() {
    return this.callback;
  }

  public void setCallback(PlurrCallback value) {
    this.callback = value;
  }

  private void updatePluralMethod() throws PlurrLocaleNotFoundException {
    try {
      String s = this.locale.replace("-", "_");
      this.pluralMethod = this.getClass().getDeclaredMethod("plural_"+s, int.class);
    } catch (NoSuchMethodException e) {
      throw new PlurrLocaleNotFoundException("Unknown locale: '"+this.locale+"'");
    }
  }

  public int plural (int n) throws PlurrInternalException {
    try {
      return (int)this.pluralMethod.invoke(this, n);
    } catch (IllegalAccessException e) {
      throw new PlurrInternalException("IllegalAccessException: " + e.getMessage());
    } catch (InvocationTargetException e) {
      throw new PlurrInternalException("InvocationTargetException: " + e.getMessage());
    }
  }

  public String format(String s, String... arg) throws PlurrInternalException, PlurrSyntaxException {

    Map<String, String> params = new HashMap<String, String>();

    for (int i = 0; i < arg.length/2; i++) {
      params.put(arg[i*2], arg[i*2+1]);
    }

    ArrayList<String> blocks = new ArrayList<String>();
    blocks.add("");

    int bracket_count = 0;

    Pattern p = Pattern.compile("([{}]|[^{}]*)");
    Matcher m = p.matcher(s);
    while(m.find()) {
      String chunk = m.group(1);

      if (chunk.equals("{")) {
        bracket_count++;
        blocks.add("");
        continue;
      }

      if (chunk.equals("}")) {
        bracket_count--;
        if (bracket_count < 0) {
          throw new PlurrSyntaxException("Unmatched } found");
        }
        String block = blocks.remove(blocks.size()-1); // pop
        int colon_pos = block.indexOf(':');

        if (strict && (colon_pos == 0)) {
          throw new PlurrSyntaxException("Empty placeholder name");
        }

        String name;

        if (colon_pos == -1) { // simple placeholder
          name = block;
        } else { // multiple choices
          name = block.substring(0, colon_pos);
        }

        if (!params.containsKey(name)) {
          int p_pos = name.indexOf(_PLURAL);
          if (this.autoPlurals && (p_pos != -1) && (p_pos == (name.length() - _PLURAL.length()))) {
            String prefix = name.substring(0, p_pos);
            if (strict && !params.containsKey(prefix)) {
              throw new PlurrSyntaxException("Neither '"+name+"' nor '"+prefix+"' are defined");
            }

            int prefix_value = 0;
            try {
              prefix_value = Integer.parseInt(params.get(prefix));
              if (prefix_value < 0) {
                throw new NumberFormatException("");
              }
            } catch (NumberFormatException e) {
              if (strict) {
                throw new PlurrSyntaxException("Value of '"+prefix+"' is not a zero or positive integer number");
              }
            }

            params.put(name, Integer.toString(this.plural(prefix_value)));
          } else {
            if (this.callback != null) {
              params.put(name, this.callback.getValue(name));
            } else if (strict) {
              throw new PlurrSyntaxException("'"+name+"' not defined");
            }
          }
        }

        String result;

        if (colon_pos == -1) { // simple placeholder
          result = params.get(name);
        } else { // multiple choices
          int block_len = block.length();

          if (strict && (colon_pos == block_len - 1)) {
            throw new PlurrSyntaxException("Empty list of variants");
          }

          int choice_idx = 0;
          try {
            choice_idx = Integer.parseInt(params.get(name));
            if (choice_idx < 0) {
              throw new NumberFormatException("");
            }
          } catch (NumberFormatException e) {
            if (strict) {
              throw new PlurrSyntaxException("Value of '"+name+"' is not a zero or positive integer number");
            }
          }

          int n = 0;
          int choice_start = colon_pos + 1;
          int choice_end = block_len;
          int j = -1;

          while ((j = block.indexOf("|", j + 1)) != -1) {
            n++;
            if (n <= choice_idx) {
              choice_start = j + 1;
            } else if (n == choice_idx + 1) {
              choice_end = j;
            }
          }
          result = block.substring(choice_start, choice_end);
        }

        blocks.set(blocks.size() - 1, blocks.get(blocks.size() - 1) + result);
        continue;
      }
      blocks.set(blocks.size() - 1, blocks.get(blocks.size() - 1) + chunk);
    }

    if (bracket_count > 0) {
      throw new PlurrSyntaxException("Unmatched { found");
    }

    return blocks.get(0);
  }
}