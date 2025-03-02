---
date: 28/02/2025
tab_title: Lilly Devlog 2 - Todo comment picker
article_title: Lilly Devlog 2 - Todo comment picker
published: yes
unlisted: yes
---
#{article_title}

The Lilly project feature set target is based on my personal existing Neovim configuration. That is to say that all of the functionality and behaviour of Neovim as I have configured it is the target goal for the Lilly editor project.

One main feature that I want to re-create from my Neovim setup is the functionality of a plugin called [todo comments](https://github.com/folke/todo-comments.nvim).

## What does todo comments (the Neovim plugin) do?

It is a plugin that mostly helps you locate and highlight different kinds comments which have a specific prefix pattern. This is very useful for me, as I tend to leave comments as bookmarks or notes all over the different code bases I work on, but later on unless I happen to stumble across these once again later, and in that moment are able to address what it is referring to (unlikely) they are unlikely to be addressed again.

Having the dialog require a specific format to look for helps to keep me consistent with their layout when writing them.
Different default prefixes it looks for:
- `PERF`
- `HACK`
- `TODO`
- `NOTE`
- `FIX / FIXME`
- `WARNING`

The core user interface that this plugin provides is a Neovim "pop-up" or "modal". In this modal it provides a tree style/nestable list of all of the files which contain comments that it found that match the filter being used, the file names/paths are the root nodes in the list and underneath there is the list of the individual found todo comments within the file itself. By default the list root nodes are expanded so its immediately easy to see the individual match entries per file. (Fig .1)

![todo-comments-example.png](/static/todo-comments-example.png)
(figure 1. an example screenshot of the modal)

## How does it search?

This question is integral to understanding how we could go about re-implementing our own custom version of this plugins functionality to be a built-in "core" feature of the Lilly editor. We need to decide if the integral mechanism with which this plugin does its pattern/searching of specially formatted comments is what we want to directly emulate or not.

We're in a very unique position, being the author of the entire editor and its surrounding ecosystem that the authors of Neovim plugins do not. Writing a pattern matcher as generic or as flexible as a regex engine in something like Lua is a bad idea. Because it's slow. It makes much more sense, if the language you're using to develop a plugin for Neovim is Lua to instead call out to a separate much faster and better optimised for the task program to carry out the searching.

This is how the Neovim plugin `todo comments` implements its searching functionality. It doesn't implement it directly at all. So what program(s) does it use? And how? Well, lets take a look.

If we go to the plugins "homepage" on Github, there is a ["requirements"](https://github.com/folke/todo-comments.nvim/tree/main?tab=readme-ov-file#%EF%B8%8F-requirements) section. This list has a sub list called "optional". Within this list we see: 
> `ripgrep` and `plenary.nvim` are used for searching

The [installation section](https://github.com/folke/todo-comments.nvim/tree/main?tab=readme-ov-file#-installation) install section on the [`README.md`](https://github.com/folke/todo-comments.nvim/tree/main?tab=readme-ov-file#-todo-comments) shows that the default required dependency is `nvim-lua/plenary.nvim`.