module read_time

pub fn text(content &string, options &Options) ReadTime {
	return calculate_read_time(content, options)
}
