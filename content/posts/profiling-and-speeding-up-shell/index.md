+++
date = '2024-12-29T12:55:42+05:30'
draft = false
title = 'Profiling zsh and Speeding up my shell'
summary = 'I fix slow startup, investigate some causes and discuss some alternatives.'
+++

## Measure, measure, measure

The key thing which I have seen around if you are going to do anything performance related is, measurement. Make it a rule to not believe stuff about performance without the measurement about current and after states.

Here I was a bit unhappy with my shell startup speed which was not terribly bad but at times when i need something quick, i would spawn a new terminal tab or a pane and wait for the prompt to come. It didnt take eternity but it was just enough to break the flow of the fingers when you are in speed.

I came across [this post](https://ellie.wtf/notes/profiling-zsh) from [Ellie Huxtable](https://ellie.wtf/) about profiling zsh. She also had written about kind of the same thing. This afternoon i decided to tackle this to some extent.

When I followed the instructions on Ellie's post, to whack a built-in zsh profiler at top of my .zshrc, I got the report. You can try it as so:

```sh
# ~/.zshrc
zmodload zsh/zprof # at the top of the file
zprof # at the end of the file
```

This should spit out a report of what functions and calls were made during the shell startup and what their respective impact was.

![From Ellie's post as I myself forgot to take the screenshot](https://substack-post-media.s3.amazonaws.com/public/images/9c50ac5b-1288-44d5-9b53-9b01aa03f91a_842x578.png)

Another way of finding is to run a bit of for loop in the shell to do
the following:

-   Force the shell to start up interactive despite of being in a subshell with `-i`,
-   `exit `out of the shell without running any command,
-   `time` the entire process each time

```bash
for i in {1..20}; do time zsh -i -c exit; done
```

Do this enough times and you should have the actual total time taken at the end of the time output like in the screenshot where I let it sleep for 2s:

![Look at the last column, it took 2.003s in total](https://substack-post-media.s3.amazonaws.com/public/images/9ab55df4-3674-4e79-b707-393cb2e866ae_1395x175.png)

Here it took 2.003s in total which is reasonable as the actual command was to well, sleep for 2s in the first place, but look at the last column of the `time` output.

## Review and research

So as I pointed out, I figured out from Ellie's post some tips. From her post, i got links to [Alex's post](https://htr3n.github.io/2018/07/faster-zsh/) and [JonLuca's post](https://blog.jonlu.ca/posts/speeding-up-zsh) about the same motive of going fast in zsh.

### One solution - lazyload module

The [zsh-lazyload](https://github.com/qoomon/zsh-lazyload) module, can be used to defer the loading of the command, i.e. here our culprit, `nvm` to load its init script later when it is actually invoked.

Ellie's post goes over this and this might work for you, but this posed a problem for my setup.

There simply was no node or npm commands registered in a new shell as, well, the nvm script didn't run and it didn't set the path up. I would not get it until I run it myself and I was using node and npm all the time so this felt like an extra step in the way though nothing massive. So I had to get some alternative solution.

### Throw Rust at it?

One project that had caught my eye in the past but I never got around to switch to it, is [fnm](https://fnm.vercel.app/) or Fast Node Manager. Written in Rust, it claimed to be fast. We'll soon see how it lives up to its name.

Install it through homebrew (or your preferred package manager on the distro):

```
brew install fnm
```

One difference was that fnm didn't recognize tags like "latest" or "lts" (or maybe I am wrong, I will look at this later), so I took to my *shell-fu* to get the last major version number. 

```sh
fnm ls-remote | tail -1 | tr -d v | cut -d. -f1
```

I installed the latest version with fnm. Not to say now when it works, I have lost my npm global packages which I had installed. No trouble, I installed them from my dotfiles config. Aaaand now its time to actually see what it brought to the table.

## Trying it out (and measure again)

Here is an updated timing output:

![](https://substack-post-media.s3.amazonaws.com/public/images/77d53123-521a-49c2-9705-9ba491704461_1271x764.png)

It now takes **\~0.2s** ! Thats a massive improvement of \~**8x**!

Opening up new shells is a breeze now. I can type as soon as I get the
focus of the new shell. Everything's loaded up already, all the configs,
the correct versions everything.

Fantastic! Enough of tinkering with tools! Back to work!
