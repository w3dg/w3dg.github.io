+++
date = '2025-01-25T12:55:42+05:30'
draft = false
title = 'Building with AI SDK - Part 1'
summary = "We explore how to interact with LLMs programmatically through Vercel's AI SDK"
+++

The [Vercel AI SDK](https://sdk.vercel.ai/) opens up exciting possibilities for building smarter and more interactive applications. Whether you\'re exploring AI-powered features or integrating seamless response streaming, this SDK has you covered. In this post, we'll dive into the basics of initializing the SDK, working with [Groq](https://groqcloud.com), although you can use sopmething more popular like OpenAI or Gemini, and demonstrating how to generate and stream responses effectively. Let\'s get started! 

## Contents

## Installing Dependencies

```
npm i ai dotenv
```

We\'ll also need a **provider** to talk to which will be hosting our LLM. There are many providers from OpenAI, Google, etc, with their own respective models.

We\'ll be using [GroqCloud\'s](https://groq.com) offering for the model with a free plan. Grab your *API key* from the console. And install the corresponding provider -

```
npm i @ai-sdk/groq
```

### Handling Credentials

We are going to read the contents in from a `.env` file, with the `dotenv` package we installed earlier. So in a file named `.env `paste the following: 

```
GROQ_API_KEY=<your_api_key_goes_here>
```

By default the SDK looks for the env var, `GROQ_API_KEY`. Although, if you want some custom, implementation to create your instance of `groq`, you can use `createGroq()` or similar init function for other providers and create your own implementation, with the configuration to be called later.

We can bring in the environment variable which will be later used and have some error checking on the way. A better way to validate a lot of environment variables to make sure they exist and they are not empty can be made with [zod](https://zod.dev) . 

```tsx
import { config } from "dotenv";

config();

if (process.env.GROQ_API_KEY == undefined || (process.env.GROQ_API_KEY as string).trim().length === 0) {
    console.error("GROQ API KEY Not found");
    process.exit(1);
}
```

## Let\'s get to generating with LLMs

Now with that out of the way, let\'s get to actual work and see how AI-SDK will simplify our workflow by abstracting away the \"*glue*\" between different providers and help us to generate responses from the LLM and *even stream* responses as they become available for better UX ( exactly like how ChatGPT generates part by part).

```tsx
import { generateText, streamText } from "ai";
import { groq } from "@ai-sdk/groq";

const groqModel = groq("gemma2-9b-it");
```

These two helper functions, `generateText` and `streamText` will help us to interact with the model and get responses. We are going to use both of them. To share the same instance of the model, we create a global `groqModel` to be passed on to both implementations. 

### `generateText` the blocking way

```tsx
const textResponse = async () => {
    const { text } = await generateText({
        model: groqModel,
        prompt: "Write a vegetarian lasagna recipe for 4 people.",
    });
    console.log(text);
};

textResponse();
```

We can call the `generateText` function with our model and prompt and expect a response. It will take a few seconds and will be **blocking**, meaning it will be *kind of stuck* and *wait* for entirety of the response to come in. Meanwhile the user will be seeing nothing, or at best we can put a loading screen or something. No immediate feedback or the gradual building up of the answer will be there, as we see on ChatGPT\'s website. This is a key reason why we\'ll be using streaming later for better UX.

![Generating text which is blocking until full response is here](./gen.gif "Generating text which is blocking until full response is here")

### `streamText` the non-blocking way

For streaming, we will use the `streamText` function, which *instead* of returning us the whole text this time, will return the *next token/word* as they become available. We can wait for these as they become available as part of the `stream` and add to the current answer and continue to show the growing answer.

```tsx
const streamResponse = async () => {
    const result = streamText({
        model: groqModel,
        prompt: "Write a 50 word summary on Earth.",
    });

    let response = "";
    for await (const textPart of result.textStream) {
        response += textPart;
        console.clear();
        console.log(response);
    }
};

streamResponse();
```

Let\'s break this down as it\'s a bit more complicated.

The `result` which we get immediately back is a `StreamTextResult` . We can tap into the `textStream` property which is an `AsyncIterable`.

Being `AsyncIterable` means we can now run a `for of` loop through the iterator, and as because its `async`, we can `await` each response to get what they `text-delta`. 

Fear not, `text-delta` is just the partial responses I talked about, i.e. the next token/words instead of the whole response at a time. We keep appending `text-deltas` and continuously clearing the screen and logging the new response so we now see the response build up and grow as expected.

![Streaming text to the frontend as the response arrives](stream.gif "Streaming text to the frontend as the response arrives")

That was an introductory journey into generating with LLMs in our own applications!

# References

- [Vercel AI SDK](https://sdk.vercel.ai/) the official docs for AI SDK
- [Groq](https://groq.com/) a LLM cloud provider
- [Vercel AI SDK Nodejs QuickStart](https://sdk.vercel.ai/docs/getting-started/nodejs) an official quick start of AI SDK Nodejs
