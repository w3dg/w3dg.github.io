+++
date = '2025-12-12T20:37:12+05:30'
title = 'Day 8, 2025: The Playground'
summary = "Let us connect some boxes together."
tags = ['advent of code', 'union find', 'data structures']
+++

{{< katex >}}

The Elves try to figure out which **junction boxes** to _connect_ so that electricity can reach every junction box.

So we are given with an input like the following list, which are a collection of `X,Y,Z` points in space.

```
162,817,812
57,618,57
906,360,560
592,479,940
352,342,300
466,668,158
...
425,690,689
```

We are told to use stright line (i.e. Euclidean) distance between the junction boxes as a metric to choose which two boxes to connect. That is all fair and good. The shorter distance will be connected first.

We can get the straight line distances between the pairs with the following iteration over the lines.

```go
for i, v1 := range positions {
    uf.Add(v1)
    for j, v2 := range positions {
        if j <= i {
            continue
        }
        pair := Pair{v1, v2}
        dist := straightLineDistance(pair)
        distances = append(distances, Distance{dist, pair})
    }
}
```

`straightLineDistance` is just a function that returns the euclidean distance between the points in 3D.

$$D\,=\,\sqrt{(x_1-x_2)^2 +(y_1-y_2)^2 + (z_1-z_2)^2)}$$


When any two junction boxes are joined, they form a **circuit**. Now we are told that, if we connect a box to another which is already in a circuit, the new box is part of the circuit as well.

This is enough information to get some intuition on what to use for this problem.

If you have something in mind, i suggest you can try it for the problem. But I will walk you through my solution, which uses _Union-Find_ and solves the problem efficiently for both parts. As you will soon see.

## Union Find

Let's explain the data structure `Union Find` or `Disjoint Sets` a bit more, and let us see how it is applicable for our problem at hand.

Union Find provides an effective way to check whether an element belongs to a set or not and is usually used to make disjoint sets.

As part of union find, we have two operations,

- **Union** - merges two disjoint sets as one set.
- **Find** - lets us find the root to determine if the elements are in same or different sets.

You may now see how these two operations are useful here.

As the junction boxes are connected together, all of the boxes form a _circuit_. And later as we've seen, that if any one of those interconnected boxes connect to a isolated junction box, it becomes a part of that set as well. This sounds a lot familiar like the union and find operations we defined above.

So let's start to work on that and get things setup.

```go
type UnionFind[T comparable] struct {
    parent map[T]T
    rank   map[T]int
}
```

```go
// NewUnionFind initializes a new Union-Find instance.
func NewUnionFind[T comparable]() *UnionFind[T] {
    return &UnionFind[T]{
        parent: make(map[T]T),
        rank:   make(map[T]int),
    }
}
```


We can model the items in the union find sets as items having a parent to itself at first, i.e. it is in its own isolated set. The rank can be used to order the elements.

Hopefully, the code below to add a new element as part of the initialisation, is a bit clear.


```go
// Add inserts a new element into the union-find structure.
func (uf *UnionFind[T]) Add(x T) {
    if _, exists := uf.parent[x]; !exists {
        uf.parent[x] = x // Set itself as parent
        uf.rank[x] = 0   // Initialize rank
    }
}
```

Let us implement `Find(x)`. It should take a look to find the element in our data structure and return an identifier for which set it belongs to.

```go

// Find returns the root of the component containing the element.
func (uf *UnionFind[T]) Find(x T) T {
    if parent, ok := uf.parent[x]; ok {
        if parent != x {
            uf.parent[x] = uf.Find(parent) // Path compression
        }
        return uf.parent[x]
    }
    // If x is not in the parent map, set it as its own parent
    uf.parent[x] = x
    return x
}
```

The above makes use of **path compression**. Instead of a long chain of entries linking to one another as parents, we can directly put the root/head of the set as the parent of the node. This replaces the linked list-like traversal we would have otherwise needed to make with a single lookup.

That said, making `Union(x, y)` should be easy. Just look at the root/head of the two components and make one equal to other's root thereby putting it in the same set.

