// Copyright (C) 2020 Julen Ruiz Aizpuru, https://github.com/julen

//! # Plurr
//!
//! A library for handling plurals/genders/conditionals.

use std::collections::HashMap;

mod plurals;
mod utils;

const _PLURAL: &str = "_PLURAL";

#[derive(Debug, PartialEq)]
pub enum PlurrError {
    EmptyPlaceholder,
    EmptyVariants,
    NotZeroOrPositiveValue,
    UnmatchedOpeningBrace,
    UnmatchedClosingBrace,
    UndefinedParameter,
    UndefinedParameterPairs,
}

type PlurrParams = HashMap<String, String>;

#[derive(Debug)]
pub struct Plurr<'a> {
    locale: &'a str,
    auto_plurals: bool,
    strict: bool,
    params: PlurrParams,
}

impl<'a> Default for Plurr<'a> {
    fn default() -> Self {
        Plurr::new()
    }
}

impl<'a> Plurr<'a> {
    pub fn new() -> Self {
        Self {
            locale: "en",
            auto_plurals: true,
            strict: true,
            params: PlurrParams::new(),
        }
    }

    /// Sets the locale for Plurr. If this is not called or an incompatible
    /// `locale_code` is provided, it defaults to English.
    pub fn locale(&mut self, locale_code: &'a str) -> &mut Self {
        self.locale = locale_code;
        self
    }

    /// Toggles the auto-plural behavior.
    /// * With auto-plurals, Plurr will automatically select the plural form for
    /// the current locale.
    /// * Without auto-plurals, you will need to manually provide an `N_PLURAL`
    /// parameter before calling `format()`.
    pub fn auto_plurals(&mut self, auto_plurals: bool) -> &mut Self {
        self.auto_plurals = auto_plurals;
        self
    }

    /// Toggles strict mode. In strict mode, errors are not skipped.
    pub fn strict(&mut self, strict: bool) -> &mut Self {
        self.strict = strict;
        self
    }

    /// Stores a parameter value. Parameters must be fed before calling
    /// `format()`.
    pub fn param<T: ToString>(&mut self, key: &str, value: T) -> &mut Self {
        self.params.insert(key.to_string(), value.to_string());
        self
    }

    /// Formats a Plurr string and returns the evaluated string.
    ///
    /// For the format spec please check out the project
    /// [README](https://github.com/loctools/plurr/blob/master/README.md).
    ///
    /// # Examples
    ///
    /// ```
    /// use plurr::Plurr;
    ///
    /// let mut p = Plurr::new();
    /// let s = "Delete {N_PLURAL:{N} file|{N} files}?";
    ///
    /// assert_eq!(
    ///     p.param("N", "5").format(s),
    ///     Ok("Delete 5 files?".to_string())
    /// );
    /// ```
    pub fn format(&mut self, value: &str) -> Result<String, PlurrError> {
        let mut bracket_count = 0;
        let mut blocks = vec!["".to_string()];

        for chunk in utils::split_string(value, "{", "}") {
            if chunk == "{" {
                bracket_count += 1;
                blocks.push("".to_string());
                continue;
            }

            if chunk == "}" {
                bracket_count -= 1;
                if bracket_count < 0 {
                    return Err(PlurrError::UnmatchedClosingBrace);
                }

                let block = blocks.pop().unwrap();
                let colon_pos_maybe = block.find(':');

                let name = if let Some(colon_pos) = colon_pos_maybe {
                    if self.strict && colon_pos == 0 {
                        return Err(PlurrError::EmptyPlaceholder);
                    }
                    // Multiple choices
                    &block[0..colon_pos]
                } else {
                    &block
                };

                if !self.params.contains_key(name) {
                    let p_pos = name.find(_PLURAL);
                    if self.auto_plurals
                        && p_pos.is_some()
                        && p_pos.unwrap() == name.len() - _PLURAL.len()
                    {
                        let prefix = name[0..p_pos.unwrap()].to_string();
                        if !self.params.contains_key(&prefix) && self.strict {
                            return Err(PlurrError::UndefinedParameterPairs);
                        }

                        // This is where the actual parameter replacing happens
                        let prefix_value_maybe = self.params.get(&prefix).unwrap();
                        let prefix_value =
                            if let Ok(parsed_value) = prefix_value_maybe.parse::<usize>() {
                                parsed_value
                            } else {
                                if self.strict {
                                    return Err(PlurrError::NotZeroOrPositiveValue);
                                }
                                0
                            };

                        self.params.insert(
                            name.to_owned(),
                            plurals::plural_func(&self.locale, prefix_value).to_string(),
                        );
                    } else if self.strict {
                        return Err(PlurrError::UndefinedParameter);
                    }
                }

                let result = if let Some(colon_pos) = colon_pos_maybe {
                    // multiple choices
                    let block_len = block.len();

                    if self.strict && colon_pos == block_len - 1 {
                        return Err(PlurrError::EmptyVariants);
                    }

                    let value = self.params.get(name).unwrap();
                    let mut choice_idx: usize = value.parse().unwrap_or(0);

                    let content_start = colon_pos + 1;
                    let clean_block = &block[content_start..];

                    let parts: Vec<&str> = clean_block.split('|').collect();
                    if choice_idx >= parts.len() {
                        choice_idx = parts.len() - 1;
                    }
                    parts[choice_idx]
                } else {
                    self.params.get(name).unwrap()
                };

                let index = blocks.len() - 1;
                blocks[index].push_str(result);

                continue;
            }

            let index = blocks.len() - 1;
            blocks[index].push_str(&chunk);
        }

        if bracket_count > 0 {
            return Err(PlurrError::UnmatchedOpeningBrace);
        }

        // Clear params for subsequent calls
        self.params.clear();

        Ok(blocks[0].clone())
    }
}
