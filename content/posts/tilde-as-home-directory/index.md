+++
date = '2025-05-15T12:55:42+05:30'
draft = false
title = 'Why Tilde was chosen as the home directory'
summary = 'To find the origins of ~, we dive into the history of computing'
tags = ['computing', 'history']
+++
## Introduction

When watching a Youtube video on bash scripting randomly, I came across the fact that the tilde (~) is used to represent the home directory in Unix-like operating systems. Not something that I didn't know, but what was more interesting in the information shared was, that in the old days, the `~` and the `HOME` keys were on the **same** key on the keyboard.

Well, that's certainly not the case anymore. `Home` is a separate key and `~` is on the top left. I went on a search. Fortunately, others got the answers before me.

## Terminal, TTY and [ADM-3A](https://en.wikipedia.org/wiki/ADM-3A)

When vim was created, it was designed to be used on a terminal. The terminal that was used was the ADM-3A. The keyboard they used was still QWERTY, but some of the other keys were different. Take a look at the keyboard below.

![ADM-3A Keyboard](./keyboard-layout.jpg "From Unix Stack Exchange https://unix.stackexchange.com/a/34198")

Here is a schematic of the keyboard.

![Schematic ADM-3A Keyboard](./adm3a-keyboard-schematic.svg "Unix Stack Exchange https://unix.stackexchange.com/a/34198")

A couple of changes to notice are, in the top right corner, there was the `HOME` key, used to move the cursor to the beginning of the line (it still does). But it was with the `~` key, so it was chosen to use the `~` key to represent the home directory of the user. 

A  practice in webservers, is to use a directory in the format of `~username` to represent the directory of that user, for eg. `~janedoe` would point to the web server directory for the user `janedoe` 

I think you can still see the webserver directory in the format of `~username` in some places, but it is not as common as it used to be, however a lot of academia websites for universities still use this format. 

`Esc` sits where the modern day `TAB` key is, thus `Esc` was far more accessible and was used to switch modes in vim.

## Vim and `hjkl`

Coming to Vim, notice the `hjkl` keys in the schematic. They have the symbols for the arrow keys! Hence they were chosen as the movement keys and the same stuck. Thus `hjkl` was used to move the cursor in vim. Rest is history.

I think a lot of interesting history is lost in the world of computers. I think it is important to know the history of the things we use, so that we can appreciate them more.

---

## References

- [Unix Stack Exchange - Answer](https://unix.stackexchange.com/questions/34196/why-was-chosen-to-represent-the-home-directory)
- [Vi Stack Exchange - Answer](https://vi.stackexchange.com/questions/9313/why-does-vim-use-hjkl-for-cursor-keys/9329#9329)