```go
// Union merges two components together.
func (uf *UnionFind[T]) Union(x, y T) {
    uf.Add(x) // Ensure x is added before union
    uf.Add(y) // Ensure y is added before union

    rootX := uf.Find(x)
    rootY := uf.Find(y)

    // If roots are different, combine the trees
    if rootX != rootY {
        if uf.rank[rootX] > uf.rank[rootY] {
            uf.parent[rootY] = rootX
        } else if uf.rank[rootX] < uf.rank[rootY] {
            uf.parent[rootX] = rootY
        } else {
            uf.parent[rootY] = rootX
            uf.rank[rootX]++
        }
    }
}
```

## Solving part 1

With these set up, we should get started and parse our inputs to be in our new union find data structure.

As we need the shortest distances first to join them together, it will be helpful, if we now pick the pair of points based on their distance from a heap.

I am using [zyedidia/generic/heap](github.com/zyedidia/generic/heap) as a go-to heap implementation.

```go
// import before
import (
    "github.com/zyedidia/generic/heap"
)
// ...

h := heap.From(func(a, b Distance) bool { return a.Value < b.Value }, distances...)
```

We can insert them one by one into our set, merging them if they need to be merged.

```go
for h.Size() > 0 {
    dist, ok := h.Pop()
    if !ok {
        break
    }

    aFind := uf.Find(dist.Points.A)
    bFind := uf.Find(dist.Points.B)

    if aFind == bFind {
        // they are already connected
    } else {
        uf.Union(aFind, bFind)
    }
}
```

Part 1 of the problem tells us to calculate how many groups of distinct sizes are there after 1000 iterations. We can have a little helper function calculate the groups, and their sizes to later pick the top 3 largest ones as asked in the question.

For getting the groups, we merge them into one map based on their root.

```go
// Returns the connected components of the union find.
// Each entry has the head of the group and a list of the components within that group.
func (uf *UnionFind[T]) GetGroups() map[T][]T {
    groups := make(map[T][]T)

    for element := range uf.parent {
        root := uf.Find(element)
        groups[root] = append(groups[root], element)
    }

    return groups
}

```

We can then get the sizes of those groups, based on the map returned from the previous function.

```go
// Returns a map of Size of the group => Number of circuits of that length
func (uf *UnionFind[T]) GetGroupSizes() map[int]int {
    m := make(map[int]int)

    // Create a map to group connected components
    groups := uf.GetGroups()

    // Append each group to the string
    for _, elements := range groups {
        circuitLength := len(elements)

        if v, ok := m[circuitLength]; ok {
            m[circuitLength] = v + 1
        } else {
            m[circuitLength] = 1
        }
    }

    return m
}

```

Getting the top 3 elements from the map returned will give the elements for calculating our answer. I sort the according to the length however you could use a heap here as well. Just make sure to invert the condition to make it a max-heap instead of a min-heap.

```go
m := uf.GetGroupSizes()
s := []int{}
for k, v := range m {
    for range v {
        s = append(s, k)
    }
}
slices.Sort(s)

l := len(s)
threeLargest := s[l-1] * s[l-2] * s[l-3]
fmt.Println("Part 1:", threeLargest)
```

---

## Solving part 2

In part 2, we can clearly see that we are told to continue this process further until we have only one set left and then report back, which two boxes we joined together to make that happen. 

Well now, instead of stopping at 1000 iterations, we can let our solution run, getting the sizes of groups at each iteration.

The moment the group sizes become 1 after a `Union` operation, we take note of the two boxes that were used. As per the question, the product of their X coordinates will be the answer.

Here is the part of the code we need to modify.

```go
aFind := uf.Find(dist.Points.A)
bFind := uf.Find(dist.Points.B)

if aFind == bFind {
    // they are already connected
} else {
    uf.Union(aFind, bFind)
    if len(uf.GetGroups()) == 1 {
        fmt.Printf("Just joined %v and %v to get one single circuit\n", dist.Points.A, dist.Points.B)
        farFromWall = dist.Points.A.X * dist.Points.B.X
        fmt.Println("Part 2:", farFromWall)
        return
    }
}
```

For the entire code, you can [visit](https://github.com/w3dg/advent-of-code/blob/main/2025/day8/x.go) the solutions on my [GitHub](https://github.com/w3dg).

