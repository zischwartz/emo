# v4 uuid matcher
# /[0-9A-Za-z]{8}-[0-9A-Za-z]{4}-4[0-9A-Za-z]{3}-[89ABab][0-9A-Za-z]{3}-[0-9A-Za-z]{12}/g

fs = require "fs"
path = require "path"

_ = require "underscore"
node_emoji = require 'node-emoji'
strip_ansi = require 'strip-ansi'

# lens = _.mapObject node_emoji.emoji, (x)->x.length
# console.log lens 

# http://stackoverflow.com/a/28212720
# modified, works ok
# check for quotes
# \S*(\S*([a-zA-Z]\S*[0-9])|([0-9]\S*[a-zA-Z])){4,}\S*
# /\S*(\S*([a-zA-Z]\S*[0-9])|([0-9]\S*[a-zA-Z])){4,}\S*/g

# if we then detected for at least two numbers and two letters, this would work well broadly, very inclusive
# \w[a-zA-Z0-9\-]*\w

class Emo
  get_data_path: -> path.join process.env["HOME"], ".emo"
  constructor: ->
    try
      data = fs.readFileSync(@get_data_path(), encoding: "utf8")
      data = JSON.parse data
      @store = data
    catch
      @store = {}
      fs.writeFileSync(@get_data_path(), JSON.stringify(@store))
      # console.log "file no existo, creating"
  
  write_store: ->
    fs.writeFileSync(@get_data_path(), JSON.stringify(@store))
  get_store: ->  @store
  set: (key, value)-> @store[key] = value
  get: (key)-> @store[key]


  delete_emo_data_file: ->
    fs.unlinkSync(@get_data_path())

  # take a string, return array of any strings we think are uuid-like
  detect: (input)->
    # re = /\S*(\S*([a-zA-Z]\S*[0-9])|([0-9]\S*[a-zA-Z])){1,}\S*/g # that this one passes shows that the tests suck 
    re = /\S*(\S*([a-zA-Z]\S*[0-9])|([0-9]\S*[a-zA-Z])){4,}\S*/g # 4, fewer false positives, but doesn't get 7 digit git sha abbrs
    # dd5a83397d84 does not match 
    match = []
    result = []
    while (match = re.exec(input)) isnt null
      if @more_tests match[0]
        result.push @clean match[0]
    result
  # helpers for @detect
  more_tests: (input)-> not /https?:\/\//.test(input)
  # remove punctuation, todo it'd be better to only do this for the ends

  clean: (input) -> 
    input = strip_ansi input
    input = input.replace(/("|'|:|;|\.)/g, '')# input.replace(/("|'|:|;|\.)$/g, '').replace(/^("|'|:|;|\.)/g, '')
    input.replace(/(\(|\()/g, '')

  # input.replace(/("|'|:|;|\.)$/g, '').replace(/^("|'|:|;|\.)/g, '')

  receive: (input)->
    result = @detect input
    console.log result
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
        console.log e
        console.log token
      
      if write_needed_flag then @write_store()
    return input


# could store last seen, as well as the name, no not name, we get that from loading the emoji

# use _.invert


module.exports = Emo

# actual uuids v4
# /[0-9A-Za-z]{8}-[0-9A-Za-z]{4}-4[0-9A-Za-z]{3}-[89ABab][0-9A-Za-z]{3}-[0-9A-Za-z]{12}/g