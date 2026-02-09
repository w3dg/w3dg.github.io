+++
date = '2026-02-07T14:52:04+05:30'
draft = false
title = "The command line isn't scary, its damn powerful."
summary = "Most people when starting out in their tech career tend to overlook the possibilities that command line offers. Here's a guide from me on the what and why you should know to be decent at the command line."
tags = ['Guide', 'CLI', 'Unix', 'Bash', 'Shell Scripting']

+++

Most people when starting out in their tech career tend to overlook the possibilities that command line offers. Here's a guide from me on the what and why you should know to be decent at the command line.

## My Motivation for this article

A lot of beginners / new grads (hi there, I am one too!) that I interact with seem to have little to no confidence in interacting with the computer through the shell. 

They might have some experience like that one or two labs at university where they had to compile C programs in the first semester or one associated with a later operating systems course. But apart from the commands like `cd` and `gcc`, which they most likely used at these courses some `npm` or `python` commands to manage their project, they are helpless at the terminal.

Often I will get asked the same questions around the lines of - "How are you so good at the terminal?" or "Holy crap! I don't understand a thing what you did there!".

These are typically asked when I typed out some shell command that uses pipes and three to four commands with different syntaxes, and frankly as much as I would love to explain each piece individually in a normal setting, I am kind of tired of starting from scratch every time. That doesn't mean I will not happily explain from scratch, but I expected some basics to be already known and comfortable with. This often will waste time for the problem at hand and is a sign that to become better you should also be comfortable at the command line.

With that preamble, I am writing this in the hope to help others to get started with the shell. I do not aim to go into a comprehensive detail but I will link all the resources that helped me or that I deem very useful to beginners and experienced alike.

---

Now to focus on to you.

## Why learn the shell?

