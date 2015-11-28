# process.stdout.write '\u001B[2J\u001B[0;0f'

fs = require 'fs'
basename = require('path').basename
# _ = require 'underscore'
# cheerio = require 'cheerio'
# rimraf = require 'rimraf'
# exec = require('child_process').exec
# spawn = require('child_process').spawn

# matchers = require './matchers'
# Stringer = require '../src/stringer.coffee'

# beforeEach ->
  # jasmine.addMatchers matchers
  # rimraf.sync 'temp/'
  # if not fs.existsSync('temp') then fs.mkdirSync 'temp'

afterEach ->
    # rimraf.sync 'temp/'

describe "Stringer", ->
  it 'should not throw an error when initialized no input', ->
    expect(-> bell = new Stringer() ).not.toThrow()

  it 'should return an array of arrays', ->
    bell = new Stringer get_path(), get_delta_filename('nochange')
    bell.load get_fixture_file_path('nochange')
    result = bell.get_on_with_it()
    expect(_.isArray result.diff).toBe true
    for a in result.diff
      expect(_.isArray a).toBe true


#  "test": "./node_modules/jasmine-node/bin/jasmine-node --coffee --autoTest  spec/ --watchFolders src/ --noStackTrace --verbose --captureExceptions",


# jasmine-node --coffee spec/AsyncSpec.coffee