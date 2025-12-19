+++
date = '2025-12-19T17:52:00+05:30'
draft = false
title = 'Hugo and GitHub Pages'
summary = "I've decided that I do not need React or Next for a blog."
tags = ['GitHub', 'git', 'react', 'knowledge management']
+++

I've decided that I do not need React or Next for a blog or a content heavy site like this for me as a hard and fast rule. My needs are not that custom anyway and . With my previous website hosted on [Vercel](https://vercel.com), along with some of my other sites, I was almost about to hit my [Fast Origin Transfer](https://vercel.com/docs/manage-cdn-usage#fast-origin-transfer) limit. 

## Hugo - A Static Site Generator

Using a static site generator which has a lot of themes available makes it easy by not having me think about styling or functionality. You just focus on the content and everything is built out to plain HTML, CSS, JS automatically without requiring much thought. And everything is fast and simple, pages load instantly and you are not locked into one cloud provider like Vercel and similarly others.

## Moving over should be easy

I use Markdown for all of my blog articles. Back when I had a site with [Next.js](https://nextjs.org) and [React](https://react.dev), I was using [MDX](https://mdxjs.com/). Combined with Next.js, it allows you to write normal page routes as markdown, import and embed React components and run transformations on the AST before previewing it in the browser. I had a few custom components and some transformations for links, images and typesetting with [Katex](https://katex.org) but all of these needs are handled by Hugo itself. 

As for the content itself, it was plain markdown with some React component syntax on top, so I stripped the articles of the syntax and I was up and running with Hugo in about half an hour.

## Knowledge management

Recently as I was looking around on the Internet, I came across some of the notes by [rwxrob](https://rwxrob.GitHub.io/). One of the pieces in the section [**Knowledge Management**](https://rwxrob.github.io/autodidactic/#_knowledge_management) seemed to dawn on me.

> What is likely to remain are domains like `GitHub.io` that millions of people depend on being there for as long as GitHub exists. There is zero practical advantage over the several domains that are from services that are completely and perpetually free (like `github.io`).
> [Excerpt from the article here](https://rwxrob.GitHub.io/autodidactic/#_knowledge_management:~:text=What%20is%20likely%20to%20remain%20are%20domains%20like%20github.io%20that%20millions%20of%20people%20depend%20on%20being%20there%20for%20as%20long%20as%20GitHub%20exists.)

There are some good solutions for this type of knowledge management. I will list some that I had looked into before:

- [Quartz](https://quartz.jzhao.xyz) and their workflow with [Obsidian](https://obsidian.md/) with [Git](https://GitHub.com/Vinzent03/obsidian-git)
- [Obsidian publish](https://obsidian.md/publiSsh)

## GitHub Pages

The documentation for the Hugo theme I'm using, [Blowfish](https://blowfish.page/), had an extensive [information section](https://blowfish.page/docs/hosting-deployment/) on hosting and deploying with several providers such as Netlify, GitHub pages, Vercel, etc.

I configured GitHub actions for automatic deployment of a `gh-pages` branch when pushed to `main` branch using the workflows that was provided.

That gives you a site at `usename.github.io`. What I wanted was my custom domain.

I had a bit of a struggle finding things with this step. First I needed to **verify** this domain as per GitHub's policies to be able to then point GitHub pages to this domain in the repository settings. That is a crucial part - in the _repository_ settings. However whenever I tried to verify the domain, it failed. I asked Claude and ChatGPT but they kept on suggesting that I contact support as they are the ones who can release the domain on their side which will let me add the verification TXT record on my domain for them to verify.

### Helpful Support Chat

And so I opened a ticket on GitHub's portal. I provided them details about the current DNS settings that I had, making sure I pointed GitHub's servers to my domain and configured them properly so that `www.username.github.io` would automatically redirect to `username.github.io`.

Within a few hours, they reached back, to me clarifying that the domain challenge verification was to be done in _user profile_ settings, after which it would be available to me in repository settings.

And so I did that, and all was set.

## Automating 

In order to save future me from remembering and doing specific steps again, I wrote a [Makefile](https://www.gnu.org/software/make/manual/make.html).

```makefile
.PHONY: serve content commit-and-deploy theme-update

serve:
    hugo server -D
content:
    @echo Try any of the following -
    @echo hugo new content content/posts/filename.md
    @echo hugo new content content/posts/dirname/index.md
    @echo hugo new content content/page.md
push-and-deploy:
    git switch main # ensure on main branch
    rm -rf public/ &2>/dev/null # delete public folder if there, it will be generated on the actions.
    git push origin main
    # wait for actions to complete and publish to gh-pages branch
theme-update:
    hugo mod get -u
```

Now I just author the content, preview with `make serve`, add the changes to Git and make a commit using [conventional helper](../on-a-conventional-commits-helper), and then deploy with `make push-and-deploy`.
