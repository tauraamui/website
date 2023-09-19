module main

import vweb

const (
	port = 8082
)

struct App {
	vweb.Context
}

fn main() {
	mut app := &App{}
	app.serve_static('/assets/black_wolf_face.png', 'src/assets/black_wolf_face.png')
	app.serve_static('/assets/styles.css', 'src/assets/styles.css')
	// makes all static files available.

	vweb.run(app, port)
}

['/']
pub fn (mut app App) page_home() vweb.Result {
	title := 'vweb app'

	return $vweb.html()
}

['/assets/:name']
pub fn (mut app App) static_files_test(name string) vweb.Result {
	return app.ok(name)
}

