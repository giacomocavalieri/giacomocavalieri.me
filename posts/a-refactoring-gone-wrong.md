---
id = "a-refactoring-gone-wrong"
title = "A refactoring gone wrong"
abstract = "Think of an abstract"
tags = ["java", "gleam"]
date = 2024-05-16
status = "hide"
---

_""_

Allow me to set the scene. We have an application that has to show in its
homepage the previews for some kind of products, a preview consists of the name
of the product and a list of its tags:

```java
public record Tag(String name) {}

public record ProductPreview(String name, List<Tag> tags) {}

```

> If you were wondering, Java records are a new feature introduced in Java XXX.
> Defining a record you get `equals`, `hashCode` and getter methods for free,
> it's really cool!

And the view is something super simple, it's nothing more than a textual list
of previews. So I defined a static method to turn a `ProductPreview` into a
`String`:

```java
static String prettyPreview(ProductPreview productPreview) {
  val tags = productPreview
    .tags()
    // We want to join all the names separated by a comma: get a stream of
    // the tags, select just the name and join them with commas.
    .stream()
    .map(tag -> tag.name())
    .collect(Collectors.joining(", "));

  return productPreview.name() + "[" + tags + "]";
}

```

This is nothing particularly pretty but more than enough for a small example!

```java
val tags = List.of(new Tag("tag1"), new Tag("tag2"))
val preview = new ProductPreview("wibbler", tags)
prettyPreview(preview) // -> "wibbler [tag1, tag2]"
```

After writing some more code I realised that it doesn't actually make a lot of
sense for tags to be a list: a product cannot have duplicate tags so the better
choice here would probably be using a `Set`.
I then went on to change the type of the `tags` collection:

```diff
- public record ProductPreview(String name, List<Tag> tags) {}
+ public record ProductPreview(String name, Set<Tag> tags) {}
```
