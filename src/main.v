module main

import os
import os.cmdline
import vweb
import encoding.html
import strconv

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

fn resolve_port() int {
	port_arg := cmdline.option(os.args_after(""), "-port", "8082")
	return strconv.atoi(port_arg) or {
		println("invalid port ${port_arg} (must be digits)")
		exit(1)
	}
}

fn main() {
	mut app := &App{}
	vweb.run(app, resolve_port())
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

['/assets/black_wolf_face.png']
pub fn (mut app App) face() vweb.Result {
	return app.ok(wolf_face_png.to_string())
}

['/']
pub fn (mut app App) home() vweb.Result {
	title := "tauraamui's website"
	return $vweb.html()
}

['/blog']
pub fn (mut app App) blog() vweb.Result {
	title := "Blog - tauraamui's website"
	existing_site := "https://tauraamui.substack.com/"
	return $vweb.html()
}


['/contact']
pub fn (mut app App) contact() vweb.Result {
	title := "Contact Info - tauraamui's website"
	email := html.escape("adamstringer@hey.com")
	github := html.escape("https://github.com/tauraamui")
	telegram := html.escape("https://t.me/tauraamui")
	discord := html.escape("https://discordapp.com/users/753689188213194862")
	return $vweb.html()
}

