var editor;
var timer;
var prev_params_keys;
var params_keys;
var params_html;

var p = new Plurr();
var param_cache = {};
param_cache['N'] = 5;

$(document).ready(function() {
  editor = CodeMirror.fromTextArea(document.getElementById("source"), {onChange: change_source});

  var html = '';
  for (option in plural_options) {
    var sel = option == 'en' ? ' selected' : ''
    html += '<option value="' + option + '"' + sel + '>' + option + ' &mdash; ' + plural_options[option] + '</option>';
  }
  $('#locale').html(html);

  change_source();

  $('#locale').on('change', change_locale);
  $('#auto_plurals').on('change', change_source);
  $('#strict').on('change', change_param);
  $(document).on('change keyup cut paste', '#params input', change_param);
});

function cb(name) {
  var value = param_cache[name] || '';
  params_keys += "\n" + name; // using newline as a delimiter
  params_html += '<tr><td><code>' + name + ':</code></td><td><input id="param_'+name+'" param="'+name+'" value="'+value+'" /></td></tr>';
  return value;
}

function change_locale() {
  return _change(true);
}

function change_source() {
  return _change(true);
}

function change_param() {
  return _change(false);
}

function _change(rebuild_params) {
  var s = editor.getValue().trim();
  var out, params, options;

  try {
    $('#params input').each(function(idx, elem) {
      var name = $(elem).attr('param');
      var value = $(elem).val().trim();
      if (value != '') {
        param_cache[name] = value;
      } else {
        delete param_cache[name];
      }
    });

    if (rebuild_params) {
      options = {
        'locale': $('#locale').val(),
        'auto_plurals': !!$('#auto_plurals').attr('checked'),
        'strict': true,
        'callback': cb,
      };
      params_keys = '';
      params_html = '';
      p.format(s, {}, options);
      if (prev_params_keys != params_keys) {
        $('#params').html(params_html);
        prev_params_keys = params_keys;
      }
    }

    params = {};
    $('#params input').each(function(idx, elem) {
      var name = $(elem).attr('param');
      var value = $(elem).val().trim();
      if (value != '') {
        params[name] = value;
      }
    });

    options = {
      'locale': $('#locale').val(),
      'auto_plurals': !!$('#auto_plurals').attr('checked'),
      'strict': !!$('#strict').attr('checked'),
    };
    out = p.format(s, params, options);

    $('#error').text('');
    $('#output').text(out);

  } catch (e) {

    $('#error').text('Exception:' + e);
    $('#output').text('');
  }

  if (!rebuild_params) {
    // do a full rebuild on next step, after DOM is created
    clearTimeout(timer);
    timer = setTimeout(change_source, 0);
  }

  return true;
}
