var PlaceParser, marked;

marked = require('marked');

module.exports = PlaceParser = (function() {
  function PlaceParser() {
    this.lexer = marked.lexer;
    this.states = {
      idle: this._wait_for_list_start,
      addr_idle: this._wait_for_addr_start,
      error: this._parse_error,
      addr: this._parse_addr,
      note: this._parse_note
    };
  }

  PlaceParser.prototype.parse = function(src) {
    var i, len, token, tokens;
    tokens = this.lexer(src);
    this.current_state = 'idle';
    this.current_item = null;
    this.items = [];
    for (i = 0, len = tokens.length; i < len; i++) {
      token = tokens[i];
      this.current_state = this.states[this.current_state].bind(this)(token, this.current_item);
    }
    this.states[this.current_state].bind(this)({
      type: 'EOF'
    }, this.current_item);
    if (src.length > 0 && this.items.length === 0) {
      throw new Error("Source not empty but not place information was found");
    }
    return this.items;
  };

  PlaceParser.prototype._finalize_item = function(item) {
    var address, m, name, r, ref;
    ref = item.address.split(':'), name = ref[0], address = ref[1];
    if (address == null) {
      throw new Error("Wrong address format: '" + item.address + "'");
    }
    item.name = name.trim();
    item.address = address.trim();
    r = /\s*(.*)\n*\s*from \@(.*)$/gm;
    m = r.exec(item.note);
    if (m != null) {
      item.note = m[1];
      item.recommendedBy = m[2];
    } else {
      throw new Error("Wrong note format: '" + item.note + "'");
    }
    return item;
  };

  PlaceParser.prototype._wait_for_list_start = function(token, item) {
    if (token.type === 'list_start' || token.type === 'EOF') {
      if (item != null) {
        this._finalize_item(item);
        this.items.push(item);
      }
      this.current_item = {
        address: "",
        note: ""
      };
      return 'addr_idle';
    }
    return this.current_state;
  };

  PlaceParser.prototype._wait_for_addr_start = function(token) {
    if (token.type === 'list_item_start') {
      return 'addr';
    }
    return this.current_state;
  };

  PlaceParser.prototype._parse_addr = function(token, item) {
    if (token.type === 'text') {
      item.address += token.text;
      return this.current_state;
    }
    if (token.type === 'list_item_end') {
      return 'note';
    }
    return this.current_state;
  };

  PlaceParser.prototype._parse_note = function(token, item) {
    if (token.type === 'EOF' || token.type === 'list_start') {
      throw new Error("Expect note for place '" + item.address + "'");
    }
    if (token.type === 'code') {
      item.note = token.text;
      return 'idle';
    }
    return this.current_state;
  };

  return PlaceParser;

})();

//# sourceMappingURL=../map/place-parser.js.map