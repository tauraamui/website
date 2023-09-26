---
Date: 26/09/2023
---
# How I write and publish blogs
The following post will attempt to go through the step by step process which I take when I would like to author and publish new blogs to this website.

### Obsidian
The blogs themselves are written using Markdown (if you don't know what Markdown (`.md`) files are somehow, you can read more about them [here](https://www.markdownguide.org/)). Obsidian is, amongst other things, great as a Markdown editor. It has native support for VIM bindings, and provides immediate feedback by rendering the document as you work on it.

I already use Obsidian as my "second brain" day to day to collect notes, snippets/quotes from other media and works, and so I can also take advantage of all of the plugins I already use to do stuff, including planning blog posts in advance using "daily notes".

Obsidian also renders externally referenced assets such as images in place, which is very useful. When I open Obsidian to edit the blogs, I open the directory `./site/blogs` as the "vault" to use. Within this directory are all of the Markdown files which each represent an individual blog post, and another sub directory `static`, which is where all images and other referenced assets live.

As the below screenshot shows, I have set up Obsidian (for this vault, settings are stored per vault which is also very useful) to always place new assets which are "pasted" into the document in this location, and reference them using a relative path, such as `![obsidian settings](/static/obsidian-settings.png)`, which comes in handy later on as we will see.

![obsidian settings](/static/obsidian-settings.png)
### Attachment file names
There is a slight caveat to this system, in that at this point of the blog authoring process it makes no difference, but I do have to make sure the names of these are all lowercased and delimited by `-` rather than whitespace. Something like `Screenshot 2023-09-26 at 10.52.39` for example is not going to work later on.

## Compiling/building
Once a blog post has been created, edited etc., the next step is to run `just compile-blogs`. This is a `justfile` command which runs this: `v run compile_blogs.v` in the root of the website repository. `compile_blogs.v` is a discrete V program which is responsible for parsing all existing markdown files within the `./blogs` directory and generating required output.

### The code
This is the entry point function to `compile_blogs.v`:
![compile blogs entrypoint](/static/compile-blogs-entrypoint.png)
You can see here that the first function invoked is called `compile_markdown_blogs_into_html_files`. Happily the function name is very clear and self documenting, but we might as well take a look to see what it is doing.

![cmbihf first few lines](/static/cmbihf-first-few-lines.png)
The first few lines are ensuring that the directory which we want to read from (the blog Markdown files directory), and the directory which we would like to write to both exist already. I could just create them if they do not exist, but for now I'd rather now. I don't really know why exactly, but I think it's because they shouldn't ever not be there anyways, and if they are indeed missing, something else is probably wrong.

Then this line:
`os.walk("./src/blog", fn (path string) { os.rm(path) or { ... } })`
ensures that the target directory is empty. When we run this compile process, each blog is "rebuilt" each time, even if no changes have occurred. We could do better, but for now there's so little blog posts that there's no good reason to spend time optimising/making stuff more complicated for very little gain.
