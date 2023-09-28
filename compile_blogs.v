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

		contents := os.read_file(path) or { println("unable to read file ${path} for conversion: ${err}"); return }
		converted_contents := markdown.to_html(contents)

		target := "./src/blog/${os.base(path)}".replace(".md", ".html")
		mut wfd := os.open_file(target, 'w') or { println("unable to open writable file ${target}: ${err}"); return }
		defer { wfd.close() }

		wfd.write_string(header_content) or { println("unable to prepend header to file: ${err}"); return }
		wfd.write_string(converted_contents) or { println("unable to write converted HTML body: ${err}"); return }
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
	code.writeln("import read_time")
	code.writeln("")
	code.writeln("const (")

	for f in generated_files {
		code.writeln("\t${os.base(f).replace("-", "_").replace(".html", "")} = \$embed_file('${f}', .zlib)")
	}

	code.writeln(")")
	code.writeln("")

	code.writeln("fn blogs_listing() []string {")
	code.writeln("\treturn [")
	for f in generated_files {
		code.writeln("\t\t\"${os.base(f).replace("-", " ").replace(".html", "")}\"")
	}
	code.writeln("\t]")
	code.writeln("}")

	code.writeln("")

	code.writeln("pub struct Post {")
	code.writeln("\thtml_content string")
	code.writeln("\treadtime read_time.ReadTime")
	code.writeln("}")

	code.writeln("fn resolve_blogs() map[string]Post {")
	code.writeln("\treturn {")
	for f in generated_files {
		code.writeln("\t\t\"${os.base(f)}\": Post {")
		code.writeln("\t\t\thtml_content: ${os.base(f).replace("-", "_").replace(".html", "")}.to_string()")
		code.writeln("\t\t}")
	}
	code.writeln("\t}")
	code.writeln("}")

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
