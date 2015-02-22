marked = require 'marked'

module.exports =
class PlaceParser
  constructor: ->
    @lexer = marked.lexer
    @states =
      idle: @_wait_for_list_start
      addr_idle: @_wait_for_addr_start
      error: @_parse_error
      addr: @_parse_addr
      note: @_parse_note

  parse: (src) ->
    tokens = @lexer(src)

    @current_state = 'idle'
    @current_item = null

    @items = []

    for token in tokens
      @current_state = @states[@current_state].bind(@) token, @current_item

    @states[@current_state].bind(@) type: 'EOF', @current_item

    if src.length > 0 and @items.length == 0
      throw new Error "Source not empty but not place information was found"

    return @items

  _finalize_item: (item) ->
    [name, address] = item.address.split(':')
    if not address?
      throw new Error("Wrong address format: '#{item.address}'")
    item.name = name.trim()
    item.address = address.trim()
    r = /\s*(.*)\n*\s*from \@(.*)$/gm
    m = r.exec(item.note)
    if m?
      item.note = m[1]
      item.recommendedBy = m[2]
    else
      throw new Error("Wrong note format: '#{item.note}'")
    item

  _wait_for_list_start: (token, item) ->
    if token.type == 'list_start' or token.type == 'EOF'
      if item?
        @_finalize_item item
        @items.push item
      @current_item =
        address: ""
        note: ""
      return 'addr_idle'

    return @current_state

  _wait_for_addr_start: (token) ->
    if token.type == 'list_item_start'
      return 'addr'
    return @current_state

  _parse_addr: (token, item) ->
    if token.type == 'text'
      item.address += token.text
      return @current_state
    if token.type == 'list_item_end'
      return 'note'
    return @current_state

  _parse_note: (token, item) ->
    if token.type == 'EOF' or token.type == 'list_start'
      throw new Error("Expect note for place '#{item.address}'")
    if token.type == 'code'
      item.note = token.text
      return 'idle'
    return @current_state
