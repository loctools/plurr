//
// Plurr.m
// Copyright (C) 2015 Igor Afanasyev, https://github.com/iafan/Plurr
//

#import "Plurr.h"

typedef NS_OPTIONS(NSUInteger, PlurrOptions) {
  PlurrOption_Strict   = 1<<0,
  PlurrOption_AutoPlurals = 1<<1
};

static NSString* const kPluralSuffix = @"_PLURAL";

@interface Plurr()
@property(nonatomic, readonly) NSInvocation* pluralInvocation;
@end

@implementation Plurr

- (instancetype)initWithLocale:(NSLocale*)locale{
  self = [super init];
  if(self){
    self.locale = locale;
    // if we are using an autoupdating locale, this updates our plural method
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(localeDidChange:) name:NSCurrentLocaleDidChangeNotification object:nil];
  }
  return self;
}

- (instancetype)init{
  self = [self initWithLocale:nil];
  return self;
}

+ (Plurr*)defaultPlurr{
  static Plurr *sPlurr = nil;
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    sPlurr = [[self alloc] init];
  });
  return sPlurr;
}

- (void)dealloc{
  [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Format methods

- (NSArray*)componentsOfString:(NSString*)format separatedbyCharactersInSet:(NSCharacterSet*)separatorSet{
  NSMutableArray* array = [[NSMutableArray alloc] init];
  NSMutableString* currentString = nil;
  
  for(NSUInteger characterIndex = 0; characterIndex < format.length;){
    NSRange characterRange =[format rangeOfComposedCharacterSequenceAtIndex:characterIndex];
    NSString* c = [format substringWithRange:characterRange];
    characterIndex = characterRange.location + characterRange.length;
    
    if([c rangeOfCharacterFromSet:separatorSet].location == NSNotFound){
      if(currentString == nil){
        currentString = [[NSMutableString alloc] init];
      }
      [currentString appendString:c];
    }
    else{
      if(currentString != nil){
        [array addObject:currentString];
      }
      [array addObject:c];
      currentString = nil;
    }
  }
  if(currentString){
    [array addObject:currentString];
  }
  
  return array;
}

- (NSString*)stringWithFormat:(NSString*)format arguments:(NSDictionary*)arguments options:(PlurrOptions)options{
  if(arguments == nil){
    @throw [NSException exceptionWithName:NSInvalidArgumentException reason:@"parameters can't be nil" userInfo:nil];
  }
  
  BOOL strict = ((options & PlurrOption_Strict) == PlurrOption_Strict);
  BOOL auto_plurals = ((options & PlurrOption_AutoPlurals) == PlurrOption_AutoPlurals);
  

  NSMutableArray* blocks = [@[@""] mutableCopy];
  __block NSInteger bracket_count = 0;
  __block NSException* exception = nil;
  
  NSMutableDictionary* params = [arguments mutableCopy];
  NSCharacterSet* curlyBraces = [NSCharacterSet characterSetWithCharactersInString:@"{}"];
  [[self componentsOfString:format separatedbyCharactersInSet:curlyBraces] enumerateObjectsUsingBlock:^(NSString* chunk, NSUInteger idx, BOOL *stop) {

    if ([chunk isEqualToString:@"{"]) {
      bracket_count++;
      [blocks addObject:@""];
      return;
    }
    
    if([chunk isEqualToString:@"}"]){
      bracket_count--;
      if(bracket_count < 0){
        exception = [NSException exceptionWithName:NSInvalidArgumentException reason:@"Unmatched } found" userInfo:@{@"string" : format}];
        *stop = YES;
        return;
      }
      NSString* block = [blocks lastObject];
      [blocks removeLastObject];
      
      NSUInteger colon_pos = [block rangeOfString:@":"].location;
      if(strict && colon_pos == 0){
        exception = [NSException exceptionWithName:NSInvalidArgumentException reason:@"Empty placeholdername" userInfo:nil];
        *stop = YES;
        return;
      }
      
      NSString* name = nil;
      
      if (colon_pos == NSNotFound) { // simple placeholder
        name = block;
      } else { // multiple choices
        name = [block substringToIndex:colon_pos];
      }
      
      if (params[name] == nil) {
        NSUInteger p_pos = [name rangeOfString:kPluralSuffix].location;
        if (auto_plurals && (p_pos != NSNotFound) && (p_pos == (name.length - kPluralSuffix.length))) {
          NSString* prefix =  [name substringToIndex:p_pos];
          
          NSString* prefix_value_string = (params[prefix]);
          if (strict && !prefix_value_string) {
            exception = [NSException exceptionWithName:NSInvalidArgumentException reason:[NSString stringWithFormat:@"Neither \"%@\" nor \"%@\" are defined", name, prefix] userInfo:nil];
            *stop = YES;
            return;
          }
          
          NSInteger prefix_value = [prefix_value_string integerValue];
          if (prefix_value_string == nil || (prefix_value < 0)) {
            if (strict) {
              exception = [NSException exceptionWithName:NSInvalidArgumentException reason:[NSString stringWithFormat:@"Value of \"%@\" is not a zero or positive integer number", prefix] userInfo:nil];
              *stop = YES;
              return;
            }
            prefix_value = 0;
          }
          
          params[name] = [self pluralVariationsForCount:prefix_value];
        } else {
          if (strict) {
            exception = [NSException exceptionWithName:NSInvalidArgumentException reason:[NSString stringWithFormat:@"Name \"%@\" not defined", name] userInfo:nil];
            *stop = YES;
            return;
          }
        }
      }
      
      NSString* result = nil;
      
      if (colon_pos == NSNotFound) { // simple placeholder
        result = params[name];
      }
      else { // multiple choices
        NSUInteger block_len = block.length;
        
        if (strict && (colon_pos == block_len - 1)) {
          exception = [NSException exceptionWithName:NSInvalidArgumentException reason:[NSString stringWithFormat:@"Empty list of variants"] userInfo:nil];
          *stop = YES;
          return;
        }
        
        NSString* choice_idx_string = params[name];
        NSInteger choice_idx = [choice_idx_string integerValue];
        if (choice_idx_string != params[name] || (choice_idx < 0)) {
          if (strict) {
            exception = [NSException exceptionWithName:NSInvalidArgumentException reason:[NSString stringWithFormat:@"Value of  \"%@\"  is not a zero or positive integer number", name] userInfo:nil];
            *stop = YES;
            return;

          }
          choice_idx = 0;
        }
        NSInteger n = 0;
        NSInteger choice_start = colon_pos + 1;
        NSInteger choice_end = block_len;
        NSInteger j = -1;
        
        while ((j = [block rangeOfString:@"|" options:0 range:NSMakeRange(j+1, block.length - (j+1))].location) != NSNotFound) {
          n++;
          if (n <= choice_idx) {
            choice_start = j + 1;
          } else if (n == choice_idx + 1) {
            choice_end = j;
          }
        }
        result = [block substringWithRange:NSMakeRange(choice_start, choice_end - choice_start)];
      }
      NSString* last = blocks[blocks.count - 1];
      NSString* append = result.description;
      blocks[blocks.count - 1] = [last stringByAppendingString:append];
      return;
    }

    NSString* last = blocks[blocks.count - 1];
    blocks[blocks.count - 1] = [last stringByAppendingString:chunk];
  }];
  
  if (exception == nil && bracket_count > 0) {
    exception =  [NSException exceptionWithName:NSInvalidArgumentException reason:@"Unmatched { found" userInfo:nil];
  }

  if(exception != nil){
    @throw exception;
  }
  
  return [blocks firstObject];
}

- (NSString*)stringWithFormat:(NSString*)format arguments:(NSDictionary*)arguments {
  return [self stringWithFormat:format arguments:arguments options:PlurrOption_Strict|PlurrOption_AutoPlurals];
}

+ (NSString*)stringWithFormat:(NSString*)format arguments:(NSDictionary*)arguments{
  return [[self defaultPlurr] stringWithFormat:format arguments:arguments];
}


- (NSString*)localizedStringWithFormat:(NSString *)format arguments:(NSDictionary *)arguments{
  return [self stringWithFormat:NSLocalizedString(format, nil) arguments:arguments];
}

+ (NSString*)localizedStringWithFormat:(NSString*)format arguments:(NSDictionary*)arguments{
  return [[self defaultPlurr] localizedStringWithFormat:format arguments:arguments];
}

#pragma mark - Locale configuration and update when it changes

- (void)setLocale:(NSLocale *)locale{
  if(locale == nil){
    locale = [NSLocale autoupdatingCurrentLocale];
  }
  _locale = locale;
  [self updatePluralMethod];
}

- (void)updatePluralMethod{
  
  // !!!: convert all locales to the right method names
  
  NSString* identifier = [self.locale objectForKey:NSLocaleIdentifier];
  
  NSDictionary* identifierMappings = @{
    @"pt"      : @"pt-br",
    @"pt-PT"   : @"pt",
    @"nb-NO"   : @"no",
    @"zh-Hans" : @"zh-cn",
    @"zh-Hant" : @"zh-tw"
  };
  
  NSString* formattedLanguageCode = identifierMappings[identifier];
  if(formattedLanguageCode == nil){
    formattedLanguageCode = [self.locale objectForKey:NSLocaleLanguageCode];
  }
  formattedLanguageCode = [[formattedLanguageCode stringByReplacingOccurrencesOfString:@"-" withString:@"_"] lowercaseString];
  
  SEL pluralSelector = NSSelectorFromString([NSString stringWithFormat:@"pluralVariationsForCount_%@:", formattedLanguageCode]);
  
  if([self respondsToSelector:pluralSelector] == NO){
    
    // Default to EN, assert while debugging and not testing
#if DEBUG
    if(NSClassFromString(@"XCTest") == nil){
      NSLog(@"Plural function %@ is not supported", formattedLanguageCode);
    }
#endif
    pluralSelector = @selector(pluralVariationsForCount_en:);
  }
  
  NSInvocation* pluralInvocation = [NSInvocation invocationWithMethodSignature:[self methodSignatureForSelector:pluralSelector]];
  [pluralInvocation setSelector:pluralSelector];
  [pluralInvocation setTarget:self];
  _pluralInvocation = pluralInvocation;
}

- (void)localeDidChange:(NSNotification*)aNotification{
  [self updatePluralMethod];
}

#pragma mark - Locale-dependent plural methods

- (NSString*)pluralVariationsForCount:(NSUInteger)count{
  [_pluralInvocation setArgument:&count atIndex:2];
  [_pluralInvocation invoke];
  NSUInteger pluralVariation = 0;
  [_pluralInvocation getReturnValue:&pluralVariation];
  return @(pluralVariation).stringValue;
}

#pragma mark

// Acholi
- (NSUInteger)pluralVariationsForCount_ach: (NSUInteger)n {
  return 0;
}
// Afrikaans
- (NSUInteger)pluralVariationsForCount_af: (NSUInteger)n {
  return (n!=1) ? 1 : 0;
}
// Akan
- (NSUInteger)pluralVariationsForCount_ak: (NSUInteger)n {
  return (n>1) ? 1 : 0;
}
// Amharic
- (NSUInteger)pluralVariationsForCount_am: (NSUInteger)n {
  return (n>1) ? 1 : 0;
}
// Aragonese
- (NSUInteger)pluralVariationsForCount_an: (NSUInteger)n {
  return (n!=1) ? 1 : 0;
}
// Arabic
- (NSUInteger)pluralVariationsForCount_ar: (NSUInteger)n {
  return n==0 ? 0 : n==1 ? 1 : n==2 ? 2 : n%100>=3 && n%100<=10 ? 3 : n%100>=11 ? 4 : 5;
}
// Mapudungun
- (NSUInteger)pluralVariationsForCount_arn: (NSUInteger)n {
  return (n>1) ? 1 : 0;
}
// Asturian
- (NSUInteger)pluralVariationsForCount_ast: (NSUInteger)n {
  return (n!=1) ? 1 : 0;
}
// Aymara
- (NSUInteger)pluralVariationsForCount_ay: (NSUInteger)n {
  return 0;
}
// Azerbaijani
- (NSUInteger)pluralVariationsForCount_az: (NSUInteger)n {
  return (n!=1) ? 1 : 0;
}

// Belarusian
- (NSUInteger)pluralVariationsForCount_be: (NSUInteger)n {
  return (n%10==1 && n%100!=11 ? 0 : n%10>=2 && n%10<=4 && (n%100<10 || n%100>=20) ? 1 : 2);
}
// Bulgarian
- (NSUInteger)pluralVariationsForCount_bg: (NSUInteger)n {
  return (n!=1) ? 1 : 0;
}
// Bengali
- (NSUInteger)pluralVariationsForCount_bn: (NSUInteger)n {
  return (n!=1) ? 1 : 0;
}
// Tibetan
- (NSUInteger)pluralVariationsForCount_bo: (NSUInteger)n {
  return 0;
}
// Breton
- (NSUInteger)pluralVariationsForCount_br: (NSUInteger)n {
  return (n>1) ? 1 : 0;
}
// Bosnian
- (NSUInteger)pluralVariationsForCount_bs: (NSUInteger)n {
  return (n%10==1 && n%100!=11 ? 0 : n%10>=2 && n%10<=4 && (n%100<10 || n%100>=20) ? 1 : 2);
}

// Catalan
- (NSUInteger)pluralVariationsForCount_ca: (NSUInteger)n {
  return (n!=1) ? 1 : 0;
}
// Chiga
- (NSUInteger)pluralVariationsForCount_cgg: (NSUInteger)n {
  return 0;
}
// Czech
- (NSUInteger)pluralVariationsForCount_cs: (NSUInteger)n {
  return (n==1) ? 0 : (n>=2 && n<=4) ? 1 : 2;
}
// Kashubian
- (NSUInteger)pluralVariationsForCount_csb: (NSUInteger)n {
  return n==1 ? 0 : n%10>=2 && n%10<=4 && (n%100<10 || n%100>=20) ? 1 : 2;
}
// Welsh
- (NSUInteger)pluralVariationsForCount_cy: (NSUInteger)n {
  return (n==1) ? 0 : (n==2) ? 1 : (n!=8 && n!=11) ? 2 : 3;
}

// Danish
- (NSUInteger)pluralVariationsForCount_da: (NSUInteger)n {
  return (n!=1) ? 1 : 0;
}
// German
- (NSUInteger)pluralVariationsForCount_de: (NSUInteger)n {
  return (n!=1) ? 1 : 0;
}
// Dzongkha
- (NSUInteger)pluralVariationsForCount_dz: (NSUInteger)n {
  return 0;
}

// Greek
- (NSUInteger)pluralVariationsForCount_el: (NSUInteger)n {
  return (n!=1) ? 1 : 0;
}
// English
- (NSUInteger)pluralVariationsForCount_en: (NSUInteger)n {
  return (n!=1) ? 1 : 0;
}
// Esperanto
- (NSUInteger)pluralVariationsForCount_eo: (NSUInteger)n {
  return (n!=1) ? 1 : 0;
}
// Spanish
- (NSUInteger)pluralVariationsForCount_es: (NSUInteger)n {
  return (n!=1) ? 1 : 0;
}
// Argentinean Spanish
- (NSUInteger)pluralVariationsForCount_es_ar: (NSUInteger)n {
  return (n!=1) ? 1 : 0;
}
// Estonian
- (NSUInteger)pluralVariationsForCount_et: (NSUInteger)n {
  return (n!=1) ? 1 : 0;
}
// Basque
- (NSUInteger)pluralVariationsForCount_eu: (NSUInteger)n {
  return (n!=1) ? 1 : 0;
}

// Persian
- (NSUInteger)pluralVariationsForCount_fa: (NSUInteger)n {
  return 0;
}
// Finnish
- (NSUInteger)pluralVariationsForCount_fi: (NSUInteger)n {
  return (n!=1) ? 1 : 0;
}
// Filipino
- (NSUInteger)pluralVariationsForCount_fil: (NSUInteger)n {
  return (n>1) ? 1 : 0;
}
// Faroese
- (NSUInteger)pluralVariationsForCount_fo: (NSUInteger)n {
  return (n!=1) ? 1 : 0;
}
// French
- (NSUInteger)pluralVariationsForCount_fr: (NSUInteger)n {
  return (n>1) ? 1 : 0;
}
// Friulian
- (NSUInteger)pluralVariationsForCount_fur: (NSUInteger)n {
  return (n!=1) ? 1 : 0;
}
// Frisian
- (NSUInteger)pluralVariationsForCount_fy: (NSUInteger)n {
  return (n!=1) ? 1 : 0;
}

// Irish
- (NSUInteger)pluralVariationsForCount_ga: (NSUInteger)n {
  return n==1 ? 0 : n==2 ? 1 : n<7 ? 2 : n<11 ? 3 : 4;
}
// Galician
- (NSUInteger)pluralVariationsForCount_gl: (NSUInteger)n {
  return (n!=1) ? 1 : 0;
}
// Gujarati
- (NSUInteger)pluralVariationsForCount_gu: (NSUInteger)n {
  return (n!=1) ? 1 : 0;
}
// Gun
- (NSUInteger)pluralVariationsForCount_gun: (NSUInteger)n {
  return (n>1) ? 1 : 0;
}

// Hausa
- (NSUInteger)pluralVariationsForCount_ha: (NSUInteger)n {
  return (n!=1) ? 1 : 0;
}
// Hebrew
- (NSUInteger)pluralVariationsForCount_he: (NSUInteger)n {
  return (n!=1) ? 1 : 0;
}
// Hindi
- (NSUInteger)pluralVariationsForCount_hi: (NSUInteger)n {
  return (n!=1) ? 1 : 0;
}
// Armenian
- (NSUInteger)pluralVariationsForCount_hy: (NSUInteger)n {
  return 0;
}
// Croatian
- (NSUInteger)pluralVariationsForCount_hr: (NSUInteger)n {
  return (n%10==1 && n%100!=11 ? 0 : n%10>=2 && n%10<=4 && (n%100<10 || n%100>=20) ? 1 : 2);
}
// Hungarian
- (NSUInteger)pluralVariationsForCount_hu: (NSUInteger)n {
  return (n!=1) ? 1 : 0;
}

// Interlingua
- (NSUInteger)pluralVariationsForCount_ia: (NSUInteger)n {
  return (n!=1) ? 1 : 0;
}
// Indonesian
- (NSUInteger)pluralVariationsForCount_id: (NSUInteger)n {
  return 0;
}
// Icelandic
- (NSUInteger)pluralVariationsForCount_is: (NSUInteger)n {
  return (n%10!=1 || n%100==11) ? 1 : 0;
}
// Italian
- (NSUInteger)pluralVariationsForCount_it: (NSUInteger)n {
  return (n!=1) ? 1 : 0;
}

// Japanese
- (NSUInteger)pluralVariationsForCount_ja: (NSUInteger)n {
  return 0;
}
// Javanese
- (NSUInteger)pluralVariationsForCount_jv: (NSUInteger)n {
  return (n!=0) ? 1 : 0;
}

// Georgian
- (NSUInteger)pluralVariationsForCount_ka: (NSUInteger)n {
  return 0;
}
// Kazakh
- (NSUInteger)pluralVariationsForCount_kk: (NSUInteger)n {
  return 0;
}
// Khmer
- (NSUInteger)pluralVariationsForCount_km: (NSUInteger)n {
  return 0;
}
// Kannada
- (NSUInteger)pluralVariationsForCount_kn: (NSUInteger)n {
  return (n!=1) ? 1 : 0;
}
// Korean
- (NSUInteger)pluralVariationsForCount_ko: (NSUInteger)n {
  return 0;
}
// Kurdish
- (NSUInteger)pluralVariationsForCount_ku: (NSUInteger)n {
  return (n!=1) ? 1 : 0;
}
// Cornish
- (NSUInteger)pluralVariationsForCount_kw: (NSUInteger)n {
  return (n==1) ? 0 : (n==2) ? 1 : (n==3) ? 2 : 3;
}
// Kyrgyz
- (NSUInteger)pluralVariationsForCount_ky: (NSUInteger)n {
  return 0;
}

// Letzeburgesch
- (NSUInteger)pluralVariationsForCount_lb: (NSUInteger)n {
  return (n!=1) ? 1 : 0;
}
// Lingala
- (NSUInteger)pluralVariationsForCount_ln: (NSUInteger)n {
  return (n>1) ? 1 : 0;
}
// Lao
- (NSUInteger)pluralVariationsForCount_lo: (NSUInteger)n {
  return 0;
}
// Lithuanian
- (NSUInteger)pluralVariationsForCount_lt: (NSUInteger)n {
  return (n%10==1 && n%100!=11 ? 0 : n%10>=2 && (n%100<10 || n%100>=20) ? 1 : 2);
}
// Latvian
- (NSUInteger)pluralVariationsForCount_lv: (NSUInteger)n {
  return (n%10==1 && n%100!=11 ? 0 : n!=0 ? 1 : 2);
}

// Mauritian Creole
- (NSUInteger)pluralVariationsForCount_mfe: (NSUInteger)n {
  return (n>1) ? 1 : 0;
}
// Malagasy
- (NSUInteger)pluralVariationsForCount_mg: (NSUInteger)n {
  return (n>1) ? 1 : 0;
}
// Maori
- (NSUInteger)pluralVariationsForCount_mi: (NSUInteger)n {
  return (n>1) ? 1 : 0;
}
// Macedonian
- (NSUInteger)pluralVariationsForCount_mk: (NSUInteger)n {
  return n==1 || n%10==1 ? 0 : 1;
}
// Malayalam
- (NSUInteger)pluralVariationsForCount_ml: (NSUInteger)n {
  return (n!=1) ? 1 : 0;
}
// Mongolian
- (NSUInteger)pluralVariationsForCount_mn: (NSUInteger)n {
  return (n!=1) ? 1 : 0;
}
// Marathi
- (NSUInteger)pluralVariationsForCount_mr: (NSUInteger)n {
  return (n!=1) ? 1 : 0;
}
// Malay
- (NSUInteger)pluralVariationsForCount_ms: (NSUInteger)n {
  return 0;
}
// Maltese
- (NSUInteger)pluralVariationsForCount_mt: (NSUInteger)n {
  return (n==1 ? 0 : n==0 || ( n%100>1 && n%100<11) ? 1 : (n%100>10 && n%100<20 ) ? 2 : 3);
}

// Nahuatl
- (NSUInteger)pluralVariationsForCount_nah: (NSUInteger)n {
  return (n!=1) ? 1 : 0;
}
// Neapolitan
- (NSUInteger)pluralVariationsForCount_nap: (NSUInteger)n {
  return (n!=1) ? 1 : 0;
}
// Norwegian Bokmal
- (NSUInteger)pluralVariationsForCount_nb: (NSUInteger)n {
  return (n!=1) ? 1 : 0;
}
// Nepali
- (NSUInteger)pluralVariationsForCount_ne: (NSUInteger)n {
  return (n!=1) ? 1 : 0;
}
// Dutch
- (NSUInteger)pluralVariationsForCount_nl: (NSUInteger)n {
  return (n!=1) ? 1 : 0;
}
// Northern Sami
- (NSUInteger)pluralVariationsForCount_se: (NSUInteger)n {
  return (n!=1) ? 1 : 0;
}
// Norwegian Nynorsk
- (NSUInteger)pluralVariationsForCount_nn: (NSUInteger)n {
  return (n!=1) ? 1 : 0;
}
// Norwegian (old code)
- (NSUInteger)pluralVariationsForCount_no: (NSUInteger)n {
  return (n!=1) ? 1 : 0;
}
// Northern Sotho
- (NSUInteger)pluralVariationsForCount_nso: (NSUInteger)n {
  return (n!=1) ? 1 : 0;
}

// Occitan
- (NSUInteger)pluralVariationsForCount_oc: (NSUInteger)n {
  return (n>1) ? 1 : 0;
}
// Oriya
- (NSUInteger)pluralVariationsForCount_or: (NSUInteger)n {
  return (n!=1) ? 1 : 0;
}

// Pashto
- (NSUInteger)pluralVariationsForCount_ps: (NSUInteger)n {
  return (n!=1) ? 1 : 0;
}
// Punjabi
- (NSUInteger)pluralVariationsForCount_pa: (NSUInteger)n {
  return (n!=1) ? 1 : 0;
}
// Papiamento
- (NSUInteger)pluralVariationsForCount_pap: (NSUInteger)n {
  return (n!=1) ? 1 : 0;
}
// Polish
- (NSUInteger)pluralVariationsForCount_pl: (NSUInteger)n {
  return (n==1 ? 0 : n%10>=2 && n%10<=4 && (n%100<10 || n%100>=20) ? 1 : 2);
}
// Piemontese
- (NSUInteger)pluralVariationsForCount_pms: (NSUInteger)n {
  return (n!=1) ? 1 : 0;
}
// Portuguese
- (NSUInteger)pluralVariationsForCount_pt: (NSUInteger)n {
  return (n!=1) ? 1 : 0;
}
// Brazilian Portuguese
- (NSUInteger)pluralVariationsForCount_pt_br: (NSUInteger)n {
  return (n>1) ? 1 : 0;
}

// Romansh
- (NSUInteger)pluralVariationsForCount_rm: (NSUInteger)n {
  return (n!=1) ? 1 : 0;
}
// Romanian
- (NSUInteger)pluralVariationsForCount_ro: (NSUInteger)n {
  return (n==1 ? 0 : (n==0 || (n%100>0 && n%100<20)) ? 1 : 2);
}
// Russian
- (NSUInteger)pluralVariationsForCount_ru: (NSUInteger)n {
  return (n%10==1 && n%100!=11 ? 0 : n%10>=2 && n%10<=4 && (n%100<10 || n%100>=20) ? 1 : 2);
}

// Scots
- (NSUInteger)pluralVariationsForCount_sco: (NSUInteger)n {
  return (n!=1) ? 1 : 0;
}
// Sinhala
- (NSUInteger)pluralVariationsForCount_si: (NSUInteger)n {
  return (n!=1) ? 1 : 0;
}
// Slovak
- (NSUInteger)pluralVariationsForCount_sk: (NSUInteger)n {
  return (n==1) ? 0 : (n>=2 && n<=4) ? 1 : 2;
}
// Slovenian
- (NSUInteger)pluralVariationsForCount_sl: (NSUInteger)n {
  return (n%100==1 ? 1 : n%100==2 ? 2 : n%100==3 || n%100==4 ? 3 : 0);
}
// Somali
- (NSUInteger)pluralVariationsForCount_so: (NSUInteger)n {
  return (n!=1) ? 1 : 0;
}
// Songhay
- (NSUInteger)pluralVariationsForCount_son: (NSUInteger)n {
  return 0;
}
// Albanian
- (NSUInteger)pluralVariationsForCount_sq: (NSUInteger)n {
  return (n!=1) ? 1 : 0;
}
// Serbian
- (NSUInteger)pluralVariationsForCount_sr: (NSUInteger)n {
  return (n%10==1 && n%100!=11 ? 0 : n%10>=2 && n%10<=4 && (n%100<10 || n%100>=20) ? 1 : 2);
}
// Sundanese
- (NSUInteger)pluralVariationsForCount_su: (NSUInteger)n {
  return 0;
}
// Swahili
- (NSUInteger)pluralVariationsForCount_sw: (NSUInteger)n {
  return (n!=1) ? 1 : 0;
}
// Swedish
- (NSUInteger)pluralVariationsForCount_sv: (NSUInteger)n {
  return (n!=1) ? 1 : 0;
}

// Tamil
- (NSUInteger)pluralVariationsForCount_ta: (NSUInteger)n {
  return (n!=1) ? 1 : 0;
}
// Telugu
- (NSUInteger)pluralVariationsForCount_te: (NSUInteger)n {
  return (n!=1) ? 1 : 0;
}
// Tajik
- (NSUInteger)pluralVariationsForCount_tg: (NSUInteger)n {
  return (n!=1) ? 1 : 0;
}
// Tigrinya
- (NSUInteger)pluralVariationsForCount_ti: (NSUInteger)n {
  return (n>1) ? 1 : 0;
}
// Thai
- (NSUInteger)pluralVariationsForCount_th: (NSUInteger)n {
  return 0;
}
// Turkmen
- (NSUInteger)pluralVariationsForCount_tk: (NSUInteger)n {
  return (n!=1) ? 1 : 0;
}
// Turkish
- (NSUInteger)pluralVariationsForCount_tr: (NSUInteger)n {
  return 0;
}
// Tatar
- (NSUInteger)pluralVariationsForCount_tt: (NSUInteger)n {
  return 0;
}

// Uyghur
- (NSUInteger)pluralVariationsForCount_ug: (NSUInteger)n {
  return 0;
}
// Ukrainian
- (NSUInteger)pluralVariationsForCount_uk: (NSUInteger)n {
  return (n%10==1 && n%100!=11 ? 0 : n%10>=2 && n%10<=4 && (n%100<10 || n%100>=20) ? 1 : 2);
}
// Urdu
- (NSUInteger)pluralVariationsForCount_ur: (NSUInteger)n {
  return (n!=1) ? 1 : 0;
}
// Uzbek
- (NSUInteger)pluralVariationsForCount_uz: (NSUInteger)n {
  return 0;
}

// Vietnamese
- (NSUInteger)pluralVariationsForCount_vi: (NSUInteger)n {
  return 0;
}

// Walloon
- (NSUInteger)pluralVariationsForCount_wa: (NSUInteger)n {
  return (n>1) ? 1 : 0;
}

// Chinese
- (NSUInteger)pluralVariationsForCount_zh: (NSUInteger)n {
  return 0;
}
// Chinese, used in special cases when dealing with personal pronoun
- (NSUInteger)pluralVariationsForCount_zh_personal: (NSUInteger)n {
  return (n>1) ? 1 : 0;
}

@end

#pragma mark - NSLocalizedString - style API

NSString* PlurrLocalizedString(NSString* format, NSDictionary* argumentss){
  return [[Plurr defaultPlurr] stringWithFormat:NSLocalizedString(format, nil) arguments:argumentss];
}
