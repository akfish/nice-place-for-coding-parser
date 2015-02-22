# nice-place-for-coding-parser

Parse `.md` files into structured data for [nice-place-for-coding][1]

### Why bother?

Although `.json` or `.yaml` format can be used directly without creating a parser, `Markdown` has its advantages:

* It's human-readable
* It's also structurally defined (like other dedicated format)
* It's fun
* It's not that much of a trouble

[1]: https://github.com/metrue/nice-place-for-coding

## Format Spec

A valid file should contain at least one place entry. Each place entry should be in this format:

> \* Place name : place address
>
> \```
>
> Notes on place
>
> from @name_of_recommender
>
> ```

Note:

* Nothing else can exist in between the list item and the code block
* English colon must be used to separate place name and address. Spaces are allowed before and after the colon
* Any contents (expect lists, both ordered an un-ordered ones) can be added between 2 place entries (see `./test/data/more-than-one.md`)

## Usage

Install:

```
npm install nice-place-for-coding-parser
```

Use:

```coffeescript
Parser = require 'nice-place-for-coding-parser'

parser = new Parser()

places = parser.parse 'Markdown source'

```

Parser output:

```js
[
  {
    name: 'name of place',
    address: 'address of place',
    note: 'note',
    recommendedBy: 'who'
  },
  // Other places
]
```
