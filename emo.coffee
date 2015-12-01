
fs = require "fs"
path = require "path"

_ = require "underscore"
node_emoji = require 'node-emoji'
strip_ansi = require 'strip-ansi'


class Emo
  constructor: ->
    try
      data = fs.readFileSync(@get_data_path(), encoding: "utf8")
      @store = JSON.parse data
    catch
      @store = {}
      fs.writeFileSync(@get_data_path(), JSON.stringify(@store))

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
    # re = /\b\S*(\S*([a-zA-Z]\S*[0-9])|([0-9]\S*[a-zA-Z]))+\b/g # ridic, but seems to work ok, basically a number and a letter 
    re = /\b\S*(?:\S*(?:[a-zA-Z]\S*[0-9])|(?:[0-9]\S*[a-zA-Z]))+\b/g # above, but non capturing groups?
    match = []
    result = []
    while (match = re.exec(input)) isnt null
      if @more_tests match[0] then result.push match[0]
    return result

  # helper
  more_tests: (input)-> 
    not /https?:\/\//.test(input) and input.length > 4

  receive: (input)->
    result = @detect input
    # console.log result
    write_needed_flag = false
    for token in result
      # have we seen it before?
      emoji = @get(token)
      if not emoji
        write_needed_flag = true
        emoji = _.sample node_emoji.emoji
        @set token, emoji
      try
        re = new RegExp(token,"g")  
        input = input.replace re, emoji
      catch e 
        console.log "ERROR, can't make a regex token out of"
        console.log e
        console.log token
      
      if write_needed_flag then @write_store()
    return input

  lookup: (input)->
    emoji = @get(input)
    if emoji isnt undefined 
      return emoji
    else
      return @get_store_inverted()[input]

# could store last seen, as well as the name, no not name, we get that from loading the emoji

# use _.invert


module.exports = Emo

# actual uuids v4
# /[0-9A-Za-z]{8}-[0-9A-Za-z]{4}-4[0-9A-Za-z]{3}-[89ABab][0-9A-Za-z]{3}-[0-9A-Za-z]{12}/g