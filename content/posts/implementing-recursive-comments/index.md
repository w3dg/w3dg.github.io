+++
date = '2024-12-01T12:55:42+05:30'
draft = false
title = 'Recursive Comments'
summary = 'Implementing recursive comments in React'
tags = ['recursion', 'react']
+++

## What is recursion?

Now I'm sure most of you will be familiar with recursion already, but
for those who aren't, recursion is a programming concept where a
function calls itself. What? Calls itself? Yes, you heard that right. A
function can call itself, and this is known as recursion.

The most obvious next question is *for how many times?*

Well, you see, until we don't want it to. Its upto us to set the
condition, the \"base case\" as we call it. Until the job is done.

## Why recursion?

There a lot of areas of programming where recursion is used to solve
problems. Some problems look naturally recursive. For example,
traversing a tree, or a graph, or even a linked list.

Now an **important** thing which I must address, there are problems
which can be solved by both iteration and recursion and mostly you can
come up with a iterative solution to the same recursive solution you
wrote. But there are problems which are best solved by recursion and not
by iteration.

Let us see some examples where recursion is used:

-   [Fibonacci
    Series](https://en.wikipedia.org/wiki/Fibonacci_sequence): This is a
    classic example as we add last two numbers in the series, but we can
    also call the same function for getting the last number itself.
    Until, and here here comes the \*base case\*, we reach 1 or 0, we
    are sure of the answer and stop recursing indefinitely.

-   [Tree Traversals](https://en.wikipedia.org/wiki/Tree_traversal):
    Inorder, Preorder, Postorder traversals are all recursive in nature.
    We visit the left child, then the root, then the right child. And we
    do this for every node in the tree. And we stop when we reach a null
    node. Doing it iteratively requires stacks to keep track of the
    nodes which is again important for interviews.

-   [Depth First
    Search](https://en.wikipedia.org/wiki/Depth-first_search): We can
    use recursion to implement DFS. Doing so iteratively will require
    stacks but that is provided implicitly by recursion itself.

-   [Factorial](https://en.wikipedia.org/wiki/Factorial): This is a
    classic example of recursion. We multiply the number with the
    factorial of the number one less than it. And we stop when we
    reach 1. Well for negative values which are not integers, you now
    will have to use some other method to calculate the factorial.

Okay! Enough with these examples. You say we\'ll never get to use
recursion out of these interview style questions. But you see, recursion
is a powerful tool and can be used in many places.

## Recursive Comments

Let\'s take an example of a comments section. We have a comment and then
we have replies to that comment. And then we have replies to those
replies. And so on. This is a recursive structure. You must\'ve seen
these on the internet, here\'s an example from YouTube comments.

![](https://substack-post-media.s3.amazonaws.com/public/images/23bafa54-ded6-490c-a4fd-e490fd1ceab4_1268x604.png)

In my [Hackernews Client](https://nextjs-hn-feed.vercel.app/top) which was made to learn how to use Next.js, inspired by the [example](https://github.com/solidjs/solid-hackernews) that SolidJS provides, I had to implement this recursive comments view. And I did it using recursion.

```json
[{
  id: 40689776,
  level: 0,
  user: 'kgeist',
  time: 1718459211,
  time_ago: '3 months ago',
  content: '<p>&gt;After the team relocated the code to a new location in the FDS,<p>I wonder what the protocol for sending update requests is. It sure must be encrypted? If so, what if the encryption algoritm is weak by modern standards, given Voyager 1 is 46 years old, and can be reverse engineered somehow? I.e. can someone outside of NASA send requests to Voyager to change its code?',
  comments: [Array]
},
{
  id: 40688218,
  level: 0,
  user: 'mrweasel',
  time: 1718438482,
  time_ago: '3 months ago'
  content: '<p>The quality of the build of Voyager and the software is nothing short of amazing.',
  comments: []
},
{
  id: 40689025,
  level: 0,
  user: 'torcete',
  time: 1718450350,
  time_ago: '3 months ago',
  content: '<p>So, a memory chip was damaged? And if that is the case, a cosmic ray did it?<p>[..] &quot;Further sleuthing revealed the exact chip causing the problem, which allowed them to find a workaround. After the team relocated the code to a new location in the FDS, Voyager 1 finally sent back intelligible data on April 20, 2024&quot;',
  comments: []
},
{
  id: 40689798,
  level: 0,
  user: 'cancerboi',
  time: 1718459370,
  time_ago: '3 months ago',
  content: '<p>How did the Voyagers avoid hitting asteroids when exiting the solar system? I thought there was a huge cloud of asteroids surrounding our solar system.',
  comments: [Array]
}]
```

These are the comments on a specific post, they also have a property `comments` which is an array of comments (well sometimes they are empty). And each comment has a `comments` property which is an array of comments. And so on. Boom! Recursion!

So here\'s an actual implementation for recursion now! Instead of calling functions like we used above, we will now use our same `UserComment` component. 

It is important in any recursive case in the function to not call the function again with the **same** arguments. This will lead to an infinite loop. We need to change the arguments in some way. Here we want to render the sub-comments and hence we pass on the sub comments from the original post, until we don\'t have any more sub-comments.

```tsx
function UserComment({ comments }: UserCommentProps) {
  return (
    <div className="space-y-4">
      {comments.map((comment) => {
        return (
          <article key={comment.id}>
            <div className="flex gap-1 items-center mb-2">{/* ... */}</div>

            <div
              className="prose-invert pb-4 break-words"
              dangerouslySetInnerHTML={{ __html: comment.content }}
            ></div>

            {/*Here we check to see if we have more comments (base case)*/}

            {/*And call the same component with a fresh set of comments coming from replies of the original one*/}

            {comment.comments.length != 0 && (
              <UserComment comments={comment.comments} />
            )}
          </article>
        );
      })}
    </div>
  );
}
```

For aesthetic purposes, we can add a margin to left with respect to the \`level\` property from the JSON response, that will give a nice indentation to the comments.

We calculate that on the fly in the \`className\` like so

```
className={`ml-${comment.level * 2}`}
```

Here's our final component:

```tsx
import { CommentType } from "@/app/post/[postId]/page";

import Link from "next/link";

interface UserCommentProps {
  comments: CommentType[];
}

function UserComment({ comments }: UserCommentProps) {
  return (
    <div className="space-y-4">
      {comments.map((comment) => {
        return (
          <article key={comment.id} className={`ml-${comment.level * 2}`}>
            <div
              className="prose-invert pb-4 break-words"
              dangerouslySetInnerHTML={{ __html: comment.content }}
            ></div>

            {comment.comments.length != 0 && (
              <UserComment comments={comment.comments} />
            )}
          </article>
        );
      })}
    </div>
  );
}
```

So this is now what we end up with:

![Recursive Comments](https://substack-post-media.s3.amazonaws.com/public/images/5895c4f5-3351-4597-8e18-5ce78423aa55_1888x777.png)

And that\'s it! We have implemented a recursive comments view using recursion. This is a very powerful tool and can be used in many places. I hope you enjoyed this post and learned something new. Until next time, happy coding! 🚀

## References

-   Hackernews Client - https://nextjs-hn-feed.vercel.app/top
-   Source Code - https://github.com/w3dg/nextjs-hn-feed
-   Solid JS Hackernews - https://github.com/solidjs/solid-hackernews
