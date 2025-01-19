module main

import os
import markdown
import strings
import src.lib.read_time
import arrays
import time

struct Post {
	path string
	meta FrontMatter
	raw_doc_content string
	html_content string
mut:
	html_path string
}

struct FrontMatter {
mut:
	date           time.Time
	tab_title      string
	article_title  string
	published      bool
	readtime       read_time.ReadTime
}

fn (mut post Post) write_html_post(footer_content string) {
	target := "./src/blog/${os.base(post.path)}".replace(".md", ".html")
	post.html_path = target

	mut wfd := os.open_file(target, 'w') or { println("unable to open writable file ${target}: ${err}"); return }
	defer { wfd.close() }

	wfd.write_string("$<{header}>") or { println("unable to write header placeholder: ${err}"); return }
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

		mut raw_contents := os.read_file(path) or { panic("unable to read post ${os.base(path)} contents: ${err}") }
		println("found post: ${path}")

		front_matter, mut contents := extract_front_matter(raw_contents)
		read_time_minutes := front_matter.readtime.seconds / 60

		mut html_content := arrays.join_to_string(
			markdown.to_html(contents).replace("<a href", "<a target='_blank' href").split("\n"), "\n", fn (e string) string { return "${" ".repeat(9)}${e}" }
		)
		html_content = html_content.replace("<p>#{article_title}</p>", "#{article_title}")
		html_content = expand_article_header(html_content, front_matter.date, front_matter.article_title, read_time_minutes)

		post := Post {
			meta: front_matter
			path: path
			raw_doc_content: contents
			html_content: html_content
		}
		ref << post
		println("-----------------------------")
	})
	posts.sort(a.meta.date > b.meta.date)
	return posts
}

fn expand_article_header(
	html_content      string,
	date              time.Time,
	article_title     string,
	read_time_minutes u64
) string {
	read_time_text := "${read_time_minutes} minute${if read_time_minutes > 1 || read_time_minutes == 0 { "s" } else { "" }}"
	mut sb := strings.new_builder(1024)
	sb.writeln("<header>")
	sb.writeln("<h1 class=\"title\">${article_title}</h1>")
	sb.writeln("<div class=\"meta\">")
	sb.writeln("<div class=\"postdate\">")
	sb.writeln("<i class=\"icon feather icon-calendar\"></i><time>${date.ymmdd()}</time>")
	sb.writeln("</div>")
	sb.writeln("<span class=\"meta-separator\">|</span>")
	sb.writeln("<div class=\"readtime\">")
	sb.writeln("<i class=\"icon feather icon-clock\"></i><time>${read_time_text}</time>")
	sb.writeln("</div>")
	sb.writeln("</div>")
	sb.writeln("</header>")
	return html_content.replace("#{article_title}", sb.str())
}

fn extract_front_matter(content string) (FrontMatter, string) {
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

		parts := line.split(":")
		if parts.len != 2 { continue }
		match parts[0].to_lower() {
			"tab_title" { matter.tab_title = parts[1].trim_left(" "); println("\t-> tab title: ${matter.tab_title}") }
			"article_title" { matter.article_title = parts[1].trim_left(" "); println("\t-> article title: ${matter.article_title}") }
			"date" {
				date_str := parts[1].trim_space()
				matter.date = time.parse_format(date_str, "DD/MM/YYYY") or { println("\t-> date: INVALID DATE/TIME '${date_str}'"); time.Time{} }
				if matter.date == time.Time{} { continue }
				println("\t-> date: ${matter.date}")
			}
			"published" {
				matter.published = match parts[1].trim_space() {
					"yes" { true }
					"no" { false }
					else { false }
				}
				println("\t-> published: ${matter.published}")
			}
			else {}
		}
	}
	if occurence_count != 2 {
		println(">   missing close/end line for front matter block")
	}


	mut cut_contents := ""
	if start_pos < end_pos {
		if start_pos == 0 {
			cut_contents = arrays.join_to_string(content.split("\n")[end_pos..], "\n", fn (e string) string { return e })
		}
	}
	matter.readtime = read_time.text(cut_contents, read_time.Options.new())
	println("\t-> read time: ${matter.readtime.seconds} seconds")
	return matter, cut_contents
}

fn main() {
	println("\nBlog compiler\n")
	mut posts := resolve_all_posts()

	// header_content := os.read_file("./src/templates/header.html") or { panic("unable to extract header content") }
	footer_content := os.read_file("./src/templates/footer.html") or { panic("unable to extract footer content") }

	os.walk("./src/blog", fn (path string) { os.rm(path) or { println("unable to remove ${path}: ${err}"); return } })

	for _, mut p in posts {
		p.write_html_post(footer_content)
	}

	code := generate_embedding_code(posts)

	target := "./src/resolve_blogs.v"
	os.rm(target) or { println("unable to remove ${target}: ${err}") }
	mut wfd := os.open_file(target, 'w') or { println("unable to open writable file: ${target}"); return }
	defer { wfd.close() }
	println("writing generated embed code to ${target}")
	wfd.write_string(code) or { panic("unable to write to file: ${target}") }
}

fn generate_embedding_code(posts []Post) string {
	mut code := strings.new_builder(1024)

	code.writeln("module main")
	code.writeln("")
	for _, p in posts {
		code.writeln("const ${os.base(p.html_path).replace("-", "_").replace(".html", "")} = \$embed_file('${p.html_path}', .zlib)")
	}
	code.writeln("")

	code.writeln("struct Listing {")
	code.writeln("\tdate string")
	code.writeln("\ttab_title string")
	code.writeln("\tarticle_title string")
	code.writeln("\tfile_name string")
	code.writeln("}")

	code.writeln("fn blogs_listing() []Listing {")
	code.writeln("\treturn [")
	println("generating blog list:")
	for _, p in posts {
		if !p.meta.published {
			println("skipping adding \"${p.meta.article_title.trim_left(' ')}\" to listing page, as its unpublished...")
		}
		if p.meta.published {
			println(">\t writing blog ${p.meta.article_title}")
			code.writeln("\t\tListing { date: \"${p.meta.date.custom_format('DD/MM/YYYY')}\" tab_title: \"${p.meta.tab_title}\", article_title: \"${p.meta.article_title}\", file_name: \"${os.base(p.html_path).replace(".html", "")}\" }")
		}
	}
	code.writeln("\t]")
	code.writeln("}")

	code.writeln("")

	code.writeln("struct Post {")
	code.writeln("\ttab_title string")
	code.writeln("\tarticle_title string")
	code.writeln("\tcontent string")
	code.writeln("}")

	code.writeln("")

	code.writeln("fn resolve_blog(name string) !Post {")
	code.writeln("\treturn match name {")
	for _, p in posts {
		name := os.base(p.html_path)
		code.writeln("\t\t\"${name.replace(".html", "")}\" {")
		code.writeln("\t\t\tPost { tab_title: \"${p.meta.tab_title}\", article_title: \"${p.meta.article_title}\", content: ${name.replace("-", "_").replace(".html", "")}.to_string() }")
		code.writeln("\t\t}")
	}
	code.writeln("\t\telse { error(\"unable to resolve blog\") }")
	code.writeln("\t}")
	code.writeln("}")

	return code.str()
}

