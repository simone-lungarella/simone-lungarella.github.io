# Personal blog

Personal website with multiple articles about my interests in software designing and developing.

This project is structured so that I can use tools that I know from my terminal to minimize the overhead related to writing articles.


```text
.
├── docs
│   ├── articles/
│   ├── css
│   │   └── style.css
│   ├── favicon.svg
│   ├── feed.xml
│   └── index.html
├── README.md
├── Makefile
├── LICENSE
├── md/
├── scripts
│   └── generate-feed.py
└── templates
    └── article.html
```

## Build workflow

It is a simple static website with no javascript. Makes use of [pandoc](https://pandoc.org/) to convert markdown to `html` files using a custom template.

Run `make all` to create, for each existing markdown file under `./md` directory, an article under `./docs/articles` directory using the custom [template](./templates/article.html).

Refreshing all articles also generates feed.xml using a python script. Each article is completely shown on feed so that no one is forced to reach for the website.
