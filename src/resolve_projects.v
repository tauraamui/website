module main

struct Project {
	title       string
	description string
	url         string
}

const gh_url := "https://github.com/tauraamui"

fn projects_listing() []Project {
	return [
		Project{ title: "Lilly", description: "A TUI text editor designed as an alternative to Neovim", url: "${gh_url}/lilly" }
		Project{ title: "Bubble Note", description: "Cross computer reminder/todo manager for my shell", url: "${gh_url}/bubble-note" }
	]
}

