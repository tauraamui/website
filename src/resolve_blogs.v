module main

const (
	how_i_write_and_publish_blogs = $embed_file('./src/blog/how-i-write-and-publish-blogs.html', .zlib)
	how_to_wash_up_correctly = $embed_file('./src/blog/how-to-wash-up-correctly.html', .zlib)
)

struct Listing {
	title string
	file_name string
}
fn blogs_listing() []Listing {
	return [
		Listing { title: "26/09/2023 -  How I write and publish blogs", file_name: "how-i-write-and-publish-blogs" }
		Listing { title: "24/09/2023 -  How to correctly wash up", file_name: "how-to-wash-up-correctly" }
	]
}

fn resolve_blog(name string) !string {
	return match name {
		"how-i-write-and-publish-blogs" {
			how_i_write_and_publish_blogs.to_string()
		}
		"how-to-wash-up-correctly" {
			how_to_wash_up_correctly.to_string()
		}
		else { error("unable to resolve blog") }
	}
}
