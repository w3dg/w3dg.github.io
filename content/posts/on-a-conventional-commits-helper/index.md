+++
date = '2025-10-23T12:55:42+05:30'
draft = false
title = 'Writing a Conventional Commits Helper'
summary = 'Writing a conventional commits helper using shell scripts and utilities. Why again? Because I can and like the simplicity.'
+++

## Why write another one?

I am aware that there are existing tools that help you author your commit messages in the style of [conventional commits](https://www.conventionalcommits.org). I have myself been using [`cz-git`](https://github.com/Zhengqbbb/cz-git) for a long while when I was first getting into formatting my commit messages better and using conventional commit style. It is a perfectly fine tool and honestly I have looked into how it's working to take inputs in my own shell script which implements the same.

I myself think that while it is good that the CLI I mentioned above has a plugin system that enables different cases to be handled on a per use-case basis, I am using the same thing over and over and can use something more better than JavaScript.

I remember I tried searching for some Go packages to help with this, (and maybe Rust?) but I didn't find anything useful. Hence I set forth to write my own small helper script.

## Few utilities

It is nice to have some utilities and functions to make the repetitive code structure easier to reuse or to just use good tools for input from user.

Some of them are:

- [`gum`](https://github.com/charmbracelet/gum) - A tool from [Charm](https://charm.sh) which provides highly configurable, ready-to-use utilities for writing shell scripts. They have their own little example for writing a conventional commit helper (meta!)
- A little function `check_exists` that checks whether a command is installed and exits otherwise

```bash
check_exists() {
    type "$1" &>/dev/null
    if [[ $? -ne 0 ]]; then
        echo "$1 not found, exiting."
        exit
    fi
}

check_exists "git"
check_exists "gum"
```

- A function `check_added_files` to check whether we have added any files to Git at all before going to commit the changes.

```bash
check_added_files() {
    git status | grep "Changes to be committed" >/dev/null

    if [ $? -ne 0 ]; then
        echo "There are no changes to be committed."
        echo "Did you forget to add?"
        echo "Are you in a valid git repo?"
        exit 1
    fi
}

check_added_files
```

## Conventional Commits

You can find the full specification at [conventionalcommits.org](https://www.conventionalcommits.org/en/v1.0.0/#specification). However for a quick refresher at the different parts is below.

A typical commit structured with conventional commit looks as follows:

```
<type>[optional scope]: <description>

[optional body]

[optional footer(s)]
```

Let us look at the implementation that takes in all the different parts from the user.

## Accessing user input and building the message

### Type

The `type` can be one of some predefined ones. There can be more depending on the project and other adapters. We store them in an array to access them later.

```bash
available_commit_types=(
  "feat" 
  "fix"
  "docs"
  "style"
  "refactor"
  "perf"
  "test"
  "build"
  "ci"
  "chore"
)
```

If you are familiar with `fzf`, you can use `gum choose` or `gum filter` to get a picker for the different types above.

```bash
final_commit_msg=""

selected_commit_type=$(gum filter --header="Type of commit" ${available_commit_types[@]})
if [ $? -ne 0 -o -z $selected_commit_type ]; then
    exit
fi
final_commit_msg=$selected_commit_type
```

### Scope

The `scope` of the commit is optional and must be in brackets after the `type`. We handle the optional case by looking at the return value from the `gum input` command and add it to the commit if provided.

```bash
# Scope of the commit (optional)
selected_scope=$(gum input --header="Scope of the commit (optional)")
if [ $? -ne 0 ]; then
    exit
elif [ -z $selected_scope ]; then
    final_commit_msg="${final_commit_msg}"
else
    final_commit_msg="${final_commit_msg}(${selected_scope})"
fi
```

### Breaking change?

A breaking change **MUST**  have either a note in the footer or a `!` after the `type` and `scope`. We ask whether it is one or not using `gum choose` and looking at the return value from the command which reflects the user's choice.

```bash
# Breaking change
gum confirm "Is this a breaking change?"
is_breaking=$?
if [ $is_breaking -ne 0 -a $is_breaking -ne 1 ]; then
    exit
fi

if [ $is_breaking -eq 0 ]; then
    final_commit_msg="${final_commit_msg}!"
fi
```

> A breaking change should have a note in the footer to be appended in the description. I do not do that here, but it is just one more input before the final confirmation.

### Commit message

Next, we ask the user for the actual commit message. We have a comfortable character limit for easy viewing capped at 50 characters using `--char-limit` flag. This is one of the last time we get to abort the commit by supplying an empty commit message.

```bash
# Commit Message
commit_message=$(gum input --header="Commit message" --char-limit=50)
if [ $? -ne 0 ]; then
    exit
fi

if [[ -z "${commit_message}" ]]; then
    echo "Empty commit message, aborting"
    exit 1
fi

final_commit_msg="${final_commit_msg}: ${commit_message}"
```

### Description

There might be an extended description of the commit which can then be accessed via other git commands. We include them in an input box from the user.

```bash
# Description of the message
description=$(gum write --placeholder "Details of this change")
```

## Confirmation

We confirm the user for the final commit and depending on whether we have a description or not, we add a newline in between for the final commit message.

```bash
if [ ! -z "${description}" ]; then
    gum confirm "Commit changes?" && git commit -m "${final_commit_msg}

    ${description}"
else
    gum confirm "Commit changes?" && git commit -m "${final_commit_msg}"
fi
```

## Demo

Here's a gif for the demo:

![Demo of my script for conventional commits making an initial git commit](./gcz-demo.gif)

![Details of the commit message for the initial commit which is now formatted as per conventional commit.](./gcz-screenshot.png)

## References

- [Conventional Commits](https://www.conventionalcommits.org/)
- [`git-cz`](https://github.com/streamich/git-cz)
- [Code for my script `gcz.sh`](https://github.com/w3dg/new-setup-dotfiles/blob/f17b25032c243f0587ad6bf1f1e234f8e56865fa/bin/gcz.sh)