#!/usr/bin/env coffee


zxc = require "zxcvbn"

# console.log "hey"
thresh = 5

process.stdin.resume()
process.stdin.setEncoding 'utf8'
process.stdin.on 'data', (data) ->
  result = ""
  console.log "DATA : ", data.length
  splits = data.split(" ")
  for s in splits
    if zxc(s)["guesses_log10"] > thresh
      s = s.toUpperCase()
    # console.log s, zxc(s)["guesses_log10"]
  # for d in data
    # console.log "-"
    result+=s+ " "
    # console.log data
  process.stdout.write result


process.on 'SIGINT', ->
  console.log('Got a SIGINT. Goodbye cruel world')
  process.exit(0)