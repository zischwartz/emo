# Emo
<p><a href="https://travis-ci.org/zischwartz/emo"><img src="https://travis-ci.org/zischwartz/emo.svg?branch=master"></a> <a href="https://www.youtube.com/watch?v=gAotWVmVRS4"><img src="https://img.shields.io/badge/emo-%E2%9C%94%EF%B8%8E_%F0%9F%98%82_%E2%AD%90%EF%B8%8F_%F0%9F%90%96_(totally emo)-blue.svg"></a> <a href="http://choosealicense.com/licenses/mit/"><img src="https://img.shields.io/badge/license-MIT%20License-blue.svg"></a> <a href="https://www.npmjs.com/package/emo2"><img src="https://badge.fury.io/js/emo2.svg" alt="npm version"></a></p>

Convert human unfriendly strings to emoji in your terminal


### What? Why?
There are a lot of human unfriendly strings out there, for instance, UUIDs and SHA1s. 

When you have to work with a couple of these strings, it's manageable; most programmers I know see `f985dab7704a` and remember that as "the one that starts with f9." And tab completion helps. 

But when you start to have tens or hundreds of these strings, it starts to get messy, and we lose the ability to quickly look at some output and see what node/commit/container/image is being referenced.

### Installation
`emo` requires nodejs. Once you've installed node (which now comes bundled with `npm`) you can install `emo` by running

```bash 
npm install -g emo2

```

### Usage

You can pipe stdout to emo, and emo will replace human unfriendly strings with emoji, and store that data to `~/.emo`.

```bash
git log | emo
```

```bash
docker ps | emo
```

Then you can look stuff up in either direction, like so:


```bash
emo f985dab7704a
```

```bash
emo 🐤
```

```bash
docker kill $(emo 👾)
```

![gif](http://fat.gfycat.com/DiligentTalkativeGoldeneye.gif)


### Options

When piping, you can add `-s` to have emo add spacing equivalent to the length of the string being replaced.

```
gitlg | emo -s
```

When you see an emoji and want to know what the hell it's called, you can get [node-emoji's](https://www.npmjs.com/package/node-emoji) name for it with the `-i` option 

```
emo 📠 -i
```

There's also a sample mode, which just returns random emoji, which you can "use" like so:

```
emo sample 10
````

### Caveats

- Unique to you, each emoji is assigned randomly. It'd be cool if they were computed/encoded from the string, but I couldn't figure out a good way to do that without needing to make the replacement many emoji long.
- Some emoji look very similar
- My regex for detecting "human unfriendly strings" leaves a lot to be desired
- You probably shouldn't use this for anything serious, though I'm having a hard time thinking how one even would
- Only tested on a Mac


