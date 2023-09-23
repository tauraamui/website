module main

import os
import markdown

fn main() {
	compile_markdown_blogs_into_html_files()
}

fn compile_markdown_blogs_into_html_files() {
	if !os.is_dir("./blogs") { panic("source blogs directory './blogs' is missing") }
	if !os.is_dir("./src/blogs") { panic("target blogs directory './src/blogs' is missing") }

	os.walk("./src/blogs", fn (path string) { os.rm(path) or { println("unable to remove ${path}: ${err}"); return } })

	os.walk("./blogs", fn (path string) {
		mut fd := os.open(path) or { println("unable to open ${path} for conversion"); return }
		defer { fd.close() }

		target := "./src/blogs/${os.base(path)}".replace(".md", ".html")
		mut wfd := os.open_file(target, 'w') or { println("unable to open writable file: ${target}"); return }
		defer { wfd.close() }

		for !fd.eof() {
			mut buffer := []u8{ len: 1024 }
			read_bytes := fd.read_bytes_into_newline(mut &buffer) or { panic(err) }
			if read_bytes < 1024 {
				// TODO:(tauraamui) -> convert empty lines with just `\n` to `<br/>` and handle stupidly long lines
				input_line := buffer[..read_bytes - if read_bytes > 1 { 1 } else { 0 }].bytestr()
				output_line := markdown.to_html(input_line)
				wfd.writeln(output_line) or { println("unable to write to file: ${target}"); return }
			}
		}
	})
}
