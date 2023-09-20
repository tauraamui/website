module main

import vweb

const (
	wolf_face_png = $embed_file('src/assets/imgs/black_wolf_face.png')
	hack_css = $embed_file('src/assets/css/hack.css')
	dark_grey_css = $embed_file('src/assets/css/dark-grey.css')
	site_css = $embed_file('src/assets/css/site.css')
	port = 8082
)

struct App {
	vweb.Context
}

fn main() {
	mut app := &App{}
	app.serve_static('/assets/black_wolf_face.png', 'src/assets/imgs/black_wolf_face.png')
	// app.serve_static('/assets/css/dark-grey.css', 'src/assets/css/dark-grey.css')
	// app.serve_static('/assets/css/hack.css', 'src/assets/css/hack.css')
	// makes all static files available.

	vweb.run(app, port)
}

['/assets/css/:name']
pub fn (mut app App) css(name string) vweb.Result {
	match name {
		"hack.css" {
			app.set_content_type(app.req.header.get(.content_type) or { "" })
			return app.ok(hack_css.to_string())
		}
		"dark-grey.css" {
			app.set_content_type(app.req.header.get(.content_type) or { "" })
			return app.ok(dark_grey_css.to_string())
		}
		"site.css" {
			app.set_content_type(app.req.header.get(.content_type) or { "" })
			return app.ok(site_css.to_string())
		}
		else {
			return app.not_found()
		}
	}
}

['/']
pub fn (mut app App) home() vweb.Result {
	title := "tauraamui's website"

	return $vweb.html()
}

