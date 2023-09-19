module main

import vweb
import os

const (
	port = 8082
)

struct App {
	vweb.Context
}

fn main() {
	mut app := &App{}
	app.serve_static('/assets/black_wolf_face.png', 'src/assets/black_wolf_face.png')
	// makes all static files available.
	app.mount_static_folder_at(os.resource_abs_path('.'), '/')

	vweb.run(app, port)
}

['/']
pub fn (mut app App) page_home() vweb.Result {
	title := 'vweb app'

	return $vweb.html()
}
