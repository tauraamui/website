run:
    v run ./src

compile-blogs:
    v run compile_blogs.v

run-watch:
    v -d vweb_livereload watch run .

install-deps:
    npm install -S hackcss-ext
    v install markdown
