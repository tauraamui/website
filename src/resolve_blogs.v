module main

const (
	how_i_write_and_publish_blogs = $embed_file('./src/blog/how-i-write-and-publish-blogs.html', .zlib)
	how_to_wash_up_correctly = $embed_file('./src/blog/how-to-wash-up-correctly.html', .zlib)
)

fn blogs_listing() []string {
	return [
		"how i write and publish blogs"
		"how to wash up correctly"
	]
}

fn resolve_blog(name string) !string {
	return match name {
		"how-i-write-and-publish-blogs.html" {
			how_i_write_and_publish_blogs.to_string()
		}
		"how-to-wash-up-correctly.html" {
			how_to_wash_up_correctly.to_string()
		}
		else { error("unable to resolve blog") }
	}
}
