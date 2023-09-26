module main

const (
	how_to_wash_up_correctly = $embed_file('./src/blog/how-to-wash-up-correctly.html', .zlib)
	how_i_write_and_publish_blogs = $embed_file('./src/blog/how-i-write-and-publish-blogs.html', .zlib)
)

fn blogs_listing() []string {
	return [
		"how to wash up correctly"
		"how i write and publish blogs"
	]
}

fn resolve_blog(name string) !string {
	return match name {
		"how-to-wash-up-correctly.html" {
			how_to_wash_up_correctly.to_string()
		}
		"how-i-write-and-publish-blogs.html" {
			how_i_write_and_publish_blogs.to_string()
		}
		else { error("unable to resolve blog") }
	}
}
