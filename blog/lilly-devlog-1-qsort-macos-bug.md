---
date: 25/10/2024
title: Lilly Devlog 1 - QSort macOS bug
published: no
---
# [Lilly](https://github.com/tauraamui/lilly) Devlog # 1
#{read_time_seconds}
.
## Introduction

I have been working on a project for nearly a year which I see as my (and perhaps others?) alternative or entire replacement of Neovim for day to day work. This editor is in the pre-alpha release stage of the project. As such there is currently no commitment to provide frequent or consistent dev logs or change log summaries. With that being said, I recently encountered for the first time a bug which I feel is worth writing an article about.

I will hopefully provide useful insight in this post into what the bug was, how it manifested in Lilly, and what the journey to fix it looked like.
## What bug?

The Lilly editor (LE) has a core feature which is called the "file picker". This lists all of the files available within the current "workspace", and the list is ordered based on the closest match to the searched name.





https://stackoverflow.com/questions/50110709/unexplainable-difference-in-qsort-results-under-macos-and-linux
