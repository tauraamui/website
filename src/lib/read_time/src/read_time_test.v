module read_time_test

import read_time
import os

fn test_default_options() {
	content := os.read_file("test.txt") or { panic("unable to read test.txt: ${err}") }
	read_options := read_time.Options.new()
	time := read_time.text(content, read_options)
	assert time.word_count == 833
	assert time.seconds == 189
}

fn test_technical_options() {
	o := read_time.Options.new()
	mut read_options := o
	read_options.word_length(3)
	read_options.technical_document(true)
	read_options.technical_difficulty(2)
	read_options = read_options.build() or { panic(err) }

	content := os.read_file("test.txt") or { panic("unable to read test.txt: ${err}") }
	time := read_time.text(content, read_options)
	assert time.word_count == 1111
	assert time.seconds == 476
}
