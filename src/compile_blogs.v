module main

import os
import markdown
import strings

fn main() {
	compile_markdown_blogs_into_html_files()
	generate_blog_embeds()
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

			if read_bytes == 1024 {
				input_line := buffer.bytestr()
				output_line := markdown.to_html(input_line)
				wfd.write_string(output_line) or { println("unable to write to file: ${target}"); return }
				return
			}

			if read_bytes < 1024 {
				mut output_line := "<br/>"
				if read_bytes > 1 {
					input_line := buffer[..read_bytes - 1].bytestr()
					output_line = markdown.to_html(input_line)
				}
				wfd.writeln(output_line) or { println("unable to write to file: ${target}"); return }
			}
		}
	})
}

fn generate_blog_embeds() {
	mut code := strings.new_builder(1024)

	code.writeln("module main")
	code.writeln("")
	code.writeln("const (")

	mut code_ref := &code
	os.walk("./src/blogs", fn [mut code_ref] (path string)  {
		code_ref.writeln("\t${os.base(path).replace("-", "_").replace(".html", "")} = \$embed_file('${path}', .zlib)")
	})

	code.writeln(")")

	println(code.str())
}
