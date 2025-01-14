module read_time

import math

fn count_words(content &string, options &Options) f32 {
	mut count := f32(0)
	for _, word in content.split(" ") {
		count += (word.len/f32(options.get_word_length()))
	}
	return f32(math.round(count))
}

pub fn calculate_read_time(content &string, options &Options) ReadTime {
	word_count := count_words(content, options)
	seconds := f32(word_count / options.get_wpm()) * 60.0

	return ReadTime{ word_count: u64(word_count), seconds: u64(math.round(seconds))}
}

pub struct ReadTime {
pub:
	word_count u64
	seconds u64
}

