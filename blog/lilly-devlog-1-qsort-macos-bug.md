---
date: 25/10/2024
title: Lilly Devlog 1 - QSort macOS bug
published: no
---
# [Lilly](https://github.com/tauraamui/lilly) Devlog # 1
#{read_time_seconds}

I have been working on a project for nearly a year which I see as my (and perhaps others?) alternative or entire replacement of Neovim for day to day work. This editor is in the pre-alpha release stage of the project. As such there is currently no commitment to provide frequent or consistent dev logs or change log summaries. With that being said, I recently encountered for the first time a bug which I feel is worth writing an article about.

I will hopefully provide useful insight in this post into what the bug was, how it manifested in Lilly, and what the journey to fix it looked like.
## What bug?

The Lilly editor (LE) has a core feature which is called the "file picker". This lists all of the files available within the current "workspace", and the list is ordered based on the closest match to the searched name. This makes navigating a familiar "workspace" very quick and simple, once you can see the file you are wanting to edit, you can then select it with the arrow keys and hit `RETURN` to open it.

![lilly-file-picker](/static/lilly-editor-file-picker-sorting.gif)

On Linux and Windows, this feature worked fine. On Mac, everything seemed to be broken. Instead of sorting the full list, only the top entry would randomly change, but what was pushed to the top didn't match whatsoever with the search query either. But the tests were all passing, and the language and its std libraries are the same across all platforms? Right?

## How does the sorting work?

A standard library function called `dice_coefficient` within the V(lang) module `strings` is used to generate a score for each entry in the list. The higher the score, the closer the match to the search query. These scores range from `0.0` to `1.0`. The file picker code uses this score to order the file path list, the higher the score, the higher in the list it will appear.

The V(lang) modules documentation has this note regarding this function:
> `dice_coefficient` implements the Sørensen–Dice coefficient. It finds the similarity between two strings, and returns a coefficient between 0.0 (not similar) and 1.0 (exact match). [module documentation](https://modules.vlang.io/strings.html#dice_coefficient)

Therefore the full name of the underlying algorithm Lilly uses to compare one string of text with another is "Sørensen–Dice coefficient" (SDC).

<details> <summary>Slightly off topic </summary>

### Sørensen–Dice coefficient vs Levenshtein Distance
This is slightly off topic for this article, but as a point of interest in case you were wondering, yes, there are also functions to calculate the "Levenshtein Distance" (LD) between two strings available within the V(lang) standard library. I have some intuitive sense that of the two options, LD is more well known and more "popular", and you may be wondering why LD wasn't chosen as the algorithm instead of SDC.

According to others research I found online, SDC is better optimised for sets of strings which are lengthy, or vary wildly in length from each other, and sets where there is a greater chance of more errors than matches.

Lists of file paths of an arbitrary length, which are all being compared to a single very specific lookup "query" matches the kind of situation that SDC is better suited for, as its optimised for this, compared to something like (LD).

Incidentally the V compiler uses (LD) to try and provide alternative function or type names in the case of a function reference or invocation being undefined, as its highly likely that the intended function has been simply misspelt.

For example:

```
src/view.v:35:12: error: unknown type `Cursorx`.
Did you mean `Cursor`?
   33 | }
   34 |
   35 | fn (cursor Cursorx) line_is_within_selection(line_y int) bool {
```
This is an optimal use of the (LD) algorithm over (SDC), as its only matching at most a couple of verbs/strings, they're very likely to be fairly short and there's a good chance that in the case of a misspelling there's probably only a few incorrect or missing characters.

</details>

Being able to score each file path against the query is the first piece of the puzzle but it is not sufficient to provide us the ability to actually order a list of file paths in score order. In order to do sorting we need a sorting algorithm.

![quicksort-anim.gif](/static/quicksort-anim.gif)

https://stackoverflow.com/questions/50110709/unexplainable-difference-in-qsort-results-under-macos-and-linux
