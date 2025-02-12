module main

import os
import os.cmdline
import veb
import net.http
import net.urllib
import encoding.html
import encoding.base64
import strconv
import time
import json
import db.pg

const favicon_ico = $embed_file('./src/assets/imgs/favicon.ico')
const wolf_face_png = $embed_file('./src/assets/imgs/black_wolf_face.png')
const hack_css = $embed_file('./src/assets/css/hack.css', .zlib)
const dark_grey_css = $embed_file('./src/assets/css/dark-grey.css', .zlib)
const site_css = $embed_file('./src/assets/css/site.css', .zlib)
const blog_css = $embed_file('./src/assets/css/blog.css', .zlib)
const resume_css = $embed_file('./src/assets/css/resume.css', .zlib)
const prism_css = $embed_file('./src/assets/css/prism.css', .zlib)
const analytics_css = $embed_file('./src/assets/css/analytics.css', .zlib)

const prism_js = $embed_file('./src/assets/js/prism.js', .zlib)
const analytics_js = $embed_file('./src/assets/js/analytics.js', .zlib)
// const alasqlv4_js = $embed_file('./src/assets/js/alasqlv4.js', .zlib)

const rubik_font = $embed_file('./src/assets/css/fonts/latin-rubik.woff2', .zlib)
const rubik_ext_font = $embed_file('./src/assets/css/fonts/latin-ext-rubik.woff2', .zlib)

const feed_rss = $embed_file('./src/blog/feed.rss', .zlib)
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
	analytics_password string @[json: "analytics-password"]
}

fn resolve_db_config() !Config {
	config_file_content := os.read_file("website.config") or { return error("unable to read config file: ${err}") }
	mut parsed_config := json.decode(Config, config_file_content) or { return error("unable to decode config from JSON: ${err}") }
	parsed_config.use_analytics = true
	return parsed_config
}

pub struct Context {
	veb.Context
mut:
	theme_mode     string
	load_analytics bool
	use_giscus     bool
}

pub fn before_request(mut ctx Context) bool {
	ctx.theme_mode = ctx.get_cookie(theme_cookie_name) or { "dark" }
	return true
}

pub struct App {
	veb.Middleware[Context]
	veb.StaticHandler
	cfg Config
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
	} or { println("failed to create table: ${err}") }
}

