+++
date = '2025-01-19T12:55:42+05:30'
draft = false
title = 'Backup Script'
summary = 'Taking backups of my machine with help from a script'
tags = ['backups', 'mac', 'linux', 'shell scripting']
+++

I keep a backup somewhat regularly and especially when I want to wipe and reinstall my OS once in a while (although it\'s very rare, and mostly I stick to Ubuntu distributions).

One issue that I have when I backup, is that the file permissions, get lost when I copy them to my 1TB Seagate HDD which is formatted with ExFAT as I want it to show up on both Windows and Linux and all others alike.

Recently I came across, [a backup script on Ellie's wiki](https://ellie.wtf/posts/my-backup-script) which is using `tar` to make `tar.gz` archives along with flags to permissions and ignore a bunch of local directories to skip while archiving.

Let's try this.

---

Supposing my test folder is `~/code/tmp` which is where I keep a lot of well.. `tmp` things, I planned to archive this with some changed permissions such as a directory with no executable access, making it not possible to cd into, an executable shell script etc.

```bash
$ ls -la

total 10560
drwxrwxr-x  6 dg dg     4096 Jan 18 23:54 .
drwxr-xr-x 35 dg dg     4096 Jan 18 13:43 ..
drwxrwxr-x  2 dg dg     4096 Jan 11 20:33 beamer-latex
drwxr-xr-x  4 dg dg     4096 Jan 11 17:33 Eisvogel-3.0.0
-rw-r--r--  1 dg dg 10783082 Jan 11 20:35 Eisvogel-3.0.0.tar.gz
-r-xr-xr-x  1 dg dg       31 Jan 18 23:54 ex.sh
drw-rw-r--  2 dg dg     4096 Jan  1 22:41 testpaper
drwxrwxr-x  3 dg dg     4096 Jan 11 00:58 updog2
```

[Here is the original script](https://ellie.wtf/posts/my-backup-script), which is MacOS specific, so on Linux some other exclusions might be useful.

```bash
BACKUP=backup-macbook-$(date +%FT%H:%M:%S).tar.gz

tar -cvpzf $BACKUP \
    --exclude=$BACKUP \
    --exclude=.cache \
    --exclude=.debug \
    --exclude=.local/lib \
    --exclude=.local/share/virtualenvs \
    --exclude=.recently-used \
    --exclude=.thumbnails \
    --exclude=.pyenv \
    --exclude=.Trash \
    --exclude=.npm \
    --exclude=.poetry \
    --exclude=.kube \
    --exclude=.fastlane \
    --exclude=.mix \
    --exclude=.pyenv \
    --exclude=.gem \
    --exclude=.vscode \
    --exclude=.cocoapods \
    --exclude=Downloads \
    --exclude=Library \
    --exclude=Movies \
    --exclude=Music \
    --exclude=nltk_data \
    --exclude=Pictures \
    --exclude=pkg \
    --exclude=Applications \
    .
```

Let's try this out.

Here I ignore [updog2](https://pypi.org/project/updog2/), which is my local installation of a more maintained version of updog which I sometimes use to host my local computer and access on my phone or other local devices.

A simple search on PyPI also showed [updog3](https://pypi.org/project/updog3/), i might look that up later.

```bash
BACKUP=backup-test-$(date +%FT%H:%M:%S).tar.gz
tar -cvpzf $BACKUP \
    --exclude=$BACKUP \
    --exclude=updog2 \
    .
```

It failed on a non writable directory with my user. I think I should
actually have access to the directory if its owned by me, so the new
permissions of that directory is as follows. The owner has all
permissions to read, write and execute into directories.

```
total 28
drwxrwxr-x  6 dg dg 4096 Jan 19 00:19 .
drwxr-xr-x 35 dg dg 4096 Jan 18 13:43 ..
drwxrwxr-x  2 dg dg 4096 Jan 11 20:33 beamer-latex
drwxr--r--  4 dg dg 4096 Jan 11 17:33 Eisvogel-3.0.0
-r-xr-xr-x  1 dg dg   31 Jan 18 23:54 ex.sh
drwxr--r--  2 dg dg 4096 Jan  1 22:41 testpaper
drwxrwxr-x  3 dg dg 4096 Jan 11 00:58 updog2
```

Okay it completed to give this:

```
-rw-rw-r-- 1 dg dg 11327475 Jan 19 00:22 backup-test-2025-01-19T00-22-59.tar.gz
```
Okay copying it to my HDD and back again clearly messed up my
permissions (notice all the executable bits and stuff)

```
.rwxr-xr-x   11M dg   19 Jan 00:22  backup-test-2025-01-19T00-22-59.tar.gz
```

Doing a `tar xzvf <file>.tar.gz` seemed to go on normally as expected and preserved permissions, so I am back with original file permissions. The directory still does not have group and world write perms and my script is not writable.

```
total 11088

drwxrwxr-x  5 dg dg     4096 Jan 19 00:19 .
drwxr-xr-x 35 dg dg     4096 Jan 19 00:24 ..
-rwxr-xr-x  1 dg dg 11327475 Jan 19 00:22 backup-test-2025-01-19T00-22-59.tar.gz
drwxrwxr-x  2 dg dg     4096 Jan 11 20:33 beamer-latex
drwxr--r--  4 dg dg     4096 Jan 11 17:33 Eisvogel-3.0.0
-r-xr-xr-x  1 dg dg       31 Jan 18 23:54 ex.sh
drwxr--r--  2 dg dg     4096 Jan  1 22:41 testpaper
```

To further encrypt stuff which is possibly wanted, we can use GPG as a handy tool for encryption:

```
gpg --symmetric --cipher-algo AES256 $BACKUP
```

It will ask for a passphrase twice and then spit out a `.gpg` file.

```
.rw-rw-r-- 11M dg 19 Jan 00:35 backup-test-2025-01-19T00-34-31.tar.gz.gpg
```
Decrypting the encrypted archive with gpg:

[Syntax from Superuser](https://superuser.com/questions/89914/how-to-extract-a-gpg-file)

```bash
gpg --output destination --decrypt sourcefile.gpg
```

So for example on my archive

```bash 
$ EXTRACTED=backup-test-2025-01-19T00-34-31.tar.gz
$ gpg --output $EXTRACTED --decrypt $EXTRACTED.gpg
gpg: AES256.CFB encrypted data
gpg: encrypted with 1 passphrase
```

Then extract the \`tar.gz\` file normally,

```bash
tar xvf $EXTRACTED
```