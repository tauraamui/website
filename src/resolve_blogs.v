module main

const (
	how_to_wash_up_correctly = $embed_file('./src/blog/how-to-wash-up-correctly.html', .zlib)
)

fn resolve_blog(name string) !string {
	return match name {
		"how-to-wash-up-correctly.html" {
			how_to_wash_up_correctly.to_string()
		}
		else { error("unable to resolve blog") }
	}
}
