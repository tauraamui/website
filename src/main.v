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
	app.serve_static('/assets/black_wolf_face.png', 'src/assets/imgs/black_wolf_face.png')
	app.serve_static('/assets/dark-grey.css', 'src/assets/css/dark-grey.css')
	app.serve_static('/assets/dark.css', 'src/assets/css/dark.css')
	app.serve_static('/assets/hack.css', 'src/assets/css/hack.css')
	app.serve_static('/assets/solarized-dark.css', 'src/assets/css/solarized-dark.css')
	app.serve_static('/assets/standard.css', 'src/assets/standard.css')
	// makes all static files available.

	vweb.run(app, port)
}

['/']
pub fn (mut app App) home() vweb.Result {
	title := "tauraamui's website"

	return $vweb.html()
}

