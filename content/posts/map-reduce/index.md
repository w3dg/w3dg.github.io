+++
date = '2025-10-12T12:55:42+05:30'
draft = false
title = 'MapReduce'
summary = 'Implementing a simple version of MapReduce'
+++

{{< katex >}}

## Overview of MapReduce

MapReduce is a programming model meant for large scale processing and generating of big datasets on a cluster in a parallel and distributed fashion. Several implementations of MapReduce are available, with Apache Hadoop being one of the most popular.

<!-- <p>
<img src="./map-reduce-schematic-light.svg" class="block dark:hidden" alt="Schematic of the Map Reduce framework showing input data splits, map 
workers, intermediate files, reduce workers, and final output files." />

<img src="./map-reduce-schematic-dark.svg" class="hidden dark:block" alt="Schematic of the Map Reduce framework showing input data splits, map workers, intermediate files, reduce workers, and final output files." />
</p>
 -->
 
> The article below and the code is written by looking at the lab requirements as per [MIT 6.824's Lab 1](https://pdos.csail.mit.edu/6.824/labs/lab-mr.html). You can find the original MapReduce Paper [here](http://research.google.com/archive/mapreduce-osdi04.pdf). A helpful lecture video from the same MIT course is on [YouTube](https://www.youtube.com/watch?v=cQP8WApzIQQ&t=3004s&pp=ygUNbWFwcmVkdWNlIG1pdA%3D%3D). A helpful Computerphile video on the same topic is also on [YouTube](https://www.youtube.com/watch?v=cvhKoniK5Uo).

A crude and simple implentation using Go channels is here, however the original problem set goes about implenting it using IPC fasion using RPC to communicate between workers.

MapReduce consists of the following programming model:

- A `Map()` function that **emits** intermediate `(key, value)` pairs to be picked up by the reduce phase later.
- A `Reduce()` function that **collects** and aggregates the information passed from the `map()` grouped by the `key`.
- An implicit `Shuffle()` procedure takes care of grouping the intermediate emitted values and group them to the correct reducer.
- You can also specify a `Combine()` function that transforms the data similar to a `Reduce()` but is executed on the Mapper before being sent as intermediate data to the actual reduce workers. Often times, this will end up being the same function as `Reduce()`.

With this programming model, several tasks that deal with distributed and large scale data mapping and processing can be expressed in very simple terms.

### Word Count

We can model this as reading the contents of the document and emitting `1` for each time a word is encountered.

On the reducer side, we can group the values by the word from the document (the `key`) and sum up the number of occurences.

<details>
<summary>Pseudocode</summary>

```python
map(documentName):
  documentContents = read(documentName)
  for each word in documentContents:
    emitIntermediate(word, 1)
```

```python
reduce(key, values):
  # values are grouped by key when shuffled
  result = 0
  for each v in values:
    result += int(v)
  
  # output final count
  emit(result)
```
</details>

### Distributed Grep

We can model the `map()` function as emitting a line if the line contains the word we are trying to match against.

The `reduce()` function can be an identity function that just outputs what its input was.

This way we can get the lines where the search term occurs.

<details className="mb-4">
<summary>Pseudocode</summary>

```python
map(documentName, searchterm):
  documentContents = readlines(documentName)
  for each line in documentContents:
    if searchterm in line:
      emitIntermediate(line)
```

```python
reduce(key, line):
  emit(line)
```
</details>

> More examples like count of url access frequency, reverse web-link graph, distributed sort etc. are given in the [original paper](http://research.google.com/archive/mapreduce-osdi04.pdf).


## My MapReduce Implementation in Go

I took some time to write this simple model in Go. MapReduce is supposed to be a simple model to program and it should feel the same way while writing the code. I remember deleting the code I initially had as it was getting a bit complex and I felt it was unnecessary. Sometimes, simplicity is the key.

For this crude and simple map-reduce implementation, I had followed somewhat of the setup that is provided in [Lab 1 of MIT 6.824 problem set](https://pdos.csail.mit.edu/6.824/labs/lab-mr.html).

They provide some starter code and some files which you can use for this lab.

```bash
$ git clone git://g.csail.mit.edu/6.5840-golabs-2025 6.5840
$ # a starter is under src/mr and src/mrapps
```

Using that as a reference, I wrote some of my own simple implementation that does this architecturally the same. 

They provide some text under the `data/` directory, to test your program against. In this case, there are a bunch of texts of classical stories which we can test against.

In a real scenario (and the ones in the MIT lab's code) RPC calls are used for transferring data between workers, I simply use Go's channels.

```
$ ls -1 data/
pg-being_ernest.txt
pg-dorian_gray.txt
pg-frankenstein.txt
pg-grimm.txt
pg-huckleberry_finn.txt
pg-metamorphosis.txt
pg-sherlock_holmes.txt
pg-tom_sawyer.txt
```

### Details

I create a type to handle and pass around the intermediate values:

```go
type KV struct {
    key   string
    value int
}
```

I use the main function to accept files as arguments to the program and we will run the word count against them. Each file will be processed by a single separate `map` worker before passing on the data to the `reduce` worker.

```go
func main() {
    args := os.Args[1:]

    if len(args) < 1 {
        fmt.Println("Pass in files to process")
        return
    }

    fmt.Println(len(args), "files passed")
}
```

Here, `main` is the _coordinator_ or the _master_ as in the MapReduce paper.


We make 2 channels, `mapChan` to send intermediate values to reducers and `mapperDoneChan` to signal that we are done with all the mapping; there will be no more data and are just waiting for the reducers to finish.

```go
mapChan := make(chan KV)
mapperDoneChan := make(chan bool)
```

We can spin off the map workers for all the files in parallel using the `go` keyword.

```go
for _, f := range args {
    go mapWorker(f, &mapChan, mapperDoneChan)
}
```

We expect to get back some data about the words and their count of occurences. This can be modelled using a map. We can pass the result back when we are done reducing over all the data.

```go
resultChan := make(chan map[string]int)

go reduceWorker(&mapChan, resultChan)
```

The next part is crucial. We keep the `mapChan` open until all the mappers are done. We can then signal back that there is no more mapping needed and instead we should now wait for the reduce to finish.

```go
cnt := 0
for cnt != len(args) {
    <-mapperDoneChan
    cnt++
}

// close the intermediate channel to signal that all mappers are done,
// no more sending to reducers is needed.
close(mapChan)
```

We can now wait and receive the result from our reducer on the result channel.

```go
result := <-resultChan
```

I write the output to a file for persistence and testing later.

```go
outfile, err := os.Create("output.txt")
if err != nil {
    log.Println("Could not create output file, length of the count map is", len(result))
}

for k, v := range result {
    fmt.Fprintf(outfile, "%v - %v\n", k, v)
}

outfile.Close()
```

This far, it was all _plumbing code_. A framework like Hadoop will take care of all this file and message passing for us. All we need to do is supply the `map` and the `reduce` functions. 

Let's define them next.

```go
func mapWorker(fn string, intermediateChan *chan KV, mapperDoneChan chan bool) {
    f, err := os.Open(fn)
    if err != nil {
        log.Printf("Could not open file %v", fn)
        mapperDoneChan <- true
        return
    }
    scanner := bufio.NewScanner(f)
    // Set the split function for the scanning operation.
    scanner.Split(bufio.ScanWords)

    for scanner.Scan() {
        word := scanner.Text()
        *intermediateChan <- KV{word, 1}
    }
    if err := scanner.Err(); err != nil {
        fmt.Println("Error reading input file:", fn, err)
    }

    mapperDoneChan <- true
}
```

In the `mapWorker`, I open the file for reading and set the `bufio.Scanner` to scan for each word at a time.

While reading in words, I pass along a struct of `{key: word, value: 1}` into the channel to the reduce worker. This corresponds to the `emitIntermediate(word, 1)` call in our pseudocode.

```go
func reduceWorker(intermediateChan *chan KV, resultChan chan map[string]int) {
    result := make(map[string]int)

    for imdt := range *intermediateChan {
        if v, ok := result[imdt.key]; ok {
            result[imdt.key] = v + 1
        } else {
            result[imdt.key] = 1
        }
    }

    resultChan <- result
}
```

For the reduce worker, I keep track of the counts in a map as they come in from the various mappers over the channel, incrementing their count by 1.

### How it all works

Map workers are spun off for each file provided and they scan the document by words and for each word emit a struct containing word as the $key$ and `1` as the $value$.

The intermediate values are collected over a channel in a Reduce worker which is keeping track of the counts from the different map workers.

In the end, we pass this final map of count of words back to the main goroutine to print the result.

---

## Final results

Running the code the output produced is of the following format.

```
abandon - 3
abandoned, - 1
abandoned - 10
abandoned. - 2
abandoning - 2
abandons - 1
a-barking - 1
abash - 1
...
```

To test out, we can compare our program's output with the Unix `wc` program. We need a sum of all the counts first however. We can do so by using `awk` and pulling the third column from the above output. We can join them back on `+` to form an addition expression. Finally we can pass the expression to `bc` for evaluation.

There is a slight problem, we have a trailing new line and the `tr` command will therefore have an extra `+` at the end which will cause `bc` to yell at a syntax error. We can suffix the entire expression with a 0 to have a fix for our addition.

```bash
$ echo $(cat output.txt | awk '{ print $3}' | tr '\n' '+')0 | bc -ql
```

We can compare this with the total words output from `wc`.

```bash
$ wc -w data/*.txt --total=only
```

Looks like our modelling is correct and our simple implementation works.

```
~/c/m/g/mr main* % ./test-mr-wc.sh
Program output
608645
Output from wc
608645
```

## References and Links

- [MIT 6.824 Lecture](https://www.youtube.com/watch?v=cQP8WApzIQQ&t=3004s&pp=ygUNbWFwcmVkdWNlIG1pdA%3D%3D)
- [MapReduce Paper from Google](http://research.google.com/archive/mapreduce-osdi04.pdf)
- [MIT 6.824 Lab 1 Details](https://pdos.csail.mit.edu/6.824/labs/lab-mr.html)
- [GitHub Repo containing discussed implementation](https://github.com/w3dg/simple-map-reduce-implementation)
