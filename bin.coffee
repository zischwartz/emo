#!/usr/bin/env coffee
# require 'coffee-script/register'
Emojify = require "./emojify.coffee"

process.stdin.resume()
process.stdin.setEncoding 'utf8'

emojify = new Emojify

process.stdin.on 'data', (data) ->
  process.stdout.write emojify.receive data

# process.on 'SIGINT', ->
#   console.log('Got a SIGINT. Goodbye cruel world')
#   process.exit(0)