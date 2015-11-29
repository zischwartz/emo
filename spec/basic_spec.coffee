# process.stdout.write '\u001B[2J\u001B[0;0f'

fs = require 'fs'
path = require 'path'
basename = require('path').basename
# exec = require('child_process').exec
# spawn = require('child_process').spawn

_ = require 'underscore'

Emojify = require "../emojify.coffee"

# we're testing, so write the file here instead
process.env["HOME"] = process.env["PWD"]


# beforeEach ->
  # jasmine.addMatchers matchers
  # rimraf.sync 'temp/'
  # if not fs.existsSync('temp') then fs.mkdirSync 'temp'

beforeEach ->
  try
    fs.unlinkSync path.join process.env["HOME"], '.emo'


describe "At the very least, Emojify", ->
  it 'should write the .emojify.json file', ->
    expect(-> 
      emojify = new Emojify()
      fs.statSync('.emo')
    ).not.toThrow()

  it 'should not throw an error when initialized', ->
    expect(-> emojify = new Emojify() ).not.toThrow()

  it 'should read an empty .emo file and load it', ->
    emojify = new Emojify()
    res = ""
    expect(->  res = emojify.get_store() ).not.toThrow()
    expect(res).toEqual({})
    

describe "Emojify.detect", ->
  it 'should return an array, either empty or containing one or more strings', ->
    emojify = new Emojify()
    res = emojify.detect("blah some text")
    expect(_.isArray res).toBe true

  it 'work with one line of `docker ps` output', ->
    emojify = new Emojify()
    res = emojify.detect """6d6a0c7f7874        jupyter/tmpnb                     "python orchestrate.p"   2 days ago          Up 2 days                                          beaea38e-bcd4-482f-8dba-01e96bb90288-n1/tmpnb"""
    expect(_.isArray res).toBe true
    expect(res.length).toBe 2
    expect(res[0]).toEqual "6d6a0c7f7874"
    expect(res[1]).toEqual "beaea38e-bcd4-482f-8dba-01e96bb90288-n1/tmpnb"

  it 'does not match urls that start with http', ->
    emojify = new Emojify()
    res = emojify.detect """Name: 39cbe55d37a4   https://gist.github.com/runemadsen/3bcd411a64ba06619b44"""
    expect(_.isArray res).toBe true
    expect(res.length).toBe 1
    expect(res[0]).toEqual "39cbe55d37a4"

  it 'does not include quotes or punctuation (other than hyphens)', ->
    emojify = new Emojify()
    res = emojify.detect """var namespace = "e75a36a9-3323-40dd-a7d1-1c57ad2aa3cd";"""
    expect(_.isArray res).toBe true
    expect(res.length).toBe 1
    expect(res[0]).toEqual "e75a36a9-3323-40dd-a7d1-1c57ad2aa3cd"


describe "Emojify.recieve", ->
  it 'should return the input with emoji replacing tokens, including repeats', ->
    emojify = new Emojify()
    res = emojify.receive("blah some 328be45c870c text")
    console.log "\n"
    console.log res
    console.log "\n"
    expect(_.isString res).toBe true
    expect(res.length).toBeLessThan("blah some 12345 text".length);

    emojify = new Emojify()
    res2 = emojify.receive("blah dd5a83397d84 some 328be45c870c text")
    expect(_.isString res2).toBe true
    console.log "\n"
    console.log res2
    console.log "\n"
    expect(res2.length).toBeLessThan("blah 12345 some 12345 text".length);


    # TODO write test for line breaks, why it needed trim

    # bell = new Stringer get_path(), get_delta_filename('nochange')
    # bell.load get_fixture_file_path('nochange')
    # result = bell.get_on_with_it()
    # expect(_.isArray result.diff).toBe true
    # for a in result.diff
      # expect(_.isArray a).toBe true


#  "test": "./node_modules/jasmine-node/bin/jasmine-node --coffee --autoTest  spec/ --watchFolders src/ --noStackTrace --verbose --captureExceptions",


# jasmine-node --coffee spec/AsyncSpec.coffee