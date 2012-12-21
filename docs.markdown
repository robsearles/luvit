# Luvit Documentation

## Requirements

There are three requirements for the docs:

* [LDoc](https://github.com/stevedonovan/ldoc) to create the docs. v1.2 required.
* [Penlight](https://github.com/stevedonovan/Penlight) which is a requirement of LDoc
* [Markdown Module](http://www.frykholm.se/files/markdown.lua) to make sure the docs are 

### Note

I tried installing the above requirements using **LuaRocks** but it didn't work at all, so in the end I manually installed and all worked fine. (Running Ubuntu 12:10). 

@TODO - write some installation notes for the documentation requirements.

## Creating the docs

Within the top level directory of the repo, simply run:

    ldoc .

This will compile the docs to the `./docs` directory.

## Configuring the Docs

The `config.ld` file contains the documentation configuration.

### Adding topics

To include other text files (including markdown files) simply add them to the `topics` list.

### Linking to an Example

When documenting a module, sometimes it is useful to direct the user to a working example. This is a two step process. 

Firstly, the example file you wish to use must be included in the `examples` list.

*Note: adding the entire examples directory via a wildcard does not seem to work, returning an error and failing to compile the docs. As such, they must be added one at a time.*

Now you can add a reference to that example file. There are two ways to add a reference within the docs. Either using the `@see` tag, or by using \`backticks\`. For example:

``-- @see http-server.lua``

Or

``You can see this in more detail in the `http-server.lua` example.``

## References

* <http://stevedonovan.github.com/ldoc/>
* <http://stevedonovan.github.com/ldoc/topics/doc.md.html>
* <https://github.com/stevedonovan/ldoc>
* <https://github.com/stevedonovan/Penlight>
* <http://www.frykholm.se/files/markdown.lua>