The shell is just another way you can use your computer. If you actually [look it up](https://en.wikipedia.org/wiki/Shell_(computing)), the concept of a shell is actually very old. It has been around since the near beginning of computers allowing users to give input to the computer at a "[terminal](https://en.wikipedia.org/wiki/Computer_terminal)".

Long gone are the days that there is a single computer that everyone connects to from their "terminal". Instead those terms are somewhat obsolete in their meaning in our everyday usage now.

But being old does not mean its not useful. Instead it's the most useful thing on a computer. Being comfortable at the command line opens up a new way of thinking. You understand the inner workings, the basics of the interface you are presented with and appreciate its simplicity for the power it bestows upon you.

If you are starting out at some internship or a junior / entry-level at a new job in the tech industry, you will most likely observe a lot of the tools used in the industry to ship the product are shell centric. Maybe you need to run a specific script to publish your changes, trigger a build or test things in a VM somewhere up in the cloud.

Here is a use-case of **finding out what are the top 10 users that might be trying to log in to your production server.** You are tasked with identifying them and produce a report for others to analyze. [^1]

```bash
ssh myserver 'journalctl -u sshd -b-1 | grep "Disconnected from"' \
  | sed -E 's/.*Disconnected from .* user (.*) [^ ]+ port.*/\1/' \
  | sort | uniq -c \
  | sort -nk1,1 | tail -n10 \
  | awk '{print $2}' | paste -sd,
# Output 
# postgres,mysql,oracle,dell,ubuntu,inspur,test,admin,user,root
```

If the above looked daunting, its okay! It is doing a lot and at first glance it might scare you as a beginner.

Coming to that earlier "VM somewhere up in the cloud" point, that's exactly when you will feel helpless the most if you are very used to the GUI interface. There are high chances that you will have to connect to it remotely and only have the command line to interact with it. No mouse pointer, no wallpaper, no fancy desktop, no icons. You will then have to somehow parse through millions of lines of logs, do some insane filtering on the contents of a thirty thousand line log file to get to the cause of a  particular error that happened a couple hours ago when you were out for lunch. 

The command line has all the tools that people have used for years to make this sort of job very easy. Know the tools and you will achieve your task in seconds. 

Here is [Dave's (You Suck at Programming) video](https://www.youtube.com/watch?v=Xdhm_XfVS9I) on why you should learn `bash`. 

## Resources

- [Missing Semester - Spring 2026](https://missing.csail.mit.edu/2026/)
- [Missing Semester - 2020](https://missing.csail.mit.edu/2020/)
	- Lectures 1 - Course Overview and The Shell
 	- Lectures 2 - Shell tools and scripting
 	- Lectures 4 - Data Wrangling
 	- Lectures 5 - Command Line environment
 	- Lectures 6 - Git
 	- Lectures 8 - Metaprogramming

- [Joe Collins](https://www.youtube.com/@EzeeLinux/videos)
- [Distrotube](https://www.youtube.com/@DistroTube)
- [Bread](https://www.youtube.com/@BreadOnPenguins/videos)

- I found this [reference](https://www.debian.org/doc/manuals/debian-reference/ch01.en.html) from Debian. Has a lot to cover on various aspects.

- [Dave Eddy (You Suck at Programming)](https://www.youtube.com/@yousuckatprogramming). He also has a [bash course](https://course.ysap.sh) which I highly recommend. Also watching the compilation of the clips is good.


## Work your way up


### Fundamentals

I highly recommend starting out by having fundamental knowledge in the following things.

- `cd`
- `pwd`
	- Absolute Paths
	- Relative Paths
	- File System hierarchy. See `man hier`
- `ls`
	- What are flags?
	- Flags to `ls`
	- What are the different parts of `ls -l` output?
	- What are the first 10 characters of above output?
	- What are file permissions? See `man ls`
- `echo`
- `man` See `man man`
- `touch`
- `mkdir` Look up what the `-p` flag to `mkdir` does. 
- `cat` Pass 1 file path as the argument, pass multiple file paths, what happens? Where does `cat` get its name from? See `man cat`

### Stop using the GUI for File explorer or Finder.

- `cp` Copy a file to a different file or a different location. 
	- What happens if you try to copy a whole directory? 
	- What if the destination file already exists? 
	- Does `cp` stop you? What can you do to make it ask before overwriting files?
- `mv` Move a file to a different location. 
	- How can you use this to rename files? 
	- Again like `cp`, how can you protect yourself against overwriting existing files?
- `rm` Remove files. Not in Trash or Recycle Bin. Just gone. Use cautiously.
- `rmdir` Remove (empty) directories. Does it let you remove non empty directory? How will you use `rm` to remove non-empty directories?
- `ln` 
	- What does linking do? 
	- What is a symbolic link (symlink) and a hard link? 
	- Where can you find number of hard links to a file (See `ls -l` output and `man ls`).
	- If you are really interested, look up what is an inode and how links relate to them.

### Learn the absolute basics of `vim`

You **will** be dropped into `vim` whether you like it or not. Maybe a system does not have any other editors or you are on a remote connection to that machine or some other command (like `git commit`) opened it up for you.

[What you *really* need to know about vim](https://gist.github.com/w3cj/16bd4c9514a5522298f8)

Take `vimtutor` if you really want to use `vim`.

Use another editor like `nano`.

## Start using Pipelines

A powerful concept in the shell is [pipelines](https://www.man7.org/linux/man-pages//man1/bash.1.html#SHELL_GRAMMAR). Essentially they let you connect up two commands to each other and pass in the output of one command to the input of another.

If you are thinking its a very simple concept, yes it is. But this simplicity is power. All the tools which are specialized to be used for one task can now be connected to each other to solve a larger task at hand.

Some commonly used tools for [data wrangling](https://en.wikipedia.org/wiki/Data_wrangling) on the command line are most often used in pipelines.

I highly recommend looking at [Data Wrangling from Missing Semester 2020](https://youtu.be/sz_dsktIjt4?si=M_MlMOD8Dt9Tn0RI).

I'll list some common commands you should be familiar with to manipulate data output from any form into your desired format. Again `man` is your best friend as well as all the resources on the internet and the ones listed above.

- `head` to take the lines from the top of the input, `tail` to take the lines from the bottom of the input. Go ahead and combine them to see how to extract some n-th line of output.
- `find` - Search and output paths of files matching on various criteria. Is it's name is matching against a given pattern? Is it of a certain size? Is it more than 30 days old since it was created?
- `grep` helps you filter out lines of text from the input matching a specific pattern. [Ripgrep](https://github.com/BurntSushi/ripgrep) (`rg`) can be a better alternative interactive use.
- `sed` - Stream editor, lets you edit text like substitutions.
- `cut` - Let's you cut the input into fields based on a delimiter and take out the fields you want from it.
- `tr` - translate characters into another.
- `awk` - Awk is like a programming language in itself and is very good to work with columnar data or data that is semi structured in a columnar way. Many commands above like `grep`, `sed` , `cut`, `head` , `tail` etc. can be replaced with `awk`.
- `jq` - Not part of the coreutils but is a specialized tool for working with JSON data. Does one thing and does it well. [Unix Philosophy](https://en.wikipedia.org/wiki/Unix_philosophy).
- Like `jq`, look into `yq` for working with YAML files and more.
- `sort` - just sorts output :) Has many modes like numeric sorting, month sorting  etc. Also can sort based on some key or column.
- `uniq` - removes repeated lines. Often used in conjunction with `sort` to repeat all instances of the repetitions by sorting the data first.
- `seq` - generates sequences of numbers increasing by one or some given number.
- `xargs` - converts the input into a list of arguments to run a given command with.


Now look again at the pipeline[^1] at the beginning of the article, can you make sense of atleast a vague idea of what it is trying to do?

Here's the somewhat same pipeline to figure out what are the top 10 file extensions in your system three levels deep from the current directory. See if you can make sense of this. Strip away the rest of the line after a part of the command and stop the filtering in the pipelines to see the output midway. Understand how each tool transforms the output for the next.

```bash
find -maxdepth 3 -type f \
	| awk  -F. '{print $NF}' \
	| sort | uniq -c | sort -rn -k1,1 | head -n 10
```

That should give you some foothold to start. Remember the possibilities are endless.


## Scripting

You would probably want to learn a bit of Bash scripting. It can be as simple as a loop with a counter or a simple loop over the files in the directory to execute some command on each of them.

### Conditionals

`if` - tests for some condition. There are a few different ways to test a condition. There is `test` command and `[` binary. These two are the same program with the `[` binary requiring the additional closing `]` as its last argument. There is also the , builtin `[[` to bash. Almost all of these accept the same kind of syntax. 

I will suggest reading through `man [` for all the syntaxes to form **AND**, **OR**, **GREATER THAN**, **LESS THAN**, **EQUALS** and all the other familiar conditions you want alike. You also have the ability to check if a given file path exists, if a variable is unset or empty, and more.

Here is an example to understand the syntax with `if`, `then`, `else` and `elif`.

```bash
a=1
b=2
c=3

if [ $a -gt $b -a $b -gt $c ]; then
        echo "$a is greatest"
elif [ $b -gt $a -a $a -gt $c ]; then
        echo "$b is greatest"
else
        echo "$c is greatest"
fi

# Output
# 3 is greatest
```

### Loops

`for` and `while` let you loop over the parameters you give as input.

```bash
for i in 1 2 3 4 5; do echo $i; done

it=1
while [ $it -lt 5 ]; do echo $it; it=$((it+1)); done
```

The input can be any command substitution or globs.

```bash
for i in $(seq 1 10); do echo $i; done # remember seq generates sequence of numbers
# 1
# 2
# 3
# ...
# 10

for f in ./* ; do echo $f; done
# Output
# ./archetypes
# ./assets
# ...
# ./themes

for f in ./**/*md ; do echo $f; done
# ./archetypes/default.md
# ./content/aoc/2024/day13.md
# ...
# ./content/work.md
```

### Expansions

Look at [Expansion and Brace Expansions](https://man7.org/linux/man-pages/man1/bash.1.html#EXPANSION) in Bash and how you can use them in loops, `cp`, `mv` etc.

Here are some examples.

```bash
# copy file.mp3 to file.mp3.bak
cp file.mp3{, .bak}

# say hi 100 times
for i in {1..100}; do echo hi $i; done

# make 100 directories at once
mkdir dir{1..100}
```

---

Still a work in progress.

Leave any to me feedback on [Bluesky](https://blu.ski/@w3dg) or use the share button below to share it on to Bluesky.

[^1]: The command pipeline is taken from the [course](https://missing.csail.mit.edu/2026/course-shell/) on Missing Semester from MIT. You can find the video and dissect the parts building up to the full command.

