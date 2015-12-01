# Emo
## Convert human unfriendly strings to emoji in your terminal

## What? Why?
There are a lot of human unfriendly strings out there, for instance, UUIDs and SHA1s. 

When you have to work with a couple of these strings, it's manageable; most programmers I know see `f985dab7704a` and remember that as "the one that starts with f9." And tab completion helps. But when you start to have tens or hundreds of these strings, it starts to get messy, and we lose the ability to quickly look at some output and see what node/commit/container/image is being referenced.

## Installation
`emo` requires nodejs. Once you've installed node (which now comes bundled with `npm`) you can install `emo` by running

```bash 
sudo npm install -g emo

```

## Usage

You can pipe stdout to emo, and emo will replace human unfriendly strings with emoji, and store that data to `~/.emo`.

```bash
git log | emo
```

```bash
docker ps | emo
```




```bash
emo f985dab7704a
```

```bash
emo 🐤
```

```bash
docker kill $(emo 🐤)
```

## Caveats

- Unique to you, each emoji is assigned
- Some emoji look very similar
- My regex for detecting "human unfriendly strings" leaves a lot to be desired. 
