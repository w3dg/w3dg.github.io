+++
date = '2024-01-22T12:55:42+05:30'
draft = false
title = 'Dotfiles and How I manage them'
summary = 'A guide to how I manage dotfiles on my system as a developer.'
tags = ['dotfiles', 'shell scripting', 'personalization']
+++

## Introduction

> Dotfiles are the configuration files for your system. It is what makes your `$HOME`, to `$HOME sweet $HOME`, basically your personalised settings.

In this blog, I will try to explain how my dotfiles are setup, and some settings/configurations I have. You can find a current copy of my dotfiles [here](https://github.com/w3dg/dotfiles).

### Update 2024

I now primarily work on Linux. This was made when I was working on Windows. Although most tools are cross platform carry over, I suggest looking at [new dotfiles](https://github.com/w3dg/new-setup-dotfiles)

---

## Shell

As for the shell i am using `bash`. I am working on Windows for the while and the standard installation of <a href="https://git-scm.com/downloads" >Git Bash</a> or <a href="https://learn.microsoft.com/en-us/windows/wsl/about" >WSL</a> works fine for me. A guide to install WSL can be found from Microsoft <a href="https://learn.microsoft.com/en-us/windows/wsl/install" >here</a>. As well as i have picked up and learnt my way through bash and the command line in general and hence i stick to it.

I have tried out <a href="https://zsh.sourceforge.io/" >ZSH</a> and <a href="https://ohmyz.sh/" >`oh-my-zsh`</a> and its great as well. Some suggestions are to use with <a href="https://github.com/zsh-users/zsh-autosuggestions" >zsh-autosuggestions</a> package and <a href="https://github.com/zsh-users/zsh-syntax-highlighting" >zsh-syntaxhighlighting</a> package.

---

### Bash Config (`.bashrc`)

Customising bash requires you to edit your `.bashrc` file located in your home directory typically denoted by `~`.

Here's a top level view of what i have in my .bashrc

```bash
eval "$(dircolors -b ~/.dircolors)"
```

This evaluates dircolors for the ls command.

```bash
source ~/.bash/bindings.bash       # Bindings
source ~/.bash/shopts.bash         # Shopts
source ~/.bash/exports.bash        # Exports
source ~/.bash/functions.bash      # Custom functions
source ~/.bash/aliases.bash        # Aliases
source ~/.bash/git_aliases.bash    # Git aliases
```

These are various keybindings, shell options, exports of environment variables, custom functions and aliases which i have enabled.

### Useful Bindings

```bash
bind '"\e[A": history-search-backward'
bind '"\e[B": history-search-forward'
```

These will allow you to press the up key after typing a command to search your history to let you see the previous ways you had used it which is useful if you forgot the certain way you used a command before.

There are more, check out my dotfiles or anyone else's or research on the interet to find more!

### Useful functions

```bash
ex()
{
  if [ -f "$1" ] ; then
    case $1 in
      *.tar.bz2)   tar xjf $1   ;;
      *.tar.gz)    tar xzf $1   ;;
      *.bz2)       bunzip2 $1   ;;
      *.rar)       unrar x $1   ;;
      *.gz)        gunzip $1    ;;
      *.tar)       tar xf $1    ;;
      *.tbz2)      tar xjf $1   ;;
      *.tgz)       tar xzf $1   ;;
      *.zip)       unzip $1     ;;
      *.Z)         uncompress $1;;
      *.7z)        7z x $1      ;;
      *.deb)       ar x $1      ;;
      *.tar.xz)    tar xf $1    ;;
      *.tar.zst)   unzstd $1    ;;
      *)           echo "'$1' cannot be extracted via ex()" ;;
    esac
  else
    echo "'$1' is not a valid file"
  fi
}
```

This allows to extract given almost any sort of compressed file which is useful as I do not need to remember which command to use specifically.

```bash
mkcd() {
  mkdir $1 && cd $1
}
```

This function makes a directory and drops you into it all at once.

A great resource I had found for my git aliases is the `oh-my-zsh` repo - <a href="https://github.com/ohmyzsh/ohmyzsh/blob/master/plugins/git/git.plugin.zsh" >git.plugin.zsh</a>

For some bling in the terminal, this line displays a ascii cow saying a random quote each time i open a terminal. This uses the [fortune](<https://en.wikipedia.org/wiki/Fortune_(Unix)>) and [cowsay](https://en.wikipedia.org/wiki/Cowsay) programs with the Tux Cowfile.

```bash
fortune | cowsay -f tux
```

The next 3 lines allow for utf8 input and output in the terminal.

```bash
# Allow UTF-8 input and output, instead of showing stuff like $'\0123\0456'
set input-meta on
set output-meta on
set convert-meta off
```

Given all this custom settings and more you would obviously want to back them up and use it across machines or if you have a new machine.

---

## How to manage the various dotfiles across machines?

Typically on Linux, people will symlink their dotfiles kept in some other directory, generally under version control, to their home directory where everything should exist to allow the programs to pick the settings up.

So, you will see people doing this,

```bash
DOTFILES=(.bash_profile .gitconfig .gitignore)

# Remove old dotfiles and replace them
for dotfile in $(echo ${DOTFILES[*]});
do
    rm ~/$(echo $dotfile)
    ln -s ~/dotfiles/$(echo $dotfile) ~/$(echo $dotfile)
done
```

This code snippet above is a for loop in bash which loops through the given array of dotfiles and links them to the home directory.

Given on linux, this works very fine.

So granted I'm using Git Bash on Windows, it should work on Windows as well right?

The sad answer is no, even though there is a `ln` command, it doesn't seem to do anything. [Enabling symlink option](https://gist.github.com/huenisys/1efb64e57c37cfab7054c65702588fce?permalink_comment_id=4190996#gistcomment-4190996) while installing looks to do the trick.

Anyway I decided to tackle this and write powershell script which does the same for me.

Heres that script,

```powershell
$dotfiles = (".bashrc", ".bash_profile", ".dircolors", ".gitconfig", ".gitconfig", ".inputrc", ".npmrc", ".bash")

foreach ($element in $dotfiles) {
  echo Linking $element
  New-Item -path $HOME\$element -itemType SymbolicLink -target $HOME\code\dotfiles\$element
}

```

This does the same thing and now the files are correctly linked to the other directory under version control. And that directory is very much my dotfiles repository.

---

### Some modern replacements

Some of the commands have modern replacements (mostly in rust these days) and some extra commands that I install and use for my day to day. These are also included in my dotfiles to run instead of the standard commands. Lets take a brief look over them.

- [7zip](https://7-zip.org/) - For working with archives
- [bat](https://github.com/sharkdp/bat) - A better `cat`
- [bc](https://www.gnu.org/software/bc/bc.html) - GNU `bc` the calculator
- [delta](https://dandavison.github.io/delta/) - For better diffs
- [exiftool](https://exiftool.org) - Viewing and editing metadata
- [eza](https://github.com/eza-community/eza) - A modern, maintained replacement for ls, built on exa
- [fd](https://github.com/sharkdp/fd) - Alternative to `find`
- [ffmpeg](https://ffmpeg.org) - A complete, cross-platform solution to record, convert and stream audio and video
- [glow](https://github.com/charmbracelet/glow) - Markdown reader for the terminal with a TUI
- [hexyl](https://github.com/sharkdp/hexyl) - Hex viewer, which uses colored output.
- [jq](https://jqlang.github.io/jq) - Lightweight and flexible command-line JSON processor
- [micro](https://micro-editor.github.io) - A terminal-based text editor that aims to be easy to use and intuitive
- [ngrok](https://ngrok.com) - For forwarding servers onto open internet.
- [pandoc](https://pandoc.org) - Universal markup converter
- [ripgrep](https://github.com/BurntSushi/ripgrep) - Better `grep`. Recursively searches directories for a regex pattern.
- [tokei](https://github.com/XAMPPRocky/tokei) - Count lines of code
- [tre-command](https://github.com/dduan/tre) - Improved Tree command
- [zoxide](https://github.com/ajeetdsouza/zoxide) - A faster way to navigate your filesystem

I set some of these as aliases to original commands as replacements. You can view them in my aliases [here](https://github.com/w3dg/dotfiles/blob/main/.bash/aliases.bash).

Thats about it for the setup. I might later do a dev setup blog soon going over the tools and technologies I use.

### References

- [My dotfiles](https://github.com/w3dg/dotfiles)
- [A collection of popular dotfiles setups](https://dotfiles.github.io/inspiration) I have taken a lot of inspiration and things from these