fn store_metric(cfg Config, metric Metric) {
	if metric.page_url.contains("localhost") {
		return
	}
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

const query_last_30_days_all_requests := "
	SELECT
		*
	FROM
		metrics
	WHERE event_timestamp >= CURRENT_TIMESTAMP - INTERVAL '30 days'
"

const query_last_30_days_exclude_likely_bot_requests := "
	WITH filtered_metrics AS (
		SELECT
			*,
			LAG(event_timestamp) OVER (PARTITION BY ip ORDER BY event_timestamp) AS previous_timestamp
		FROM
			metrics
		WHERE
			event_timestamp >= CURRENT_TIMESTAMP - INTERVAL '30 days'
	)
	SELECT
		*
	FROM
		filtered_metrics
	WHERE
		previous_timestamp IS NULL OR
		event_timestamp - previous_timestamp > INTERVAL '1 second'
	AND NOT (
		page_url ~ '^(\\d{1,3}\\.){3}\\d{1,3}$' OR  -- Matches IPv4 format
        referrer_url LIKE 'http://tauraamui.website%' OR
        browser LIKE 'Twitterbot/%'
    );
"

fn query_metrics(cfg Config) ?[]Metric {
	db := pg.connect(pg.Config{
		host: cfg.db_host
		port: cfg.db_port
		user: cfg.db_user
		password: cfg.db_pass
		dbname: cfg.db_name
	}) or { eprintln("unable to connect to DB: ${err}"); return none }
	defer { db.close() }

	metric_rows := db.exec(query_last_30_days_exclude_likely_bot_requests) or { eprintln("failed to query metrics: ${err}"); return none }

	return metric_rows.map(fn (row pg.Row) Metric {
		values := row.vals

		id_val := values[0]
		event_timestamp_val := values[1]
		event_type_val := values[2]
		page_url_val := values[3]
		referrer_url := values[4]
		ip_val := values[5]
		browser_val := values[6]
		country_val := values[7]

		return Metric{
			id: id_val or { "" }
			event_timestamp: event_timestamp_val or { "" }
			event_type: event_type_val or { "" }
			page_url: page_url_val or { "" }
			referrer_url: referrer_url or { "" }
			ip: ip_val or { "" }
			browser: browser_val or { "" }
			country: country_val or { "" }
		}
	})
}

fn main() {
	mut config := resolve_db_config() or { println("failed to resolve DB config: ${err}"); Config{ use_analytics: false } }
	if config.use_analytics {
		println("ANALYTICS ENABLED -> SETTING UP DB")
		// create_tables(config) or { config.use_analytics = false; println("failed to setup DB: ${err}"); println("ANALYTICS FORCE DISABLED!") }
	}
	mut app := new_app(config)
	app.use(handler: before_request)
	veb.run[App, Context](mut app, resolve_port())
}

fn new_app(cfg Config) App {
	mut app := App{ cfg: cfg }
	app.serve_static("/assets/js/alasqlv4.js", "./assets/js/alasqlv4.js") or { panic(err) }
	app.mount_static_folder_at("./blog/static", "/static") or { panic(err) }
	return app
}

@['/favicon.ico']
pub fn (mut app App) favicon_ico(mut ctx Context) veb.Result {
	ctx.set_content_type(veb.mime_types[".ico"] or { "" })
	return ctx.ok(favicon_ico.to_string())
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
		"analytics.css" {
			ctx.set_content_type(veb.mime_types[".css"] or { "" })
			return ctx.ok(analytics_css.to_string())
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

@['/assets/js/analytics.js']
pub fn (mut app App) analytics_js(mut ctx Context) veb.Result {
	ctx.set_content_type(veb.mime_types[".js"] or { "" })
	return ctx.ok(analytics_js.to_string())
}

/*
@['/assets/js/alasqlv4.js']
pub fn (mut app App) alasqlv4_js(mut ctx Context) veb.Result {
	ctx.set_content_type(veb.mime_types[".js"] or { "" })
	return ctx.ok(alasqlv4_js.to_string())
}
*/

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
	match ctx.req.url {
		"/" {
			spawn store_metric(app.cfg, Metric{
				event_type: "page_view"
				page_url: "${ctx.req.host}${ctx.req.url}"
				browser: ctx.req.header.get(.user_agent) or { "empty" }
				ip: ctx.ip()
				referrer_url: ctx.req.referer()
				country: ctx.req.header.get_custom("CF-IPCountry", http.HeaderQueryConfig{ exact: true }) or { "" }
			})

			tab_title := "tauraamui's website"
			metric_data := ""
			return $veb.html()
		}
		else { return ctx.not_found() }
	}
}

@['/blog']
pub fn (mut app App) blog(mut ctx Context) veb.Result {
	spawn store_metric(app.cfg, Metric{
		event_type: "page_view"
		page_url: "${ctx.req.host}${ctx.req.url}"
		browser: ctx.req.header.get(.user_agent) or { "empty" }
		ip: ctx.ip()
		referrer_url: ctx.req.referer()
		country: ctx.req.header.get_custom("CF-IPCountry", http.HeaderQueryConfig{ exact: true }) or { "" }
	})

	posts := blogs_listing()
	tab_title := "Blog - tauraamui's website"
	metric_data := ""
	return $veb.html()
}

@['/blog/feed.rss']
pub fn (mut app App) rss_feed(mut ctx Context) veb.Result {
	ctx.set_content_type(veb.mime_types[".rss"] or { "" })
	return ctx.ok(feed_rss.to_string())
}

@['/blog/:name']
pub fn (mut app App) blog_view(mut ctx Context, name string) veb.Result {
	post := resolve_blog(name) or { return ctx.not_found() }

	spawn store_metric(app.cfg, Metric{
		event_type: "page_view"
		page_url: "${ctx.req.host}${ctx.req.url}"
		browser: ctx.req.header.get(.user_agent) or { "empty" }
		ip: ctx.ip()
		referrer_url: ctx.req.referer()
		country: ctx.req.header.get_custom("CF-IPCountry", http.HeaderQueryConfig{ exact: true }) or { "" }
	})

	ctx.use_giscus = true
	tab_title := post.tab_title
	metric_data := ""
	header_content := $tmpl("./templates/header.html")
	footer_content := $tmpl("./templates/footer.html")
	// return app.html(post.content.replace("\$\{title\}", "${post.title} - tauraamui's website").replace("site.css", "blog.css"))
	return ctx.html(post.content.replace(
		"\$\{tab_title\}", "${post.tab_title} - tauraamui's website"
		).replace("\$<\{header\}>", header_content
		).replace("\$<\{footer\}>", footer_content
		).replace("site.css", "blog.css"
	))
}

@['/resume']
pub fn (mut app App) resume(mut ctx Context) veb.Result {
	spawn store_metric(app.cfg, Metric{
		event_type: "page_view"
		page_url: "${ctx.req.host}${ctx.req.url}"
		browser: ctx.req.header.get(.user_agent) or { "empty" }
		ip: ctx.ip()
		referrer_url: ctx.req.referer()
		country: ctx.req.header.get_custom("CF-IPCountry", http.HeaderQueryConfig{ exact: true }) or { "" }
	})

	tab_title := "Resume - tauraamui's website'"
	metric_data := ""
	return $veb.html()
}

@['/contact']
pub fn (mut app App) contact(mut ctx Context) veb.Result {
	spawn store_metric(app.cfg, Metric{
		event_type: "page_view"
		page_url: "${ctx.req.host}${ctx.req.url}"
		browser: ctx.req.header.get(.user_agent) or { "empty" }
		ip: ctx.ip()
		referrer_url: ctx.req.referer()
		country: ctx.req.header.get_custom("CF-IPCountry", http.HeaderQueryConfig{ exact: true }) or { "" }
	})

	tab_title := "Contact Info - tauraamui's website"
	email := html.escape("adamstringer@hey.com")
	github := html.escape("https://github.com/tauraamui")
	telegram := html.escape("https://t.me/tauraamui")
	discord := html.escape("https://discordapp.com/users/753689188213194862")
	x       := html.escape("https://x.com/tauraamuix")
	metric_data := ""
	return $veb.html()
}

const theme_cookie_name := "theme"
const valid_themes = ["dark", "light"]

@['/analytics']
pub fn (mut app App) analytics(mut ctx Context) veb.Result {
	url := urllib.parse(ctx.req.url) or { return ctx.not_found() }
	password := url.query().get("password") or { return ctx.not_found() }
	if app.cfg.analytics_password != password {
		ctx.res.set_status(http.Status.unauthorized)
		return ctx.text("unauthorized: invalid password")
	}
	ctx.takeover_conn()
	spawn app.serve_analytics(mut ctx)
	return veb.no_result()
}

const html_chunk_size := 1024

fn (mut app App) serve_analytics(mut ctx Context) {
	defer { ctx.conn.close() or { eprintln("error occurred during closing connection: ${err}") } }
	metrics := query_metrics(app.cfg) or {
		ctx.res.set_status(http.Status.internal_server_error)
		ctx.text("unable to load metric data")
		eprintln("faild to query metric data")
		return
	}

	ctx.load_analytics = true
	tab_title := "Analytics - tauraamui's website"
	metric_data := base64.encode_str(json.encode(metrics))

	// the size of the page is so large that the built in auto
	// html rendering methods don't seem to send all of the data
	// the only way to guarantee that we send ALL of the data
	// is to do it ourselves manually
	page := $tmpl("./templates/analytics.html").str()
	page_char_size := page.len
	iter_count := page_char_size / html_chunk_size
	remaining_bytes := (page_char_size - (html_chunk_size * iter_count))
	ctx.conn.write_string("HTTP/1.1 200 OK\r\nContent-type: text/html\r\nContent-length: ${page_char_size}\r\n\r\n") or { eprintln("failed to write HTML header to connection: ${err}"); return }

	for x in 0..iter_count {
		start := x * html_chunk_size
		end := (x + 1) * 1024
		ctx.conn.write(page[start..end].bytes()) or { eprintln("failed to write HTML segment ${start} to ${end} to connection: ${err}"); continue }
	}

	ctx.conn.write(page[page_char_size - remaining_bytes..].bytes()) or { eprintln("failed to write HTML segment to connection: ${err}"); return }
}

@['/theme/:mode'; post]
pub fn (mut app App) set_theme(mut ctx Context, mode string) veb.Result {
	spawn store_metric(app.cfg, Metric{
		event_type: "theme_switch"
		page_url: "${ctx.req.host}${ctx.req.url}"
		browser: ctx.req.header.get(.user_agent) or { "empty" }
		ip: ctx.ip()
		referrer_url: ctx.req.referer()
		country: ctx.req.header.get_custom("CF-IPCountry", http.HeaderQueryConfig{ exact: true }) or { "" }
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

fn request_is_me(app App) bool {
	return false
}

