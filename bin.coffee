#!/usr/bin/env coffee
# require 'coffee-script/register'
Emo = require "./emo.coffee"

process.stdin.resume()
process.stdin.setEncoding 'utf8'

emo = new Emo

process.stdin.on 'data', (data) ->
  process.stdout.write emo.receive data

# process.on 'SIGINT', ->
#   console.log('Got a SIGINT. Goodbye cruel world')
#   process.exit(0)