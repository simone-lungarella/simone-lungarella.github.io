---
title: A Small Note About Simple Software 2
date: 2026-05-16
description: An example article used to test the visual style of a minimal static blog.
canonical: https://example.com/articles/example-article.html
site_title: My Blog
feed_url: /feed.xml
css: /css/style.css
home_url: /
lang: en
---

Simple software is often described as boring, limited, or unfinished.
I think this is unfair. Good simple software is not software with fewer
ideas. It is software where the important ideas are easier to see.

A static blog is a good example. It does not need a database, an
administration panel, a JavaScript framework, or a deployment pipeline
made of twelve different services. It can be a directory of files, a
stylesheet, and a small build script.

## The value of boring structure

A boring structure is useful because it stays understandable over time.
If the layout of the project can be explained by listing a few
directories, the project is easier to debug, move, archive, and rebuild.

For example, this structure is enough for many personal blogs:

```text
blog/
├── index.html
├── css/
│   └── style.css
├── articles/
│   └── example-article.html
├── md/
│   └── example-article.md
└── templates/
    └── article.html
```
