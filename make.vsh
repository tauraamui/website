#!/usr/bin/env -S v run

import build
import strconv
import math

const app_name = "website"

mut context := build.context(
	default: "run"
)

// BUILD TASKS
context.task(name: "compile", help: "Compile the entire website into a single binary", run: |self| system("v -os linux -prod ./src -o website.bin"))
context.task(name: "compile-blogs", help: "Compile the blog markdown into HTML", run: |self| system("v run compile_blogs.v"))
context.task(name: "compile-resume", help: "Compile resume page markdown into HTML", run: |self| system("v run compile_resume.v"))
context.task(name: "release-build", help: "Fully builds entire website", depends: ["compile-blogs", "compile-resume", "compile"], run: fn (self build.Task) ! {})

// DEV TASKS
context.task(name: "run", help: "Run the website on a local port", depends: ["compile-blogs", "compile-resume"], run: |self| system("v -g run ./src"))

context.run()

