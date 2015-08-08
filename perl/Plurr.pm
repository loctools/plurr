# Copyright (C) 2012 Igor Afanasyev, https://github.com/iafan/Plurr

package Plurr;

my $VERSION = '1.0';

use strict;

#
# Merge two arrays
#
sub add_missing_options {
  my ($opt, $defaults) = @_;
  map { $opt->{$_} = $defaults->{$_} unless exists $opt->{$_} } keys %$defaults;
} # sub add_missing_options

#
# Initialize object
#
sub new {
  my ($class, $options) = @_;

  $options = {} unless $options;
  add_missing_options($options, {
    locale => 'en',
    auto_plurals => 1,
    strict => 1
  });

  my $self = {
    _default_options => $options,
    _plural => undef
  };

  bless $self, $class;

  # initialize with the provided or default locale ('en')
  $self->locale($options->{locale} || 'en');

  return $self;
}

#
# list of plural equations taken from
# http://translate.sourceforge.net/wiki/l10n/pluralforms
#
my $_plural_equations = {
  'ach' => sub { my $n = shift; return 0; }, # Acholi
  'af' => sub { my $n = shift; return ($n!=1) ? 1 : 0; }, # Afrikaans
  'ak' => sub { my $n = shift; return ($n>1) ? 1 : 0; }, # Akan
  'am' => sub { my $n = shift; return ($n>1) ? 1 : 0; }, # Amharic
  'an' => sub { my $n = shift; return ($n!=1) ? 1 : 0; }, # Aragonese
  'ar' => sub { my $n = shift; return $n==0 ? 0 : $n==1 ? 1 : $n==2 ? 2 : $n%100>=3 && $n%100<=10 ? 3 : $n%100>=11 ? 4 : 5; }, # Arabic
  'arn' => sub { my $n = shift; return ($n>1) ? 1 : 0; }, # Mapudungun
  'ast' => sub { my $n = shift; return ($n!=1) ? 1 : 0; }, # Asturian
  'ay' => sub { my $n = shift; return 0; }, # Aymara
  'az' => sub { my $n = shift; return ($n!=1) ? 1 : 0; }, # Azerbaijani

  'be' => sub { my $n = shift; return ($n%10==1 && $n%100!=11 ? 0 : $n%10>=2 && $n%10<=4 && ($n%100<10 || $n%100>=20) ? 1 : 2); }, # Belarusian
  'bg' => sub { my $n = shift; return ($n!=1) ? 1 : 0; }, # Bulgarian
  'bn' => sub { my $n = shift; return ($n!=1) ? 1 : 0; }, # Bengali
  'bo' => sub { my $n = shift; return 0; }, # Tibetan
  'br' => sub { my $n = shift; return ($n>1) ? 1 : 0; }, # Breton
  'bs' => sub { my $n = shift; return ($n%10==1 && $n%100!=11 ? 0 : $n%10>=2 && $n%10<=4 && ($n%100<10 || $n%100>=20) ? 1 : 2); }, # Bosnian

  'ca' => sub { my $n = shift; return ($n!=1) ? 1 : 0; }, # Catalan
  'cgg' => sub { my $n = shift; return 0; }, # Chiga
  'cs' => sub { my $n = shift; return ($n==1) ? 0 : ($n>=2 && $n<=4) ? 1 : 2; }, # Czech
  'csb' => sub { my $n = shift; return $n==1 ? 0 : $n%10>=2 && $n%10<=4 && ($n%100<10 || $n%100>=20) ? 1 : 2; }, # Kashubian
  'cy' => sub { my $n = shift; return ($n==1) ? 0 : ($n==2) ? 1 : ($n!=8 && $n!=11) ? 2 : 3; }, # Welsh

  'da' => sub { my $n = shift; return ($n!=1) ? 1 : 0; }, # Danish
  'de' => sub { my $n = shift; return ($n!=1) ? 1 : 0; }, # German
  'dz' => sub { my $n = shift; return 0; }, # Dzongkha

  'el' => sub { my $n = shift; return ($n!=1) ? 1 : 0; }, # Greek
  'en' => sub { my $n = shift; return ($n!=1) ? 1 : 0; }, # English
  'eo' => sub { my $n = shift; return ($n!=1) ? 1 : 0; }, # Esperanto
  'es' => sub { my $n = shift; return ($n!=1) ? 1 : 0; }, # Spanish
  'es-ar' => sub { my $n = shift; return ($n!=1) ? 1 : 0; }, # Argentinean Spanish
  'et' => sub { my $n = shift; return ($n!=1) ? 1 : 0; }, # Estonian
  'eu' => sub { my $n = shift; return ($n!=1) ? 1 : 0; }, # Basque

  'fa' => sub { my $n = shift; return 0; }, # Persian
  'fi' => sub { my $n = shift; return ($n!=1) ? 1 : 0; }, # Finnish
  'fil' => sub { my $n = shift; return ($n>1) ? 1 : 0; }, # Filipino
  'fo' => sub { my $n = shift; return ($n!=1) ? 1 : 0; }, # Faroese
  'fr' => sub { my $n = shift; return ($n>1) ? 1 : 0; }, # French
  'fur' => sub { my $n = shift; return ($n!=1) ? 1 : 0; }, # Friulian
  'fy' => sub { my $n = shift; return ($n!=1) ? 1 : 0; }, # Frisian

  'ga' => sub { my $n = shift; return $n==1 ? 0 : $n==2 ? 1 : $n<7 ? 2 : $n<11 ? 3 : 4; }, # Irish
  'gl' => sub { my $n = shift; return ($n!=1) ? 1 : 0; }, # Galician
  'gu' => sub { my $n = shift; return ($n!=1) ? 1 : 0; }, # Gujarati
  'gun' => sub { my $n = shift; return ($n>1) ? 1 : 0; }, # Gun

  'ha' => sub { my $n = shift; return ($n!=1) ? 1 : 0; }, # Hausa
  'he' => sub { my $n = shift; return ($n!=1) ? 1 : 0; }, # Hebrew
  'hi' => sub { my $n = shift; return ($n!=1) ? 1 : 0; }, # Hindi
  'hy' => sub { my $n = shift; return 0; }, # Armenian
  'hr' => sub { my $n = shift; return ($n%10==1 && $n%100!=11 ? 0 : $n%10>=2 && $n%10<=4 && ($n%100<10 || $n%100>=20) ? 1 : 2); }, # Croatian
  'hu' => sub { my $n = shift; return ($n!=1) ? 1 : 0; }, # Hungarian

  'ia' => sub { my $n = shift; return ($n!=1) ? 1 : 0; }, # Interlingua
  'id' => sub { my $n = shift; return 0; }, # Indonesian
  'is' => sub { my $n = shift; return ($n%10!=1 || $n%100==11); }, # Icelandic
  'it' => sub { my $n = shift; return ($n!=1) ? 1 : 0; }, # Italian

  'ja' => sub { my $n = shift; return 0; }, # Japanese
  'jv' => sub { my $n = shift; return ($n!=0) ? 1 : 0; }, # Javanese

  'ka' => sub { my $n = shift; return 0; }, # Georgian
  'kk' => sub { my $n = shift; return 0; }, # Kazakh
  'km' => sub { my $n = shift; return 0; }, # Khmer
  'kn' => sub { my $n = shift; return ($n!=1) ? 1 : 0; }, # Kannada
  'ko' => sub { my $n = shift; return 0; }, # Korean
  'ku' => sub { my $n = shift; return ($n!=1) ? 1 : 0; }, # Kurdish
  'kw' => sub { my $n = shift; return ($n==1) ? 0 : ($n==2) ? 1 : ($n==3) ? 2 : 3; }, # Cornish
  'ky' => sub { my $n = shift; return 0; }, # Kyrgyz

  'lb' => sub { my $n = shift; return ($n!=1); }, # Letzeburgesch
  'ln' => sub { my $n = shift; return ($n>1) ? 1 : 0; }, # Lingala
  'lo' => sub { my $n = shift; return 0; }, # Lao
  'lt' => sub { my $n = shift; return ($n%10==1 && $n%100!=11 ? 0 : $n%10>=2 && ($n%100<10 || $n%100>=20) ? 1 : 2); }, # Lithuanian
  'lv' => sub { my $n = shift; return ($n%10==1 && $n%100!=11 ? 0 : $n!=0 ? 1 : 2); }, # Latvian

  'mfe' => sub { my $n = shift; return ($n>1) ? 1 : 0; }, # Mauritian Creole
  'mg' => sub { my $n = shift; return ($n>1) ? 1 : 0; }, # Malagasy
  'mi' => sub { my $n = shift; return ($n>1) ? 1 : 0; }, # Maori
  'mk' => sub { my $n = shift; return $n==1 || $n%10==1 ? 0 : 1; }, # Macedonian
  'ml' => sub { my $n = shift; return ($n!=1) ? 1 : 0; }, # Malayalam
  'mn' => sub { my $n = shift; return ($n!=1) ? 1 : 0; }, # Mongolian
  'mr' => sub { my $n = shift; return ($n!=1) ? 1 : 0; }, # Marathi
  'ms' => sub { my $n = shift; return 0; }, # Malay
  'mt' => sub { my $n = shift; return ($n==1 ? 0 : $n==0 || ( $n%100>1 && $n%100<11) ? 1 : ($n%100>10 && $n%100<20 ) ? 2 : 3); }, # Maltese

  'nah' => sub { my $n = shift; return ($n!=1) ? 1 : 0; }, # Nahuatl
  'nap' => sub { my $n = shift; return ($n!=1) ? 1 : 0; }, # Neapolitan
  'nb' => sub { my $n = shift; return ($n!=1) ? 1 : 0; }, # Norwegian Bokmal
  'ne' => sub { my $n = shift; return ($n!=1) ? 1 : 0; }, # Nepali
  'nl' => sub { my $n = shift; return ($n!=1) ? 1 : 0; }, # Dutch
  'se' => sub { my $n = shift; return ($n!=1) ? 1 : 0; }, # Northern Sami
  'nn' => sub { my $n = shift; return ($n!=1) ? 1 : 0; }, # Norwegian Nynorsk
  'no' => sub { my $n = shift; return ($n!=1) ? 1 : 0; }, # Norwegian (old code)
  'nso' => sub { my $n = shift; return ($n!=1) ? 1 : 0; }, # Northern Sotho

  'oc' => sub { my $n = shift; return ($n>1) ? 1 : 0; }, # Occitan
  'or' => sub { my $n = shift; return ($n!=1) ? 1 : 0; }, # Oriya

  'ps' => sub { my $n = shift; return ($n!=1) ? 1 : 0; }, # Pashto
  'pa' => sub { my $n = shift; return ($n!=1) ? 1 : 0; }, # Punjabi
  'pap' => sub { my $n = shift; return ($n!=1) ? 1 : 0; }, # Papiamento
  'pl' => sub { my $n = shift; return ($n==1 ? 0 : $n%10>=2 && $n%10<=4 && ($n%100<10 || $n%100>=20) ? 1 : 2); }, # Polish
  'pms' => sub { my $n = shift; return ($n!=1) ? 1 : 0; }, # Piemontese
  'pt' => sub { my $n = shift; return ($n!=1) ? 1 : 0; }, # Portuguese
  'pt-br' => sub { my $n = shift; return ($n>1) ? 1 : 0; }, # Brazilian Portuguese

  'rm' => sub { my $n = shift; return ($n!=1); }, # Romansh
  'ro' => sub { my $n = shift; return ($n==1 ? 0 : ($n==0 || ($n%100>0 && $n%100<20)) ? 1 : 2); }, # Romanian
  'ru' => sub { my $n = shift; return ($n%10==1 && $n%100!=11 ? 0 : $n%10>=2 && $n%10<=4 && ($n%100<10 || $n%100>=20) ? 1 : 2); }, # Russian

  'sco' => sub { my $n = shift; return ($n!=1) ? 1 : 0; }, # Scots
  'si' => sub { my $n = shift; return ($n!=1) ? 1 : 0; }, # Sinhala
  'sk' => sub { my $n = shift; return ($n==1) ? 0 : ($n>=2 && $n<=4) ? 1 : 2; }, # Slovak
  'sl' => sub { my $n = shift; return ($n%100==1 ? 1 : $n%100==2 ? 2 : $n%100==3 || $n%100==4 ? 3 : 0); }, # Slovenian
  'so' => sub { my $n = shift; return ($n!=1) ? 1 : 0; }, # Somali
  'son' => sub { my $n = shift; return 0; }, # Songhay
  'sq' => sub { my $n = shift; return ($n!=1) ? 1 : 0; }, # Albanian
  'sr' => sub { my $n = shift; return ($n%10==1 && $n%100!=11 ? 0 : $n%10>=2 && $n%10<=4 && ($n%100<10 || $n%100>=20) ? 1 : 2); }, # Serbian
  'su' => sub { my $n = shift; return 0; }, # Sundanese
  'sw' => sub { my $n = shift; return ($n!=1) ? 1 : 0; }, # Swahili
  'sv' => sub { my $n = shift; return ($n!=1) ? 1 : 0; }, # Swedish

  'ta' => sub { my $n = shift; return ($n!=1) ? 1 : 0; }, # Tamil
  'te' => sub { my $n = shift; return ($n!=1) ? 1 : 0; }, # Telugu
  'tg' => sub { my $n = shift; return ($n!=1) ? 1 : 0; }, # Tajik
  'ti' => sub { my $n = shift; return ($n>1) ? 1 : 0; }, # Tigrinya
  'th' => sub { my $n = shift; return 0; }, # Thai
  'tk' => sub { my $n = shift; return ($n!=1) ? 1 : 0; }, # Turkmen
  'tr' => sub { my $n = shift; return 0; }, # Turkish
  'tt' => sub { my $n = shift; return 0; }, # Tatar

  'ug' => sub { my $n = shift; return 0; }, # Uyghur
  'uk' => sub { my $n = shift; return ($n%10==1 && $n%100!=11 ? 0 : $n%10>=2 && $n%10<=4 && ($n%100<10 || $n%100>=20) ? 1 : 2); }, # Ukrainian
  'ur' => sub { my $n = shift; return ($n!=1) ? 1 : 0; }, # Urdu
  'uz' => sub { my $n = shift; return 0; }, # Uzbek

  'vi' => sub { my $n = shift; return 0; }, # Vietnamese

  'wa' => sub { my $n = shift; return ($n>1) ? 1 : 0; }, # Walloon

  'zh' => sub { my $n = shift; return 0; }, # Chinese
  'zh-personal' => sub { my $n = shift; return ($n>1) ? 1 : 0; }, # Chinese, used in special cases when dealing with personal pronoun
};

