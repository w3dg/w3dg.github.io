+++
date = '2025-03-06T12:55:42+05:30'
draft = false
title = 'Simple KNN Implementation from Scratch'
summary = 'To define KNN from scratch'
+++

# Introduction

[K Nearest Neighbors](https://en.wikipedia.org/wiki/K-nearest_neighbors_algorithm) is a *non-parametric*, *unsupervised* machine learning algorithm. It is a &ldquo;lazy learner&rdquo; algorithm, that means we do not need to train anything at all. It is a simple algorithm that stores all available cases and classifies new cases based on a similarity measure.

Let's unpack all those jargon terms above.

- **Non-parametric** means we do not need to store any parameters earlier for the model and store it. At the time of prediction, it will do the necessary calculations and give the output.
- **Unsupervised** means that we do not need any class labels for training the data.

# How KNN Works

The KNN algorithm assumes that similar things exist in close proximity. In other words, similar things are near to each other. KNN captures the idea of similarity (sometimes called distance, proximity, or closeness) with some mathematics.

We can have a lot of metrics for calculating this "distance" between two points. The most common ones are:

**Euclidean distance**:
$$d = \sqrt{\Sigma(p_i - q_i)^2}$$

**Manhattan distance**:
  $$d = \Sigma\text{\textbar} {p_i - q_i} \text{\textbar}$$

**Minkowski distance**:
$$d = {(\Sigma\text{\textbar} {p_i - q_i} \text{\textbar}^{p})}^{1/p}$$

**Hamming distance**: No. of bits that differ between two binary strings.

Based on these distance metrics, we can calculate the closest neighbors to the given data, and classify accordingly.

Generally `k` is an odd value chosen to avoid ties in the classification. If the neighbors have mixed results, we can choose the majority class as the output. This is called **Majority Voting**.

# Implementation with `numpy`

Let us define our data in the dataset as follows:

```python
import numpy as np

X = np.array([[1, 2], [1, 4], [1, 0], [4, 2], [4, 4], [4, 0]])
y = np.array([0, 0, 0, 1, 1, 1])
```

`X` denotes the points of our dataset. `y` denotes the corresponding class labels for the points.

Let us now define KNN:

We essentially want to take our data point we want to classify and find the distance of the point to all other dataset points.
Then we can sort the distances and take the `k` smallest distances.

```python
def knn(X, y,p, k=3):
  # calculate distances to all other points
  distances = [np.linalg.norm(point - p) for point in X]
  
  # sort the distances but get the indices in order that
  # would sort the distances
  sorted_indices = np.argsort(distances)

  # get the top k indices
  top_k_indices = sorted_indices[:k]

  # get the points and labels of the chosen k points
  nearest_k_points = [X[i] for i in top_k_indices]
  top_k_labels = [y[i] for i in top_k_indices]

  return (nearest_k_points, top_k_labels)
```

Let's explain the above code. For distance we are using Euclidean distance. This can be achieved using `numpy`'s `linalg.norm` function. That saves us a bit of writing although its simple to implement. We calculate the distance to all points in our dataset and store it using List Comprehension.

We then sort the distances and get the indices that would sort the distances. We then take the top `k` indices and get the corresponding points and labels for those points again by list comprehension.

At this point we have the nearest neighbors, its upto us whether we want to classify a class or make a regression prediction.

### For Classification

We can count the majority classes based on the labels returned and make the prediction.

```python
from collections import Counter

def classify(X, y, p, k):
  nearest_k_points, top_k_labels = knn(X, y, p, k)
  majority_label = Counter(top_k_labels).most_common(1)[0][0]
  return majority_label
```

Use it like so:

```python
classify(X, y, [5.0,3.6,1.4,0.2], 3)
# np.int64(2)
```

### For Regression

We use the same approach but we average over all values associated with the dataset.

```python
def predictRegression(X, y, p, k):
  nearest_k_points, top_k_labels = knn(X, y, p, k)
  return np.mean(top_k_labels)
```

An obvious next step is to evaluate our model. The data should be split out into a training and testing set and then we can evaluate on metrics such as mean squared error or accuracy.

I'll leave that up to you.

## Pros and Cons

It does not need any training time or resources which is nice, however it can get very slow with large datasets as we need to calculate distances to every single point.

I hope you learnt something and enjoyed this post. Further reading and references are below.

---

# References and Further Reading

I'll now suggest to switch to a standard library like `sklearn` and recreate the above. Often times this is much faster and they do more optimisations under the hood, hence it'll work better with larger datasets.

- [`sklearn`'s `KNeighborsClassifier`](https://scikit-learn.org/stable/modules/generated/sklearn.neighbors.KNeighborsClassifier.html#sklearn.neighbors.KNeighborsClassifier)
- [`sklearn`'s `KNeighborsRegressor`](https://scikit-learn.org/stable/modules/generated/sklearn.neighbors.KNeighborsRegressor.html#sklearn.neighbors.KNeighborsRegressor)
- [Guide and documentation of working with neighbor algorithms](https://scikit-learn.org/stable/modules/neighbors.html)
