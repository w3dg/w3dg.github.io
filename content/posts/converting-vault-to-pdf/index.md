+++
date = '2025-06-02T12:55:42+05:30'
draft = false
title = 'Converting my Obsidian Vault to PDFs'
summary = 'How I export my Obsidian vault to PDFs using Pandoc and (more recently) Go.'
tags = ['knowledge management', 'obsidian', 'go']
+++

{{< katex >}}

# About Obsidian and my Workflow

I have been using [Obsidian](https://obsidian.md/) for a while now and have been trying to learn and document my notes to go over them more thoroughly and easily. It allows things to be searchable, and I can link to other topics as well. This way, while I am following a book, I can take notes for each chapter or topic and have them all in one place for revision or quick reference.

Unlike Notion, Obsidian is *local first*, meaning the files are just stored on your computer, and does not require an internet connection. It achieves this by using Markdown files, which are plain text files. As a developer, I am already familiar with Markdown and it helps a lot for quick formatting. Being markdown notes, you can also use the familiar tools that you already know and love. One such tool is [Pandoc](https://pandoc.org/), which is a universal document converter. It can convert Markdown files to various formats, including PDF, HTML, and Word documents.

I had been using Pandoc to convert from Markdown files to PDFs. It does this by an intermediate compilation of Markdown to LaTeX, which is then converted to PDF. It thus requires a working LaTeX installation on your system. I sometimes combine the conversion with the custom template [Eisvogel](https://github.com/Wandmalfarbe/pandoc-latex-template) which sets the style automatically and provides a nice conver page, header, footer and fonts for you. I have a quick one off script that can take any markdown file and convert using the eisvogel template to a PDF which comes in handy for quick exports.

---

Coming to the point, I want the same approach to work on my Obsidian vault. Since the notes are just markdown files, I can use Pandoc. However, a few hoops to jump over first.

- When using Obsidian, if you paste in an image, it gives it a unique name, stores the image in the vault directory and links it using its own syntax. This is not Markdown or Github Flavored Markdown. I tackle this by having a dedicated folder for images and change the name of the image to a more readable name. 
- As I said pandoc is very configurable, and you can use a `yaml` header in your markdown files to specify options for pandoc to pick up for the conversion. I generally do not want these information in my notes but for the final PDF, I want to have the title, author, date and other metadata.

With these two things in mind that we have to do on the fly, I started out to make the process as automated as possible.

At the time when I first had the idea, I was learning Python and wanted to use it for the task. I wrote a script that used Regular Expressions to find and correct the path to images in documents to GFM, prepend the YAML header to the file, save the converted file in a temporary directory, call Pandoc to convert the file and finally save it in a location mimics your vault directory tree structure.

I got away with all the things in Python. 

I read the file, use `re` to find and replace image paths, prepend `yaml` header with up to date metadata, make the temporary directory and all subdirectories mimicking the structure of the vault, call Pandoc to convert the file and finally save it in the correct location while also mimicking the directory structure. A helper shell script I wrote would use `find` to find all markdown files in the vault or filter them by a directory name or a specific file name I specify. It would then call the Python script for each file and convert it to PDF.

# Where Go comes in

All of this worked well, and its not a lot of times I convert my entire vault to PDFs. However when I did, it took a long time. Not that long, it took 1 minute 30ish seconds for almost 70 files. 

I am learning Go at the moment and have finished with [The Tour of Go](https://tour.golang.org/). I wanted to try out Go for this task. Being compiled to a binary meant that it would be faster than Python atleast although most of the job is really done by Pandoc, and Python is fine for the job.

My script would call Pandoc for each file in a for loop where `$1` was the name of directory or file to filter by. :

```bash
for f in $(find -type f -iname '*.md' | grep -i "${1}"); do
    python3 ./convert-image-links-and-to-pdf.py "${f}";
done
```

Soon enough I realized that this is a very inefficient way to do it one by one. Go has a very good concurrency model and it makes it easy to run multiple tasks in parallel. I decided to use goroutines to run the conversion in parallel.

I initially wrote a simple Go program that would take in 1 file at a time and convert it to PDF, that is to say, I first ported the Python script to Go just to see how it would work and get used to the `std` library. Nothing that was used was not in the `std` library. I used the `os` package to read and write files, `regexp` for regular expressions, `path/filepath` to handle file paths and directories, and `os/exec` to call Pandoc, `strings` package for adding the formatted YAML header to the file.

Now my shell script looked like this instead:

```bash
for f in $(find -type f -iname '*.md' | grep -i "${1}"); do
    ./pdf-converter "${f}";
done
```

# Going Concurrent

I was not using goroutines yet, it ran one by one and well, as you can guess, the conversion of one note does not depend on the others. They are parallelizable.

Converting my already written Go program to leverage goroutines took me maybe 5 minutes.

Here is a diff of the changes I made to the Go program:

```diff
diff sequential.go main.go
12a13
>       "sync"
16,17c17,18
<       if len(os.Args) != 2 {
<               fmt.Println("Provide single argument: the file path to convert")
---
>       if len(os.Args) < 2 {
>               fmt.Println("Provide arguments: the path to files to convert")
21c22
<       inputFilePath := os.Args[1]
---
>       inputFiles := os.Args[1:]
22a24,37
>       var wg sync.WaitGroup
>       wg.Add(len(inputFiles))
>
>       for _, inputFile := range inputFiles {
>               go func() {
>                       processFile(inputFile)
>                       wg.Done()
>               }()
>       }
>
>       wg.Wait()
> }
>
> func processFile(inputFilePath string) {
77,78c92,95
<       if err := cmd.Run(); err != nil {
<               log.Fatalf("Error producing pdf for file: %v", markdownFilePath)
---
>
>       err := cmd.Run()
>       if err != nil {
>               log.Printf("Command finished with error for: %v", markdownFilePath)
```

If that is hard to understand from the diff syntax for patching, here is a better visual explanation with `delta`:

![Diff in Delta showing differences from previous sequential code to code using Go routines](./diff.png)

I am really not kidding when I said it took me under 10 minutes to write a concurrent version of the program. I swapped out the single file path for a slice of file paths that would be read from command line arguments, added a `sync.WaitGroup` to wait for all goroutines to finish, and then used a goroutine for each file to process it. The `processFile` function is the same as the previous code, but now it is called in parallel for each file.

There is one catch that did not happen in the original version. You see, one of my files were being failed to be converted. But the rest of them converted just fine. As I was running one file at a time, it did not matter earlier.

The reason that last diff has `log.Printf` instead of `log.Fatalf` in the concurrent version, is that as soon it hit the one problematic file, it would error out and exit from the program. Already running goroutines that had forked off `pandoc` would then not be able to find the files as my shell script cleaned up the temporary directory right after.

Classic rookie mistake. The goroutines will end if the main function ends. As it does with other libraries like `pthreads` in C.

---

## Results

That one change which merely took me 10 minutes to implement, reduced the time taken to convert my vault from 1 minute 30ish seconds to just around 20-25 seconds.

For the particular speedup while converting 66 files (barring the one which errors out), that is: 

$$Speedup = \frac{\textrm{Old time}}{\textrm{New time}} = \frac{85s}{23s} = 3.7$$

This is a significant speedup for such a small change. With larger vaults, the speedup would may be more precisely measured, but I am happy with the results.
I am now using this Go program to convert my Obsidian vault to PDFs. It is fast, efficient, and easy to use. I can now convert my entire vault to PDFs in under 30 seconds, which is a huge improvement over the previous method.

## Conclusion

I have been watching a few videos on Go from [Rob Pike](http://herpolhode.com/rob/) about the language, the concurrency model, how to think in concurrency and Go and I think, I have just started to scratch the surface. As I use it more and learn more about it, I am sure I will find more use cases for it. The simplicity is really key here.

### References and Further Reading
- [Obsidian](https://obsidian.md)
- [Pandoc](https://pandoc.org)
- [Eisvogel](https://github.com/Wandmalfarbe/pandoc-latex-template)
- [Go Homepage](https://go.dev/)
- [The Tour of Go](https://go.dev/tour)
- [Go concurrency patterns](https://www.youtube.com/watch?v=f6kdp27TYZs)
- [Rob Pike's Talk - Concurreny not parallelism](https://vimeo.com/49718712)
