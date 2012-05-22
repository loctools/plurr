CodeMirror.defineMode("plurr", function() {
  return {
    token: function(stream, state) {
      var ch = stream.next();

      if (state.error) {
        return "error";
      }

      if (ch == "{") {
        state.blocks.push({key: true, variants: false});
        return "brace";
      }

      if (ch == "}") {
        if (state.blocks.length == 1) {
          state.error = true;
          return "error";
        }
        state.blocks.pop();
        return "brace";
      }

      var b = state.blocks[state.blocks.length - 1];

      if (ch == ":") {
        if ((b.key) && (!b.variants)) {
          b.key = false;
          b.variants = true;
          return "colon";
        }
      }

      if (ch == "|") {
        if (b.variants) {
          return "bar";
        }
      }

      if (b.key) {
        return "key";
      }

      return null;
    },

    startState: function() {
      return {
        blocks: [
          {key: false, variants: false},
        ]
      };
    },
  };
});

CodeMirror.defineMIME("text/x-plurr", "plurr");
