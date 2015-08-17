var editor;
var timer;
var prev_params_keys;
var params_keys;
var params_html;

var p = new Plurr();
var param_cache = {};
param_cache['N'] = 5;

var current_query;
var prevent_hash_update;

$(document).ready(function() {
  editor = CodeMirror.fromTextArea(document.getElementById("source"));
  editor.on('change', change_source);

  var html = '';
  for (option in plural_options) {
    var sel = option == 'en' ? ' selected' : ''
    html += '<option value="' + option + '"' + sel + '>' + option + ' &mdash; ' + plural_options[option] + '</option>';
  }
  $('#locale').html(html);

  update_from_hash();
  change_source();

  $('#locale').on('change', change_locale);
  $('#auto_plurals').on('change', change_source);
  $('#strict').on('change', change_param);
  $(document).on('change keyup cut paste', '#params input', change_param);

  $(window).on('hashchange', update_from_hash);
});

function update_from_hash() {
  new_query = window.location.hash.substr(1); // strip leading '#' symbol
  if (new_query != '') {
    deserialize(new_query);
  }
}

function deserialize(query) {
  var options = jQuery.deparam(query);

  prevent_hash_update = true;
  $('#locale').val(options.locale);
  $('#auto_plurals').attr('checked', !!options.auto_plurals);
  $('#strict').attr('checked', !!options.strict);
  editor.setValue(options.s ? options.s : '');

  $('#params input').each(function(idx, elem) {
    var name = $(elem).attr('param');
    $(elem).val(options.p[name]);
  });

  prevent_hash_update = false;
}

function serialize(s, params, options) {
  var out = options;
  out.s = s;
  out.p = params;

  current_query = jQuery.param(out);
  window.location.hash = current_query;
}

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
        'strict': false,
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

    if (!prevent_hash_update) {
      serialize(s, params, options);
    }

    out = p.format(s, params, options);

    $('#error').text('');
    $('#output').text(out);

  } catch (e) {

    $('#error').text('Exception: ' + e);
    $('#output').text('');
  }

  if (!rebuild_params) {
    // do a full rebuild on next step, after DOM is created
    clearTimeout(timer);
    timer = setTimeout(change_source, 0);
  }

  return true;
}
