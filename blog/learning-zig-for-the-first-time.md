---
date: 06/12/2024
tab_title: Learning Zig
article_title: Learning Zig (for the first time basically)
published: yes
---
#{article_title}

### NOTE: This post is a WIP but I'm treating it as a public log of exploration

So for various reasons I have not used Zig yet. The main reason being unclear documentation and (at the time) no official package management support. This has likely changed, and it felt like time to explore the language and the ecosystem once more.

Today is 5th December 2024, and my first re-visiting of Zig and doing some searching around has revealed so far:

- Zig zon is a thing
- Its apparently the way you can pin/define concrete deps for your project!

I cannot just use Zig for the sake of it, in isolation with no clear project or goal in mind, I _HAVE_ to learn by doing something "real". I can't help it, its like a disease.

Therefore the first library I wanted to try out was this one:  https://github.com/ziglibs/ansi-term
How can I get it? The options:

- Git submodules (ew)
- Directly cloning (feeling nauseous)
- Using a build system to manage my deps (ahhhh)

I figured out by frantically Google searching that Zig does technically have a native package manager these days, but it is completely undocumented from the official sources from what I could see. Some posts I can across implied this is deliberate due to it being in unsettled unstable stage of its creation.

This post: https://ziggit.dev/t/how-to-add-a-dependency-to-build-zig-zon/6769 helped me learn that it is indeed possible (thank god) to install deps even if the repo that contains the desired code has no associated releases.

To be continued...
