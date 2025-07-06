module main

const lilly_devlog_1_qsort_macos_bug = $embed_file('./src/blog/lilly-devlog-1-qsort-macos-bug.html', .zlib)
const learning_zig_for_the_first_time = $embed_file('./src/blog/learning-zig-for-the-first-time.html', .zlib)
const how_i_write_and_publish_blogs = $embed_file('./src/blog/how-i-write-and-publish-blogs.html', .zlib)
const how_to_wash_up_correctly = $embed_file('./src/blog/how-to-wash-up-correctly.html', .zlib)

struct Listing {
	date string
	formatted_date string
	tab_title string
	article_title string
	file_name string
}
fn blogs_listing() []Listing {
	return [
		Listing { date: "27/01/2025", formatted_date: "Monday, January 1, 2025" tab_title: "Lilly Devlog 1 - QSort macOS bug", article_title: "Lilly Devlog 1 - File picker ordering bug", file_name: "lilly-devlog-1-qsort-macos-bug" }
		Listing { date: "06/12/2024", formatted_date: "Friday, December 12, 2024" tab_title: "Learning Zig", article_title: "Learning Zig (for the first time basically)", file_name: "learning-zig-for-the-first-time" }
		Listing { date: "26/09/2023", formatted_date: "Tuesday, September 9, 2023" tab_title: "How I write and publish blogs", article_title: "How I write and publish blogs", file_name: "how-i-write-and-publish-blogs" }
		Listing { date: "24/09/2023", formatted_date: "Sunday, September 9, 2023" tab_title: "How to correctly wash up", article_title: "How to correctly wash up", file_name: "how-to-wash-up-correctly" }
	]
}

struct Post {
	tab_title string
	article_title string
	content string
}

fn resolve_blog(name string) !Post {
	return match name {
		"lilly-devlog-1-qsort-macos-bug" {
			Post { tab_title: "Lilly Devlog 1 - QSort macOS bug", article_title: "Lilly Devlog 1 - File picker ordering bug", content: lilly_devlog_1_qsort_macos_bug.to_string() }
		}
		"learning-zig-for-the-first-time" {
			Post { tab_title: "Learning Zig", article_title: "Learning Zig (for the first time basically)", content: learning_zig_for_the_first_time.to_string() }
		}
		"how-i-write-and-publish-blogs" {
			Post { tab_title: "How I write and publish blogs", article_title: "How I write and publish blogs", content: how_i_write_and_publish_blogs.to_string() }
		}
		"how-to-wash-up-correctly" {
			Post { tab_title: "How to correctly wash up", article_title: "How to correctly wash up", content: how_to_wash_up_correctly.to_string() }
		}
		else { error("unable to resolve blog") }
	}
}
