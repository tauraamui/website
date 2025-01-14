module read_time

pub struct Options {
mut:
	word_length u32
	wpm u32
	is_technical_document bool
	technical_difficulty u8
	total_words u64
	total_seconds u64
}

pub fn Options.new() Options {
	return Options {
		word_length: 4
		wpm: 265
		is_technical_document: false
		technical_difficulty: 3
		total_words: 0
		total_seconds: 0
	}
}

pub fn (mut options Options) word_length(word_length u32) Options {
	options.word_length = word_length
	return options
}

pub fn (options Options) get_word_length() u32 {
	return options.word_length
}

pub fn (mut options Options) wpm(wpm u32){
	options.wpm = wpm
}

pub fn (options Options) get_wpm() u32 {
	return options.wpm
}

pub fn (mut options Options) technical_document(is_technical_document bool) {
	options.is_technical_document = is_technical_document
}

pub fn (options Options) is_technical_document() bool {
	return options.is_technical_document
}

pub fn (mut options Options) technical_difficulty(technical_difficulty u8) {
	options.technical_difficulty = technical_difficulty
}

pub fn (options Options) calculate_wpm() u32 {
	mut new_wpm := options.wpm
	if options.total_words > 0 && options.total_seconds > 0 {
		new_wpm = u32((options.total_words * 60) / options.total_seconds)
	}
	if options.is_technical_document {
		t_wpm := u32(options.wpm - (65 + (30 * options.technical_difficulty)))
		new_wpm = if t_wpm <= 0 { u32(50) } else { t_wpm }
	}
	if options.total_words <= 0 || options.total_seconds <= 0 {
		if !options.is_technical_document {
			new_wpm = 265
		}
	}
	return u32(new_wpm)
}

pub fn (options Options) get_technical_difficulty() u8 {
	return options.technical_difficulty
}

pub fn (mut options Options) previous_read_time(total_words u64, total_seconds u64) {
	options.total_words = total_words
	options.total_seconds = total_seconds
}

pub fn (options Options) build() !Options {
	if options.technical_difficulty < 1 || options.technical_difficulty > 5 {
		return error("Technical Difficulty must be in the range [1, 5]")
	}
	return Options{
		word_length: options.word_length
		wpm: options.calculate_wpm()
		is_technical_document: options.is_technical_document
		technical_difficulty: options.technical_difficulty
		total_words: options.total_words
		total_seconds: options.total_seconds
	}
}
