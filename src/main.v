module main

import os
import os.cmdline
import veb
import net.http
import net.urllib
import encoding.html
import strconv
import time
import json
import db.pg

const wolf_face_png = $embed_file('./src/assets/imgs/black_wolf_face.png')
const hack_css = $embed_file('./src/assets/css/hack.css', .zlib)
const dark_grey_css = $embed_file('./src/assets/css/dark-grey.css', .zlib)
const site_css = $embed_file('./src/assets/css/site.css', .zlib)
const blog_css = $embed_file('./src/assets/css/blog.css', .zlib)
const resume_css = $embed_file('./src/assets/css/resume.css', .zlib)
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

struct Config {
pub mut:
	use_analytics bool
	db_host string @[json: "host"]
	db_port int    @[json: "port"]
	db_user string @[json: "user"]
	db_pass string @[json: "password"]
	db_name string @[json: "dbname"]
}

fn resolve_db_config() !Config {
	config_file_content := os.read_file("db.config") or { return error("unable to read config file: ${err}") }
	mut parsed_config := json.decode(Config, config_file_content) or { return error("unable to decode config from JSON: ${err}") }
	parsed_config.use_analytics = true
	return parsed_config
}

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
	cfg Config
mut:
	views shared map[string]int
}

@[table: 'metrics']
struct Metric {
	id              string @[default: 'gen_random_uuid()'; primary; sql_type: 'uuid']
	event_timestamp string @[default: 'CURRENT_TIMESTAMP'; sql_type: 'TIMESTAMP WITH TIME ZONE NOT NULL']
	event_type      string
	page_url        string
	referrer_url    ?string
	ip              ?string
	browser         ?string
	country         ?string
}

fn resolve_port() int {
	port_arg := cmdline.option(os.args_after(""), "-port", "8080")
	return strconv.atoi(port_arg) or {
		println("invalid port ${port_arg} (must be digits)")
		exit(1)
	}
}

fn create_tables(cfg Config) ! {
	db := pg.connect(pg.Config{
		host: cfg.db_host
		port: cfg.db_port
		user: cfg.db_user
		password: cfg.db_pass
		dbname: cfg.db_name
	}) or { return error("unable to connect to DB: ${err}") }
	defer { db.close() }

	sql db {
		create table Metric
	}!
}

fn store_metric(cfg Config, metric Metric) {
	db := pg.connect(pg.Config{
		host: cfg.db_host
		port: cfg.db_port
		user: cfg.db_user
		password: cfg.db_pass
		dbname: cfg.db_name
	}) or { println("unable to connect to DB: ${err}"); return }
	defer { db.close() }
	sql db {
		insert metric into Metric
	} or { println("failed to insert metric into table: ${err}") }
}

fn main() {
	mut config := resolve_db_config() or { println("failed to resolve DB config: ${err}"); Config{ use_analytics: false } }
	if config.use_analytics {
		println("ANALYTICS ENABLED -> SETTING UP DB")
		create_tables(config) or { config.use_analytics = false; println("failed to setup DB: ${err}"); println("ANALYTICS FORCE DISABLED!") }
	}
	mut app := new_app(config)
	app.use(handler: before_request)
	veb.run[App, Context](mut app, resolve_port())
}

fn new_app(cfg Config) App {
	shared views := map[string]int{}
	mut app := App{ cfg: cfg, views: views }
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
		"resume.css" {
			ctx.set_content_type(veb.mime_types[".css"] or { "" })
			return ctx.ok(resume_css.to_string())
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

	spawn store_metric(app.cfg, Metric{
		event_type: "page_view"
		page_url: "${ctx.req.host}${ctx.req.url}"
		browser: ctx.req.user_agent
		referrer_url: ctx.req.referer()
	})

	tab_title := "tauraamui's website"
	return $veb.html()
}

@['/blog']
pub fn (mut app App) blog(mut ctx Context) veb.Result {
	lock app.views {
		if !request_is_me(app) {
			app.views["blog"] += 1
		}
	}
	spawn store_metric(app.cfg, Metric{
		event_type: "page_view"
		page_url: "${ctx.req.host}${ctx.req.url}"
		browser: ctx.req.user_agent
		referrer_url: ctx.req.referer()
	})
	posts := blogs_listing()
	tab_title := "Blog - tauraamui's website"
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
	spawn store_metric(app.cfg, Metric{
		event_type: "page_view"
		page_url: "${ctx.req.host}${ctx.req.url}"
		browser: ctx.req.header.get(.user_agent) or { "empty" }
		referrer_url: ctx.req.referer()
	})
	tab_title := post.tab_title
	header_content := $tmpl("./templates/header.html")
	// return app.html(post.content.replace("\$\{title\}", "${post.title} - tauraamui's website").replace("site.css", "blog.css"))
	return ctx.html(post.content.replace(
		"\$\{tab_title\}", "${post.tab_title} - tauraamui's website"
		).replace("\$<\{header\}>", header_content
		).replace("site.css", "blog.css"
	))
}

@['/resume']
pub fn (mut app App) resume(mut ctx Context) veb.Result {
	lock app.views {
		if !request_is_me(app) {
			app.views["resume"] += 1
		}
	}
	spawn store_metric(app.cfg, Metric{
		event_type: "page_view"
		page_url: "${ctx.req.host}${ctx.req.url}"
		browser: ctx.req.user_agent
		referrer_url: ctx.req.referer()
	})
	tab_title := "Resume - tauraamui's website'"
	return $veb.html()
}

@['/contact']
pub fn (mut app App) contact(mut ctx Context) veb.Result {
	lock app.views {
		if !request_is_me(app) {
			app.views["contact"] += 1
		}
	}
	spawn store_metric(app.cfg, Metric{
		event_type: "page_view"
		page_url: "${ctx.req.host}${ctx.req.url}"
		browser: ctx.req.header.get(.user_agent) or { "empty" }
		referrer_url: ctx.req.referer()
	})
	tab_title := "Contact Info - tauraamui's website"
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

	spawn store_metric(app.cfg, Metric{
		event_type: "page_view"
		page_url: "${ctx.req.host}${ctx.req.url}"
		browser: ctx.req.header.get(.user_agent) or { "empty" }
		referrer_url: ctx.req.referer()
	})

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

