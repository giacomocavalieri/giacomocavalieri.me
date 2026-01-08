---
id = "effortless-animations-with-css-view-transitions"
title = "Effortless animations with CSS view transitions"
abstract = "Designing an appealing web page is always a bit of a challenge for me. But this time around I actually had a really good time, and really enjoyed dipping my toes into CSS View Transitions. Here's how I managed to add nice animations to my static personal website with just a few lines of CSS."
tags = ["web-design"]
date = 2026-01-07
status = "show"
---

Designing an appealing web page is always a bit of a challenge for me: I don't
have a lot of web design experience, and the one time a year I set up to do
anything that has to look decent I always feel like I'm relearning CSS 101 from
scratches.

Surprisingly, this time around I actually had a really good time, and the part
I enjoyed the most was dipping my toes into [CSS view transitions.](https://developer.mozilla.org/en-US/docs/Web/API/View_Transition_API)
I think the final result is really impressive given this is a static web page,
with no JavaScript, no tricks, and just a couple of lines of CSS:

```=html
<video muted loop autoplay>
  <source type='video/mp4' src='/imgs/view-transition-preview.mp4'/>
</video>
```

## Getting started

So how did I do it? To get started we need to add a `@view-transition` rule to
the page's CSS:

```css
@view-transition {
  navigation: auto;
}
```

This will enable view transitions when navigating from one page to the other.
And that's it... mostly!
With this one rule the default animation between pages becomes a smooth
cross-fade.
You can see it in action when clicking on the `contact` link on my homepage.
[Not all browsers](https://caniuse.com/?search=%40view-transition) fully support
cross document view transitions yet, so here's what it looks like for people
using Firefox:

```=html
<video muted loop autoplay>
  <source type='video/mp4' src='/imgs/view-transition-contact.mp4'/>
</video>
```

## Customising the animation

The default animation can be changed using the [`::view-transition-group()`](https://developer.mozilla.org/en-US/docs/Web/CSS/Reference/Selectors/::view-transition-group)
CSS pseudo-element. With our basic setup every element in the page will belong
to a single group, being animated as one.
To affect all groups (more to come later!) we can write something like this:

```css
::view-transition-group(*) {
  animation-duration: 0.25s;
}
```

And that's what I did in my website. I also played around with the
`animation-timing-function` property for a spring-y animation:

```css
::view-transition-group(*) {
  animation-duration: 0.25s;
  animation-timing-function: cubic-bezier(0.78, -0.02, 0.33, 1.15);
}
```

But ended up sticking to the default, as the animation was getting a bit
distracting. You can really get creative with this, the sky's the limit!

## Animating individual items

This works great but I wanted to animate some individual items separately to
make the page feel a bit more interesting.
I thought it would be really nice if the "speaking" and "writing" menu items
would move to form the breadcrumbs element when clicked.
This is the final result, pretty neat if you ask me:

```=html
<video muted loop autoplay>
  <source type='video/mp4' src='/imgs/view-transition-breadcrumb.mp4'/>
</video>
```

As you might recall, with no additional rules everything gets bunched together
into a single animation group.
To put some elements into their own separate group we need to specify its name
with the `view-transition-name` property.

```css
selector-for-element-to-animate-separately {
  view-transition-name: the-name-of-the-group;
}
```

As long as two elements have the same `view-transition-name` they will be
animated together, separately from all other groups. So to get the "writing" and
"speaking" text to move across pages, they just need to have the same value:

```html
<!-- index.html -->
<a href="..." id="writing">writing</a>

<!-- writing.html -->
<ol class="breadcrumb">
  <li>...</li>
  <li>
    <h3 id="writing">writing</h3>
  </li>
</ol>
```

```css
#writing {
  view-transition-name: writing-animation;
}
```

I find it a bit more convenient to specify the `view-transition-name` on the
html elements directly, so if you'll inspect this website's source you'll see
this:

```html
<!-- index.html -->
<a href="..." style="view-transition-name: writing-animation">writing</a>

<!-- writing.html -->
<ol class="breadcrumb">
  <li>...</li>
  <li>
    <h3 style="view-transition-name: writing-animation">writing</h3>
  </li>
</ol>
```

> Actually I'm not handwriting this HTML, I'm generating it in
> [Gleam](https://gleam.run) using [Lustre](https://lustre.build).
> So I have a little helper to cut down on repetition:
>
> ```gleam
> pub fn animate(name: String) -> Attribute(_) {
>   attribute.style("view-transition-name", name <> "-animation")
> }
> ```
>
> And whenever I need to make sure two items get animated as one I make sure to
> give them the same name:
>
> ```gleam
> // homepage
> html.a([animate("writing")], [html.text("writing")])
>
> // writing breadcrumb
> html.h3([animate("writing")], [html.text("writing")])
> ```

That's it, for real! Those very few lines of css are all that I needed to add
a few fancy animations in my website. I'm far from being an experienced frontend
developer, and I'm really satisfied with how little effort it required to get a
really nice looking page.
