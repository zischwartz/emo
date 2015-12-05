# process.stdout.write '\u001B[2J\u001B[0;0f'

fs = require 'fs'
path = require 'path'
basename = require('path').basename
# exec = require('child_process').exec
# spawn = require('child_process').spawn

_ = require 'underscore'

Emo = require "../emo.coffee"

# we're testing, so write the file here instead
process.env["HOME"] = process.env["PWD"]

beforeEach ->
  try
    # delete the .emo file if it exists before each test
    fs.unlinkSync path.join process.env["HOME"], '.emo'


describe "At the very least, Emo", ->
  it 'should write the .emo.json file', ->
    expect(-> 
      emo = new Emo()
      fs.statSync('.emo')
    ).not.toThrow()

  it 'should not throw an error when initialized', ->
    expect(-> emo = new Emo() ).not.toThrow()

  it 'should read an empty .emo file and load it', ->
    emo = new Emo()
    res = ""
    expect(->  res = emo.get_store() ).not.toThrow()
    expect(res).toEqual({})
    

describe "Emo.detect", ->
  it 'should return an array, either empty or containing one or more strings', ->
    emo = new Emo()
    res = emo.detect("blah some text")
    expect(_.isArray res).toBe true

  it 'work with one line of `docker ps` output', ->
    emo = new Emo()
    res = emo.detect """6d6a0c7f7874        jupyter/tmpnb                     "python orchestrate.p"   2 days ago          Up 2 days                                          beaea38e-bcd4-482f-8dba-01e96bb90288-n1/tmpnb"""
    expect(_.isArray res).toBe true
    expect(res.length).toBe 2
    expect(res[0]).toEqual "6d6a0c7f7874"
    expect(res[1]).toEqual "beaea38e-bcd4-482f-8dba-01e96bb90288-n1/tmpnb"

  it 'does not match urls that start with http', ->
    emo = new Emo()
    res = emo.detect """Name: 39cbe55d37a4   https://gist.github.com/runemadsen/3bcd411a64ba06619b44"""
    expect(_.isArray res).toBe true
    expect(res.length).toBe 1
    expect(res[0]).toEqual "39cbe55d37a4"

  it 'does not include quotes or punctuation (other than hyphens)', ->
    emo = new Emo()
    res = emo.detect """var namespace = "e75a36a9-3323-40dd-a7d1-1c57ad2aa3cd";"""
    expect(_.isArray res).toBe true
    expect(res.length).toBe 1
    expect(res[0]).toEqual "e75a36a9-3323-40dd-a7d1-1c57ad2aa3cd"


describe "Emo.recieve", ->
  it 'should retain spacing with -s', ->
    emo = new Emo()
    input = "blah some 9328be45c870c text 1c57ad2aa3cd"
    res1 = emo.receive(input, "-s")
    expect(res1.length).toEqual(input.length)

  it 'should return the input with emoji replacing tokens, including repeats, and persistence', ->
    emo = new Emo()
    res1 = emo.receive("blah some 9328be45c870c text 1c57ad2aa3cd")
    expect(_.isString res1).toBe true
    res1_s = _.filter res1.split(" "), (x)-> x
    [first, second] = [res1_s[2], res1_s[4]]
    expect(first).not.toBeUndefined()
    expect(second).not.toBeUndefined()
    # and, test for persistence
    emo = new Emo()
    res2 = emo.receive("blah dd5a83397d84 | 9328be45c870c some 328be45c870c text 1c57ad2aa3cd b5ut ") # b5ut, testing that we only convert if len > 4
    expect(_.isString res2).toBe true
    res2_s = _.filter res2.split(" "), (x)-> x
    expect(first).toEqual res2_s[3]
    expect(second).toEqual res2_s[7]

