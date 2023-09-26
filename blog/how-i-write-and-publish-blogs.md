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

### Step 1a.
![cmbihf first few lines](/static/cmbihf-first-few-lines.png)
The first few lines are ensuring that the directory which we want to read from (the blog Markdown files directory), and the directory which we would like to write to both exist already. I could just create them if they do not exist, but for now I'd rather now. I don't really know why exactly, but I think it's because they shouldn't ever not be there anyways, and if they are indeed missing, something else is probably wrong.
### Step 1b.
Then this: `os.walk("./src/blog", fn (path string) { os.rm(path) or { ... } })` ensures that the target directory is empty. When we run this compile process, each blog is "rebuilt" each time, even if no changes have occurred. We could do better, but for now there's so little blog posts that there's no good reason to spend time optimising/making stuff more complicated for very little gain.
### Step 2.
![for each blog entry](/static/for-each-blog-entry.png)
Next up, for every file which exists with an extension of `.md` within the blogs directory, we create and write to a new file with the same name, but one which has a `.html` extension. We then immediately write the previously extracted header template (which is shared across all site pages) to this file.

### Step 3.
![convert line by line](/static/convert-line-by-line.png)
The rest of this function is then an iteration over each line of the current Markdown file we are working on. First we allocate a list of bytes 1024 (or 1kb) in size called `buffer`. We then call the V std library method on our open file descriptor to read as many bytes as available into our buffer.

#### What does `read_bytes_into_newline` mean/do?
If we check the V std lib documentation for this method, we find the following:
![std lib doc](/static/std-lib-doc.png)
The last line (which incidentally seems to be incorrectly worded) is of most interest in the case of the above code. What it means is simply that the function will return if:
1. The buffer is filled up before a newline is encountered
2. A newline is encountered
3. The file's EOF is reached

That's the reason for the following branches, after we invoke this read method:

#### Branch 1.
`if read_bytes == 1024 {`
`        input_line := buffer.bytestr()`
`        output_line := markdown.to_html(input_line)`
`        wfd.write_string(output_line) or { println("unable to write to file: ${target}"); return }`
`        return`
`}`

and

#### Branch 2.
`if read_bytes < 1024 {`
`    mut output_line := "<br/>"`
`    if read_bytes > 1 {`
`    input_line := buffer[..read_bytes - 1].bytestr()`
`    output_line = markdown.to_html(input_line)`
`}`
`wfd.writeln(output_line) or { println("unable to write to file: ${target}"); return }`
`}`

For branch 1. it basically takes the fact that the whole buffer was filled to mean that the line it just read has yet to finish, so it must be just a really long line. We don't really care, and we therefore just convert all of the line we've read so far into HTML from Markdown.

For branch 2. we didn't fill up the whole buffer before returning, and so we must have encountered a newline (or EOF). In this situation, we want to check if the line is more than one character long, if it is we convert this line, excluding it's newline (we assume it has one, as of yet we're not handling the EOF case! 😮) If the line is only one character long, we assume it's a newline character on its own, and we convert that into padding.

#### Finally
The final line at the end of this function just writes the previously read HTML footer to the end of the new HTML file.

### The attachment caveat
I mentioned earlier that images needed to be lowercased and delimited by `-` instead of spaces. That is because when the Markdown to HTML converter we need the resulting conversion to be a valid URL. The Markdown converter does not concern itself with doing escaping of illegal characters, so for our purposes it is just simpler to name these files with already valid/legal characters.

### Embedding
We're not done yet. The second function invoked in `main` is `generate_blog_embeds_code`.

### Step 1. Acquire blog HTML files list
![generate embeds entry](/static/generate-embeds-entry.png)
The first thing this function does is build a list of the all the just created HTML versions of all the blog posts. It could be derived perhaps from the generation function, but for now this will do.

### Step 2. Generate embed directive line per HTML file in list
![define embed per entry](static/define-embed-per-entry.png)
Next we write to the strings builder for each discovered file some V code which when compiled as part of the main program/server/website app, will instruct the compiler to directly embed these files into the resulting output binary.