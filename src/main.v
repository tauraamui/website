module main

import os
import os.cmdline
import veb
import net.http
import net.urllib
import encoding.html
import strconv
import time

const wolf_face_png = $embed_file('./src/assets/imgs/black_wolf_face.png')
const hack_css = $embed_file('./src/assets/css/hack.css', .zlib)
const dark_grey_css = $embed_file('./src/assets/css/dark-grey.css', .zlib)
const site_css = $embed_file('./src/assets/css/site.css', .zlib)
const blog_css = $embed_file('./src/assets/css/blog.css', .zlib)
const prism_css = $embed_file('./src/assets/css/prism.css', .zlib)

const prism_js = $embed_file('./src/assets/js/prism.js', .zlib)

const rubik_font = $embed_file('./src/assets/css/fonts/latin-rubik.woff2', .zlib)
const rubik_ext_font = $embed_file('./src/assets/css/fonts/latin-ext-rubik.woff2', .zlib)
// pending potential removal
/*
spectral_font = $embed_file('./src/assets/css/fonts/latin-spectral.woff2', .zlib)
spectral_ext_font = $embed_file('./src/assets/css/fonts/latin-ext-spectral.woff2', .zlib)
*/

const port = 8082

pub struct Context {
	veb.Context
mut:
	theme_mode string
}

pub fn before_request(mut ctx Context) bool {
	ctx.theme_mode = ctx.get_cookie(theme_cookie_name) or { "dark" }
	return true
}

pub struct App {
	veb.Middleware[Context]
	veb.StaticHandler
mut:
	views shared map[string]int
}


fn resolve_port() int {
	port_arg := cmdline.option(os.args_after(""), "-port", "8080")
	return strconv.atoi(port_arg) or {
		println("invalid port ${port_arg} (must be digits)")
		exit(1)
	}
}

fn main() {
	mut app := new_app()
	app.use(handler: before_request)
	veb.run[App, Context](mut app, resolve_port())
}

fn new_app() App {
	shared views := map[string]int{}
	mut app := App{ views: views }
	app.mount_static_folder_at("./blog/static", "/static") or { panic(err) }
	return app
}

@['/assets/css/:name']
pub fn (mut app App) css(mut ctx Context, name string) veb.Result {
	match name {
		"hack.css" {
			ctx.set_content_type(veb.mime_types[".css"] or { "" })
			return ctx.ok(hack_css.to_string())
		}
		"dark-grey.css" {
			ctx.set_content_type(veb.mime_types[".css"] or { "" })
			return ctx.ok(dark_grey_css.to_string())
		}
		"site.css" {
			ctx.set_content_type(veb.mime_types[".css"] or { "" })
			return ctx.ok(site_css.to_string())
		}
		"blog.css" {
			ctx.set_content_type(veb.mime_types[".css"] or { "" })
			return ctx.ok(blog_css.to_string())
		}
		"prism.css" {
			ctx.set_content_type(veb.mime_types[".css"] or { "" })
			return ctx.ok(prism_css.to_string())
		}
		else {
			return ctx.not_found()
		}
	}
}

@['/assets/js/prism.js']
pub fn (mut app App) prism_js(mut ctx Context) veb.Result {
	ctx.set_content_type(veb.mime_types[".js"] or { "" })
	return ctx.ok(prism_js.to_string())
}

@['/assets/css/fonts/:name']
pub fn (mut app App) fonts(mut ctx Context, name string) veb.Result {
	match name {
		"latin-rubik.woff2" {
			ctx.set_content_type(veb.mime_types[".woff2"] or { "" })
			return ctx.ok(rubik_font.to_string())
		}
		"latin-ext-rubik.woff2" {
			ctx.set_content_type(veb.mime_types[".woff2"] or { "" })
			return ctx.ok(rubik_ext_font.to_string())
		}
		// pending potential removal
		/*
		"latin-spectral.woff2" {
			ctx.set_content_type(veb.mime_types[".woff2"] or { "" })
			return ctx.ok(spectral_font.to_string())
		}
		"latin-ext-spectral.woff2" {
			ctx.set_content_type(veb.mime_types[".woff2"] or { "" })
			return ctx.ok(spectral_ext_font.to_string())
		}
		*/
		else {
			return ctx.not_found()
		}
	}
}

@['/assets/black_wolf_face.png']
pub fn (mut app App) face(mut ctx Context) veb.Result {
	ctx.set_content_type(veb.mime_types[".png"] or { "" })
	return ctx.ok(wolf_face_png.to_string())
}

@['/']
pub fn (mut app App) home(mut ctx Context) veb.Result {
	lock app.views {
		if !request_is_me(app) {
			app.views["home"] += 1
		}
	}

	title := "tauraamui's website"
	return $veb.html()
}

@['/blog']
pub fn (mut app App) blog(mut ctx Context) veb.Result {
	lock app.views {
		if !request_is_me(app) {
			app.views["blog"] += 1
		}
	}
	posts := blogs_listing()
	title := "Blog - tauraamui's website"
	return $veb.html()
}

@['/blog/:name']
pub fn (mut app App) blog_view(mut ctx Context, name string) veb.Result {
	post := resolve_blog(name) or { return ctx.not_found() }
	lock app.views {
		if !request_is_me(app) {
			app.views["blog: ${name}"] += 1
		}
	}
	title := post.title
	header_content := $tmpl("./templates/header.html")
	// return app.html(post.content.replace("\$\{title\}", "${post.title} - tauraamui's website").replace("site.css", "blog.css"))
	return ctx.html(post.content.replace("\$\{title\}", "${post.title} - tauraamui's website").replace("\$<\{header\}>", header_content).replace("site.css", "blog.css"))
}

@['/contact']
pub fn (mut app App) contact(mut ctx Context) veb.Result {
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
	return $veb.html()
}

const theme_cookie_name := "theme"
const valid_themes = ["dark", "light"]

@['/theme/:mode'; post]
pub fn (mut app App) set_theme(mut ctx Context, mode string) veb.Result {
	lock app.views {
		if !request_is_me(app) {
			app.views["set-theme"] += 1
		}
	}

	url := urllib.parse(ctx.req.url) or { ctx.res.set_status(http.Status.internal_server_error); return ctx.text('error: invalid redirect url') }
	origin_url := url.query().get("redirect") or { "/" }

	theme_index := valid_themes.index(mode)
	if theme_index < 0 {
		ctx.res.set_status(http.Status.bad_request)
		return ctx.text('error: unexpected theme mode: ${mode}')
	}

	ctx.set_cookie(http.Cookie{ name: theme_cookie_name, value: valid_themes[theme_index], path: '/', expires: time.now().add_days(30) })
	return ctx.redirect(origin_url)
}

/*
@['/metrics']
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
*/

fn request_is_me(app App) bool {
	return false
}

