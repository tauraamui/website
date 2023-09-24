module main

import os
import markdown
import strings

fn main() {
	compile_markdown_blogs_into_html_files()
	target := "./src/resolve_blogs.v"
	code := generate_blog_embeds_code()
	os.rm(target) or { println("unable to remove ${target}: ${err}") }
	mut wfd := os.open_file(target, 'w') or { println("unable to open writable file: ${target}"); return }
	defer { wfd.close() }
	wfd.write_string(code) or { panic("unable to write to file: ${target}") }
}

fn compile_markdown_blogs_into_html_files() {
	if !os.is_dir("./blog") { panic("source blogs directory './blog' is missing") }
	if !os.is_dir("./src/blog") { panic("target blogs directory './src/blog' is missing") }

	os.walk("./src/blog", fn (path string) { os.rm(path) or { println("unable to remove ${path}: ${err}"); return } })

	header_content := os.read_file("./src/templates/header.html") or { println("unable to extract header content"); return }
	footer_content := os.read_file("./src/templates/footer.html") or { println("unable to extract footer content"); return }

	os.walk("./blog", fn [header_content, footer_content] (path string) {
		if path.starts_with(".obsidian") || os.file_ext(path) != ".md" { return }

		mut fd := os.open(path) or { println("unable to open ${path} for conversion"); return }
		defer { fd.close() }

		target := "./src/blog/${os.base(path)}".replace(".md", ".html")
		mut wfd := os.open_file(target, 'w') or { println("unable to open writable file: ${target}"); return }
		defer { wfd.close() }

		wfd.write_string(header_content) or { println("unable to prepend header to file: ${err}"); return }

		for !fd.eof() {
			mut buffer := []u8{ len: 1024 }
			read_bytes := fd.read_bytes_into_newline(mut &buffer) or { panic(err) }

			wfd.write_string(" ".repeat(9)) or { println("unable to write to file: ${target}"); return }

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

		wfd.write_string("${" ".repeat(6)}</div>\n${footer_content}") or { println("unable to append footer to file: ${err}"); return }
	})
}

fn generate_blog_embeds_code() string {
	mut generated_files := []string{}
	mut ref := &generated_files

	os.walk("./src/blog", fn [mut ref] (path string) {
		ref << path
	})
	mut code := strings.new_builder(1024)

	code.writeln("module main")
	code.writeln("")
	code.writeln("const (")

	for f in generated_files {
		code.writeln("\t${os.base(f).replace("-", "_").replace(".html", "")} = \$embed_file('${f}', .zlib)")
	}

	code.writeln(")")
	code.writeln("")

	code.writeln("fn resolve_blog(name string) !string {")
	code.writeln("\treturn match name {")
	for f in generated_files {
		code.writeln("\t\t\"${os.base(f)}\" {")
		code.writeln("\t\t\t${os.base(f).replace("-", "_").replace(".html", "")}.to_string()")
		code.writeln("\t\t}")
	}
	code.writeln("\t\telse { error(\"unable to resolve blog\") }")
	code.writeln("\t}")
	code.writeln("}")

	return code.str()
}
