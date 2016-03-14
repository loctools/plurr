#!/usr/bin/env python
# -*- coding: utf-8 -*-

import sys
sys.path.append("..")

from plurr import Plurr


def t(n, p, s, params, options, message, exception=None):
    result = None
    try:
        result = p.format(s, params, options)
        if exception is not None:
            print("n: fail: should produce exception [{0}]".format(exception))
            return
        print(n + ": "  + ('pass' if result == message else "fail: [{0}] vs [{1}]".format(result, message)))
    except Exception as e:
        s = '{0}: {1}'.format(e.__class__.__name__, str(e))
        print(n + ": "  + ('pass' if s == exception else "fail: [{0}] vs [{1}]".format(s, exception)))


p = Plurr()

t('e.1', p, '', None, None, '', "TypeError: 'params' is not a dict")
t('e.2', p, 'err {', {}, None, '', "SyntaxError: Unmatched { found")
t('e.3', p, 'err }', {}, None, '', "SyntaxError: Unmatched } found")
t('e.4', p, '{foo}', {}, None, '', "LookupError: 'foo' not defined")
t('e.5', p, '{N_PLURAL}', {'N': 'NaN'}, None, '', "ValueError: Value of 'N' is not a zero or positive integer number")
t('e.6', p, '{N_PLURAL}', {'N': 1.5}, None, '', "ValueError: Value of 'N' is not a zero or positive integer number")

s = 'Do you want to delete {N_PLURAL:this {N} file|these {N} files} permanently?'

t('1.1', p, s, {'N': 1}, None, 'Do you want to delete this 1 file permanently?')
t('1.2', p, s, {'N': 5}, None, 'Do you want to delete these 5 files permanently?')

s = 'Do you want to drink {CHOICE:coffee|tea|juice}?'

t('2.1', p, s, {'CHOICE': 0}, None, 'Do you want to drink coffee?')
t('2.2', p, s, {'CHOICE': 1}, None, 'Do you want to drink tea?')
t('2.3', p, s, {'CHOICE': 2}, None, 'Do you want to drink juice?')

s = u'Удалить {N_PLURAL:этот {N} файл|эти {N} файла|эти {N} файлов} навсегда?'

t('3.1', p, s, {'N': 1}, {'locale': 'ru'}, u'Удалить этот 1 файл навсегда?')
t('3.2', p, s, {'N': 2}, {'locale': 'ru'}, u'Удалить эти 2 файла навсегда?')
t('3.3', p, s, {'N': 5}, {'locale': 'ru'}, u'Удалить эти 5 файлов навсегда?')
t('3.4', p, s, {'N': 5}, None, u'Удалить эти 5 файла навсегда?')

s = '{X_PLURAL:{X:|One|{X}} file|{X:No|{X}} files} found.'

t('4.1', p, s, {'X': 0}, None, 'No files found.')
t('4.2', p, s, {'X': 1}, None, 'One file found.')
t('4.3', p, s, {'X': 2}, None, '2 files found.')

t('4.4', p, s, {'X': '0'}, None, 'No files found.')
t('4.5', p, s, {'X': '1'}, None, 'One file found.')
t('4.6', p, s, {'X': '2'}, None, '2 files found.')

s = u'{X_PLURAL:Найден {X:|один|{X}} файл|Найдены {X} файла|{X:Не найдено|Найдено {X}} файлов}.'

t('5.1', p, s, {'X': 0}, {'locale': 'ru'}, u'Не найдено файлов.')
t('5.2', p, s, {'X': 1}, {'locale': 'ru'}, u'Найден один файл.')
t('5.3', p, s, {'X': 2}, {'locale': 'ru'}, u'Найдены 2 файла.')
t('5.4', p, s, {'X': 5}, {'locale': 'ru'}, u'Найдено 5 файлов.')

s = '{FOO}'

t('6.1', p, s, {'FOO': 1}, None, '1')
t('6.2', p, s, {'FOO': 5.5}, None, '5.5')
t('6.3', p, s, {'FOO': 'bar'}, None, 'bar')

s = u'Удалить {N_PLURAL:этот {N} файл|эти {N} файла|эти {N} файлов} навсегда?'
p.set_locale('ru')
t('7.1', p, s, {'N': 5}, None, u'Удалить эти 5 файлов навсегда?')
t('7.2', p, s, {'N': 5}, {'locale': 'en'}, u'Удалить эти 5 файла навсегда?')
t('7.3', p, s, {'N': 5}, None, u'Удалить эти 5 файлов навсегда?')
p.set_locale('en');
t('7.4', p, s, {'N': 5}, None, u'Удалить эти 5 файла навсегда?')

# Test for locale overrides and fallback
s = 'Test {N_PLURAL:Foo|Bar {N}}'
p = Plurr({'locale': 'ru'})
p._plural_equations['foo-bar'] = lambda n: 1 if (n != 2) else 0
t('8.1', p, s, {'N': 2}, {'locale': 'foo-bar'}, 'Test Foo')
t('8.2', p, s, {'N': 2}, {'locale': 'foo_BAR'}, 'Test Bar 2')
