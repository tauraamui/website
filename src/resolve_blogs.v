module main

const (
	how_i_write_and_publish_blogs = $embed_file('./src/blog/how-i-write-and-publish-blogs.html', .zlib)
	how_to_wash_up_correctly = $embed_file('./src/blog/how-to-wash-up-correctly.html', .zlib)
)

struct Listing {
	date string
	title string
	file_name string
}
fn blogs_listing() []Listing {
	return [
		Listing { date: "26/09/2023" title: " How I write and publish blogs", file_name: "how-i-write-and-publish-blogs" }
		Listing { date: "24/09/2023" title: " How to correctly wash up", file_name: "how-to-wash-up-correctly" }
	]
}

struct Post {
	title string
	content string
}

fn resolve_blog(name string) !Post {
	return match name {
		"how-i-write-and-publish-blogs" {
			Post { title: " How I write and publish blogs", content: how_i_write_and_publish_blogs.to_string() }
		}
		"how-to-wash-up-correctly" {
			Post { title: " How to correctly wash up", content: how_to_wash_up_correctly.to_string() }
		}
		else { error("unable to resolve blog") }
	}
}