#
# Choose the plural function based on locale name
# 
sub locale {
  my ($self, $locale) = @_;
  $self->{_plural} = $_plural_equations->{$locale};
} # sub locale

my $_PLURAL = '_PLURAL';

sub format {
  my ($self, $s, $params, $options) = @_;
  if (ref($params) ne 'HASH') {
    die "'params' is not a hash\n";
  }

  if ((defined $options) && (ref($options) ne 'HASH')) {
    die "'options' is not a hash\n";
  }

  $options = {} unless $options;

  my $plural_func = $options->{locale} ?
    $_plural_equations->{$options->{locale}} || $_plural_equations->{'en'} :
    $self->{_plural};

  add_missing_options($options, $self->{_default_options});

  my $strict = !!$options->{strict};
  my $auto_plurals = !!$options->{auto_plurals};
  my $callback = $options->{callback};

  my @chunks = split(/([\{\}])/, $s);
  my @blocks = ('');
  my $bracket_count = 0;
  for (my $i = 0, my $ch_len = scalar(@chunks); $i < $ch_len; $i++) {
    my $chunk = $chunks[$i];

    if ($chunk eq '{') {
      $bracket_count++;
      push @blocks, '';
      next;
    }

    if ($chunk eq '}') {
      $bracket_count--;
      if ($bracket_count < 0) {
        die "Unmatched } found\n";
      }

      my $block = pop @blocks;
      my $colon_pos = index($block, ':');

      if ($strict && ($colon_pos == 0)) {
        die "Empty placeholder name\n";
      }

      my $name;

      if ($colon_pos == -1) { # simple placeholder
        $name = $block;
      } else { # multiple choices
        $name = substr($block, 0, $colon_pos);
      }

      if (!exists $params->{$name}) {
        my $p_pos = index($name, $_PLURAL);
        if ($auto_plurals && ($p_pos != -1) && ($p_pos == (length($name) - length($_PLURAL)))) {
          my $prefix = substr($name, 0, $p_pos);
          if ($strict && !exists $params->{$prefix}) {
            die "Neither '$name' nor '$prefix' are defined\n";
          }

          my $prefix_value = int($params->{$prefix});
          if (($prefix_value ne $params->{$prefix}) || ($prefix_value < 0)) {
            if ($strict) {
              die "Value of '$prefix' is not a zero or positive integer number\n";
            }
            $prefix_value = 0;
          }

          $params->{$name} = &$plural_func($prefix_value);
        } else {
          if ($callback) {
            $params->{$name} = &$callback($name);
          } elsif ($strict) {
            die "'$name' not defined\n";
          }
        }
      }

      my $result;

      if ($colon_pos == -1) { # simple placeholder
        $result = $params->{$name};
      } else { # multiple choices
        my $block_len = length($block);

        if ($strict && ($colon_pos == $block_len - 1)) {
          die 'Empty list of variants';
        }

        my $choice_idx = int($params->{$name});
        if (($choice_idx ne $params->{$name}) || ($choice_idx < 0)) {
          if ($strict) {
            die "Value of '$name' is not a zero or positive integer number\n";
          }
          $choice_idx = 0;
        }
        my $n = 0;
        my $choice_start = $colon_pos + 1;
        my $choice_end = $block_len;
        my $j = -1;

        while (($j = index($block, '|', $j + 1)) != -1) {
          $n++;
          if ($n <= $choice_idx) {
            $choice_start = $j + 1;
          } elsif ($n == $choice_idx + 1) {
            $choice_end = $j;
          }
        }
        $result = substr($block, $choice_start, $choice_end - $choice_start);
      }

      $blocks[$#blocks] .= $result;
      next;
    }
    $blocks[$#blocks] .= $chunk;
  }

  if ($bracket_count > 0) {
    die "Unmatched { found\n";
  }

  return $blocks[0];
} # sub format

1; # return true
