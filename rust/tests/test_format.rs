// Copyright (C) 2020 Julen Ruiz Aizpuru, https://github.com/julen

extern crate plurr;

use plurr::{Plurr, PlurrError};

#[test]
fn format_error_unmatched_braces() {
    let mut p = Plurr::new();

    let result_opening = p.format("err {");
    assert!(result_opening.is_err());
    assert_eq!(result_opening, Err(PlurrError::UnmatchedOpeningBrace));

    let result_closing = p.format("err }");
    assert!(result_closing.is_err());
    assert_eq!(result_closing, Err(PlurrError::UnmatchedClosingBrace));
}

#[test]
fn format_error_param_undefined() {
    let mut p = Plurr::new();

    let result = p.format("{foo}");
    assert!(result.is_err());
    assert_eq!(result, Err(PlurrError::UndefinedParameter));
}

#[test]
fn format_error_empty_placeholder() {
    let mut p = Plurr::new();

    let s = "Delete {:{N} file|{N} files}?";
    assert_eq!(
        p.param("N", "2").format(s),
        Err(PlurrError::EmptyPlaceholder)
    )
}

#[test]
fn format_n_plural() {
    let mut p = Plurr::new();
    let s = "Do you want to delete {N_PLURAL:this {N} file|these {N} files} permanently?";

    assert_eq!(
        p.param("N", "1").format(s),
        Ok("Do you want to delete this 1 file permanently?".to_string())
    );

    assert_eq!(
        p.param("N", "5").format(s),
        Ok("Do you want to delete these 5 files permanently?".to_string())
    );
}

#[test]
fn format_no_auto_plurals() {
    let mut p = Plurr::new();
    p.auto_plurals(false);
    let s = "Do you want to delete {N_PLURAL:this {N} file|these {N} files} permanently?";

    assert_eq!(
        p.param("N", "1").format(s),
        Err(PlurrError::UndefinedParameter)
    );
    assert_eq!(
        p.param("N_PLURAL", "0").param("N", "1").format(s),
        Ok("Do you want to delete this 1 file permanently?".to_string())
    );
    assert_eq!(
        p.param("N_PLURAL", "1").param("N", "5").format(s),
        Ok("Do you want to delete these 5 files permanently?".to_string())
    );
}

#[test]
fn format_not_zero_or_positive_args() {
    let mut p = Plurr::new();
    let s = "{N_PLURAL:One file|{N} files}";

    assert_eq!(
        p.param("N", "-1").format(s),
        Err(PlurrError::NotZeroOrPositiveValue)
    );
    assert_eq!(
        p.param("N", "Hello").format(s),
        Err(PlurrError::NotZeroOrPositiveValue)
    );
}

#[test]
fn format_arbitrary_arg() {
    let mut p = Plurr::new();

    let s = "Do you want to drink {CHOICE:coffee|tea|juice}?";

    assert_eq!(
        p.param("CHOICE", "0").format(s),
        Ok("Do you want to drink coffee?".to_string())
    );
    assert_eq!(
        p.param("CHOICE", "1").format(s),
        Ok("Do you want to drink tea?".to_string())
    );
    assert_eq!(
        p.param("CHOICE", "2").format(s),
        Ok("Do you want to drink juice?".to_string())
    );
    // when out of bounds, last form is used
    assert_eq!(
        p.param("CHOICE", "5").format(s),
        Ok("Do you want to drink juice?".to_string())
    );
}

#[test]
fn format_locale_arg() {
    let mut p = Plurr::new();

    let s = "Удалить {N_PLURAL:этот {N} файл|эти {N} файла|эти {N} файлов} навсегда?";
    assert_eq!(
        p.locale("ru").param("N", "1").format(s),
        Ok("Удалить этот 1 файл навсегда?".to_string())
    );
    assert_eq!(
        p.locale("ru").param("N", "2").format(s),
        Ok("Удалить эти 2 файла навсегда?".to_string())
    );
    assert_eq!(
        p.locale("ru").param("N", "5").format(s),
        Ok("Удалить эти 5 файлов навсегда?".to_string())
    );
}

#[test]
fn format_nested() {
    let mut p = Plurr::new();

    let s = "{X_PLURAL:{X:|One|{X}} file|{X:No|{X}} files} found.";

    assert_eq!(
        p.param("X", "0").format(s),
        Ok("No files found.".to_string())
    );
    assert_eq!(
        p.param("X", "1").format(s),
        Ok("One file found.".to_string())
    );
    assert_eq!(
        p.param("X", "2").format(s),
        Ok("2 files found.".to_string())
    );
}

#[test]
fn format_nested_locale() {
    let mut p = Plurr::new();
    let s =
        "{X_PLURAL:Найден {X:|один|{X}} файл|Найдены {X} файла|{X:Не найдено|Найдено {X}} файлов}.";

    assert_eq!(
        p.locale("ru").param("X", "0").format(s),
        Ok("Не найдено файлов.".to_string())
    );
    assert_eq!(
        p.locale("ru").param("X", "1").format(s),
        Ok("Найден один файл.".to_string())
    );
    assert_eq!(
        p.locale("ru").param("X", "2").format(s),
        Ok("Найдены 2 файла.".to_string())
    );
    assert_eq!(
        p.locale("ru").param("X", "5").format(s),
        Ok("Найдено 5 файлов.".to_string())
    );
}

#[test]
fn format_args() {
    let mut p = Plurr::new();
    let s = "{FOO}";

    assert_eq!(p.param("FOO", "1").format(s), Ok("1".to_string()));
    assert_eq!(p.param("FOO", "5.5").format(s), Ok("5.5".to_string()));
    assert_eq!(p.param("FOO", "bar").format(s), Ok("bar".to_string()));
}
