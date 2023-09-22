module main

import os
import os.cmdline
import vweb
import encoding.html
import strconv
import strings

const (
	wolf_face_png = $embed_file('src/assets/imgs/black_wolf_face.png', .zlib)
	hack_css = $embed_file('src/assets/css/hack.css', .zlib)
	dark_grey_css = $embed_file('src/assets/css/dark-grey.css', .zlib)
	site_css = $embed_file('src/assets/css/site.css', .zlib)
	port = 8082
)

struct App {
	vweb.Context
mut:
	views shared map[string]int
}

fn resolve_port() int {
	port_arg := cmdline.option(os.args_after(""), "-port", "8082")
	return strconv.atoi(port_arg) or {
		println("invalid port ${port_arg} (must be digits)")
		exit(1)
	}
}

fn main() {
	vweb.run_at(new_app(), vweb.RunParams{
		port: resolve_port()
	}) or { panic(err) }
}

fn new_app() &App {
	shared views := map[string]int{}
	mut app := &App{ views: views }
	return app
}

['/assets/css/:name']
pub fn (mut app App) css(name string) vweb.Result {
	match name {
		"hack.css" {
			app.set_content_type(vweb.mime_types[".css"] or { "" })
			return app.ok(hack_css.to_string())
		}
		"dark-grey.css" {
			app.set_content_type(vweb.mime_types[".css"] or { "" })
			return app.ok(dark_grey_css.to_string())
		}
		"site.css" {
			app.set_content_type(vweb.mime_types[".css"] or { "" })
			return app.ok(site_css.to_string())
		}
		else {
			return app.not_found()
		}
	}
}

['/assets/black_wolf_face.png']
pub fn (mut app App) face() vweb.Result {
	app.set_content_type(vweb.mime_types[".png"] or { "" })
	return app.ok(wolf_face_png.to_string())
}

['/']
pub fn (mut app App) home() vweb.Result {
	lock app.views {
		if !request_is_me(app) {
			app.views["home"] += 1
		}
	}
	title := "tauraamui's website"
	return $vweb.html()
}

['/blog']
pub fn (mut app App) blog() vweb.Result {
	lock app.views {
		if !request_is_me(app) {
			app.views["blog"] += 1
		}
	}
	title := "Blog - tauraamui's website"
	existing_site := "https://tauraamui.substack.com/"
	return $vweb.html()
}


['/contact']
pub fn (mut app App) contact() vweb.Result {
	lock app.views {
		if !request_is_me(app) {
			app.views["contact"] += 1
		}
	}
	title := "Contact Info - tauraamui's website"
	email := html.escape("adamstringer@hey.com")
	github := html.escape("https://github.com/tauraamui")
	telegram := html.escape("https://t.me/tauraamui")
	discord := html.escape("https://discordapp.com/users/753689188213194862")
	return $vweb.html()
}

['/metrics']
pub fn (mut app App) metrics() vweb.Result {
	mut result := strings.new_builder(1024)
	lock app.views {
		if !request_is_me(app) {
			app.views["metrics"] += 1
			result.write_string("hello me!\n")
		}
		for k, v in app.views {
			result.write_string("${k}: ${v}\n")
		}
	}
	return app.text(result.str())
}

fn request_is_me(app App) bool {
	remote_ip := app.get_header("X-Real-IP")
	return remote_ip == "2a02:c7c:b415:9900:d228:9473:7550:5957" || remote_ip == "90.216.170.192"
}

