
fs = require "fs"
path = require "path"

_ = require "underscore"
node_emoji = require 'node-emoji'
strip_ansi = require 'strip-ansi'

argv = require('minimist')(process.argv.slice(2))

class Emo
  constructor: (is_cli)->
    try
      data = fs.readFileSync(@get_data_path(), encoding: "utf8")
      @store = JSON.parse data
    catch
      @store = {}
      fs.writeFileSync(@get_data_path(), JSON.stringify(@store))

    if is_cli then @run()

  get_data_path: -> path.join process.env["HOME"], ".emo"
  
  write_store: -> fs.writeFileSync(@get_data_path(), JSON.stringify(@store))
  
  get_store: -> @store
  
  get_store_inverted: -> _.invert @store
  
  set: (key, value)-> @store[key] = value
  
  get: (key)-> @store[key]

  delete_emo_data_file: ->
    fs.unlinkSync(@get_data_path())

  # Take a string, return array of any strings we think are uuid-like
  detect: (input)->
    input = strip_ansi input
    re = /\b\S*(?:\S*(?:[a-zA-Z]\S*[0-9])|(?:[0-9]\S*[a-zA-Z]))+\b/g # above, but non capturing groups
    match = []
    result = []
    while (match = re.exec(input)) isnt null
      if @more_tests match[0] then result.push match[0]
    return result

  # helper
  more_tests: (input)-> 
    not /https?:\/\//.test(input) and input.length > 4

  receive: (input, spacing)->
    result = @detect input
    write_needed_flag = false
    for token in result
      # have we seen it before?
      emoji = @get(token)
      if not emoji
        write_needed_flag = true
        emoji = _.sample node_emoji.emoji
        @set token, emoji
      re = new RegExp @escape_regex token, "g"
      if not spacing
        input = input.replace re, emoji
      else
        len = token.length-emoji.length+2
        spaces = [Array(Math.floor(len/2)).join(" "), Array(Math.ceil(len/2)).join(" ")]
        input = input.replace re, "#{spaces[0]}#{emoji}#{spaces[1]}"
      
    if write_needed_flag then @write_store()
    return input

  # http://stackoverflow.com/a/1144788/83859
  escape_regex: (str)->str.replace(/([.*+?^=!:${}()|\[\]\/\\])/g, "\\$1")

  # these arguments are from argv, hence the weird
  lookup: (input, get_name=false)->
    # console.log input, get_name
    emoji = @get(input)
    if emoji isnt undefined 
      return emoji
    else
      if get_name then return _.invert(node_emoji.emoji)[input]
      else return @get_store_inverted()[input]

  # For running as cli
  run: =>
    if argv["_"].length and not argv["s"] or argv["i"]
      if argv["i"] is true then res = @lookup(argv["_"][0], true)
      else if argv["i"]    then res = @lookup(argv["i"], true)
      else                      res = @lookup(argv["_"][0])
      
      if res then process.stdout.write res
      process.exit 0
    else
      # piping mode
      process.stdin.resume()
      process.stdin.setEncoding 'utf8'
      process.stdin.on 'data', (data) =>
        process.stdout.write @receive(data, argv["s"])
      process.stdin.on 'readable', (data) ->
        # Nothing mode, just exit
        if @read() is null then process.exit 0

module.exports = Emo
