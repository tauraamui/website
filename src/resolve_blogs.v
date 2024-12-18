module main

const learning_zig_for_the_first_time = $embed_file('./src/blog/learning-zig-for-the-first-time.html', .zlib)
const lilly_devlog_1_qsort_macos_bug = $embed_file('./src/blog/lilly-devlog-1-qsort-macos-bug.html', .zlib)
const where_did_you_buy_your_license = $embed_file('./src/blog/where-did-you-buy-your-license.html', .zlib)
const how_to_wash_up_correctly = $embed_file('./src/blog/how-to-wash-up-correctly.html', .zlib)
const how_i_write_and_publish_blogs = $embed_file('./src/blog/how-i-write-and-publish-blogs.html', .zlib)

struct Listing {
	date string
	title string
	file_name string
}
fn blogs_listing() []Listing {
	return [
		Listing { date: "06/12/2024" title: "Learning Zig (for the first time basically)", file_name: "learning-zig-for-the-first-time" }
		Listing { date: "05/10/2023" title: "You can't drive (yes you)", file_name: "where-did-you-buy-your-license" }
		Listing { date: "24/09/2023" title: "How to correctly wash up", file_name: "how-to-wash-up-correctly" }
		Listing { date: "26/09/2023" title: "How I write and publish blogs", file_name: "how-i-write-and-publish-blogs" }
	]
}

struct Post {
	title string
	content string
}

fn resolve_blog(name string) !Post {
	return match name {
		"learning-zig-for-the-first-time" {
			Post { title: "Learning Zig (for the first time basically)", content: learning_zig_for_the_first_time.to_string() }
		}
		"lilly-devlog-1-qsort-macos-bug" {
			Post { title: "Lilly Devlog 1 - QSort macOS bug", content: lilly_devlog_1_qsort_macos_bug.to_string() }
		}
		"where-did-you-buy-your-license" {
			Post { title: "You can't drive (yes you)", content: where_did_you_buy_your_license.to_string() }
		}
		"how-to-wash-up-correctly" {
			Post { title: "How to correctly wash up", content: how_to_wash_up_correctly.to_string() }
		}
		"how-i-write-and-publish-blogs" {
			Post { title: "How I write and publish blogs", content: how_i_write_and_publish_blogs.to_string() }
		}
		else { error("unable to resolve blog") }
	}
}
