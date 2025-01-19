module main

import os
import arrays
import markdown

fn main() {
	println("\nResume compiler\n")

	header_content := os.read_file("./src/templates/header.html") or { panic("unable to extract header content") }
	footer_content := os.read_file("./src/templates/footer.html") or { panic("unable to extract footer content") }
	resume_contents_markdown := os.read_file("./src/resume.md") or { panic("unable to read resume ./resume.md content: ${err}") }

	println(resume_contents_markdown)
	println(markdown.to_html(resume_contents_markdown))

	mut rfd := os.open_file("./src/templates/resume.html", "w") or { panic("unable to open writable file ./src/templates/resume.html: ${err}") }
	defer { rfd.close() }

	rfd.write_string(header_content.replace("site.css", "resume.css")) or { panic("unable to write header: ${err}") }
	html_content := arrays.join_to_string(
		markdown.to_html(resume_contents_markdown).replace("<a href", "<a target='_blank' href").split("\n"), "\n", fn (e string) string { return "${" ".repeat(9)}${e}" }
	)
	rfd.write_string(html_content) or { panic("unable to write resume body: ${err}") }
	rfd.write_string(footer_content) or { panic("unable to write footer: ${err}") }
}
