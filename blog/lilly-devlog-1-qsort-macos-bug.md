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

~~~v

src/view.v:35:12: error: unknown type `Cursorx`.
Did you mean `Cursor`?
   33 | }
   34 |
   35 | fn (cursor Cursorx) line_is_within_selection(line_y int) bool {
~~~

This is an optimal use of the (LD) algorithm over (SDC), as its only matching at most a couple of verbs/strings, they're very likely to be fairly short and there's a good chance that in the case of a misspelling there's probably only a few incorrect or missing characters.

</details>

Being able to score each file path against the query is the first piece of the puzzle but it is not sufficient to provide us the ability to actually order a list of file paths in score order. In order to do sorting we need a sorting algorithm.

### The sorting algorithm

Within the V(lang) programming language, native builtin types have utility methods available on them. The array type is the native list type of the language, and it has a method for sorting in-place, called `sort_with_compare`.

The V(lang) modules documentation has this note regarding this method:

> `sort_with_compare` sorts the array in-place using the results of the given function to determine sort order. The function should return one of three values:- `-1` when `a` should come before `b` ( `a < b`). Return should be `1` when `b` should come before `a` (`b < a`) or `0` when the order cannot be determined (`a == b`)

It also provides an example (this will be important later):

~~~v

fn main() {
	mut a := ['hi', '1', '5', '3']
	a.sort_with_compare(fn (a &string, b &string) int {
        if a < b {
            return -1
        }
        if a > b {
            return 1
        }
        return 0
    })
    assert a == ['1', '3', '5', 'hi']
}
~~~

### What we have so far:

The steps:

1. The file list is loaded as is from the raw list contained within the `workspace` instance in Lilly.
	~~~v
	files := ["./src/main.v", "./src/lib/clipboard/clipboard.v", "./src/editor.v"]
	~~~
2. We invoke `sort_with_compare` on the file list directly. This will order the entries in the list based on the `1` or `0` or `-1` return value from the callback passed in this step
	~~~v

	query := "clip"
	files.sort_with_compare(fn [query] (a &string, b &string) int {
		a_score := dice_coefficient(query, a)
		b_score := dice_coefficient(query, b)

		if a_score < b_score { return 1 }
		if b_score > a_score { return -1 }
		return 0
	})
	~~~
3. The list contents is then sorted into descending order, with the closest query match at the top, with the more distant matches below that.

## Discovery of the bug on macOS

The file picker works! At least it does on Windows and Linux, but on macOS, not so much... Instead of behaving as we expect, this is how the file picker behaves on macOS _exclusively_.

![lilly-mac-file-picker-broken.gif](lilly-mac-file-picker-broken.gif)







misc notes
https://github.com/tauraamui/lilly/commit/1ec825eb1e843785319d3142222e700fac9e2c39#diff-8d3f22fa8dee4939ef9424992d181673cc07c6b6ecc47c34e1e136b7e6c7aee4R173


![quicksort-anim.gif](/static/quicksort-anim.gif)

https://stackoverflow.com/questions/50110709/unexplainable-difference-in-qsort-results-under-macos-and-linux
