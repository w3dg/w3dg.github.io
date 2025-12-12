+++
date = '2025-02-15T12:55:42+05:30'
draft = false
title = 'Building with AI SDK 2'
summary = "We explore how to generate structured outputs with LLMs programmatically through Vercel's AI SDK"
tags = ['ai', 'llms', 'vercel']
+++
## Introduction

> This is a part of a series and the previous post can be found [here](https://w3dg.substack.com/p/building-with-ai-sdk-1) where we start to explore text generation and streaming outputs as a basic and gentle introduction to using AI SDK to interact with LLMs.

So far, we have seen how to generate text based output from LLMs. That is probably the most widely used usecase for LLMs and is prevalent on platforms offering solutions like ChatGPT, Gemini, etc. However, we typically have no control over the structure of the data we get back. Even if we tell it, for example, that we want the steps of a recipe in a list form, it isn't really guaranteed although it will likely do a good job at it. We can use somewhat of a different approach to get outputs from the LLM that can have user defined structure.


## Why use structured outputs?

When building an agent for tasks like mathematical analysis or report generation, it\'s often useful to have the agent\'s final output structured in a consistent format that your application can process. We can even force the LLM with a tool call that will always return a structured output, therefore guaranteeing the shape of the data we will be receiving on our side for further processing.

## Before we start using structured outputs

Make sure that you use a model that supports structured outputs. Not all models have the same capabilites. See if your model supports **structured outputs** or the same under another name of **object generation**. 

I will be using Gemini's API with `gemini-1.5-flash `model. You can view their page on [AI Studio](https://aistudio.google.com/app/) how to get hands on an API key ( yes a free tier is available, and the model mentioned is free to use ).

> Benefit of using AI SDK is that we can swap out LLM providers at any point of time without modifying much of the other code we have already written.

```tsx
import { config } from "dotenv";

config();

if (
  process.env.GOOGLE_GENERATIVE_AI_API_KEY == undefined ||
  (process.env.GOOGLE_GENERATIVE_AI_API_KEY as string).trim().length === 0
) {
  console.error("GOOGLE_GENERATIVE_AI_API_KEY KEY Not found");
  process.exit(1);
}

import { google } from "@ai-sdk/google";

const googleModel = google("gemini-1.5-flash");
```

## Defining the structure of our outputs

Let's prepare a prompt that will give us the steps for a recipe. Its a simple one,
```tsx
const prompt = "Write a recipe for cheese sandwich.";
```

We can now use `generateObject` or `streamObject` methods from the SDK to get the structured output in form of an object. We can define which model we will be using, the prompt, and most importantly the schema of the response object we want the model to adhere to.

```tsx
import { generateObject } from "ai";
import { z } from "zod";

const generateRecipe = async () => {
  const { object: recipeData } = await generateObject({
    model: googleModel,
    schema: z.object({
      recipe: z.object({
        name: z.string(),
        ingredients: z.array(z.object({ name: z.string(), amount: z.string() })),
        steps: z.array(z.string()),
      }),
    }),
    prompt,
  });
};
```

Here we are using [zod](https://zod.dev), a Typescript validation library but for defining the schema that our model should adhere to. Here we say that the top level response should be an object with a `recipe` property, which should include a name, an `ingredients` array containing the `name` and `amount` of ingredient, and the `steps` to make the dish should be an array of strings explaining the steps.

This makes it predictable and deterministic that the output from the LLM will adhere to this schema and that enables us to access the data returned with confidence. 

## Accessing the returned data

This is now pretty straightforward, just like accessing any other object data. We can pick and modify the data as we like as it is now an object that adheres to the format. One modification I am making here, is to join the recipe steps from the array into a giant string with newlines. 
```tsx
const recipe = await generateRecipe();

console.log(recipeData.recipe.name);

console.log(recipeData.recipe.ingredients.map((ingredient) => `${ingredient.amount} ${ingredient.name}`).join("\n"));

console.log(recipeData.recipe.steps.join("\n"));
```

That yields us with the output:

![Output image](https://substack-post-media.s3.amazonaws.com/public/images/6c9f16a6-727b-45f6-8c9f-284bf5c94d19_1042x702.png)

## Questions generation - an actual use case example

Let us say that we want to ask the LLM to generate some questions and their multiple choice answers that we can then access in our frontend to make some sort of revision app or flashcards app. Sounds like a nice small usecase right?

In the following example I go over a bit more with the code. There is a **system prompt** along with the actual prompt which will be preceded and followed as instructions by the LLM. These can be helpful when you want the LLM to behave in a certain way no matter what the user asks or no matter what the query is from the other side. Here I set the system prompt to ensure the following:

-   To always generate 4 options as answer choices to the questions.
-   To make all the answer choices of relatively the same length and tone.
-   To not provide much more information in the correct option and less information for incorrect options.
-   To make all options sound and seem equally probable with sufficient text in each.

Based on my testing for a few initial runs, I found that the LLM was providing a somewhat detailed answer to the correct options and leaving the other options relatively short making it easy to guess the answer. Also by default it was generating 3 answer choices so I forced it to always generate 4.

I guess prompt engineering is definitely a thing now!

Here is the full code describing the output format of having a questions array with the answer content and a boolean flag for marking the answer as correct or wrong, along with the system prompt that follows it.
```tsx
const generateQuestions = async () => {
  const questionPrompt = "Generate 1 question for Artificial Intelligence exam";
  const { object: questionData } = await generateObject({
    model: googleModel,
    schemaName: "Questions",
    schemaDescription: "Practice Questions for subject provided",
    schema: z.object({
      questions: z.array(
        z.object({
          question: z.string(),
          answers: z.array(z.object({ answer: z.string(), correct: z.boolean() })),
        })
      ),
    }),
    system:
      "You are a excellent question setter. Generate MCQ questions for the subject you will be provided with. Make sure to always generate 4 options as answer choices to the questions. Make all choices of relatively the same tone and length. Do not provide much more information in the correct option and less information for incorrect options, make all options sound and seem equally probable with sufficient text in each. ",
    prompt: questionPrompt,
  });

  console.log(JSON.stringify(questionData, null, 4));
};
```
F
inally we get some answer that strictly adheres to the structure and can be reliably passed on to the front end to be shown in a UI and the user can then answer them and gain feedback as correct or wrong. This can mark the beginning of a helpful study assistant or a flashcards app sort of thingy!
```json
{
    "questions": [
        {
            "question": "What is Artificial Intelligence (AI)?",
            "answers": [
                {
                    "answer": "A process that allows machines to mimic human intelligence by learning from data, recognizing patterns, and making decisions.",
                    "correct": true
                },
                {
                    "answer": "A branch of computer science that deals with the theory and development of computer systems.",
                    "correct": false
                },
                {
                    "answer": "A field of study that focuses on the design and development of algorithms.",
                    "correct": false
                },
                {
                    "answer": "A type of software that is used to automate tasks.",
                    "correct": false
                }
            ]
        },
    ]
}
```

**References**

-   [Vercel SDK Docs on Structured Outputs](https://sdk.vercel.ai/docs/ai-sdk-core/generating-structured-data) 
-   [Previous post on building with AI SDK - an introduction](/posts/building-with-ai-sdk-1)
