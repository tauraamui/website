module main

import os
import os.cmdline
import vweb
import encoding.html
import strconv
import strings
import read_time

const (
	wolf_face_png = $embed_file('./src/assets/imgs/black_wolf_face.png')
	hack_css = $embed_file('./src/assets/css/hack.css', .zlib)
	dark_grey_css = $embed_file('./src/assets/css/dark-grey.css', .zlib)
	site_css = $embed_file('./src/assets/css/site.css', .zlib)
	blog_css = $embed_file('./src/assets/css/blog.css', .zlib)

	rubik_font = $embed_file('./src/assets/css/fonts/latin-rubik.woff2', .zlib)
	rubik_ext_font = $embed_file('./src/assets/css/fonts/latin-ext-rubik.woff2', .zlib)
	// pending potential removal
	/*
	spectral_font = $embed_file('./src/assets/css/fonts/latin-spectral.woff2', .zlib)
	spectral_ext_font = $embed_file('./src/assets/css/fonts/latin-ext-spectral.woff2', .zlib)
	*/

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
	app.mount_static_folder_at("./blog/static", "/static")
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
		"blog.css" {
			app.set_content_type(vweb.mime_types[".css"] or { "" })
			return app.ok(blog_css.to_string())
		}
		else {
			return app.not_found()
		}
	}
}

['/assets/css/fonts/:name']
pub fn (mut app App) fonts(name string) vweb.Result {
	match name {
		"latin-rubik.woff2" {
			app.set_content_type(vweb.mime_types[".woff2"] or { "" })
			return app.ok(rubik_font.to_string())
		}
		"latin-ext-rubik.woff2" {
			app.set_content_type(vweb.mime_types[".woff2"] or { "" })
			return app.ok(rubik_ext_font.to_string())
		}
		// pending potential removal
		/*
		"latin-spectral.woff2" {
			app.set_content_type(vweb.mime_types[".woff2"] or { "" })
			return app.ok(spectral_font.to_string())
		}
		"latin-ext-spectral.woff2" {
			app.set_content_type(vweb.mime_types[".woff2"] or { "" })
			return app.ok(spectral_ext_font.to_string())
		}
		*/
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
	posts := blogs_listing()
	title := "Blog - tauraamui's website"
	return $vweb.html()
}

['/blog/:name']
pub fn (mut app App) blog_view(name string) vweb.Result {
	lock app.views {
		if !request_is_me(app) {
			app.views["blog: ${name}"] += 1
		}
	}
	content := resolve_blog(name) or { return app.not_found() }
	opts := read_time.Options.new()
	time := read_time.text(content, opts)
	println("${time}")
	return app.html(content.replace("\$\{title\}", "${name.replace("-", " ").capitalize().replace(" i ", " I ")} - tauraamui's website").replace("site.css", "blog.css"))
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
		} else {
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

