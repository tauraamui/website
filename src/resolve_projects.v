module main

struct Project {
	title       string
	description string
	url         string
}

const gh_url := "https://github.com/tauraamui"

fn projects_listing() []Project {
	return [
		Project{
			title: "Lilly"
			description: "A TUI text editor designed as an alternative to Neovim"
			url: "${gh_url}/lilly"
		}
		Project{
			title: "Bubble Note"
			description: "Cross computer reminder/todo manager for my shell"
			url: "${gh_url}/bubble-note"
		}
		Project{
			title: "Blue Panda"
			description: "A NoSQL database based on KVS with an ownership relationship model"
			url: "${gh_url}/bluepanda"
		}
		Project{
			title: "KVS"
			description: "Go library for easy and very fast storing and loading of structs to BadgerDB"
			url: "${gh_url}/kvs"
		}
		Project{
			title: "xerror"
			description: "Go library for tagging error strings with a `KIND` prefix for easier introspection"
			url: "${gh_url}/xerror"
		}
		Project{
			title: "Star Cloud"
			description: "A desktop application/experiement to provide Excelike functionality across an infinite canvas"
			url: "${gh_url}/starcloud"
		}
		Project{
			title: "Website"
			description: "Code for this website"
			url: "${gh_url}/website"
		}
	]
}

