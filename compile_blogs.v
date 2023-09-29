module main

import os
import markdown
import strings
import read_time

struct Post {
	meta FrontMatter
	path string
	raw_doc_content string
	html_content string
	readtime read_time.ReadTime
}

struct FrontMatter {
mut:
	start_pos int
	end_pos int
	date string
}

fn (post Post) write_html_post(header_content string, front_matter_content string, footer_content string) {
	target := "./src/blog/${os.base(post.path)}".replace(".md", ".html")
	mut wfd := os.open_file(target, 'w') or { println("unable to open writable file ${target}: ${err}"); return }
	defer { wfd.close() }

	wfd.write_string(header_content) or { println("unable to prepend header to file: ${err}"); return }
	wfd.write_string(post.html_content) or { println("unable to write converted HTML body: ${err}"); return }
	wfd.write_string("${" ".repeat(6)}</div>\n${footer_content}") or { println("unable to append footer to file: ${err}"); return }
}

fn resolve_all_posts() []Post {
	mut posts := []Post{}
	mut ref := &posts
	mut i := 0
	println("resolving all posts in ./blog")
	println("-----------------------------")
	os.walk("./blog", fn [mut i, mut ref] (path string) {
		i += 1
		if path.starts_with(".obsidian") || os.file_ext(path) != ".md" { return }

		if i <= 1 {
			println("-----------------------------")
		}
		raw_contents := os.read_file(path) or { panic("unable to read post ${os.base(path)} contents: ${err}") }
		println("found post: ${path}")

		front_matter := extract_front_matter(raw_contents)
		if front_matter.start_pos < front_matter.end_pos {
			println("START ${front_matter.start_pos}, END ${front_matter.end_pos}")
		}
		post := Post {
			meta: front_matter
			path: path
			raw_doc_content: raw_contents
			html_content: markdown.to_html(raw_contents)
			readtime: read_time.text(raw_contents, read_time.Options.new())
		}
		ref << post
		println("-----------------------------")
	})
	return posts
}

fn extract_front_matter(content string) FrontMatter {
	mut matter := FrontMatter{}
	println(">   extracting front matter")
	mut occurence_count := 0

	mut start_pos := 0
	mut end_pos := 0
	for i, line in content.split("\n") {
		if occurence_count == 2 { end_pos = i; break }

		if line == "---" {
			if occurence_count == 0 { start_pos = i }
			occurence_count += 1
			continue
		}

		parts := line.to_lower().replace(" ", "").split(":")
		if parts.len != 2 { continue }
		match parts[0] {
			"date" { matter.date = parts[1]; println("     |> date: ${matter.date}") }
			else {}
		}
	}
	matter.start_pos = start_pos
	matter.end_pos = if occurence_count == 2 { end_pos } else { 0 }
	if occurence_count != 2 {
		println(">   missing close/end line for front matter block")
	}
	return matter
}

fn main() {
	println("WEBSITE COMPILING ALL BLOG POSTS\n")
	posts := resolve_all_posts()

	header_content := os.read_file("./src/templates/header.html") or { panic("unable to extract header content") }
	front_matter_content := os.read_file("./src/templates/post_front_matter.html") or { panic("unable to extract front matter template") }
	footer_content := os.read_file("./src/templates/footer.html") or { panic("unable to extract footer content") }

	os.walk("./src/blog", fn (path string) { os.rm(path) or { println("unable to remove ${path}: ${err}"); return } })

	for _, p in posts {
		p.write_html_post(header_content, front_matter_content, footer_content)
	}
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

/*
fn main() {
	compile_markdown_blogs_into_html_files()
	target := "./src/resolve_blogs.v"
	code := generate_blog_embeds_code()
	os.rm(target) or { println("unable to remove ${target}: ${err}") }
	mut wfd := os.open_file(target, 'w') or { println("unable to open writable file: ${target}"); return }
	defer { wfd.close() }
	wfd.write_string(code) or { panic("unable to write to file: ${target}") }
}
*/
