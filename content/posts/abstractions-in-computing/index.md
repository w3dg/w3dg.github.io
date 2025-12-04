+++
date = '2024-11-29T12:55:42+05:30'
draft = false
title = 'Abstractions in Computing'
summary = 'A guide to how I manage dotfiles on my system as a developer.'
+++

> This is sort of a summary and thoughts on what I have learnt about OS, from the amazing book OSTEP - Operating Systems, Three easy pieces. [See the online version here](https://pages.cs.wisc.edu/~remzi/OSTEP/).
> I also go into why abstractions are everywhere, how much of it is useful, and how it has become an integral part of our lives.

## Abstractions are everywhere!

Almost everyday as i sit down on the computer, I think to myself that what have we made possible as a human race. We ultimately convinced some metal (silicon) to work at our will and do complex things for us. It has enabled us to have our own world digitally, online and communicate to each other with nothing but some high and low voltages. A very powerful, mminiature computer is now in everybody\'s pocket and has become almost like a native organ to our body and we feel incomplete without it.

But here\'s the thing, most of the times you **don\'t** think about this very fact. You dont think at this deep of a level. You probably just want to get things done and at last edit that word file to finish your essay while listening to music in the background and relax on a fine Sunday afternoon.

## A lot of things do happen but you don\'t feel it

A lot of things happen \"under the hood\" and most of the time its meant for you to not feel it. For example, you don\'t think about the car internals until something breaks down. You dont think about how your computer works very often unless you dig deep and get into the weeds. 

A bookish definition for abstraction from object-oriented programming is to *hide all the unnecessary details and expose only necessary ones.*

#### This \"under the hood\" mechanism is called abstraction. A handy dandy way of saying that \"dont worry how it works, just use it!\"

The way that sometimes I see things in CS, is that its heavy on abstractions and in one way or the other, we are getting good at lying. Yes, **lying**.

The OS wants to **virtualise** every resource. It\'s a ***resource manager***. Its in control of what the processes on top layer sees and what it can or cannot do. It wants to manage everything so that it increases the efficiency, utilisation and throughput of the system. In order to do so, it needs a conceptual view of everything and manages the conceptual view of others.

## Processes

A process to the OS, is just another entry on its process_list and it probably has an associated structure for the process_state. All the relevant registers, PC, stack and heap memory, open files etc. For effective throughput and utilisation, it must switch between all the running processes on the system and give them time to complete their job. This leads to having to discuss about **context-switches**, how the OS can *regain control* and run another or same process and what **scheduling policies** should it follow based on the various needs of the system and a precursory idea about what the system will be useful for. the better we can get our assumptions correct, the better scheduling policies will be and will lead to optimum use and efficiency.

When we need to switch processes, we can save all data about one process, sometimes called the **Process Control Block**, and switch to the stack of another running process. But when do we know to switch processes? How do we regain control of the CPU when some other process is actually using it? This is where the OS sets up abstractions, interrupts and timers that transfer control to the OS, i.e. it **traps** to the OS and let the OS do its thing.

## Memory and Security

While reading and writing to files and memory it must go through the eyes of the OS. What if some offending (or malicious) program were to get hold of a *\"protected\"* file (protections are again conceptual) or some other processes\' memory and cause havoc there? **What if the other process was the OS itself?** Then it would be *really, really* bad if the kernel memory is corrupted. We also virtualise memory by making the process seem like that it has the entirety of memory to itself however its not and mapped to some physical memory. We could implement sharing of data between programs if both progams can talk to the same physical
memory but different virtual memory from their point of view.

The OS takes care of all of this by providing a unified view of the system to the processes and handling all the ***priveleged*** requests through a **system call** from the process which lets it intervene **like a man in the middle** and either allow or disallow stuff from happening.

---

## Abstractions - are you convinced?

So yeah it seems like in whatever you do, you\'re probably getting lied to in the face but thats for the own good. Sometimes we do not want to deal with the details. Developers will make abstractions all the time, whether it be simple extracting away code to a function or reusing that function over again, or create new structures that in the very same way do some **magical** things that we do not need to understand, just use.

Think of hosted deployment services - you just attach the git repo or upload your code and its there online! Within seconds! With a domain and a SSL Certificate so that its HTTPS as well! That wouldn\'t be a lot of pain to setup but its nice that theres this service that does it for you! Okay lets go into the classic example of a library, you can just import it and start using it, without thinking about the implementation or how it works under the hood. Its a good thing that it exists, and can be used by others unless you feel the need to pry it open.

You probably dont go into your local grocery store or local market and think what pains and conditions they had to endure to bring the product here or what stages and transportation the product has undergone, it is all presented in a nice package.

## How much abstraction is good?

[Here is a StackOverflow post](https://stackoverflow.com/questions/2668355/how-much-abstraction-is-too-much) discussing the topic.

And here is an interesting take on it, taken from the links in [this answer](https://stackoverflow.com/a/2668641/13168983) on SO:

> A humorous Internet memorandum, RFC 1925, insists that:
>
> (6) It is easier to move a problem around (for example, by moving the problem to a different part of the overall network architecture) than it is to solve it.
> 
> (6a) (corollary). It is always possible to add another level of indirection.

## "It is always possible to add another level of indirection."

And hence the ultimate decision depends upon the usage, experience and seeing the overall benefit that it would have in the long run. Whether it would be feasible or not to build that extra abstraction layer or that extra tool that provides the abstraction by automation and reducing workload (presumably), is a burning question. [Here is another excerpt](https://thorstenball.com/blog/2020/08/25/but-does-it-help-you-ship/) regarding these **\"toolsmiths\"** who like to contribute to the ever growing internal toolchain.

> If what I consider working on is not the thing we want to ship itself, but lies in the vast grey area of software projects where I could write code all day long without the user ever noticing, this question helps me decide whether to drop it or invest some time in it - *does it help me ship?*
>
> It's another process, another tool, another automated piece in our machinery. Another thing that needs to be fixed when it ultimately breaks down, another bit of automation that works 99% of the time, but starts making funny noises when you slip into the 1% and, say, moved a TODO down five lines by accident and don't want the bot to close and re-open tickets, kicking off another wave of notifications.

In his thought, [Thorsten](https://thorstenball.com/blog/2020/08/25/but-does-it-help-you-ship/) wanted a bot that would automatically raise tickets for every `TODO` in the codebase so that it becomes easy to track in the project management tool. However there are a lot of caveats with it and here is the important highlight, *when it will ultimately break, who will bother fixing it?*

The modern dev experience is just abstractions over abstractions and this is the fundamental thing in software engineering.
